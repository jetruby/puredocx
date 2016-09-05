FactoryGirl.define do
  factory :document, class: PureDocx::Document do
    file_path './example.docx'
    options { { pagination_position: 'right' } }

    initialize_with { new(file_path, options) }
  end
end
