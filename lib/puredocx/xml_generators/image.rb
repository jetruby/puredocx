module PureDocx
  module XmlGenerators
    class Image < Base
      attr_reader   :width,
                    :height,
                    :image_path,
                    :image_name,
                    :in_header,
                    :align,
                    :rels_id,
                    :size_constructor

      def initialize(image_path, rels_constructor, arguments = {})
        super(nil, rels_constructor)
        @image_path       = image_path
        @image_name       = File.basename(image_path)
        ensure_file!
        @width            = arguments[:width]
        @height           = arguments[:height]
        @in_header        = arguments[:in_header]
        @align            = arguments[:align]
        @rels_id          = "rId#{appropriated_rels_size}"
        @size_constructor = PureDocx::Constructors::ImageSize.new(
          user_params: [width, height],
          real_params: FastImage.size(image_path)
        )
      end

      def xml
        add_image_rels
        super
      end

      def params
        align_params = { horizontal: '', vertical: '' }
        align_params.merge! prepare_align_params(align) if align
        {
          '{WIDTH}'            => size_constructor.prepare_size[:width],
          '{HEIGHT}'           => size_constructor.prepare_size[:height],
          '{RID}'              => rels_id,
          '{NAME}'             => image_name,
          '{UNIQUE_NAME}'      => uniq_name(image_name),
          '{HORIZONTAL_ALIGN}' => align_params[:horizontal],
          '{VERTICAL_ALIGN}'   => align_params[:vertical]
        }
      end

      def template
        return File.read(DocArchive.template_path('float_image.xml')) if align&.any?
        File.read(DocArchive.template_path('image.xml'))
      end

      private

      def uniq_name(image_name)
        "image_#{SecureRandom.uuid}#{File.extname(image_name)}"
      end

      def ensure_file!
        raise ImageReadingError, "The #{image_name}  not found!" unless File.exist?(image_path)
      end

      def add_image_rels
        return rels_constructor.prepare_header_rels!(image_path, uniq_name(image_name)) if in_header?
        rels_constructor.prepare_word_rels!(image_path, uniq_name(image_name))
      end

      def in_header?
        in_header
      end

      def appropriated_rels_size
        rels_constructor.rels[(in_header? && :header_rels) || :word_rels].size
      end

      def prepare_align_params(align_params)
        align = {
          horizontal: :left,
          vertical:   :top
        }
        align_params.each do |item|
          align[:horizontal] = item if %i[right left].include? item
          align[:vertical]   = item if %i[bottom top].include? item
        end
        align
      end
    end
  end
end
