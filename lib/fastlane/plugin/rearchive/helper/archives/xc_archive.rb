require "fastlane_core/ui/ui"
require_relative "../plist_buddy"

module Fastlane
  module RearchiveHelper
    class XCArchive
      def initialize(archive_path)
        @archive_path = archive_path
        @app_path = "Products/#{self.class.extract_app_path(archive_path)}"
      end

      # Returns the full path to the given file that can be modified
      def local_path(path)
        "#{@archive_path}/#{path}"
      end

      # Returns an archive-relative path to the given application file
      def app_path(path)
        if path.start_with?("/")
          path.sub(%r{^/}, "")
        else
          "#{@app_path}/#{path}"
        end
      end

      # Extract files to the temp dir
      def extract(path)
        path
      end

      # Restore extracted files from the temp dir
      def replace(path)
      end

      # Delete path inside the ipa
      def delete(path)
        FastlaneCore::UI.verbose("Deleting #{path}")

        Dir.glob(local_path(path)).each { |f| File.delete(f) }
      end

      def self.extract_app_path(archive_path)
        plist_buddy = PlistBuddy.new("#{archive_path}/Info.plist")
        plist_buddy.exec("Print :ApplicationProperties:ApplicationPath")
      end
    end
  end
end
