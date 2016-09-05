require 'spec_helper'

describe PureDocx::XmlGenerators::Table do
  let(:template_content) do
    <<~HEREDOC.gsub(/\s+/, ' ').strip
      table_width           {TABLE_WIDTH};
      padding_top           {PADDING_TOP};
      padding_bottom        {PADDING_BOTTOM};
      padding_left          {PADDING_LEFT};
      padding_right         {PADDING_RIGHT};
      border_top:           {BORDER_TOP};
      border_bottom:        {BORDER_BOTTOM};
      border_left:          {BORDER_LEFT};
      border_right:         {BORDER_RIGHT};
      border_inside_h:      {BORDER_INSIDE_H};
      border_inside_v:      {BORDER_INSIDE_V};
      border_top_size:      {BORDER_TOP_SIZE};
      border_bottom_size:   {BORDER_BOTTOM_SIZE};
      border_left_size:     {BORDER_LEFT_SIZE};
      border_right_size:    {BORDER_RIGHT_SIZE};
      border_inside_h_size: {BORDER_INSIDE_H_SIZE};
      border_inside_v_size: {BORDER_INSIDE_V_SIZE};
      grid_options:         {GRID_OPTIONS};
      rows:                 {ROWS};
    HEREDOC
  end
  let(:default_result) do
    <<~HEREDOC.gsub(/\s+/, ' ').strip
      table_width           8000;
      padding_top           0;
      padding_bottom        0;
      padding_left          0;
      padding_right         0;
      border_top:           single;
      border_bottom:        single;
      border_left:          single;
      border_right:         single;
      border_inside_h:      single;
      border_inside_v:      single;
      border_top_size:      4;
      border_bottom_size:   4;
      border_left_size:     4;
      border_right_size:    4;
      border_inside_h_size: 4;
      border_inside_v_size: 4;
      grid_options:         grid xml;
      rows:                 rows xml;
    HEREDOC
  end
  let(:result) do
    <<~HEREDOC.gsub(/\s+/, ' ').strip
      table_width           8000;
      padding_top           10;
      padding_bottom        20;
      padding_left          30;
      padding_right         40;
      border_top:           ;
      border_bottom:        ;
      border_left:          ;
      border_right:         ;
      border_inside_h:      single;
      border_inside_v:      single;
      border_top_size:      4;
      border_bottom_size:   4;
      border_left_size:     4;
      border_right_size:    4;
      border_inside_h_size: 18;
      border_inside_v_size: 18;
      grid_options:         grid xml;
      rows:                 rows xml;
    HEREDOC
  end
  let(:row_generator) { instance_double('PureDocx::Generators::RowXmlGenerator') }
  let(:table_builder) { instance_double('PureDocx::Constructors::TableColumn') }
  let(:calculated_columns_width) { [6000, 4000] }

  before do
    allow(PureDocx::DocArchive).to receive(:template_path).with('table/table.xml') { template_content }
    allow(File).to receive(:read).with(template_content)
    allow(PureDocx::XmlGenerators::Row).to receive(:new)        { row_generator }
    allow(row_generator).to receive(:xml)                       { 'row xml' }
    allow(PureDocx::Constructors::TableColumn).to receive(:new) { table_builder }
    allow(table_builder).to receive(:columns_width)             { calculated_columns_width }
    allow(table_builder).to receive(:table_width)               { 8_000 }
  end
  subject         { build :table_xml_generator }
  it_behaves_like 'BaseXmlGeneratorInterface'

  describe '#xml' do
    context 'returns xml context' do
      before { allow_any_instance_of(described_class).to receive(:template)   { template_content } }
      before { allow_any_instance_of(described_class).to receive(:table_grid) { 'grid xml' } }
      before { allow_any_instance_of(described_class).to receive(:rows)       { 'rows xml' } }

      it 'with header image' do
        expect(subject.xml).to eq result
      end

      describe 'with default params' do
        subject { build :table_xml_generator_default }

        it { expect(subject.xml).to eq default_result }
      end
    end
  end

  describe '#template' do
    context 'reads template file' do
      after { subject.template }

      it { expect(File).to receive(:read).with(template_content) }
    end
  end

  describe '#rows' do
    context 'returns xml for table rows' do
      describe 'gets rows xml from RowXmlGenerator object' do
        after { subject.send :rows }

        specify do
          expect(PureDocx::XmlGenerators::Row).to receive(:new).twice { row_generator }
          expect(row_generator).to receive(:xml).twice { 'row xml' }
        end
      end
      describe 'returns right rows xml' do
        it { expect(subject.send(:rows)).to eq ['row xml', 'row xml'].join }
      end
    end
  end

  describe '#columns_width' do
    context 'returns array with columns width' do
      after { subject.send :columns_width }

      it { expect(table_builder).to receive(:columns_width) { calculated_columns_width } }
    end
  end

  describe '#table_width' do
    context 'returns table width' do
      after { subject.send :table_width }

      it { expect(table_builder).to receive(:table_width) { 8_000 } }
    end
  end

  describe '#check_columns_count' do
    context 'raises error when wrong table data or user options' do
      subject { build :wrong_table_xml_generator }

      it { expect { subject.send(:check_file) }.to raise_error PureDocx::TableColumnsCountError }
    end
  end

  describe '#table_grid' do
    context 'returns xml for table grid' do
      let(:result) { %(<w:gridCol w:w=\"6000\"/><w:gridCol w:w=\"4000\"/>) }

      it { expect(subject.send(:table_grid)).to eq result }
    end
  end

  describe '#prepare_sides' do
    context 'prepares table sides hash' do
      let(:result_1) { { right: '', left: '', top: '', bottom: '', inside_h: 'single', inside_v: 'single' } }
      let(:result_2) { { right: '4', left: '4', top: '4', bottom: '4', inside_h: '18', inside_v: '18' } }

      it { expect(subject.instance_eval { sides_without_border }).to eq result_1 }
      it { expect(subject.instance_eval { bold_sides }).to           eq result_2 }
    end
  end
end
