require "fastlane/action"
require "fastlane_core/configuration/config_item"
require_relative "../helper/archives/ipa_archive"
require_relative "../helper/archives/xc_archive"

module Fastlane
  module Actions
    class ReplaceFileAction < Action
      def self.run(params)
        archive_path = File.expand_path(params[:archive_path])
        raise "Archive path #{archive_path} does not exist" unless File.exist?(archive_path)

        if File.directory?(archive_path)
          archive = RearchiveHelper::XCArchive.new(archive_path)
        else
          archive = RearchiveHelper::IPAArchive.new(archive_path)
        end
        params[:files].each do |old_file, new_file|
          FastlaneCore::UI.message("Replacing #{old_file}")
          relative_path = archive.app_path(old_file)
          local_path = archive.local_path(relative_path)
          `mkdir -p #{File.dirname(local_path).shellescape}`
          `cp #{new_file.shellescape} #{local_path.shellescape}`
          archive.replace(relative_path)
        end
      end

      def self.description
        "Replace files inside .ipa/.xcarchive"
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

          FastlaneCore::ConfigItem.new(key: :replace_files,
                               description: "Files that should be replaced",
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
