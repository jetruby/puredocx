FactoryGirl.define do
  factory :cell_xml_generator, class: PureDocx::XmlGenerators::Cell do
    content          { { column: ['cell content'] } }
    rels_constructor { nil }
    width            5200

    initialize_with { new(content, rels_constructor, width: width) }
  end
end
