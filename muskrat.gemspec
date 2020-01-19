lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "muskrat/version"

Gem::Specification.new do |spec|
  spec.name          = "Muskrat"
  spec.version       = Muskrat::VERSION
  spec.authors       = ["Midhun Krishna"]
  spec.email         = ["reachme@midhunkrishna.in"]

  spec.summary       = %q{Simple mqtt message processor.}
  spec.description   = %q{mqtt pub-sub message processor for Ruby.}
  spec.homepage      = "https://midhunkrishna.in/muskrat"
  spec.license       = "MIT"

  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  # spec.metadata["homepage_uri"] = spec.homepage
  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.

  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(spec)/}) }
  end

  spec.executables   = ["muskrat"]
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.5.0"

  spec.add_dependency "mqtt", "~> 0.5.0"
end
