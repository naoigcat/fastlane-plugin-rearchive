require "fastlane_core/ui/ui"

module Fastlane
  module RearchiveHelper
    class FilePatcher
      def self.replace(archive, file_values)
        file_values.each do |old_file, new_file|
          FastlaneCore::UI.message("Replacing #{old_file}")

          relative_path = archive.app_path(old_file)
          local_path = archive.local_path(relative_path)

          `mkdir -p #{File.dirname(local_path).shellescape}`
          `cp #{new_file.shellescape} #{local_path.shellescape}`
          archive.replace(relative_path)
        end
      end

      def self.remove(archive, file_values)
        file_values.each do |file_to_delete|
          FastlaneCore::UI.message("Deleting #{file_to_delete}")

          relative_path = archive.app_path(file_to_delete)

          archive.delete(relative_path)
        end
      end
    end
  end
end
