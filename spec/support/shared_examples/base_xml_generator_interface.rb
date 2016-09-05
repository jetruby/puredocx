shared_examples 'BaseXmlGeneratorInterface' do
  describe 'responded methods' do
    it { expect(subject).to respond_to(:xml) }
    it { expect(subject).to respond_to(:template) }
    it { expect(subject).to respond_to(:params) }
  end

  describe '#xml' do
    context 'parses template with appropriated params' do
      let(:params)   { { 'CONTENT' => 'xml content' } }
      let(:template) { '<w:p>{CONTENT}</w:p>' }
      let(:result)   { '<w:p>{xml content}</w:p>' }
      before do
        allow(subject).to receive(:params).and_return(params)
        allow(subject).to receive(:template).and_return(template)
      end

      it { expect(subject.xml).to eq result }
    end
  end

  describe '#params' do
    context 'returns hash params' do
      it { expect(subject.params).to be_a_kind_of(Hash) }
    end
  end
end
