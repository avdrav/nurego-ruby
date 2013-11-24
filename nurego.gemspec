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

  s.add_dependency('rest-client', '~> 1.4')
  s.add_dependency('mime-types', '~> 1.25')
  s.add_dependency('multi_json', '>= 1.0.4', '< 2')

  s.files = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- test/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']
end
