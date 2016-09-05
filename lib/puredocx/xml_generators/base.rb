module PureDocx
  module XmlGenerators
    class Base
      attr_reader :content, :rels_constructor

      def initialize(content, rels_constructor)
        @content          = content
        @rels_constructor = rels_constructor
      end

      def xml
        params.each_with_object(template.clone) { |(param, value), memo| memo.gsub!(param, value.to_s) }
      end

      def template
        raise NotImplementedError, "#{__method__} is not implemented."
      end

      def params
        {}
      end
    end
  end
end
