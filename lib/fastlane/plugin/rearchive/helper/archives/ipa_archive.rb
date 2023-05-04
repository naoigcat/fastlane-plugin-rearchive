require "fastlane_core/ui/ui"

module Fastlane
  module RearchiveHelper
    class IPAArchive
      def initialize(archive_path)
        @archive_path = archive_path
        @temp_dir = Dir.mktmpdir
        FastlaneCore::UI.verbose("Working in temp dir: #{@temp_dir}")
        @app_path = self.class.extract_app_path(@archive_path)
      end

      # Returns the full path to the given file that can be modified
      def local_path(path)
        "#{@temp_dir}/#{path}"
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
        FastlaneCore::UI.verbose("Extracting #{path}")

        Dir.chdir(@temp_dir) do
          result = `unzip -o -q #{@archive_path.shellescape} #{path.shellescape}`

          if $?.exitstatus.nonzero?
            FastlaneCore::UI.important(result)
            raise "extract operation failed with exit code #{$?.exitstatus}"
          end
        end
      end

      # Restore extracted files from the temp dir
      def replace(path)
        FastlaneCore::UI.verbose("Replacing #{path}")
        Dir.chdir(@temp_dir) do
          `zip -q #{@archive_path.shellescape} #{path.shellescape}`
        end
      end

      # Delete path inside the ipa
      def delete(path)
        FastlaneCore::UI.verbose("Deleting #{path}")
        Dir.chdir(@temp_dir) do
          `zip -dq #{@archive_path.shellescape} #{path.shellescape}`
        end
      end

      def self.extract_app_path(archive_path)
        `zipinfo -1 #{archive_path.shellescape} "Payload/*.app/" | sed -n '1 p'`.strip.chomp("/")
      end
    end
  end
end
