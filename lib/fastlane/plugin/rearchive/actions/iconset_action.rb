require "fastlane/action"
require "fastlane_core/configuration/config_item"
require_relative "../helper/archives/ipa_archive"
require_relative "../helper/archives/xc_archive"

module Fastlane
  module Actions
    class IconsetAction < Action
      def self.run(params) # rubocop:disable Metrics/PerceivedComplexity
        archive_path = File.expand_path(params[:archive_path])
        raise "Archive path #{archive_path} does not exist" unless File.exist?(archive_path)

        iconset_path = File.expand_path(params[:iconset_path])
        iconset_manifest_path = File.expand_path("#{iconset_path}/Contents.json")
        raise ".iconset manifest #{iconset_manifest_path} does not exist" unless File.exist?(iconset_manifest_path)

        if File.directory?(archive_path)
          archive = RearchiveHelper::XCArchive.new(archive_path)
        else
          archive = RearchiveHelper::IPAArchive.new(archive_path)
        end
        FastlaneCore::UI.message("Patching icons from: #{iconset_path}")
        plist_path = archive.extract(archive.app_path("Info.plist"))
        plist_buddy = RearchiveHelper::PlistBuddy.new(archive.local_path(plist_path))
        plist_buddy.parse_dict_keys(plist_buddy.exec("Print")).filter_map do |key|
          key.match(/^CFBundleIcons(~.+)?$/)
        end.map do |(key, idiom_suffix)|
          [":#{key}:CFBundlePrimaryIcon:CFBundleIconFiles", idiom_suffix]
        end.each do |(icon_files_key, idiom_suffix)|
          plist_buddy.parse_scalar_array(plist_buddy.exec("Print #{icon_files_key}")).map do |name|
            %W[#{name}#{idiom_suffix}* #{name}@*x#{idiom_suffix}*].each do |path|
              archive.delete(archive.app_path(path))
            end
          end
          plist_buddy.exec("Delete #{icon_files_key}")
        rescue RuntimeError => _e
          next
        end
        JSON.parse(File.read(iconset_manifest_path))["images"].select do |image|
          image["filename"]
        end.map do |entry|
          scale_suffix = entry["scale"] == "1x" ? "" : "@#{entry["scale"]}"
          idiom_suffix = entry["idiom"] == "iphone" ? "" : "~#{entry["idiom"]}"
          file_extension = File.extname(entry["filename"])
          {
            source: "#{iconset_path}/#{entry["filename"]}",
            name: "#{File.basename(iconset_path, ".appiconset")}#{entry["size"]}",
            idiom: entry["idiom"],
            target: "#{File.basename(iconset_path, ".appiconset")}#{entry["size"]}#{scale_suffix}#{idiom_suffix}#{file_extension}"
          }
        end.group_by do |icon|
          icon[:idiom]
        end.each do |idiom, icons|
          idiom_suffix = idiom == "iphone" ? "" : "~#{idiom}"
          icons_plist_key = ":CFBundleIcons#{idiom_suffix}:CFBundlePrimaryIcon:CFBundleIconFiles"
          plist_buddy.exec("Add #{icons_plist_key} array")
          icons.each do |i|
            relative_path = archive.app_path((i[:target]).to_s)
            local_path = archive.local_path(relative_path)
            system("cp #{i[:source].shellescape} #{local_path.shellescape}", exception: true)
            archive.replace(relative_path)
          end
          icons.map { |i| i[:name] }.uniq.each_with_index do |key, index|
            plist_buddy.exec("Add #{icons_plist_key}:#{index} string #{key}")
          end
        end
        Dir.mktmpdir do |dir|
          Dir.chdir(dir) do
            IO.popen(%W[
              #{IO.popen("xcode-select -p", &:read).chomp}/usr/bin/actool
              --output-format=human-readable-text
              --notices
              --warnings
              --output-partial-info-plist=assetcatalog_generated_info.plist
              --app-icon=#{File.basename(iconset_path, ".appiconset")}
              --compress-pngs
              --enable-on-demand-resources=YES
              --sticker-pack-identifier-prefix=#{plist_buddy.exec("Print CFBundleIdentifier")}.sticker-pack.
              --development-region=English
              --target-device=iphone
              --target-device=ipad
              --minimum-deployment-target=#{plist_buddy.exec("Print MinimumOSVersion")}
              --platform=iphoneos
              --product-type=com.apple.product-type.application
              --compile
              .
              #{File.dirname(iconset_path)}
            ].map(&:shellescape).join(" "), "r") do |io|
              FastlaneCore::UI.verbose(io.read) if params[:verbose]
            end
            generated_plist_buddy = RearchiveHelper::PlistBuddy.new("assetcatalog_generated_info.plist")
            plist_buddy.parse_dict_keys(generated_plist_buddy.exec("Print")).filter_map do |key|
              key.match(/^CFBundleIcons(~.+)?$/)
            end.each do |key|
              plist_buddy.exec("Delete #{key}")
            end
            plist_buddy.exec("Merge assetcatalog_generated_info.plist")
            archive.replace(plist_path)
            relative_path = archive.app_path("Assets.car")
            local_path = archive.local_path(relative_path)
            system("mkdir -p #{File.dirname(local_path).shellescape}", exception: true)
            system("mv Assets.car #{local_path.shellescape}", exception: true)
            archive.replace(relative_path)
          end
        end
      end

      def self.description
        "Replace icons inside .ipa/.xcarchive"
      end

      def self.authors
        ["naoigcat"]
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :archive_path,
                               description: "The path of the .ipa or .xcarchive to be modified",
                                  optional: false,
                                      type: String),

          FastlaneCore::ConfigItem.new(key: :iconset_path,
                               description: "The path to iconset to swap into the .ipa or .xcarchive",
                                  optional: false,
                                      type: String),

          FastlaneCore::ConfigItem.new(key: :verbose,
                               description: "Display the output of commands",
                                  optional: true,
                             default_value: false,
                                      type: [TrueClass, FalseClass])
        ]
      end

      def self.is_supported?(platform)
        [:ios].include?(platform)
      end
    end
  end
end
