# frozen_string_literal: true

require 'openssl'
require 'base64'
require 'digest/md5'
require 'cgi'

module Thumbor
  class CryptoURL
    attr_writer :computed_key

    def initialize(key = nil)
      @key = key
    end

    def computed_key
      (@key * 16)[0..15]
    end

    def calculate_width_and_height(url_parts, options)
      width = options[:width]
      height = options[:height]

      width *= -1 if width && options[:flip]
      height *= -1 if height && options[:flop]

      if width || height
        width ||= 0
        height ||= 0
      end

      has_width = width
      has_height = height
      if options[:flip] && !has_width && !has_height
        width = '-0'
        height = '0' if !has_height && !(options[:flop])
      end
      if options[:flop] && !has_width && !has_height
        height = '-0'
        width = '0' if !has_width && !(options[:flip])
      end

      url_parts.push("#{width}x#{height}") if width || height
    end

    def calculate_centered_crop(options)
      width = options[:width]
      height = options[:height]
      original_width = options[:original_width]
      original_height = options[:original_height]
      center = options[:center]

      return unless original_width &&
                    original_height &&
                    center &&
                    (width || height)

      raise 'center must be an array of x,y' unless center.is_a?(Array) && center.length == 2

      center_x, center_y = center
      width ||= original_width
      height ||= original_height
      width = width.abs
      height = height.abs
      new_aspect_ratio = width / height.to_f
      original_aspect_ratio = original_width / original_height.to_f

      crop = nil
      # We're going wider, vertical crop
      if new_aspect_ratio > original_aspect_ratio
        # How tall should we be? because new_aspect_ratio is > original_aspect_ratio we can be sure
        # that cropped_height is always less than original_height (original). This is assumed below.
        cropped_height = (original_width / new_aspect_ratio).round
        # Calculate coordinates around center
        top_crop_point = (center_y - (cropped_height * 0.5)).round
        bottom_crop_point = (center_y + (cropped_height * 0.5)).round

        # If we've gone above the top of the image, take all from the bottom
        if top_crop_point.negative?
          top_crop_point = 0
          bottom_crop_point = cropped_height
        # If we've gone below the top of the image, take all from the top
        elsif bottom_crop_point > original_height
          top_crop_point = original_height - cropped_height
          bottom_crop_point = original_height
          # Because cropped_height < original_height, top_crop_point and
          # bottom_crop_point will never both be out of bounds
        end

        # Put it together
        crop = [0, top_crop_point, original_width, bottom_crop_point]
      # We're going taller, horizontal crop
      elsif new_aspect_ratio < original_aspect_ratio
        # How wide should we be? because new_aspect_ratio is < original_aspect_ratio we can be sure
        # that cropped_width is always less than original_width (original). This is assumed below.
        cropped_width = (original_height * new_aspect_ratio).round
        # Calculate coordinates around center
        left_crop_point = (center_x - (cropped_width * 0.5)).round
        right_crop_point = (center_x + (cropped_width * 0.5)).round

        # If we've gone beyond the left of the image, take all from the right
        if left_crop_point.negative?
          left_crop_point = 0
          right_crop_point = cropped_width
        # If we've gone beyond the right of the image, take all from the left
        elsif right_crop_point > original_width
          left_crop_point = original_width - cropped_width
          right_crop_point = original_width
          # Because cropped_width < original_width, left_crop_point and
          # right_crop_point will never both be out of bounds
        end

        # Put it together
        crop = [left_crop_point, 0, right_crop_point, original_height]
      end

      options[:crop] = crop
    end

    def url_for(options)
      raise 'image is a required argument.' unless options[:image]

      url_parts = []

      url_parts.push('debug') if options[:debug]

      if options[:trim]
        trim_options = ['trim']
        trim_options << options[:trim] unless (options[:trim] == true) || (options[:trim][0] == true)
        url_parts.push(trim_options.join(':'))
      end

      url_parts.push('meta') if options[:meta]

      calculate_centered_crop(options)

      crop = options[:crop]
      if crop
        crop_left = crop[0]
        crop_top = crop[1]
        crop_right = crop[2]
        crop_bottom = crop[3]

        if crop_left.positive? || crop_top.positive? || crop_bottom.positive? || crop_right.positive?
          url_parts.push(crop_left.to_s << 'x' << crop_top.to_s << ':' << crop_right.to_s << 'x' << crop_bottom.to_s)
        end
      end

      %i[fit_in adaptive_fit_in full_fit_in adaptive_full_fit_in].each do |fit|
        url_parts.push(fit.to_s.gsub('_', '-')) if options[fit]
      end

      if (options.include?(:fit_in) || options.include?(:full_fit_in)) && !(options.include?(:width) || options.include?(:height))
        raise ArgumentError, 'When using fit-in or full-fit-in, you must specify width and/or height.'
      end

      calculate_width_and_height(url_parts, options)

      url_parts.push(options[:halign]) if options[:halign] && (options[:halign] != :center)

      url_parts.push(options[:valign]) if options[:valign] && (options[:valign] != :middle)

      url_parts.push('smart') if options[:smart]

      if options[:filters] && !options[:filters].empty?
        filter_parts = []
        options[:filters].each do |filter|
          filter_parts.push(filter)
        end

        url_parts.push("filters:#{filter_parts.join(':')}")
      end

      url_parts.join('/')
    end

    def url_safe_base64(str)
      Base64.encode64(str).gsub('+', '-').gsub('/', '_').gsub!(/\n/, '')
    end

    def generate(options)
      thumbor_path = []

      image_options = url_for(options)
      thumbor_path << "#{image_options}/" unless image_options.empty?

      thumbor_path << options[:image]

      if @key.nil?
        thumbor_path.insert(0, '/unsafe/')
      else
        signature = url_safe_base64(OpenSSL::HMAC.digest('sha1', @key, thumbor_path.join))
        thumbor_path.insert(0, "/#{signature}/")
      end
      thumbor_path.join
    end
  end
end
