FactoryGirl.define do
  factory :row_xml_generator, class: PureDocx::XmlGenerators::Row do
    row_content do
      [
        { column: ['content 1'] },
        { column: ['content 2'] }
      ]
    end
    rels_constructor { nil }
    columns_width    { [5200, 5200] }

    initialize_with { new(row_content, rels_constructor, cells_width: columns_width) }
  end
end
