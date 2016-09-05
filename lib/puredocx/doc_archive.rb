module PureDocx
  class DocArchive
    HEADER_TEMPLATE_PATH   = 'word/header1.xml'.freeze
    FOOTER_TEMPLATE_PATH   = 'word/footer1.xml'.freeze
    DOCUMENT_TEMPLATE_PATH = 'word/document.xml'.freeze

    attr_reader :io, :basic_rels, :word_rels, :header_rels

    def initialize(io, rels)
      @io = io
      @basic_rels  = rels[:basic_rels]
      @word_rels   = rels[:word_rels]
      @header_rels = rels[:header_rels]
    end

    def self.open(file_path, rels)
      Zip::File.open(file_path, Zip::File::CREATE) do |zip_file|
        file = new(zip_file, rels)
        yield file
      end
    end

    def add(file, path)
      io.add(file, path)
    end

    def save_document_content(content, header, pagination_position)
      document_colontitle!(header,              HEADER_TEMPLATE_PATH)
      document_colontitle!(pagination_position, FOOTER_TEMPLATE_PATH)

      io.get_output_stream(DOCUMENT_TEMPLATE_PATH) do |os|
        os.write document_content(content, header, pagination_position)
      end
    end

    def save_rels
      add_rels!('_rels/.rels',             basic_rels)
      add_rels!('_rels/document.xml.rels', word_rels,   'word/') unless word_rels.empty?
      add_rels!('_rels/header1.xml.rels',  header_rels, 'word/') unless header_rels.empty?
    end

    def add_rels!(file_name, rels, path = '')
      generate_template_files!(rels, path)
      generate_files_with_rels_extension!(file_name, rels, path)
    end

    def generate_template_files!(rels, path)
      rels.each do |target_path, (_, image_path)|
        pathfile = image_path || self.class.template_path(File.join(path, target_path))
        io.add("#{path}#{target_path}", pathfile)
      end
    end

    def generate_files_with_rels_extension!(file_name, rels, path)
      io.get_output_stream("#{path}#{file_name}") do |os|
        os.write(
          <<~HEREDOC.gsub(/\s+/, ' ').strip
            <?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>\n
            <Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
              #{rels_content(rels)}
            </Relationships>
          HEREDOC
        )
      end
    end

    def document_content(content, header, pagination_position)
      header_reference = colontitle_reference_xml('headerReference', 'header1.xml') unless header.empty?
      footer_reference = colontitle_reference_xml('footerReference', 'footer1.xml') if pagination_position

      File.read(self.class.template_path(DOCUMENT_TEMPLATE_PATH)).tap do |document_content|
        document_content.gsub!('{HEADER}',  header_reference || '')
        document_content.gsub!('{CONTENT}', content)
        document_content.gsub!('{FOOTER}',  footer_reference || '')
      end
    end

    def document_colontitle!(content, content_path)
      content_xml = File.read(self.class.template_path(content_path))
      content_xml.gsub!('{CONTENT}', content || '')
      io.get_output_stream(content_path) { |os| os.write content_xml }
    end

    def colontitle_reference_xml(reference_name, file_name)
      <<-HEREDOC.gsub(/\s+/, ' ').strip
        <w:#{reference_name}
        r:id="rId#{word_rels.keys.index(file_name)}"
        w:type="default"/>
      HEREDOC
    end

    def rels_content(rels)
      rels.map.with_index do |(target_path, (target_type, _)), index|
        %(<Relationship Id="rId#{index}" Type="#{target_type}" Target="#{target_path}"/>)
      end.join
    end

    def self.template_path(file_name)
      File.join(dir_path, 'template', file_name)
    end

    def self.dir_path
      Pathname.new(__FILE__).expand_path.parent.dirname
    end
  end
end
