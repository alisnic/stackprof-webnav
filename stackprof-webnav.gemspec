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

  spec.add_dependency "nyny", "~> 3.4"
  spec.add_dependency "haml", "~> 4.0"
  spec.add_dependency "stackprof", "~> 0.2"
  spec.add_dependency "sprockets-nyny", "0.0.3"
  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake", "~> 10.1"
end
