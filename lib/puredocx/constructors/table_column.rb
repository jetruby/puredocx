module PureDocx
  module Constructors
    class TableColumn
      MAX_TABLE_WIDTH = 9_355

      attr_reader :client_columns_width, :columns_count

      def initialize(client_table_width, client_columns_width, columns_count)
        @client_table_width   = client_table_width
        @client_columns_width = client_columns_width
        @columns_count        = columns_count
      end

      def columns_width
        default_width = calculate_default_width
        ensure_correct_table_max_width! unless total_params_width.nil?

        return [default_width] * columns_count if client_columns_width.nil?
        client_columns_width.map { |item| item.nil? ? default_width : item }
      end

      def table_width
        @client_table_width || MAX_TABLE_WIDTH
      end

      def total_params_width
        @total_params_width ||= client_columns_width&.compact&.inject(:+)
      end

      def calculate_default_width
        return (table_width / columns_count)          if client_columns_width.nil?
        return (table_width - total_params_width / 1) if client_columns_width.none?(&:nil?)
        ((table_width - total_params_width) / client_columns_width.select(&:nil?).size)
      end

      private

      def ensure_correct_table_max_width!
        return unless total_params_width > MAX_TABLE_WIDTH
        msg = %(Wrong table width: #{total_params_width}, please change it! Table width should be 10000.)
        raise TableColumnsWidthError, msg
      end
    end
  end
end
