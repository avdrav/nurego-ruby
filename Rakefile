require 'rspec'
require "rspec/core/rake_task"
require "rack/test"
require "ci/reporter/rake/rspec"


namespace "spec" do
  RSpec::Core::RakeTask.new("unit") do |t|
    t.rspec_opts = ["--format", "documentation", "--colour"]
    t.pattern = "**/unit/**/*_spec.rb"
  end

  RSpec::Core::RakeTask.new("integration") do |t|
    t.rspec_opts = ["--format", "documentation", "--colour"]
    t.pattern = "**/integration/**/*_spec.rb"
  end

  desc "Run specs with code coverage"
  task :rcov => ["ci:setup:rspec"] do
    require 'simplecov'
    require 'simplecov-rcov'

    FileUtils.rm_rf File.join('.', "coverage")

    SimpleCov.start do
      formatter SimpleCov::Formatter::CSVFormatter
      coverage_dir ENV["COVERAGE_REPORTS"]
      root '.'

      add_filter "/spec/"

      RSpec::Core::Runner.disable_autorun!
      exit 1 unless RSpec::Core::Runner.run(['spec/unit'], STDERR, STDOUT) == 0
    end
  end

end

task :default => [:spec]
task :spec => ['spec:unit']
