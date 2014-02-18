# encoding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'skimlinks/version'

Gem::Specification.new do |gem|
  gem.name          = 'skimlinks'
  gem.version       = Skimlinks::VERSION
  gem.platform      = Gem::Platform::RUBY
  gem.authors       = ['Manuel Meurer']
  gem.email         = 'manuel@krautcomputing.com'
  gem.summary       = 'A simple wrapper around the Skimlinks APIs'
  gem.description   = 'A simple wrapper around the Skimlinks APIs'
  gem.homepage      = 'https://github.com/krautcomputing/skimlinks'
  gem.license       = 'MIT'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r(^bin/)).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r(^(test|spec|features)/))
  gem.require_paths = ['lib']

  gem.add_development_dependency 'rake', '>= 0.9.0'
  gem.add_development_dependency 'rspec', '~> 2.13.0'
  gem.add_development_dependency 'webmock', '~> 1.11'
  gem.add_development_dependency 'vcr', '~> 2.4.0'
  gem.add_development_dependency 'ffaker', '~> 1.15.0'
  gem.add_development_dependency 'rb-fsevent', '~> 0.9.3'
  gem.add_development_dependency 'guard', '~> 1.6.1'
  gem.add_development_dependency 'guard-rspec', '~> 2.5.0'

  gem.add_runtime_dependency 'gem_config', '~> 0.0.2'
  gem.add_runtime_dependency 'mechanize', '~> 2.5'
  gem.add_runtime_dependency 'rest-client', '~> 1.6.7'
  gem.add_runtime_dependency 'activesupport', '~> 3.0'
  gem.add_runtime_dependency 'activemodel', '~> 3.0'

  if RUBY_PLATFORM == 'java'
    gem.add_runtime_dependency 'json-jruby', '~> 1.5.0'
    gem.add_runtime_dependency 'jruby-openssl', '~> 0.8.2'
  end
end
