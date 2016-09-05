FactoryGirl.define do
  factory :table_xml_generator, class: PureDocx::XmlGenerators::Table do
    content do
      [
        [{ column: ['xml'] }, { column: ['xml'] }],
        [{ column: ['xml'] }, { column: ['xml'] }]
      ]
    end
    rels_constructor { nil }
    options do
      {
        sides_without_border: [:left, :right, :top, :bottom],
        bold_sides:  [:inside_h, :inside_v],
        table_width: 8_000,
        col_width:   [nil, 4000],
        paddings:    { top: 10, bottom: 20, left: 30, right: 40 }
      }
    end

    initialize_with { new(content, rels_constructor, options) }
  end

  factory :table_xml_generator_default, class: PureDocx::XmlGenerators::Table do
    content do
      [
        [{ column: ['xml'] }, { column: ['xml'] }],
        [{ column: ['xml'] }, { column: ['xml'] }]
      ]
    end
    rels_constructor { PureDocx::Constructors::Rels.new }

    initialize_with { new(content, rels_constructor) }
  end

  factory :wrong_table_xml_generator, class: PureDocx::XmlGenerators::Table do
    content do
      [
        [{ column: ['xml'] }, { column: ['xml'] }],
        [{ column: ['xml'] }]
      ]
    end
    rels_constructor { nil }
    options do
      {
        sides_without_border: [:left, :right, :top, :bottom],
        bold_sides: [:inside_h, :inside_v],
        col_width:  [nil, 4000]
      }
    end

    initialize_with { new(content, rels_constructor, options) }
  end
end
