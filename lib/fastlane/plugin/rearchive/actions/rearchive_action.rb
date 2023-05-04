require "fastlane/action"
require "fastlane_core/configuration/config_item"
require_relative "../helper/archives/ipa_archive"
require_relative "../helper/archives/xc_archive"
require_relative "../helper/file_patcher"
require_relative "../helper/icon_patcher"
require_relative "../helper/plist_patcher"

module Fastlane
  module Actions
    class RearchiveAction < Action
      def self.run(params)
        raise "You must supply an :archive_path" unless params[:archive_path]

        params[:archive_path] = File.expand_path(params[:archive_path])
        raise "Archive path #{params[:archive_path]} does not exist" unless File.exist?(params[:archive_path])

        if File.directory?(params[:archive_path])
          archive = RearchiveHelper::XCArchive.new(params[:archive_path], params[:app_name])
        else
          archive = RearchiveHelper::IPAArchive.new(params[:archive_path], params[:app_name], params[:temp_dir])
        end

        if params[:plist_file]
          params[:plist_file] = archive.app_path(params[:plist_file])
        else
          params[:plist_file] = archive.app_path("Info.plist")
        end

        if params[:plist_values] || params[:plist_commands]
          RearchiveHelper::PlistPatcher.patch(
            archive,
            params[:plist_file],
            params[:plist_values],
            params[:plist_commands]
          )
        end

        if params[:iconset]
          RearchiveHelper::IconPatcher.patch(
            archive,
            params[:iconset],
            !params[:skip_delete_icons]
          )
        end

        if params[:replace_files]
          RearchiveHelper::FilePatcher.replace(
            archive,
            params[:replace_files]
          )
        end

        if params[:remove_files]
          RearchiveHelper::FilePatcher.remove(
            archive,
            params[:remove_files]
          )
        end
      end

      def self.description
        "Reconfigures .plists and icons inside a compiled IPA"
      end

      def self.authors
        ["Richard Szalay"]
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :archive_path,
                                  env_name: "FACELIFT_ARCHIVE_PATH",
                               description: "Path of the IPA or XCARCHIVE being modified",
                                  optional: true,
                                      type: String),

          FastlaneCore::ConfigItem.new(key: :iconset,
                               description: "Path to iconset to swap into the IPA (ignores :plist option)",
                                  optional: true,
                                      type: String),

          FastlaneCore::ConfigItem.new(key: :plist_file,
                                  env_name: "FACELIFT_PLIST_FILE",
                               description: "The name of the plist file to modify, relative to the .app bundle`",
                                  optional: true,
                             default_value: "Info.plist",
                                      type: String),

          FastlaneCore::ConfigItem.new(key: :plist_values,
                               description: "Hash of plist values to set to the plist file",
                                  optional: true,
                                      type: Hash),

          FastlaneCore::ConfigItem.new(key: :plist_commands,
                               description: "Array of PlistBuddy commands to invoke",
                                  optional: true,
                                      type: Array),

          # TODO: :force flag for ignoring command errors and auto-adding plist_values if non-existant

          # Very optional
          FastlaneCore::ConfigItem.new(key: :app_name,
                                  env_name: "FACELIFT_APP_NAME",
                               description: "The name of the .app file (including extension), will be extracted if not supplied",
                                  optional: true,
                                      type: String),

          FastlaneCore::ConfigItem.new(key: :temp_dir,
                                  env_name: "FACELIFT_TEMP_DIR",
                               description: "The temporary directory to work from. One will be created if not supplied",
                                  optional: true,
                                      type: String),

          FastlaneCore::ConfigItem.new(key: :skip_delete_icons,
                                    env_name: "FACELIFT_SKIP_DELETE_ICONS",
                                 description: "When true, the old icon files will not be deleted from the archive",
                                    optional: true,
                               default_value: false,
                                        type: [TrueClass, FalseClass]),

          FastlaneCore::ConfigItem.new(key: :replace_files,
                               description: "Files that should be replaced",
                                  optional: true,
                             default_value: false,
                                      type: Hash),

          FastlaneCore::ConfigItem.new(key: :remove_files,
                               description: "Files that should be removed",
                                  optional: true,
                             default_value: false,
                                      type: Array)
        ]
      end

      def self.is_supported?(platform)
        [:ios].include?(platform)
      end
    end
  end
end
