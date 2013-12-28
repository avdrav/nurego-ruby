require 'rspec'
require "rspec/core/rake_task"

namespace "spec" do
  RSpec::Core::RakeTask.new("unit") do |t|
    t.rspec_opts = ["--format", "documentation", "--colour"]
    t.pattern = "**/unit/**/*_spec.rb"
  end
end

task :default => [:spec]
task :spec => ['spec:unit']