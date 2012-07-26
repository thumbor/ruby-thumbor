$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'openssl'
require 'base64'
require 'digest/md5'
require 'cgi'

module Thumbor
    VERSION = '1.0.0'

    class CryptoURL
        attr_accessor :key, :computed_key

        def initialize(key)
            @key = key
            @computed_key = (key * 16)[0..15]
        end

        def pad(s)
            s + ("{" * (16 - s.length % 16))
        end

        def url_for(options, include_hash = true)
            raise ArgumentError.new('image is a required argument.') if not options[:image]

            url_parts = []

            url_parts << 'meta'   if options[:meta]
            url_parts << 'fit-in' if options[:fit_in]

            url_parts << options_for_crop(options)
            url_parts << options_for_width_and_height(options)

            url_parts << options[:halign] if [:left, :right].include? options[:halign]
            url_parts << options[:valign] if [:top, :bottom].include? options[:valign]

            url_parts << 'smart' if options[:smart]

            url_parts << options_for_filters(options)

            url_parts << Digest::MD5.hexdigest(options[:image]) if include_hash

            url_parts.reject(&:nil?).join('/')
        end

        def url_safe_base64(str)
            Base64.encode64(str).tr('+/', '-_').delete "\n"
        end

        def generate_old(options)
            url         = pad(url_for(options))
            cipher      = OpenSSL::Cipher::AES128.new(:ECB).encrypt
            cipher.key  = @computed_key
            encrypted   = cipher.update(url)
            based       = url_safe_base64(encrypted)

            "/#{based}/#{options[:image]}"
        end

        def generate_new(options)
            url_options = url_for(options, false)
            url         = "#{url_options}/#{options[:image]}"

            signature   = OpenSSL::HMAC.digest('sha1', @key, url)
            signature   = url_safe_base64(signature)

            "/#{signature}/#{url}"
        end

        def generate(options)
            return generate_old(options) if options[:old]
            generate_new(options)
        end

        private
        def options_for_crop(options)
          options = options[:crop]

          if options and options.length == 4 and options.reduce(:+).nonzero?
            crop_left, crop_top, crop_right, crop_bottom = options
            "#{crop_left}x#{crop_top}:#{crop_right}x#{crop_bottom}"
          end
        end

        def options_for_width_and_height(options)
          return unless (options.keys & [:width, :height, :flip, :flop]).any?

          options               = {:width => 0, :height => 0}.merge(options)
          width, height         = options[:width].to_s, options[:height].to_s
          has_width, has_height = width.to_i.nonzero?, height.to_i.nonzero?

          width  = width.insert  0, '-' if options[:flip]
          height = height.insert 0, '-' if options[:flop]

          "#{width}x#{height}"
        end

        def options_for_filters(options)
          if options[:filters] and options[:filters].any?
            "filters:#{ options[:filters].join(':') }"
          end
        end
    end
end
