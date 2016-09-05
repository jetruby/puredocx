require 'spec_helper'

describe PureDocx::Constructors::TableColumn do
  let(:nil_width_params)        { [nil,    nil,          2] }
  let(:one_nil_width_param)     { [8_000, [500,    nil], 2] }
  let(:present_width_params)    { [8_000, [500,    500], 2] }
  let(:width_params_with_error) { [8_000, [20_000, nil], 2] }

  describe '#columns_width' do
    context 'calculates table columns width according to the parameters' do
      it { expect(described_class.new(*nil_width_params).columns_width).to     eq [4_677, 4_677] }
      it { expect(described_class.new(*one_nil_width_param).columns_width).to  eq [500, 7_500] }
      it { expect(described_class.new(*present_width_params).columns_width).to eq [500, 500] }
    end
  end

  describe '#table_width' do
    context 'calculates table columns width according to the parameters' do
      it { expect(described_class.new(*nil_width_params).table_width).to     eq 9_355 }
      it { expect(described_class.new(*one_nil_width_param).table_width).to  eq 8_000 }
      it { expect(described_class.new(*present_width_params).table_width).to eq 8_000 }
    end
  end

  describe '#calculate_default_width' do
    context 'calculates default width for table columns' do
      it { expect(described_class.new(*nil_width_params).calculate_default_width).to     eq 4_677 }
      it { expect(described_class.new(*one_nil_width_param).calculate_default_width).to  eq 7_500 }
      it { expect(described_class.new(*present_width_params).calculate_default_width).to eq 7_000 }
    end
  end

  describe '#total_table_width' do
    context 'calculates total table width' do
      it { expect(described_class.new(*nil_width_params).total_params_width).to     eq nil }
      it { expect(described_class.new(*one_nil_width_param).total_params_width).to  eq 500 }
      it { expect(described_class.new(*present_width_params).total_params_width).to eq 1000 }
    end
  end

  describe '#ensure_correct_table_max_width!' do
    context 'reises exception if table width is greater than maximum table width parameter' do
      specify do
        expect { described_class.new(*width_params_with_error).send :ensure_correct_table_max_width! }
          .to raise_error(PureDocx::TableColumnsWidthError)
      end
    end
  end
end
