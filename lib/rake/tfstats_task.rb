require 'rake/tasklib'
require 'tfstats'

class Rake::TfstatsTask < Rake::TaskLib
  attr_accessor :recursive, :filespec, :directory, :tabseparated, :verbose

  def initialize()
    self.recursive = false
    self.filespec = "*.tf"
    self.directory = '.'
    self.tabseparated = false
    self.verbose = false
    yield self if block_given?
    self.define
  end


  def define
    namespace :stats do
      desc 'Display terraform statistics'
      task :terraform do
        Tfstats.verbose = self.verbose
        Tfstats::Collector.collect(directory, filespec, recursive, tabseparated)
      end
    end
  end
end