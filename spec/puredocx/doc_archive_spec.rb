require 'spec_helper'

describe PureDocx::DocArchive do
  let(:text)      { 'Some text' }
  let(:file_path) { './file_path' }
  let(:header_template_path)   { PureDocx::DocArchive::HEADER_TEMPLATE_PATH }
  let(:footer_template_path)   { PureDocx::DocArchive::FOOTER_TEMPLATE_PATH }
  let(:document_template_path) { PureDocx::DocArchive::DOCUMENT_TEMPLATE_PATH }
  let(:file)           { double(:file) }
  let(:path)           { double(:path) }
  let(:self_instance)  { double(:self_instance) }
  let(:os)             { double(:zip_output_stream) }
  let(:io)             { double(:zip_input_stream) }
  let(:rels)           { { basic_rels: 'basic_rels', word_rels: 'word_rels', header_rels: 'header_rels' } }
  subject { described_class.new io, rels }

  describe '.open' do
    context 'creates zip document' do
      after { described_class.open(file_path, rels) }

      it { expect(Zip::File).to receive(:open).with(file_path, Zip::File::CREATE) }
    end

    context 'yields self instance' do
      before do
        allow(Zip::File).to receive(:open).and_yield(file)
        allow(described_class).to receive(:new).and_return(self_instance)
      end

      it { expect { |b| described_class.open(file_path, rels, &b) }.to yield_with_args(self_instance) }
    end
  end

  describe '#add' do
    context 'addes file to the zip input stream' do
      after { subject.add(file, path) }

      it { expect(subject.io).to receive(:add).with(file, path) }
    end
  end

  describe '#save_document_content' do
    context 'writes xml content to word/document.xml inside zip document' do
      let(:params) { %w[content header right] }
      before do
        allow(subject).to receive(:document_colontitle!).with('header', header_template_path)
        allow(subject).to receive(:document_colontitle!).with('right',  footer_template_path)
        allow(subject).to receive(:document_content).with(*params).and_return('xml content')
      end
      after { subject.save_document_content(*params) }

      it 'saves document\'s content and colontitles into zip document' do
        expect(subject).to receive(:document_colontitle!).with('header', header_template_path)
        expect(subject).to receive(:document_colontitle!).with('right',  footer_template_path)
        expect(subject.io).to receive(:get_output_stream).with(document_template_path)
      end

      it 'saves document content into file by document\'s template path' do
        expect(subject.io).to receive(:get_output_stream).with(document_template_path).and_yield(os)
        expect(os).to receive(:write).with('xml content')
      end
    end
  end

  describe '#save_rels' do
    context 'adds rels files from template to the document' do
      after { subject.save_rels }

      specify do
        expect(subject).to receive(:add_rels!).with('_rels/.rels',             'basic_rels')
        expect(subject).to receive(:add_rels!).with('_rels/document.xml.rels', 'word_rels',   'word/')
        expect(subject).to receive(:add_rels!).with('_rels/header1.xml.rels',  'header_rels', 'word/')
      end
    end
  end

  describe '#add_rels!' do
    context 'generates rels files' do
      let(:params) { ['_rels/.rels', rels, 'word/'] }
      after { subject.add_rels!(*params) }

      specify do
        expect(subject).to receive(:generate_template_files!).with(rels, 'word/')
        expect(subject).to receive(:generate_files_with_rels_extension!).with(*params)
      end
    end
  end

  describe '#generate_template_files!' do
    context 'adds all template files, that were mentioned inside rels object ' do
      let(:rels_without_image) { { 'file_name' => 'link' } }
      let(:rels_with_image)    { { 'file_name' => %w[link image_path] } }
      context 'adds rels files by template target path' do
        before { allow(described_class).to receive(:template_path).and_return(path) }
        after  { subject.generate_template_files!(rels_without_image, 'some_path/') }

        it { expect(subject.io).to receive(:add).with('some_path/file_name', path) }
      end

      context 'adds rels files by image path' do
        after { subject.generate_template_files!(rels_with_image, '') }

        it { expect(subject.io).to receive(:add).with('file_name', 'image_path') }
      end
    end
  end

  describe '#generate_files_with_rels_extension!' do
    context 'generate files with rels extension' do
      let(:params)  { ['_rels/.rels', rels, 'word/'] }
      let(:content) do
        <<~HEREDOC.gsub(/\s+/, ' ').strip
          <?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>\n
          <Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
            rels content
          </Relationships>
        HEREDOC
      end
      before { allow(subject).to receive(:rels_content).with(rels).and_return('rels content') }
      after  { subject.generate_files_with_rels_extension!(*params) }

      specify do
        expect(subject.io).to receive(:get_output_stream).with('word/_rels/.rels').and_yield(os)
        expect(os).to receive(:write).with(content)
      end
    end
  end

  describe '#document_content' do
    context 'prepares xml content for document' do
      let(:template_content) { 'content: {CONTENT}, header: {HEADER}, footer: {FOOTER}' }
      before do
        allow(described_class).to receive(:template_path).and_return(path)
        allow(File).to receive(:read).with(path).and_return(template_content)
        allow(subject).to receive(:colontitle_reference_xml).with('headerReference', 'header1.xml').and_return('header')
        allow(subject).to receive(:colontitle_reference_xml).with('footerReference', 'footer1.xml').and_return('footer')
      end

      describe 'without header' do
        let(:params) { ['content', '', 'right'] }
        let(:result) { 'content: content, header: , footer: footer' }

        it { expect(subject.document_content(*params)).to eq result }
      end

      describe 'without footer' do
        let(:params) { ['content', 'header', nil] }
        let(:result) { 'content: content, header: header, footer: ' }

        it { expect(subject.document_content(*params)).to eq result }
      end

      describe 'with all params' do
        let(:params) { %w[content header footer] }
        let(:result) { 'content: content, header: header, footer: footer' }

        it { expect(subject.document_content(*params)).to eq result }
      end
    end
  end

  describe '#document_colontitle!' do
    context 'generates xml content for colontitle from template and adds it to the zip document' do
      let(:template_content) { 'content: {CONTENT}' }
      before do
        allow(described_class).to receive(:template_path).and_return(path)
        allow(File).to receive(:read).with(path).and_return(template_content)
      end

      context 'with content' do
        after { subject.document_colontitle!('content', file_path) }

        specify do
          expect(subject.io).to receive(:get_output_stream).with(file_path).and_yield(os)
          expect(os).to receive(:write).with('content: content')
        end
      end

      context 'without content' do
        after { subject.document_colontitle!('', file_path) }

        specify do
          expect(subject.io).to receive(:get_output_stream).with(file_path).and_yield(os)
          expect(os).to receive(:write).with('content: ')
        end
      end
    end
  end

  describe '#colontitle_reference_xml' do
    context 'prepares reference xml according to the reference file index' do
      let(:params) { ['headerReference', 'header1.xml'] }
      let(:result) { '<w:headerReference r:id="rId2" w:type="default"/>' }
      before { allow(subject).to receive_message_chain('word_rels.keys.index').with('header1.xml') { 2 } }

      it { expect(subject.colontitle_reference_xml(*params)).to eq result }
    end
  end

  describe '#rels_content' do
    context 'generate rels content' do
      let(:rels)   { { 'file_name' => 'link' } }
      let(:result) { %(<Relationship Id="rId0" Type="link" Target="file_name"/>) }

      it { expect(subject.rels_content(rels)).to eq result }
    end
  end

  describe '.template_path' do
    context 'returns file path inside template folder' do
      let(:file_name) { 'example.docx' }
      before { allow(described_class).to receive(:dir_path) { 'home/' } }

      it { expect(described_class.template_path(file_name).to_s).to eq 'home/template/example.docx' }
    end
  end
end
