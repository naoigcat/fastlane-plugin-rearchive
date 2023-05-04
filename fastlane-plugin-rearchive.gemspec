lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "fastlane/plugin/rearchive/version"

Gem::Specification.new do |spec|
  spec.name          = "fastlane-plugin-rearchive"
  spec.version       = Fastlane::Rearchive::VERSION
  spec.author        = "naoigcat"
  spec.email         = "17925623+naoigcat@users.noreply.github.com"
  spec.summary       = "Modify files inside ipa/xcarchive for publishing multiple configurations without rearchiving."
  spec.homepage      = "https://github.com/naoigcat/fastlane-plugin-rearchive"
  spec.license       = "MIT"
  spec.files         = Dir["lib/**/*"] + %w(README.md LICENSE)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  spec.required_ruby_version = ">= 2.7"

  spec.add_development_dependency("bundler")
  spec.add_development_dependency("fastlane", ">= 2.212.2")
  spec.add_development_dependency("pry")
  spec.add_development_dependency("rake")
  spec.add_development_dependency("rspec")
  spec.add_development_dependency("rspec_junit_formatter")
  spec.add_development_dependency("rubocop", "1.12.1")
  spec.add_development_dependency("rubocop-performance")
  spec.add_development_dependency("rubocop-require_tools")
  spec.add_development_dependency("simplecov")
end
