nurego-ruby
===========

Ruby bindings for Nurego API

== Installation

You don't need this source code unless you want to modify the gem. If
you just want to use the Nurego Ruby bindings, you should run:

  gem install --source https://code.nurego.com nurego

If you want to build the gem from source:

  gem build nurego.gemspec

== Requirements

* Ruby 1.8.7 or above. 

== Mirrors

The nurego gem is mirrored on Rubygems, so you should be able to
install it via <tt>gem install nurego</tt> if desired. We recommend using
the https://code.nurego.com mirror so all code is fetched over SSL.

Note that if you are installing via bundler, you should be sure to use the https
rubygems source in your Gemfile, as any gems fetched over http could potentially be
compromised in transit and alter the code of gems fetched securely over https:

  source 'https://code.nurego.com'
  source 'https://rubygems.org'

  gem 'nurego'

== Development

Test cases can be run with: `bundle exec rake test`
=======
To run one of the examples use:

cd nurego_ruby
bundle install
ruby -I./lib examples/<example_name>.rb
