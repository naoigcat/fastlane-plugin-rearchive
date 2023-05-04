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

The `resign` is required after executing the following actions.

Modify the application Info.plist.

```ruby
plist_value(
  archive_path: "example/Example.xcarchive",
  plist_values: {
    ":CustomApplicationKey" => "Replaced!"
  }
)
```

Execute commands for the application Info.plist.

```ruby
plist_command(
  archive_path: "example/Example.xcarchive",
  plist_commands: [
    "Delete :DebugApplicationKey"
  ]
)
```

Replace icons of the application.

```ruby
iconset(
  archive_path: "example/Example.xcarchive",
  iconset_path: "example/Blue.appiconset"
)
```

Modify a different application plist

```ruby
plist_value(
  archive_path: "example/Example.xcarchive",
  plist_path: "GoogleService-Info.plist",
  plist_values: {
    ":TRACKING_ID" => "UA-22222222-22"
  }
)
```

Prefixing with a / allows you to target any plist in the archive.

```ruby
plist_value(
  archive_path: "example/Example.xcarchive",
  plist_path: "/Info.plist",
  plist_values: {
    ":TRACKING_ID" => "UA-22222222-22"
  }
)
```

Replace a file with a local one (files only - asset catalog items are not supported)

```ruby
replace_file(
  archive_path: "example/Example.ipa",
  files: {
    "GoogleService-Info.plist" => "example/New-GoogleService-Info.plist"
  }
)
```

Remove a file (files only - asset catalog items are not supported)

```ruby
remove_file(
  archive_path: "example/Example.ipa",
  files: [
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
