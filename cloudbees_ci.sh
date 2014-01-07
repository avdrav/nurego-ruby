#!/bin/bash

export TZ=/usr/share/zoneinfo/America/Los_Angeles
curl -s -o use-ruby https://repository-cloudbees.forge.cloudbees.com/distributions/ci-addons/ruby/use-ruby
RUBY_VERSION=1.9.3-p327 \
 source ./use-ruby

export RACK_ENV=test

gem install --conservative bundler
bundle install

bundle exec rake spec:rcov
