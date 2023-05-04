require "fastlane_core/ui/ui"

module Fastlane
  module RearchiveHelper
    class PlistBuddy
      def initialize(plist_path)
        @plist_path = plist_path
      end

      def exec(command)
        FastlaneCore::UI.verbose("/usr/libexec/PlistBuddy -c \"#{command}\" \"#{@plist_path}\"")
        result = `/usr/libexec/PlistBuddy -c "#{command}" "#{@plist_path}"`

        if $?.exitstatus.nonzero?
          FastlaneCore::UI.important("PlistBuddy command failed: #{result}")
          raise "PlistBuddy command failed failed with exit code #{$?.exitstatus} - #{result}"
        end

        return result
      end

      def parse_scalar_array(result)
        # This should probably use -x and parse the xml using Nokogiri

        return [] unless result =~ /\S/

        result_lines = result.lines.map(&:chop)

        raise "value is not an array" unless result_lines.first == "Array {"

        array_values = result_lines.drop(1).take(result_lines.size - 2)

        return array_values.map { |line| line[4..line.size] }
      end

      def parse_dict_keys(entry)
        # This should probably use -x and parse the xml using Nokogiri

        result_lines = entry.lines.map(&:chop)

        raise "value is not an dict" unless result_lines.first == "Dict {"

        keys = result_lines
               .map { |l| l.match(/^\s{4}([^\s}]+)/) }
               .select { |l| l }
               .map { |l| l[1] }

        return keys
      end
    end
  end
end
