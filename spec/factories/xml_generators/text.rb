FactoryGirl.define do
  factory :text_xml_generator, class: PureDocx::XmlGenerators::Text do
    content          'content &'
    rels_constructor { nil }
    options do
      {
        style: %i[bold italic],
        size:  32,
        align: 'center'
      }
    end

    initialize_with { new(content, rels_constructor, options) }
  end

  factory :text_xml_generator_default, class: PureDocx::XmlGenerators::Text do
    content          'content &'
    rels_constructor { nil }

    initialize_with { new(content, rels_constructor) }
  end
end
