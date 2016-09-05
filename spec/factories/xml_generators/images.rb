FactoryGirl.define do
  factory :image_xml_generator, class: PureDocx::XmlGenerators::Image do
    image_path       './spec/fixtures/images/image.jpg'
    rels_constructor { PureDocx::Constructors::Rels.new }
    options do
      {
        width: 500,
        size:  500,
        in_header: true,
        align: [:right]
      }
    end

    initialize_with { new(image_path, rels_constructor, options) }
  end

  factory :image_xml_generator_default, class: PureDocx::XmlGenerators::Image do
    image_path        './spec/fixtures/images/image.jpg'
    rels_constructor { PureDocx::Constructors::Rels.new }

    initialize_with { new(image_path, rels_constructor) }
  end
end
