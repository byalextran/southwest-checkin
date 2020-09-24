require_relative 'lib/autoluv/version'

Gem::Specification.new do |spec|
  spec.name          = "autoluv"
  spec.version       = Autoluv::VERSION
  spec.authors       = ["Alex Tran"]
  spec.email         = ["hello@alextran.org"]

  spec.summary       = "Easy-to-use gem to check in to Southwest flights automatically. Also supports sending email notifications."
  spec.homepage      = "https://github.com/byalextran/southwest-checkin"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.add_runtime_dependency "rest-client", "~> 2.1.0"
  spec.add_runtime_dependency "pony", "~> 1.13.0"
  spec.add_runtime_dependency "dotenv", "~> 2.7.0"
  spec.add_runtime_dependency "tzinfo", "~> 0.3.0"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "bin"
  spec.executables   = ["autoluv"]
  spec.require_paths = ["lib"]
end
