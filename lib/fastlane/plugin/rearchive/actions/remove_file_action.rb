require "fastlane/action"
require "fastlane_core/configuration/config_item"
require_relative "../helper/archives/ipa_archive"
require_relative "../helper/archives/xc_archive"

module Fastlane
  module Actions
    class RemoveFileAction < Action
      def self.run(params)
        archive_path = File.expand_path(params[:archive_path])
        raise "Archive path #{archive_path} does not exist" unless File.exist?(archive_path)

        if File.directory?(archive_path)
          archive = RearchiveHelper::XCArchive.new(archive_path)
        else
          archive = RearchiveHelper::IPAArchive.new(archive_path)
        end
        params[:files].each do |file|
          FastlaneCore::UI.message("Deleting #{file}")
          relative_path = archive.app_path(file)
          archive.delete(relative_path)
        end
      end

      def self.description
        "Remove files inside .ipa/.xcarchive"
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

          FastlaneCore::ConfigItem.new(key: :files,
                               description: "Files that should be removed",
                                  optional: false,
                                      type: Array)
        ]
      end

      def self.is_supported?(platform)
        [:ios].include?(platform)
      end
    end
  end
end
