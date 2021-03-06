require_relative 'lib/tfstats/version'

Gem::Specification.new do |spec|
  spec.name          = "tfstats"
  spec.version       = Tfstats::VERSION
  spec.authors       = ["stonefield"]
  spec.email         = ["knut.stenmark@gmail.com"]

  spec.summary       = %q{Collects statistics for terraform}
  spec.description   = %q{Collects statistics for terraform - Supports both comman line and rake task}
  spec.homepage      = "https://github.com/stonefield/tfstats"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  #spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/stonefield/tfstats"
  spec.metadata["changelog_uri"] = "https://github.com/stonefield/tfstats/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
