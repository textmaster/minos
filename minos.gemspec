# frozen_string_literal: true

require_relative "lib/minos/version"

Gem::Specification.new do |spec|
  spec.name                  = "minos"
  spec.version               = Minos::VERSION
  spec.authors               = ["Pierre-Louis Gottfrois"]
  spec.email                 = ["pierre-louis@textmaster.com"]

  spec.summary               = %q{Easy and repeatable Kubernetes deployment based on Docker images}
  spec.description           = %q{Easy and repeatable Kubernetes deployment based on Docker images}
  spec.homepage              = "https://github.com/textmaster/minos"
  spec.license               = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/textmaster/minos"
  spec.metadata["changelog_uri"] = "https://github.com/textmaster/minos"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "activesupport", ">= 5.2", "< 8.0"
  spec.add_dependency "thor", "~> 1.0"
  spec.add_dependency "dry-matcher", "~> 1.0"
  spec.add_dependency "dry-monads", "~> 1.0"

  spec.add_development_dependency "rspec", "~> 3.0"
end
