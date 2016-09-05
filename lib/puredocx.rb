#!/usr/bin/env ruby
require 'securerandom'
require 'fastimage'
require 'zip'

module PureDocx
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def create(file_path, options = {})
      doc = Document.new(file_path, options)

      yield doc if block_given?

      doc.save!
    end
  end

  class Basement
    include PureDocx
  end

  def self.create(*args, &block)
    Basement.create(*args, &block)
  end
end

require_relative 'puredocx/document'
require_relative 'puredocx/doc_archive'
require_relative 'puredocx/exceptions'

require_relative 'puredocx/constructors/rels'
require_relative 'puredocx/constructors/image_size'
require_relative 'puredocx/constructors/table_column'

require_relative 'puredocx/xml_generators/base'
require_relative 'puredocx/xml_generators/image'
require_relative 'puredocx/xml_generators/text'
require_relative 'puredocx/xml_generators/table'
require_relative 'puredocx/xml_generators/row'
require_relative 'puredocx/xml_generators/cell'
