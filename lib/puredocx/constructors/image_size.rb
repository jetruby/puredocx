module PureDocx
  module Constructors
    class ImageSize
      MAX_IMAGE_WIDTH = 650
      PX_EMU          = 8625

      attr_reader :width, :height, :real_width, :real_height

      def initialize(arguments = {})
        @width, @height           = arguments[:user_params]
        @real_width, @real_height = arguments[:real_params]
      end

      def prepare_size
        new_width, new_height = set_new_size_params
        new_width, new_height = scaled_params(new_width, new_height) if new_width > MAX_IMAGE_WIDTH
        { width: new_width, height: new_height }.map { |key, value| [key, (value * PX_EMU)] }.to_h
      end

      private

      def set_new_size_params
        return [real_width, real_height] if image_size_params_nil?
        return [width, height]           if image_size_params_present?
        calculate_params
      end

      def image_size_params_nil?
        [height, width].all?(&:nil?)
      end

      def image_size_params_present?
        [height, width].none?(&:nil?)
      end

      def calculate_params
        [
          (width  || height * real_width / real_height),
          (height || width  * real_height / real_width)
        ]
      end

      def scaled_params(width, height)
        size_factor = width.to_f / MAX_IMAGE_WIDTH
        [width, height].map { |value| size_factor > 1 ? (value / size_factor).to_i : value }
      end
    end
  end
end
