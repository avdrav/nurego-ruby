$:.unshift(File.join(File.dirname(__FILE__), 'lib'))

require 'nurego/version'

spec = Gem::Specification.new do |s|
  s.name = 'nurego'
  s.version = Nurego::VERSION
  s.summary = 'Ruby bindings for the Nurego API'
  s.description = 'Business Operations for Subscription Services.  See http://www.nurego.com for details.'
  s.authors = ['Ilia Gilderman']
  s.email = ['ilia@nurego.com']
  s.homepage = 'http://www.nurego.com/api'
  s.license = 'MIT'

  s.add_dependency('rest-client', '~> 1.4')
  s.add_dependency('mime-types', '~> 1.25')
  s.add_dependency('multi_json', '>= 1.0.4', '< 2')
  s.add_dependency('cf-uaa-lib', '= 1.3.10')

  s.add_development_dependency('rake')
  s.add_development_dependency('uuidtools')
  s.add_development_dependency('rspec')
  s.add_development_dependency('simplecov')
  s.add_development_dependency('simplecov-rcov')
  s.add_development_dependency('simplecov-csv')
  s.add_development_dependency('rack-test')
  s.add_development_dependency('ci_reporter')

  s.files = Dir.glob("{lib,examples}/**/*") + %w(Gemfile Gemfile.lock nurego.gemspec Rakefile VERSION LICENSE README.md)
  s.test_files    = `git ls-files -- spec/unit*`.split("\n")
  s.require_paths = ['lib']
end
