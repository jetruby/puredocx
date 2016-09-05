require 'rspec'
require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
  add_group 'Document', %w(
    lib/puredocx/doc_archive.rb
    lib/puredocx/document.rb
    lib/puredocx.rb
    lib/puredocx/exceptions.rb
  )
  add_group 'Constructors', 'lib/puredocx/constructors'
  add_group 'Generators',   'lib/puredocx/xml_generators'
end

require 'puredocx'
require 'puredocx/doc_archive'
require 'puredocx/document'
require_relative './support/shared_examples/base_xml_generator_interface'
require_relative './support/factory_girl'

RSpec.configure do |config|
  config.color     = true
  config.tty       = true
  config.formatter = :progress
end
