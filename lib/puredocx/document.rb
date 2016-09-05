module PureDocx
  class Document
    attr_accessor :body_content, :header_content
    attr_reader   :file_path, :file_name, :brake, :new_page, :rels_constructor, :pagination_position

    def initialize(file_path, arguments = {})
      @file_path = file_path
      ensure_file!
      @file_name           = File.basename(file_path)
      @pagination_position = arguments[:pagination_position]
      @rels_constructor    = PureDocx::Constructors::Rels.new
      @brake               = File.read(DocArchive.template_path('brake.xml'))
      @new_page            = File.read(DocArchive.template_path('new_page.xml'))
      @header_content      = ''
      @body_content        = ''
      (class << self; self; end).class_eval do
        [:text, :table, :image].each do |method_name|
          define_method method_name do |content, options = {}|
            Object.const_get(
              "PureDocx::XmlGenerators::#{method_name.to_s.capitalize}"
            ).new(content, rels_constructor, options).xml
          end
        end
      end
    end

    def header(items)
      self.header_content += items.join
    end

    def content(items)
      self.body_content += items.join
    end

    def ensure_file!
      return unless File.exist?(file_path)
      raise FileCreatingError, 'File already exists in this directory. Please change the file name!'
    end

    def save!
      rels_constructor.prepare_basic_rels!
      DocArchive.open(file_path, rels_constructor.rels) do |file|
        file.add('[Content_Types].xml', DocArchive.template_path('[Content_Types].xml'))
        file.save_rels
        file.save_document_content(body_content, header_content, pagination_position)
      end
    end
  end
end
