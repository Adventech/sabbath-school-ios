const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const test = require("node:test");
const { execFileSync } = require("node:child_process");

const repositoryRoot = path.resolve(__dirname, "..");
const projectPath = path.join(
  repositoryRoot,
  "Sabbath School.xcodeproj",
  "project.pbxproj",
);
const schemesPath = path.join(
  repositoryRoot,
  "Sabbath School.xcodeproj",
  "xcshareddata",
  "xcschemes",
);
const project = fs.readFileSync(projectPath, "utf8");
const trackedFiles = new Set(
  execFileSync("git", ["ls-files"], {
    cwd: repositoryRoot,
    encoding: "utf8",
  })
    .split(/\r?\n/u)
    .filter(Boolean),
);

function projectObjects(isa) {
  const objects = new Map();
  const multilineExpression = new RegExp(
    `^\\t\\t([A-F0-9]{24}) \\/\\* ([^*]+) \\*\\/ = \\{\\r?\\n` +
      `\\t\\t\\tisa = ${isa};([\\s\\S]*?)^\\t\\t\\};`,
    "gmu",
  );

  for (const match of project.matchAll(multilineExpression)) {
    objects.set(match[1], { label: match[2].trim(), body: match[3] });
  }

  const singleLineExpression = new RegExp(
    `^\\t\\t([A-F0-9]{24}) \\/\\* ([^*]+) \\*\\/ = \\{isa = ${isa};([^\\r\\n]*)\\};$`,
    "gmu",
  );
  for (const match of project.matchAll(singleLineExpression)) {
    objects.set(match[1], { label: match[2].trim(), body: match[3] });
  }

  return objects;
}

function value(body, key) {
  const match = body.match(
    new RegExp(`(?:^|[;\\r\\n])\\s*${key} = ("[^"]*"|[^;]+);`, "u"),
  );
  return match?.[1].replace(/^"|"$/gu, "");
}

function list(body, key) {
  const match = body.match(
    new RegExp(`^\\t\\t\\t${key} = \\(\\r?\\n([\\s\\S]*?)^\\t\\t\\t\\);`, "mu"),
  );
  return [...(match?.[1] ?? "").matchAll(/([A-F0-9]{24}) \/\*/gu)].map(
    (entry) => entry[1],
  );
}

function schemeTestTargets() {
  const targets = [];
  const plans = [];
  const schemeFiles = [...trackedFiles].filter((file) =>
    file.startsWith("Sabbath School.xcodeproj/xcshareddata/xcschemes/") &&
    file.endsWith(".xcscheme"),
  );

  for (const schemeFile of schemeFiles) {
    const scheme = fs.readFileSync(path.join(repositoryRoot, schemeFile), "utf8");
    for (const testable of scheme.matchAll(
      /<TestableReference\s+skipped = "NO">([\s\S]*?)<\/TestableReference>/gu,
    )) {
      const identifier = testable[1].match(/BlueprintIdentifier = "([A-F0-9]{24})"/u)?.[1];
      targets.push({ identifier, source: schemeFile });
    }

    for (const planReference of scheme.matchAll(
      /<TestPlanReference[\s\S]*?reference = "container:([^"]+)"[\s\S]*?<\/TestPlanReference>/gu,
    )) {
      const planFile = planReference[1];
      plans.push({ planFile, source: schemeFile });
      const plan = JSON.parse(fs.readFileSync(path.join(repositoryRoot, planFile), "utf8"));
      for (const testTarget of plan.testTargets ?? []) {
        targets.push({
          identifier: testTarget.target?.identifier,
          source: planFile,
        });
      }
    }
  }

  return { plans, targets };
}

function trackedSourceFor(fileReference) {
  const fileName = value(fileReference.body, "path") ?? fileReference.label;
  return [...trackedFiles].find(
    (file) => path.posix.basename(file) === fileName && file.endsWith(".swift"),
  );
}

test("every enabled shared-scheme test reference resolves to a native test target", () => {
  const nativeTargets = projectObjects("PBXNativeTarget");
  const { targets } = schemeTestTargets();

  assert.ok(targets.length > 0, "the shared schemes must expose at least one test target");
  for (const target of targets) {
    assert.match(target.identifier ?? "", /^[A-F0-9]{24}$/u, `missing target identifier in ${target.source}`);
    const nativeTarget = nativeTargets.get(target.identifier);
    assert.ok(nativeTarget, `${target.source} references missing native target ${target.identifier}`);
    assert.match(
      value(nativeTarget.body, "productType") ?? "",
      /^com\.apple\.product-type\.bundle\.(unit-test|ui-testing)$/u,
      `${nativeTarget.label} is not a native test bundle`,
    );
  }
});

test("the shared native test target contains a tracked, discoverable XCTest", () => {
  const nativeTargets = projectObjects("PBXNativeTarget");
  const sourcePhases = projectObjects("PBXSourcesBuildPhase");
  const buildFiles = projectObjects("PBXBuildFile");
  const fileReferences = projectObjects("PBXFileReference");
  const { targets } = schemeTestTargets();

  const discoveredTests = [];
  for (const target of targets) {
    const nativeTarget = nativeTargets.get(target.identifier);
    assert.ok(nativeTarget, `${target.source} references a deleted target`);
    const sourceIds = list(nativeTarget.body, "buildPhases")
      .map((identifier) => sourcePhases.get(identifier))
      .filter(Boolean)
      .flatMap((phase) => list(phase.body, "files"));

    for (const buildFileId of sourceIds) {
      const buildFile = buildFiles.get(buildFileId);
      const fileReferenceId = buildFile?.body.match(/fileRef = ([A-F0-9]{24})/u)?.[1];
      const fileReference = fileReferences.get(fileReferenceId);
      const trackedSource = fileReference && trackedSourceFor(fileReference);
      if (!trackedSource) continue;
      const source = fs.readFileSync(path.join(repositoryRoot, trackedSource), "utf8");
      if (/\bXCTestCase\b/u.test(source) && /\bfunc\s+test[A-Za-z0-9_]*\s*\(/u.test(source)) {
        discoveredTests.push(trackedSource);
      }
    }
  }

  assert.ok(discoveredTests.length > 0, "the native test target would discover zero XCTest methods");
});

test("shared schemes use a tracked test plan and contain no deleted SnapshotUITests references", () => {
  const { plans } = schemeTestTargets();

  assert.ok(plans.length > 0, "a shared .xctestplan must define the native test lane");
  for (const plan of plans) {
    assert.ok(trackedFiles.has(plan.planFile), `${plan.source} references untracked ${plan.planFile}`);
  }
  assert.equal(
    [...trackedFiles].some((file) => file.includes("SnapshotUITests")),
    false,
    "the deleted SnapshotUITests scheme/source must not remain advertised",
  );
  assert.doesNotMatch(project, /SnapshotUITests/u);
});
