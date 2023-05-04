describe Fastlane::RearchiveHelper::IPAArchive do
  describe Fastlane::Actions::PlistValueAction do
    describe "#run" do
      before do
        @tmp_dir = Dir.mktmpdir
        @tmp_dir = File.join(@tmp_dir, "dir with spaces")
        Dir.mkdir(@tmp_dir)
        @ipa_file = File.join(@tmp_dir, "Example.ipa")
        Dir.chdir("example/layout/") do
          `zip #{@ipa_file.shellescape} -r *`
        end
      end

      after do
        FileUtils.rm_rf(@tmp_dir)
      end

      context "providing plist values" do
        it "defaults to info.plist" do
          Fastlane::Actions::PlistValueAction.run(
            archive_path: @ipa_file,
            plist_values: {
              ":CustomApplicationKey" => "Replaced"
            }
          )
          result = invoke_plistbuddy("Print :CustomApplicationKey", "Payload/Example.app/Info.plist")
          expect(result).to eql("Replaced")
        end

        it "can use a different plist" do
          Fastlane::Actions::PlistValueAction.run(
            archive_path: @ipa_file,
            plist_path: "GoogleService-Info.plist",
            plist_values: {
              ":TRACKING_ID" => "UA-22222222-22"
            }
          )
          result = invoke_plistbuddy("Print :TRACKING_ID", "Payload/Example.app/GoogleService-Info.plist")
          expect(result).to eql("UA-22222222-22")
        end

        it "can use a plist outside the app_dir" do
          Fastlane::Actions::PlistValueAction.run(
            archive_path: @ipa_file,
            plist_path: "/Info.plist",
            plist_values: {
              ":ApplicationProperties:CFBundleIdentifier" => "com.richardszalay.somethingelse"
            }
          )
          result = invoke_plistbuddy("Print :ApplicationProperties:CFBundleIdentifier", "Info.plist")
          expect(result).to eql("com.richardszalay.somethingelse")
        end
      end
    end
  end

  describe Fastlane::Actions::PlistCommandAction do
    describe "#run" do
      before do
        @tmp_dir = Dir.mktmpdir
        @tmp_dir = File.join(@tmp_dir, "dir with spaces")
        Dir.mkdir(@tmp_dir)
        @ipa_file = File.join(@tmp_dir, "Example.ipa")
        Dir.chdir("example/layout/") do
          `zip #{@ipa_file.shellescape} -r *`
        end
      end

      after do
        FileUtils.rm_rf(@tmp_dir)
      end
      context "providing plist commands" do
        it "defaults to info.plist" do
          Fastlane::Actions::PlistCommandAction.run(
            archive_path: @ipa_file,
            plist_commands: [
              "Add :NewKey string NewValue"
            ]
          )
          result = invoke_plistbuddy("Print :NewKey", "Payload/Example.app/Info.plist")
          expect(result).to eql("NewValue")
        end

        it "can use a different plist" do
          Fastlane::Actions::PlistCommandAction.run(
            archive_path: @ipa_file,
            plist_path: "GoogleService-Info.plist",
            plist_commands: [
              "Add :NewKey string NewValue"
            ]
          )
          result = invoke_plistbuddy("Print :NewKey", "Payload/Example.app/GoogleService-Info.plist")
          expect(result).to eql("NewValue")
        end
      end
    end
  end

  describe Fastlane::Actions::IconsetAction do
    describe "#run" do
      before do
        @tmp_dir = Dir.mktmpdir
        @tmp_dir = File.join(@tmp_dir, "dir with spaces")
        Dir.mkdir(@tmp_dir)
        @ipa_file = File.join(@tmp_dir, "Example.ipa")
        Dir.chdir("example/layout/") do
          `zip #{@ipa_file.shellescape} -r *`
        end
      end

      after do
        FileUtils.rm_rf(@tmp_dir)
      end

      context "providing an iconset" do
        it "deletes old icon files" do
          Fastlane::Actions::IconsetAction.run(
            archive_path: @ipa_file,
            iconset_path: "example/Blue.appiconset"
          )
          result = archive_contains("Payload/Example.app/Orange29x29@2x.png")
          expect(result).to be false
        end

        it "adds new icon files" do
          Fastlane::Actions::IconsetAction.run(
            archive_path: @ipa_file,
            iconset_path: "example/Blue.appiconset"
          )
          result = archive_contains("Payload/Example.app/Blue29x29@2x.png")
          expect(result).to be true
        end

        it "excludes images without filenames" do
          Fastlane::Actions::IconsetAction.run(
            archive_path: @ipa_file,
            iconset_path: "example/Blue.appiconset"
          )
          result = archive_contains("Payload/Example.app/Blue60x60@3x.png")
          expect(result).to be false
        end

        it "modifies the Info.plist" do
          Fastlane::Actions::IconsetAction.run(
            archive_path: @ipa_file,
            iconset_path: "example/Blue.appiconset"
          )
          result = [
            invoke_plistbuddy("Print :CFBundleIcons:CFBundlePrimaryIcon:CFBundleIconFiles:0", "Payload/Example.app/Info.plist"),
            invoke_plistbuddy("Print :CFBundleIcons:CFBundlePrimaryIcon:CFBundleIconFiles:1", "Payload/Example.app/Info.plist")
          ]
          expect(result).to eql(["Blue29x29", "Blue40x40"])
        end
      end
    end
  end

  describe Fastlane::Actions::ReplaceFileAction do
    describe "#run" do
      before do
        @tmp_dir = Dir.mktmpdir
        @tmp_dir = File.join(@tmp_dir, "dir with spaces")
        Dir.mkdir(@tmp_dir)
        @ipa_file = File.join(@tmp_dir, "Example.ipa")
        Dir.chdir("example/layout/") do
          `zip #{@ipa_file.shellescape} -r *`
        end
      end

      after do
        FileUtils.rm_rf(@tmp_dir)
      end

      context "replacing files" do
        it "replaces app-relative files" do
          Fastlane::Actions::ReplaceFileAction.run(
            archive_path: @ipa_file,
            files: {
              "GoogleService-Info.plist" => "example/New-GoogleService-Info.plist"
            }
          )
          result = invoke_plistbuddy("Print :TRACKING_ID", "Payload/Example.app/GoogleService-Info.plist")
          expect(result).to eql("UA-123456789-12")
        end

        it "replaces archive-relative files" do
          Fastlane::Actions::ReplaceFileAction.run(
            archive_path: @ipa_file,
            files: {
              "/Info.plist" => "example/New-Info.plist"
            }
          )
          result = invoke_plistbuddy("Print :SchemeName", "Info.plist")
          expect(result).to eql("NewExample")
        end

        it "adds if there is no file to replace" do
          Fastlane::Actions::ReplaceFileAction.run(
            archive_path: @ipa_file,
            files: {
              "Foo.plist" => "example/Foo.plist"
            }
          )
          result = invoke_plistbuddy("Print :Foo", "Payload/Example.app/Foo.plist")
          expect(result).to eql("42")
        end
      end
    end
  end

  describe Fastlane::Actions::RemoveFileAction do
    describe "#run" do
      before do
        @tmp_dir = Dir.mktmpdir
        @tmp_dir = File.join(@tmp_dir, "dir with spaces")
        Dir.mkdir(@tmp_dir)
        @ipa_file = File.join(@tmp_dir, "Example.ipa")
        Dir.chdir("example/layout/") do
          `zip #{@ipa_file.shellescape} -r *`
        end
      end

      after do
        FileUtils.rm_rf(@tmp_dir)
      end

      context "delete files" do
        it "deletes app-relative paths" do
          Fastlane::Actions::RemoveFileAction.run(
            archive_path: @ipa_file,
            files: [
              "GoogleService-Info.plist"
            ]
          )
          result = archive_contains("Payload/Example.app/GoogleService-Info.plist")
          expect(result).to be false
        end

        it "deletes archive-relative files" do
          Fastlane::Actions::RemoveFileAction.run(
            archive_path: @ipa_file,
            files: [
              "/Info.plist"
            ]
          )
          result = archive_contains("Info.plist")
          expect(result).to be false
        end
      end
    end
  end

  def invoke_plistbuddy(command, plist)
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        `unzip -o -q #{@ipa_file.shellescape} #{plist.shellescape}`
        `/usr/libexec/PlistBuddy -c "#{command}" "#{plist.shellescape}"`.strip
      end
    end
  end

  def archive_contains(path)
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        `zipinfo -1 #{@ipa_file.shellescape} #{path.shellescape} 2>&1`
        $?.exitstatus.zero?
      end
    end
  end
end
