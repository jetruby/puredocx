require 'cgi'

module PureDocx
  module XmlGenerators
    class Text < Base
      DEFAULT_TEXT_SIZE  = 28
      DEFAULT_TEXT_ALIGN = 'left'.freeze
      attr_reader :bold_enable, :italic_enable, :align, :size

      def initialize(content, rels_constructor, arguments = {})
        super(nil, rels_constructor)
        @content       = CGI.escapeHTML(content)
        @bold_enable   = [*arguments[:style]].include?(:bold)
        @italic_enable = [*arguments[:style]].include?(:italic)
        @align         = arguments[:align] || DEFAULT_TEXT_ALIGN
        @size          = arguments[:size]  || DEFAULT_TEXT_SIZE
      end

      def params
        {
          '{TEXT}'          => content,
          '{ALIGN}'         => align,
          '{BOLD_ENABLE}'   => bold_enable,
          '{ITALIC_ENABLE}' => italic_enable,
          '{SIZE}'          => size
        }
      end

      def template
        File.read(DocArchive.template_path('paragraph.xml'))
      end
    end
  end
end
