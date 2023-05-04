require "fastlane/action"
require "fastlane_core/configuration/config_item"
require_relative "../helper/archives/ipa_archive"
require_relative "../helper/archives/xc_archive"
require_relative "../helper/plist_buddy"

module Fastlane
  module Actions
    class PlistValueAction < Action
      def self.run(params)
        archive_path = File.expand_path(params[:archive_path])
        raise "Archive path #{archive_path} does not exist" unless File.exist?(archive_path)

        if File.directory?(archive_path)
          archive = RearchiveHelper::XCArchive.new(archive_path)
        else
          archive = RearchiveHelper::IPAArchive.new(archive_path)
        end
        if params[:plist_path]
          plist_path = archive.app_path(params[:plist_path])
        else
          plist_path = archive.app_path("Info.plist")
        end
        FastlaneCore::UI.message("Patching Plist: #{plist_path}")
        archive.extract(plist_path)
        plist_buddy = RearchiveHelper::PlistBuddy.new(archive.local_path(plist_path))
        params[:plist_values].each do |key, value|
          plist_buddy.exec("Set #{key} #{value}")
        end
        archive.replace(plist_path)
      end

      def self.description
        "Overwrite values of .plists inside .ipa/.xcarchive"
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

          FastlaneCore::ConfigItem.new(key: :plist_path,
                               description: "The name of the .plist file to modify, relative to the .app bundle",
                                  optional: true,
                             default_value: "Info.plist",
                                      type: String),

          FastlaneCore::ConfigItem.new(key: :plist_values,
                               description: "Hash of plist values to set to the plist file",
                                  optional: false,
                                      type: Hash)
        ]
      end

      def self.is_supported?(platform)
        [:ios].include?(platform)
      end
    end
  end
end
