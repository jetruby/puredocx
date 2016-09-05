require 'spec_helper'

describe PureDocx::XmlGenerators::Row do
  let(:template_content) { 'content: {CELLS};' }
  let(:result)           { 'content: row content row content ;' }
  let(:cell_generator)   { instance_double('PureDocx::Generators::CellXmlGenerator') }

  before do
    allow(PureDocx::DocArchive).to receive(:template_path).with('table/rows.xml') { template_content }
    allow(File).to receive(:read).with(template_content)
    allow(PureDocx::XmlGenerators::Cell).to receive(:new) { cell_generator }
    allow(cell_generator).to receive(:xml) { 'row content ' }
  end
  subject         { build :row_xml_generator }
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

  describe '#cells' do
    context 'returns xml for row cells' do
      describe 'gets cells xml from CellXmlGenerator object' do
        after { subject.send(:cells) }

        specify do
          expect(PureDocx::XmlGenerators::Cell).to receive(:new).twice { cell_generator }
          expect(cell_generator).to receive(:xml).twice { 'content xml' }
        end
      end

      describe 'returns right cells xml' do
        let(:result) { ['row content ', 'row content '].join }

        it { expect(subject.send(:cells)).to eq result }
      end
    end
  end
end
