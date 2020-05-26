
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "minos/version"

Gem::Specification.new do |spec|
  spec.name          = "minos"
  spec.version       = Minos::VERSION
  spec.authors       = ["Pierre-Louis Gottfrois"]
  spec.email         = ["pierre-louis@textmaster.com"]

  spec.summary       = %q{Easy and repeatable Kubernetes deployment based on Docker images}
  spec.description   = %q{Easy and repeatable Kubernetes deployment based on Docker images}
  spec.homepage      = "https://github.com/textmaster/minos"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport", ">= 5.2", "< 7.0"
  spec.add_dependency "thor", "~> 0.20"
  spec.add_dependency "dry-matcher", "~> 0.7"
  spec.add_dependency "dry-monads", "~> 1.2"

  spec.add_development_dependency "bundler", "~> 1.17"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rspec"
end
