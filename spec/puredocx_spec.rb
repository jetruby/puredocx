require 'spec_helper'

describe PureDocx do
  let(:doc)  { double(:doc) }
  let(:text) { 'This text' }
  before { allow(PureDocx::Document).to receive(:new).and_return(doc) }
  before { allow(doc).to receive(:save!) }

  describe '.create' do
    it 'creates new WordDocument object' do
      described_class.create('./fake_doc.docx', option: 1)

      expect(PureDocx::Document).to have_received(:new).with('./fake_doc.docx', option: 1)
      expect(doc).to have_received(:save!)
    end

    it 'yields given block' do
      expect { |doc| described_class.create('./fake_doc.docx', &doc) }.to yield_control
    end
  end
end
