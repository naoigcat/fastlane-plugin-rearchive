# rearchive plugin

[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-rearchive)

## Getting Started

This project is a [_fastlane_](https://github.com/fastlane/fastlane) plugin. To get started with `fastlane-plugin-rearchive`, add it to your project by running:

```bash
fastlane add_plugin rearchive
```

## About rearchive

Modify files inside ipa/xcarchive for publishing multiple configurations without rearchiving.

## Example

Check out the [example `Fastfile`](fastlane/Fastfile) to see how to use this plugin. Try it by cloning the repo, running `fastlane install_plugins` and `bundle exec fastlane test`.

## Usage

```ruby
# Modify the application Info.plist
rearchive(
  archive_path: "example/Example.xcarchive",

  iconset: "example/Blue.appiconset",

  # Set a hash of plist values
  plist_values: {
    ":CustomApplicationKey" => "Replaced!"
  },

  # Run a list of PlistBuddy commands
  plist_commands: [
    "Delete :DebugApplicationKey"
  ]
)

# Modify a different application plist
rearchive(
  archive_path: "example/Example.xcarchive",

  # Using a relative path indicates a plist file inside the .app
  plist_file: "GoogleService-Info.plist",

  plist_values: {
    ":TRACKING_ID" => "UA-22222222-22"
  }
)

# Modify the xcarchive manifest plist
rearchive(
  archive_path: "example/Example.xcarchive",

  # Prefixing with a / allows you to target any plist in the archive
  plist_file: "/Info.plist",

  plist_values: {
    ":TRACKING_ID" => "UA-22222222-22"
  }
)

# Modify Info.plist in an IPA
rearchive(
  archive_path: "example/Example.ipa",

  iconset: "example/Blue.appiconset",

  # Set a hash of plist values
  plist_values: {
    ":CustomApplicationKey" => "Replaced!"
  },

  # Run a list of PlistBuddy commands
  plist_commands: [
    "Delete :DebugApplicationKey"
  ]
)

# Replace a file with a local one (files only - asset catalog items are not supported)
rearchive(
  archive_path: "example/Example.ipa",

  replace_files: {
    "GoogleService-Info.plist" => "example/New-GoogleService-Info.plist"
  }
)

# Remove a file (files only - asset catalog items are not supported)
rearchive(
  archive_path: "example/Example.ipa",

  remove_files: [
    "GoogleService-Info.plist"
  ]
)
```

## Run tests for this plugin

To run both the tests, and code style validation, run

```sh
rake
```

To automatically fix many of the styling issues, use

```sh
rubocop -a
```

## Issues and Feedback

For any other issues and feedback about this plugin, please submit it to this repository.

## Troubleshooting

If you have trouble using plugins, check out the [Plugins Troubleshooting](https://docs.fastlane.tools/plugins/plugins-troubleshooting/) guide.

## Using _fastlane_ Plugins

For more information about how the `fastlane` plugin system works, check out the [Plugins documentation](https://docs.fastlane.tools/plugins/create-plugin/).

## About _fastlane_

_fastlane_ is the easiest way to automate beta deployments and releases for your iOS and Android apps. To learn more, check out [fastlane.tools](https://fastlane.tools).
