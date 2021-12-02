require "rspec/core/rake_task"
require 'rake/tfstats_task'
RSpec.describe Rake::TfstatsTask do
  subject { described_class.new }

  describe '.new' do
    context 'defaults' do
      specify do
        is_expected.to have_attributes(defaults)
      end
    end
  end

  describe '.define' do
    subject { Rake::Task.tasks.first }
    it { is_expected.to have_attributes(name: task_name) }
  end

  describe '.invoke' do
    it 'should call collector' do
      expect(Tfstats::Collector).to receive(:collect).with('.', '*.tf', false, false)
      Rake::Task[task_name].invoke
    end
  end


  let(:defaults) do
    {
      recursive: false,
      filespec: "*.tf",
      directory: '.',
      tabseparated: false,
      verbose: false
    }
  end

  let(:task_name) { 'stats:terraform' }
end