FactoryGirl.define do
  factory :base_xml_generator, class: PureDocx::XmlGenerators::Base do
    content          'content'
    rels_constructor { PureDocx::Constructors::Rels.new }

    initialize_with { new(content, rels_constructor) }
  end
end
