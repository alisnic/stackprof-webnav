# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'stackprof-webnav/version'

Gem::Specification.new do |spec|
  spec.name          = "stackprof-webnav"
  spec.version       = StackProf::Webnav::VERSION
  spec.authors       = ["Andrei Lisnic"]
  spec.email         = ["andrei.lisnic@gmail.com"]
  spec.summary       = %q{View stackprof dumps in a web UI}
  spec.description   = %q{Provides the ability to analyze StackProf dumps}
  spec.homepage      = "https://github.com/alisnic/stackprof-webnav"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.bindir = 'bin'
  spec.executables << 'stackprof-webnav'

  spec.add_dependency "sinatra", ">= 2.0.7"
  spec.add_dependency "haml", ">= 5.1.2"
  spec.add_dependency "stackprof", ">= 0.2.13"
  spec.add_dependency "better_errors", ">= 1.1.0"
  spec.add_dependency "ruby-graphviz", ">= 1.2.4"
  spec.add_dependency "sinatra-contrib", ">= 2.0.5"
  spec.add_development_dependency "bundler", "~> 2.2"
  spec.add_development_dependency "rake", "~> 10.1"
  spec.add_development_dependency "rspec", "~> 3.9.0"
  spec.add_development_dependency "rack-test", "~> 1.1.0"
end
