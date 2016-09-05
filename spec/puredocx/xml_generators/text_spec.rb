require 'spec_helper'

describe PureDocx::XmlGenerators::Text do
  let(:template_content) do
    <<~HEREDOC.gsub(/\s+/, ' ').strip
      text:   {TEXT};
      align:  {ALIGN};
      bold:   {BOLD_ENABLE};
      italic: {ITALIC_ENABLE};
      size:   {SIZE};
    HEREDOC
  end
  let(:default_result) do
    <<~HEREDOC.gsub(/\s+/, ' ').strip
      text:   content &amp;;
      align:  left;
      bold:   false;
      italic: false;
      size:   28;
    HEREDOC
  end
  let(:result) do
    <<~HEREDOC.gsub(/\s+/, ' ').strip
      text:   content &amp;;
      align:  center;
      bold:   true;
      italic: true;
      size:   32;
    HEREDOC
  end
  before do
    allow(PureDocx::DocArchive).to receive(:template_path).with('paragraph.xml') { template_content }
    allow(File).to receive(:read).with(template_content)
  end

  subject         { build :text_xml_generator }
  it_behaves_like 'BaseXmlGeneratorInterface'

  describe '#xml' do
    context 'returns xml context' do
      before { allow_any_instance_of(described_class).to receive(:template).and_return(template_content) }

      it 'with all params' do
        expect(subject.xml).to eq result
      end

      describe 'with default params' do
        subject { build :text_xml_generator_default }

        it { expect(subject.xml).to eq default_result }
      end
    end
  end

  describe '#template' do
    context 'reads template file' do
      after { subject.template }

      it { expect(File).to receive(:read).with(template_content) }
    end
  end
end
