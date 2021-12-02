RSpec.describe Tfstats::Collector do

  describe '.collect' do

  end

  describe '.process_dirs' do
    subject { described_class.process_dir(fixture_dir, "*.tf", recursive) }
    context 'single dir' do
      let(:recursive) { false }
      let(:statistics) do
        {
          "fixtures"=>{
            :data=>4, :files=>2, :lines=>51, :loc=>30, :modules=>3, :resources=>2, :variables=>1
          }
        }
      end
      specify { expect(subject).to eq statistics }
    end
    context 'recursively' do
      let(:recursive) { true }
      let(:statistics) { statistics_output }
      specify { expect(subject).to eq statistics }
    end
  end

  describe '.output' do
    subject { described_class.output(statistics_output, tabseparated) }
    context 'with text format' do
      let(:text_formatted) do
        <<~TEXT
          +-------------------+-----------+-----------+-----------+-----------+-----------+-----------+-----------+
          | Directory         |     Files |   modules | resources |      data | variables |     Lines |       LOC |
          +-------------------+-----------+-----------+-----------+-----------+-----------+-----------+-----------+
          | fixtures          |         2 |         3 |         2 |         4 |         1 |        51 |        30 |
          | fixtures/modules  |         3 |         1 |         1 |         1 |         1 |        46 |        34 |
          +-------------------+-----------+-----------+-----------+-----------+-----------+-----------+-----------+
          | Total             |         5 |         4 |         3 |         5 |         2 |        97 |        64 |
          +-------------------+-----------+-----------+-----------+-----------+-----------+-----------+-----------+
        TEXT
      end
      let(:tabseparated) { false }
      it 'should be tabular' do
        expect(subject).to eq text_formatted
      end
    end
    context 'with tab-format' do
      let(:tabseparated) { true }
      let(:like_a_file) do
        <<~TEXT
          Directory\tFiles\tmodules\tresources\tdata\tvariables\tLines\tLOC
          fixtures\t2\t3\t2\t4\t1\t51\t30
          fixtures/modules\t3\t1\t1\t1\t1\t46\t34
          Total\t5\t4\t3\t5\t2\t97\t64
        TEXT
      end
      it 'should be like a file' do
        expect(subject).to eq like_a_file
      end
    end
    context 'should leave out empty directories' do
      let(:tabseparated) { true }
      specify { expect(subject).not_to include "userdata" }
    end
  end

  describe '#collect' do
    subject { described_class.new(modules_path, filespec) }

    context 'with default filespec' do
      let(:filespec) { "*.tf" }
      specify do
        as_defined = { :data=>1, :files=>3, :lines=>46, :loc=>34, :modules=>1, :resources=>1, :variables=>1 }
        expect(subject.collect).to eq as_defined
      end
    end

    context 'with modified filespec' do
      let(:filespec) { "*.{tf,sh}"}
      specify do
        as_defined = { :files=>4, :lines=>48, :loc=>35, :modules=>1, :resources=>1, :data=>1, :variables=>1 }
        expect(subject.collect).to eq as_defined
      end
    end
  end

  let(:modules_path) { fixture_file_path('modules')}

  let(:statistics_output) do
    {
      "fixtures"=>{
        :files=>2, :modules=>3, :lines=>51, :loc=>30, :resources=>2, :data=>4, :variables=>1
        },
      "fixtures/modules"=>{
        :files=>3, :resources=>1, :lines=>46, :loc=>34, :modules=>1, :data=>1, :variables=>1
        },
      "fixtures/userdata"=>{}
    }
  end

end