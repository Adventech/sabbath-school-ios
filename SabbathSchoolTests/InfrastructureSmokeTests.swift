import Foundation
import XCTest

final class InfrastructureSmokeTests: XCTestCase {
    func testSyntheticFixtureRoundTripsThroughAtomicDiskWrite() throws {
        let fileManager = FileManager.default
        let testDirectory = fileManager.temporaryDirectory
            .appendingPathComponent("SabbathSchoolTests-\(UUID().uuidString)", isDirectory: true)
        defer { try? fileManager.removeItem(at: testDirectory) }

        try fileManager.createDirectory(
            at: testDirectory,
            withIntermediateDirectories: true
        )

        let fixture = Data("synthetic-local-input-v1".utf8)
        let fixtureURL = testDirectory.appendingPathComponent("input.json")
        try fixture.write(to: fixtureURL, options: .atomic)

        XCTAssertEqual(try Data(contentsOf: fixtureURL), fixture)
    }
}
