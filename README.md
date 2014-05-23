nurego-ruby
===========

Ruby bindings for Nurego API

== Installation

You don't need this source code unless you want to modify the gem. If
you just want to use the Nurego Ruby bindings, you should run:

  gem install nurego

If you want to build the gem from source:

  gem build nurego.gemspec

== Requirements

* Ruby 1.8.7 or above. 

== Development

Test cases can be run with: `bundle exec rake spec:unit`

Examples can be run with: `bundle install; ruby -I./lib examples/<example_name>.rb`
