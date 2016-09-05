require 'spec_helper'

describe PureDocx::XmlGenerators::Image do
  let(:template_content) do
    <<~HEREDOC.gsub(/\s+/, ' ').strip
      width:      {WIDTH};
      height:     {HEIGHT};
      rid:        {RID};
      name:       {NAME};
      uniq_name:  {UNIQUE_NAME};
      horizontal: {HORIZONTAL_ALIGN};
      vertical:   {VERTICAL_ALIGN};
    HEREDOC
  end
  let(:default_result) do
    <<~HEREDOC.gsub(/\s+/, ' ').strip
      width:      5606250;
      height:     3156750;
      rid:        rId9;
      name:       image.jpg;
      uniq_name:  uniq_name;
      horizontal: ;
      vertical:   ;
    HEREDOC
  end
  let(:result) do
    <<~HEREDOC.gsub(/\s+/, ' ').strip
      width:      4312500;
      height:     2423625;
      rid:        rId0;
      name:       image.jpg;
      uniq_name:  uniq_name;
      horizontal: right;
      vertical:   top;
    HEREDOC
  end
  subject         { build :image_xml_generator }
  it_behaves_like 'BaseXmlGeneratorInterface'

  describe '#xml' do
    context 'returns xml context' do
      before { allow_any_instance_of(described_class).to receive(:template).and_return(template_content) }
      before { allow_any_instance_of(described_class).to receive(:uniq_name).and_return('uniq_name') }

      describe 'checkes if subject calls add_image_rels method' do
        after { subject.xml }

        it { expect(subject).to receive :add_image_rels }
      end

      it 'with header image' do
        expect(subject.xml).to eq result
      end

      describe 'with default params' do
        subject { build :image_xml_generator_default }

        it { expect(subject.xml).to eq default_result }
      end
    end
  end

  describe '#template' do
    context 'reades template file' do
      after { subject.template }

      describe 'with align' do
        before { allow(subject).to receive(:align) { [:right] } }

        specify do
          expect(PureDocx::DocArchive).to receive(:template_path).with('float_image.xml') { template_content }
          expect(File).to receive(:read).with(template_content)
        end
      end

      describe 'without align' do
        before { allow(subject).to receive(:align) { nil } }

        specify do
          expect(PureDocx::DocArchive).to receive(:template_path).with('image.xml') { template_content }
          expect(File).to receive(:read).with(template_content)
        end
      end
    end
  end

  describe '#check_file' do
    context 'reises exception if there is no file by file path' do
      before { allow(File).to receive(:exist?).and_return(false) }

      it { expect { subject.send :check_file }.to raise_error(PureDocx::ImageReadingError) }
    end
  end

  describe '#add_image_rels' do
    context 'modifies rels object' do
      after { subject.send :add_image_rels }

      describe 'with image inside header' do
        it { expect(subject).to receive_message_chain('rels_constructor.prepare_header_rels!') }
      end

      describe 'with image inside content' do
        subject { build :image_xml_generator_default }

        it { expect(subject).to receive_message_chain('rels_constructor.prepare_word_rels!') }
      end
    end
  end

  describe '#appropriated_rels_size' do
    context 'returns appropriated rels size' do
      describe 'with image inside header' do
        before { allow(subject).to receive(:in_header?).and_return(true) }

        it { expect(subject.send(:appropriated_rels_size)).to eq 0 }
      end

      describe 'with image inside content' do
        before { allow(subject).to receive(:in_header?).and_return(false) }

        it { expect(subject.send(:appropriated_rels_size)).to eq 9 }
      end
    end
  end

  describe '#prepare_align_params' do
    context 'returns alignparameters if align present' do
      describe 'with one align parameter' do
        let(:result) { { horizontal: :right, vertical: :top } }

        it { expect(subject.send(:prepare_align_params, [:right])).to eq result }
      end

      describe 'with two align parameters' do
        let(:result) { { horizontal: :right, vertical: :bottom } }

        it { expect(subject.send(:prepare_align_params, [:right, :bottom])).to eq result }
      end
    end
  end
end
