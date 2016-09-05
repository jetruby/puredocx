require 'spec_helper'

describe PureDocx::Constructors::Rels do
  let(:file_path) { '/some_path' }
  let(:file_name) { 'docx_file' }
  subject { described_class.new }

  describe '#rels' do
    let(:result) do
      {
        basic_rels:  described_class::BASIC_RELS,
        word_rels:   described_class::WORD_RELS,
        header_rels: {}
      }
    end

    it { expect(subject.rels).to eq result }
  end

  describe '#prepare_basic_rels!' do
    context 'modifies basic rels hash' do
      it { expect { subject.prepare_basic_rels! }.to change { subject.basic_rels.size }.by(1) }
      describe 'merges new parameter into basic rels' do
        before { subject.prepare_basic_rels! }

        it { expect(subject.basic_rels.key?('word/document.xml')).to be true }
      end
    end
  end

  describe '#prepare_word_rels!' do
    context 'modifies word rels hash' do
      it do
        expect { subject.prepare_word_rels!(file_path, file_name) }.to change { subject.word_rels.size }.by(1)
      end
      describe 'merges new parameter into word rels' do
        before { subject.prepare_word_rels!(file_path, file_name) }

        it { expect(subject.word_rels.key?('media/docx_file')).to be true }
      end
    end
  end

  describe '#prepare_header_rels!' do
    context 'modifies header rels hash' do
      it do
        expect { subject.prepare_header_rels!(file_path, file_name) }.to change { subject.header_rels.size }.by(1)
      end
      describe 'merges new parameter into header rels' do
        before { subject.prepare_header_rels!(file_path, file_name) }

        it { expect(subject.header_rels.key?('media/docx_file')).to be true }
      end
    end
  end
end
