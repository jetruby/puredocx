require 'spec_helper'

describe PureDocx::XmlGenerators::Cell do
  let(:template_content) { 'content: {CONTENT}; width: {WIDTH};' }
  let(:result)           { 'content: cell content; width: 5200;' }

  before do
    allow(PureDocx::DocArchive).to receive(:template_path).with('table/cells.xml') { template_content }
    allow(File).to receive(:read).with(template_content)
  end
  subject         { build :cell_xml_generator }
  it_behaves_like 'BaseXmlGeneratorInterface'

  describe '#xml' do
    context 'returns xml context' do
      before { allow_any_instance_of(described_class).to receive(:template) { template_content } }

      it { expect(subject.xml).to eq result }
    end
  end

  describe '#template' do
    context 'reads template file' do
      after { subject.template }

      it { expect(File).to receive(:read).with(template_content) }
    end
  end
end
