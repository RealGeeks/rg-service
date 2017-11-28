# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rg/service/version'

Gem::Specification.new do |spec|
  spec.name          = "rg-service"
  spec.version       = Rg::Service::VERSION
  spec.authors       = ["Sam Livingston-Gray"]
  spec.email         = ["geeksam@gmail.com"]

  spec.summary       = %q{Service framework for Real Geeks}
  spec.description   = %q{Service framework for Real Geeks}
  spec.homepage      = "https://github.com/realgeeks/rg-service"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"

  spec.add_runtime_dependency "activesupport", ">= 4.0"
  spec.add_runtime_dependency "virtus", ">= 1.0.5"
end
