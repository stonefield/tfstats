RSpec.describe Tfstats::Collector do

  let(:modules_path) { fixture_file_path('modules')}
  let(:filespec) { "*.tf" }

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

  let(:statistics) do
    {
      "fixtures"=>{
        :data=>4, :files=>2, :lines=>51, :loc=>30, :modules=>3, :resources=>2, :variables=>1
      }
    }
  end

  let(:terraform_versions) do
    {
      "fixtures"=>{
        :terraform_version => '1.0.9',
        :providers => {
          'registry.terraform.io/hashicorp/archive' => '2.2.0',
          'registry.terraform.io/hashicorp/aws' => '3.67.0'
        }
      }
    }
  end


  describe '.collect' do
    subject { described_class.new(fixture_dir, filespec)}
    specify do
      allow(described_class).to receive(:new).and_return(subject)
      expect(subject).to receive(:collect).and_return(statistics['fixtures'])
      expect(described_class).to receive(:output).with(statistics, false)
      described_class.collect(fixture_dir, filespec, false, false)
    end
  end

  describe '.versions' do
    subject { described_class.new(fixture_dir, filespec)}
    specify do
      allow(described_class).to receive(:new).and_return(subject)
      expect(subject).to receive(:versions).and_return(terraform_versions['fixtures'])
      expect(described_class).to receive(:output_versions).with(terraform_versions, false)
      described_class.versions(fixture_dir, filespec, false, false)
    end

    it 'should output versions correctly' do
      expect { described_class.versions(fixture_dir, filespec, false, false)}.to output(yaml_formatted_version_info).to_stdout
    end
  end

  describe '.process_dirs' do
    subject { described_class }
    context 'single dir' do
      let(:expected_yield) { [:object, 'fixtures'] }
      specify do
        allow(subject).to receive(:new).and_return(:object)
        expect { |b| subject.process_dir(fixture_dir, filespec, false, &b)}.to yield_with_args(*expected_yield)
      end
    end
    context 'recursively' do
      let(:expected_yields) {
        [[:object, 'fixtures'], [:object, 'fixtures/modules'], [:object, "fixtures/userdata"]]
      }
      specify do
        allow(subject).to receive(:new).and_return(:object)
        expect { |b| subject.process_dir(fixture_dir, filespec, true, &b)}.to yield_successive_args(*expected_yields)
      end
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

  let(:yaml_formatted_version_info) do
    <<~TEXT
      fixtures:
        terraform-version: 1.0.9
        providers:
          registry.terraform.io/hashicorp/archive:    2.2.0
          registry.terraform.io/hashicorp/aws:       3.67.0
    TEXT
  end

  describe '.version_output' do
    subject { described_class.output_versions(terraform_versions, tabseparated) }
    let(:no_terraform_versions) do
      {
        "fixtures"=>{
          :terraform_version => 'undefined',
          :providers => 'undefined'
        }
      }
    end
    context 'with yaml-format' do
      let(:tabseparated) { false }
      context 'with versioning info' do
        it 'should be yaml' do
          expect(subject).to eq yaml_formatted_version_info
        end
      end
      context 'without versioning info' do
        let(:terraform_versions) { no_terraform_versions }
        let(:yaml_formatted_without_versions) do
          <<~TEXT
            fixtures:
              terraform-version: undefined
              providers: undefined
          TEXT
        end
        it 'should be yaml' do
          expect(subject).to eq yaml_formatted_without_versions
        end
      end
    end
    context 'with tab-format' do
      let(:tabseparated) { true }
      context 'with versioning info' do
        let(:like_a_file) do
          <<~TEXT
            Directory\tProvider\tVersion
            fixtures\tterraform-version\t1.0.9
            fixtures\tregistry.terraform.io/hashicorp/archive\t2.2.0
            fixtures\tregistry.terraform.io/hashicorp/aws\t3.67.0
          TEXT
        end
        it 'should be like a file' do
          expect(subject).to eq like_a_file
        end
      end
      context 'without versioning info' do
        let(:terraform_versions) { no_terraform_versions }
        let(:tab_formatted_without_versions) do
          <<~TEXT
            Directory\tProvider\tVersion
            fixtures\tterraform-version\tundefined
            fixtures\tproviders\tundefined
          TEXT
        end
        it 'should be yaml' do
          expect(subject).to eq tab_formatted_without_versions
        end
      end
    end
  end

  describe '#collect' do
    subject { described_class.new(modules_path, filespec) }

    context 'with default filespec' do
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

  describe '#terraform_version' do
    subject { described_class.new(modules_path, filespec) }
    context 'when file does not exist' do
      specify do
        expect(subject.terraform_version).to eq 'undefined'
      end
    end
    context 'when file exist' do
      let(:modules_path) { fixture_dir }
      specify do
        expect(subject.terraform_version).to eq '1.0.9'
      end
    end
  end

end
