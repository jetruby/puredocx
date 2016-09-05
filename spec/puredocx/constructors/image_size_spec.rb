require 'spec_helper'

describe PureDocx::Constructors::ImageSize do
  let(:nil_params)     { { user_params: nil,        real_params: [600, 600] } }
  let(:one_nil_param)  { { user_params: [500, nil], real_params: [600, 600] } }
  let(:present_params) { { user_params: [500, 500], real_params: [600, 600] } }

  describe '#prepare_size' do
    context 'returns hash of prepared and scaled width/height' do
      let(:result) { { width: 4_312_500, height: 4_312_500 } }
      before { allow_any_instance_of(described_class).to receive(:set_new_size_params) { [500, 500] } }

      it { expect(described_class.new(present_params).prepare_size).to eq result }
    end
  end

  describe '#image_size_params_nil?' do
    context 'checks if all size params are nil' do
      it { expect(described_class.new(nil_params).send(:image_size_params_nil?)).to     be true }
      it { expect(described_class.new(one_nil_param).send(:image_size_params_nil?)).to  be false }
      it { expect(described_class.new(present_params).send(:image_size_params_nil?)).to be false }
    end
  end

  describe '#image_size_params_present?' do
    context 'checks if all size params are present' do
      it { expect(described_class.new(nil_params).send(:image_size_params_present?)).to     be false }
      it { expect(described_class.new(one_nil_param).send(:image_size_params_present?)).to  be false }
      it { expect(described_class.new(present_params).send(:image_size_params_present?)).to be true }
    end
  end

  describe '#set_new_size_params' do
    context 'returns array of calculated size parameters' do
      it { expect(described_class.new(nil_params).send(:set_new_size_params)).to     eq [600, 600] }
      it { expect(described_class.new(one_nil_param).send(:set_new_size_params)).to  eq [500, 500] }
      it { expect(described_class.new(present_params).send(:set_new_size_params)).to eq [500, 500] }
    end
  end

  describe '#calculate_params' do
    context 'calculate second size parameter by first one' do
      describe 'with width parameter' do
        before { allow_any_instance_of(described_class).to receive(:width).and_return(500) }

        it { expect(described_class.new(nil_params).send(:calculate_params)).to eq [500, 500] }
      end

      describe 'with height parameter' do
        before { allow_any_instance_of(described_class).to receive(:height).and_return(500) }

        it { expect(described_class.new(nil_params).send(:calculate_params)).to eq [500, 500] }
      end
    end
  end

  describe '#scaled_params' do
    context 'it scales image width according to the max document width' do
      it 'with image width greater than maximum document width' do
        expect(described_class.new(nil_params).send(:scaled_params, 1000, 1000)).to eq [650, 650]
      end

      it 'with image width lower than maximum document width' do
        expect(described_class.new(nil_params).send(:scaled_params, 400, 400)).to eq [400, 400]
      end
    end
  end
end
