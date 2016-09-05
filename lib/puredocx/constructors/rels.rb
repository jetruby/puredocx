module PureDocx
  module Constructors
    class Rels
      DOCUMENT_RELATIONSHIPS = 'http://schemas.openxmlformats.org/officeDocument/2006/relationships/'.freeze
      PACKAGE__RELATIONSHIPS = 'http://schemas.openxmlformats.org/package/2006/relationships/'.freeze
      BASIC_RELS = {
        'docProps/core.xml' => "#{PACKAGE__RELATIONSHIPS}metadata/core-properties",
        'docProps/app.xml'  => "#{DOCUMENT_RELATIONSHIPS}extended-properties"
      }.freeze
      WORD_RELS = {
        'endnotes.xml'      => "#{DOCUMENT_RELATIONSHIPS}endnotes",
        'footnotes.xml'     => "#{DOCUMENT_RELATIONSHIPS}footnotes",
        'header1.xml'       => "#{DOCUMENT_RELATIONSHIPS}header",
        'footer1.xml'       => "#{DOCUMENT_RELATIONSHIPS}footer",
        'styles.xml'        => "#{DOCUMENT_RELATIONSHIPS}styles",
        'settings.xml'      => "#{DOCUMENT_RELATIONSHIPS}settings",
        'webSettings.xml'   => "#{DOCUMENT_RELATIONSHIPS}webSettings",
        'fontTable.xml'     => "#{DOCUMENT_RELATIONSHIPS}fontTable",
        'theme/theme1.xml'  => "#{DOCUMENT_RELATIONSHIPS}theme"
      }.freeze

      attr_accessor :basic_rels, :word_rels, :header_rels

      def initialize
        @basic_rels  = BASIC_RELS.dup
        @word_rels   = WORD_RELS.dup
        @header_rels = {}
      end

      def rels
        {
          basic_rels:  basic_rels,
          word_rels:   word_rels,
          header_rels: header_rels
        }
      end

      def prepare_basic_rels!
        basic_rels.merge!('word/document.xml' => "#{DOCUMENT_RELATIONSHIPS}officeDocument")
      end

      def prepare_word_rels!(file_path, file_name)
        word_rels.merge! prepare_rels_for_attached_image(file_path, file_name)
      end

      def prepare_header_rels!(file_path, file_name)
        header_rels.merge! prepare_rels_for_attached_image(file_path, file_name)
      end

      private

      def prepare_rels_for_attached_image(file_path, file_name)
        { "media/#{file_name}" => ["#{DOCUMENT_RELATIONSHIPS}image", file_path] }
      end
    end
  end
end
