var ARTIFACT_NAME       = 'sabbath-school-reader-latest.zip',
    PROD_PROJECT_ID     = 'blistering-inferno-8720',
    STAGE_PROJECT_ID    = 'sabbath-school-stage',
    PROD_KEY_FILENAME   = 'deploy-creds.json',
    STAGE_KEY_FILENAME  = 'deploy-creds-stage.json',
    PROD_BUCKET         = 'blistering-inferno-8720.appspot.com',
    STAGE_BUCKET        = 'sabbath-school-stage.appspot.com';

var fs = require('fs'),
    archiver = require('archiver'),
    gstorage = require('@google-cloud/storage');

var argv = require('optimist')
    .usage("Build script\n" +
        "Usage: $0 -b [string]")
    .alias({"b": "branch"})
    .describe({
        "b": "branch"
    })
    .demand(["b"])
    .argv;

var branch = argv.b;

if (branch.toLowerCase() == "master"){
    projectId = PROD_PROJECT_ID;
    keyFilename = PROD_KEY_FILENAME;
    bucketName = PROD_BUCKET;
} else if (branch.toLowerCase() == "stage") {
    projectId = STAGE_PROJECT_ID;
    keyFilename = STAGE_KEY_FILENAME;
    bucketName = STAGE_BUCKET;
} else {
    return;
}

storage = gstorage({
    projectId: projectId,
    keyFilename: keyFilename
});
bucket = storage.bucket(bucketName);

// create a file to stream archive data to.
var output = fs.createWriteStream(__dirname + '/' + ARTIFACT_NAME);
var archive = archiver('zip', {
    zlib: { level: 9 } // Sets the compression level.
});

// listen for all archive data to be written
output.on('close', function() {
    console.log(archive.pointer() + ' total bytes');
    console.log('archiver has been finalized and heethe output file descriptor has closed.');
    bucket.upload("./"+ARTIFACT_NAME, function(err, file){
        if (!err){
            console.log(ARTIFACT_NAME + ' (' + archive.pointer() + ' bytes) uploaded');
        } else {
            console.log(err);
        }
    });
});

// good practice to catch this error explicitly
archive.on('error', function(err) {
    throw err;
});

// pipe archive data to the file
archive.pipe(output);

// Appending reader related assets
var index = __dirname + '/index.html';
archive.append(fs.createReadStream(index), { name: 'index.html' });
archive.directory('css/');
archive.directory('fonts/');
archive.directory('js/');

// finalize the archive (ie we are done appending files but streams have to finish yet)
archive.finalize();