require 'bundler/gem_tasks'
require 'rake/extensiontask'
require 'rake/testtask'

spec = Gem::Specification.load('qfs.gemspec')
Rake::ExtensionTask.new do |ext|
  ext.name = 'qfs_ext'
  ext.gem_spec = spec
  ext.ext_dir = 'ext/qfs'
end
Rake::TestTask.new test: :compile do |t|
    t.pattern = 'test/*_test.rb'
end
task default: :test
