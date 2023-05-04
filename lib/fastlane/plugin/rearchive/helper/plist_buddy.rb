require "fastlane_core/ui/ui"

module Fastlane
  module RearchiveHelper
    class PlistBuddy
      def initialize(plist_path)
        @plist_path = plist_path
      end

      def exec(command)
        FastlaneCore::UI.verbose("/usr/libexec/PlistBuddy -c \"#{command}\" \"#{@plist_path}\"")
        result = IO.popen("/usr/libexec/PlistBuddy -c \"#{command}\" \"#{@plist_path}\"", &:read).gsub(/\A\s*"?|"?\s*\z/m, "")

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

        case RUBY_PLATFORM
        when "x86_64-linux", "aarch64-linux-gnu"
          raise "value is not an array (#{RUBY_PLATFORM}): #{result_lines}" unless result_lines.first == "("

          result_lines.drop(1).take(result_lines.size - 2).map do |line|
            line[1..line.size].sub(/,$/, "")
          end
        else
          raise "value is not an array (#{RUBY_PLATFORM}): #{result_lines}" unless result_lines.first == "Array {"

          result_lines.drop(1).take(result_lines.size - 2).map do |line|
            line[4..line.size]
          end
        end
      end

      def parse_dict_keys(entry)
        # This should probably use -x and parse the xml using Nokogiri

        result_lines = entry.lines.map(&:chop)

        case RUBY_PLATFORM
        when "x86_64-linux", "aarch64-linux-gnu"
          raise "value is not an dict (#{RUBY_PLATFORM}): #{result_lines}" unless result_lines.first == "{"

          result_lines.map do |line|
            line.match(/(?<=^\t)[^\s}]+/)
          end
        else
          raise "value is not an dict (#{RUBY_PLATFORM}): #{result_lines}" unless result_lines.first == "Dict {"

          result_lines.map do |line|
            line.match(/(?<=^\s{4})[^\s}]+/)
          end
        end.compact.map(&:to_s)
      end
    end
  end
end
