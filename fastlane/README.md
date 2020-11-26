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
## iOS
### ios appstore_testflight
```
fastlane ios appstore_testflight
```

### ios github_test
```
fastlane ios github_test
```

### ios screenshot
```
fastlane ios screenshot
```
Take screenshots of the app
### ios test
```
fastlane ios test
```
Deploy a test to testflight
### ios distributeFirebase
```
fastlane ios distributeFirebase
```
Distribute version to Firebase
### ios error
```
fastlane ios error
```
Check for errors
### ios uploadDSYM
```
fastlane ios uploadDSYM
```
Upload dSYM to Crashlytics
### ios documentation
```
fastlane ios documentation
```
Create documentation
### ios deploy
```
fastlane ios deploy
```
Deploy app to appstore (With screenshots, only run on mayor releases)
### ios fastDeploy
```
fastlane ios fastDeploy
```
Fast deploy (No screenshots)
### ios fastDeployTV
```
fastlane ios fastDeployTV
```
Fast deploy (No screenshots)
### ios deployTV
```
fastlane ios deployTV
```
Deploy (With Screenshots)

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
