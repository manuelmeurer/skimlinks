# encoding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'skimlinks/version'

Gem::Specification.new do |gem|
  gem.name          = 'skimlinks'
  gem.version       = Skimlinks::VERSION
  gem.platform      = Gem::Platform::RUBY
  gem.authors       = ['Manuel Meurer']
  gem.email         = 'manuel.meurer@gmail.com'
  gem.summary       = 'A simple wrapper around the Skimlinks APIs'
  gem.description   = 'A simple wrapper around the Skimlinks APIs'
  gem.homepage      = 'https://github.com/krautcomputing/skimlinks'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r(^bin/)).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r(^(test|spec|features)/))
  gem.require_paths = ['lib']

  gem.add_development_dependency 'rspec', '~> 2.12.0'
  gem.add_development_dependency 'webmock', '~> 1.9.0'
  gem.add_development_dependency 'vcr', '~> 2.3.0'
  gem.add_development_dependency 'ffaker', '~> 1.15.0'
  gem.add_development_dependency 'rake', '~> 10.0.1'
  gem.add_development_dependency 'rb-fsevent', '~> 0.9.2'
  gem.add_development_dependency 'guard', '~> 1.5.2'
  gem.add_development_dependency 'guard-rspec', '~> 2.1.2'

  gem.add_dependency 'mechanize', '~> 2.5.1'
  gem.add_dependency 'rest-client', '~> 1.6.7'
  gem.add_dependency 'activesupport', '~> 3.0'
  gem.add_dependency 'activemodel', '~> 3.0'

  if RUBY_PLATFORM == 'java'
    gem.add_dependency 'json-jruby', '~> 1.5.0'
    gem.add_dependency 'jruby-openssl', '~> 0.8.2'
  end
end
