fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

## Choose your installation method:

| Method                     | OS support                              | Description                                                                                                                           |
|----------------------------|-----------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------|
| [Homebrew](http://brew.sh) | macOS                                   | `brew cask install fastlane`                                                                                                          |
| Installer Script           | macOS                                   | [Download the zip file](https://download.fastlane.tools). Then double click on the `install` script (or run it in a terminal window). |
| RubyGems                   | macOS or Linux with Ruby 2.0.0 or above | `sudo gem install fastlane -NV`                                                                                                       |

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


----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
