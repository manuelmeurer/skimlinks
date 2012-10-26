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
  gem.description   = 'A simple wrapper around the Skimlinks APIs'
  gem.summary       = 'A simple wrapper around the Skimlinks APIs'
  gem.homepage      = 'https://github.com/krautcomputing/skimlinks'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r(^bin/)).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r(^(test|spec|features)/))
  gem.require_paths = ['lib']

  gem.add_development_dependency 'rspec', '~> 2.11.0'
  gem.add_development_dependency 'rake', '~> 0.9.2.2'
  gem.add_development_dependency 'rb-fsevent', '~> 0.9.2'
  gem.add_development_dependency 'guard', '~> 1.4.0'
  gem.add_development_dependency 'guard-rspec', '~> 2.1.0'
end
