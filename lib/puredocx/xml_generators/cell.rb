module PureDocx
  module XmlGenerators
    class Cell < Base
      attr_reader :width

      def initialize(content, rels_constructor, arguments = {})
        super(content, rels_constructor)
        @width = arguments[:width]
      end

      def template
        File.read(DocArchive.template_path('table/cells.xml'))
      end

      def params
        {
          '{CONTENT}' => content[:column].map(&:chomp).join,
          '{WIDTH}'   => width
        }
      end
    end
  end
end
