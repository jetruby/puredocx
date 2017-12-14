require 'puredocx'
require 'ostruct'

FILE_PATH =    './documents/example.docx'.freeze
LOGO_PATH =    './images/logo.jpg'.freeze
IMAGE_1_PATH = './images/image_1.jpg'.freeze
IMAGE_2_PATH = './images/image_2.jpg'.freeze

# Example data
project = OpenStruct.new(
  name:      'User address:',
  address_1: '867 Boylston Street',
  city:      'Boston',
  state:     'Massachusetts',
  zip_code:  '56345'
)

company = OpenStruct.new(
  name:      'New Company Adjusters',
  address_1: '867 Boylston Street',
  city:      'Detroit',
  state:     'Michigan',
  zip_code:  '56345',
  user:      'Test User'
)

photo = OpenStruct.new(
  description: <<-HEREDOC.gsub(/\s+/, ' '),
    Lorem ipsum dolor sit amet, sea dolore commune ut, et alienum dissentiunt usu,
    sea forensibus elaboraret te. No nulla legendos nec, ad tale suas scaevola per.
    Ius no malorum salutandi tincidunt.
  HEREDOC
  created_at:       '13 Sep 2016',
  location_details: 'These are some details'
)

# Tables
header_table_options = {
  paddings: { left: 50, top: 20 },
  sides_without_border: [:left, :top, :right, :bottom, :inside_h, :inside_v],
  col_width:  [nil, 4000]
}

nested_table_options = {
  sides_without_border: [:left, :top, :right, :bottom, :inside_h, :inside_v],
  paddings: { left: 10, top: 100, right: 50, bottom: 30 },
  table_width: 3900
}

body_table_options = {
  sides_without_border: [:inside_h, :inside_v],
  paddings: { left: 50, top: 50, right: 50, bottom: 50 },
  col_width:  [450, 3000, nil]
}

header_nested_table = lambda do |doc|
  [
    [
      { column: [doc.text('Insured Name: ', style: [:bold], size: 20, align: 'left')] },
      { column: [doc.text(project.name, size: 20, align: 'right')] }
    ],
    [
      { column: [doc.text('Customer address: ', style: [:bold], size: 20, align: 'left')] },
      { column: [
        doc.text(project.address_1, size: 20, align: 'right'),
        doc.text("#{project.city}, #{project.state}", size: 20, align: 'right')
      ] }
    ]
  ]
end

header_table = lambda do |doc|
  [
    [
      { column: [doc.image(LOGO_PATH, width: 100, in_header: true)] },
      { column: [doc.table(header_nested_table.call(doc), nested_table_options)] }
    ],
    [
      { column: [
        doc.text(project.name,      style: [:bold], size: 20),
        doc.text(project.address_1, size: 20),
        doc.text([project.city, project.state].join(', '), size: 20),
        doc.text(project.zip_code, size: 20)

      ] },
      { column: [doc.text('', size: 20)] }
    ]
  ]
end

photo_info_table = lambda do |doc|
  [
    [
      { column: [doc.text('Date Taken: ', style: [:bold], size: 20)] },
      { column: [doc.text(photo.created_at, size: 20)] }
    ],
    [
      { column: [doc.text('Taken By: ', style: [:bold], size: 20)] },
      { column: [doc.text(company.user, size: 20)] }
    ]
  ]
end

body_table = lambda do |doc, id, path|
  [
    [
      { column: [doc.text(id, size: 20)] },
      {
        column: [
          doc.brake,
          doc.text(photo.location_details, size: 25),
          doc.brake,
          doc.text(photo.description, size: 20),
          doc.brake,
          doc.table(photo_info_table.call(doc), nested_table_options),
          doc.brake
        ]
      },
      { column: [doc.image(path, width: 400, align: [:right])] }
    ]
  ]
end

FileUtils.rm_f(FILE_PATH)
PureDocx.create(FILE_PATH, paginate_pages: 'right') do |doc|
  doc.header([doc.table(header_table.call(doc), header_table_options)])
  doc.content([
                doc.brake,
                doc.table(body_table.call(doc, '1', IMAGE_1_PATH), body_table_options),
                doc.brake,
                doc.table(body_table.call(doc, '2', IMAGE_2_PATH), body_table_options)
              ])
end
