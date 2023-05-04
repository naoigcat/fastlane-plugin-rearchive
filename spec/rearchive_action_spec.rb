describe Fastlane::Actions::RearchiveAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The rearchive plugin is working!")

      Fastlane::Actions::RearchiveAction.run(nil)
    end
  end
end
