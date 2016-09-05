require 'spec_helper'

describe PureDocx::XmlGenerators::Base do
  subject { build(:base_xml_generator) }
  it_behaves_like 'BaseXmlGeneratorInterface'

  describe '#template' do
    context 'raises exception' do
      it { expect { subject.template }.to raise_error(NotImplementedError) }
    end
  end
end
