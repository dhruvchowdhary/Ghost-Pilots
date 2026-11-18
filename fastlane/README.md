fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios check

```sh
[bundle exec] fastlane ios check
```

Check App Store Connect credentials and print the latest build number

### ios build

```sh
[bundle exec] fastlane ios build
```

Install pods and build a signed App Store archive

### ios beta

```sh
[bundle exec] fastlane ios beta
```

Build and upload to TestFlight

### ios release

```sh
[bundle exec] fastlane ios release
```

Build, upload, and submit the current version for App Review

### ios resubmit

```sh
[bundle exec] fastlane ios resubmit
```

Push metadata and age rating, then resubmit a rejected version with its current build

### ios privacy

```sh
[bundle exec] fastlane ios privacy
```

Publish the App Privacy answers in app_privacy_details.json, added to what's there

Signs in with your Apple ID (FASTLANE_USER, or it asks): Apple doesn't let

an API key change App Privacy. Nothing already there is removed, the change

is shown before anything is sent, and it asks before publishing (yes:true skips that).

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
