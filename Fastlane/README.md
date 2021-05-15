fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew install fastlane`

# Available Actions
### travis
```
fastlane travis
```

### match_config
```
fastlane match_config
```
Configure local environment certificates
### beta
```
fastlane beta
```

### release
```
fastlane release
```

### deliverApp
```
fastlane deliverApp
```

### build
```
fastlane build
```

### screenshots
```
fastlane screenshots
```
Generate screenshots and upload to the App Store
### refresh_dsyms
```
fastlane refresh_dsyms
```
Download dSYM files from iTC, upload them to Crashlytics and delete the local dSYM files
### increment_build
```
fastlane increment_build
```

### match_sync
```
fastlane match_sync
```
Sync your certificates and profiles across your team using git

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
