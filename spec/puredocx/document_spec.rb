require 'spec_helper'

describe PureDocx::Document do
  let(:content)          { 'Content' }
  let(:rels_constructor) { instance_double 'PureDocx::Constructors::RelsConstructor' }
  let(:text_generator)   { instance_double 'PureDocx::Generators::TextXmlGenerator' }
  let(:image_generator)  { instance_double 'PureDocx::Generators::ImageXmlGenerator' }
  let(:table_generator)  { instance_double 'PureDocx::Generators::TableXmlGenerator' }
  let(:params_for_xml)   { [content, rels_constructor, {}] }
  let(:document_content) { ['text xml content', 'image xml content'] }
  subject { build :document }
  before  { allow(subject).to receive(:rels_constructor) { rels_constructor } }

  describe '#text' do
    context 'calls xml method on TextXmlGenerator' do
      after { subject.text(content, {}) }

      specify do
        expect(PureDocx::XmlGenerators::Text)
          .to receive(:new).with(*params_for_xml) { text_generator }
        expect(text_generator).to receive(:xml)
      end
    end
  end

  describe '#image' do
    context 'calls xml method on ImageXmlGenerator' do
      after { subject.image(content, {}) }

      specify do
        expect(PureDocx::XmlGenerators::Image)
          .to receive(:new).with(*params_for_xml) { image_generator }
        expect(image_generator).to receive(:xml)
      end
    end
  end

  describe '#table' do
    context 'calls xml method on TableXmlGenerator' do
      after { subject.image(content, {}) }

      specify do
        expect(PureDocx::XmlGenerators::Image)
          .to receive(:new).with(*params_for_xml) { image_generator }
        expect(image_generator).to receive(:xml)
      end
    end
  end

  describe '#header' do
    context 'changes document header content' do
      let(:result) { document_content.join }

      it do
        expect { subject.header(document_content) }.to change { subject.header_content }.from('').to(result)
      end
    end
  end

  describe '#content' do
    context 'changes document body content' do
      let(:result) { document_content.join }

      it do
        expect { subject.content(document_content) }.to change { subject.body_content }.from('').to(result)
      end
    end
  end

  describe '#save!' do
    context 'opens DocArchive and makes operations with adding new files to the docx file' do
      let(:file) { double(:file, add: true, save_rels: true, save_document_content: true) }
      before do
        allow(PureDocx::DocArchive).to receive(:open).and_yield(file)
        allow(rels_constructor).to     receive(:prepare_basic_rels!)
        allow(rels_constructor).to     receive(:rels)
        allow(subject).to              receive(:file_path) { './example.docx' }
        allow(Zip::File).to            receive(:open).with('./example.docx', Zip::File::CREATE)
        allow(PureDocx::DocArchive).to receive(:template_path).with('[Content_Types].xml') { 'xml file' }
      end
      after { subject.save! }

      it { expect(rels_constructor).to receive(:prepare_basic_rels!) }

      specify do
        expect(PureDocx::DocArchive).to receive(:open).and_yield(file)
        expect(file).to receive(:add).with('[Content_Types].xml', 'xml file')
        expect(file).to receive(:save_rels)
        expect(file).to receive(:save_document_content)
      end
    end
  end

  describe '#ensure_file!' do
    context 'raises error if file exists' do
      before { allow(File).to receive(:exist?).and_return(true) }

      it { expect { subject.send :ensure_file! }.to raise_error(PureDocx::FileCreatingError) }
    end
  end
end
