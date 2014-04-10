# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'aerogel/mailer/version'

Gem::Specification.new do |spec|
  spec.name          = "aerogel-mailer"
  spec.version       = Aerogel::Mailer::VERSION
  spec.authors       = ["Alex Kukushkin"]
  spec.email         = ["alex@kukushk.in"]
  spec.description   = %q{Mail sending for aerogel applications}
  spec.summary       = %q{Mail sending for aerogel applications}
  spec.homepage      = "https://github.com/kukushkin/aerogel-mailer"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "aerogel-core", "~> 1.4"
  spec.add_dependency "mail"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
