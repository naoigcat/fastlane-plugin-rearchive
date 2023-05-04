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
          result = IO.popen("unzip -o -q #{@archive_path.shellescape} #{path.shellescape}", &:read).chomp
          if $?.exitstatus.nonzero?
            FastlaneCore::UI.important(result)
            raise "extract operation failed with exit code #{$?.exitstatus}"
          end
        end
        path
      end

      # Restore extracted files from the temp dir
      def replace(path)
        FastlaneCore::UI.verbose("Replacing #{path}")
        Dir.chdir(@temp_dir) do
          system("zip -q #{@archive_path.shellescape} #{path.shellescape}", exception: true)
        end
      end

      # Delete path inside the ipa
      def delete(path)
        FastlaneCore::UI.verbose("Deleting #{path}")
        Dir.chdir(@temp_dir) do
          system("zip -dq #{@archive_path.shellescape} #{path.shellescape} >/dev/null 2>&1", exception: false)
        end
      end

      def self.extract_app_path(archive_path)
        IO.popen("zipinfo -1 #{archive_path.shellescape} \"Payload/*.app/\" | sed -n '1 p'", &:read).strip.chomp("/")
      end
    end
  end
end
