# PureDocx
[![CircleCI](https://circleci.com/gh/jetruby/puredocx.svg?style=shield)](https://circleci.com/gh/jetruby/puredocx)
[![Code Climate](https://codeclimate.com/github/jetruby/puredocx/badges/gpa.svg)](https://codeclimate.com/github/jetruby/puredocx)
[![Test Coverage](https://codeclimate.com/github/jetruby/puredocx/badges/coverage.svg)](https://codeclimate.com/github/jetruby/puredocx/coverage)
[![Issue Count](https://codeclimate.com/github/jetruby/puredocx/badges/issue_count.svg)](https://codeclimate.com/github/jetruby/puredocx)

Puredocx allows you to create docx files and assign images, text and tables to it.

### Installation

To install puredox gem type the following:

```sh
$ gem 'puredocx'
```

### Document building

You can create **'example.docx'** by creating PureDocx object:

```sh
PureDocx.create('../example.docx', paginate_pages: 'right') do |doc|
  doc.header([
    doc.text('header', style: [:italic], size: 28, align: 'left'),
    doc.image('../images/logo.jpg', width: 100, in_header: true)
  ])

  doc.content([
    doc.text('text', style: [:bold], size: 32, align: 'center'),
    doc.image('../images/logo.jpg', width: 100),
    doc.table(table, table_options)
  ])
end
```

**doc.header** method will generate header for the docx document and **doc.content** - its content. If you want to pass more than one image with text in the content or in the header, assign them in the correct sequence inside the array. There are 4 types of methods to prepare xml:
* text - prepares xml for text;
* image - prepares xml for image. It's very important to add **in_header: true** into image options for image inside the header!
* table - prepares xml for table;
* brake - prepares xml for brake line;
* new_page - prepares xml to move cursor to another page.

You can specify the footer position in **paginate_pages** option. It can be 'left', 'right' or 'center'.

### Table preparation

If you want to insert table into the document you shold prepare table data as shown below. This mast be an array of rows. Each row contains column object with some parameters. Every columns element will start from a new line.

You should create an object **table_options** also, to add some styles to the table. This object accepts 3 keys:
* table_width - an integer number, that represents table width(maximum table width by default);
* paddings - a hash of values({ top: 10, left: 20}), that represents table paddings(all values equal 0 by default);
* sides_without_border - an array of symbols, that specify sides, that should be hidden;
* bold_sides - an array of symbols, that specify sides, that should be bold;
* col_width - an array of strings and nils. The maximum width of the table should be **10400** according to the document's width. The number elements inside the array must be the same, as the number of columns in the table. If you want to specify only one column's width, pass nil in place of other elements, and their width will be calculated automaticly.

If you want to insert **table2** with options into another table, you should prepare data for this table and add it to the right column. It is important to set width for nested table(table_width parameter). Look at the following example:

```sh
  table = [
    [
      { column: [doc.text('first column, first row')] },
      {
        column: [
          doc.text('second column a, first row'),
          doc.text('second column b, first row'),
          doc.text('second column c, first row')
        ]
      },
      { column: [doc.image('../image.jpg', width: 500)] }
    ],
    [
      {
        column: [
          doc.table(table2, table2_options),
          doc.brake
        ]
      },
      { column: [doc.text('second column, second row')] },
      { column: [doc.text('third column, second row')]  }
    ]
  ]

  table_options = {
    table_width: 4000,
    sides_without_border: [:left, :top, :right, :insideH, :insideV],
    bold_sides: [:bottom],
    col_width:  [nil, 2852, nil]
  }
```
This example shows how to create the table data and it's options.

You can see generated docx file example here [example.docx](examples/documents/example.docx)

Puredocx gem works fine with Microsoft Word 2016 and Libre Office.

License
----

MIT

**Free Software**

About JetRuby
----------------

![jetruby](http://jetruby.com/expertise/wp-content/themes/jetruby-wordpress-template/img/sprite2x.png)


puredocx is maintained and founded by JetRuby Agency, inc.

We love open source software!
See [our projects][portfolio] or
[hire us][hire] to design, develop, and grow your product.

[portfolio]: http://jetruby.com/portfolio/
[hire]: http://jetruby.com/#contactUs
