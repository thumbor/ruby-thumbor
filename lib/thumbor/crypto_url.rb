require 'openssl'
require 'base64'
require 'digest/md5'
require 'cgi'

module Thumbor
    class CryptoURL
        attr_accessor :computed_key

        def initialize(key)
            Thumbor.key = key
            @computed_key = (Thumbor.key * 16)[0..15]
        end

        def pad(s)
            s + ("{" * (16 - s.length % 16))
        end

        def calculate_width_and_height(url_parts, options)
            width = options[:width]
            height = options[:height]

            if width and options[:flip]
                width = width * -1
            end
            if height and options[:flop]
                height = height * -1
            end

            if width or height
                width = 0 if not width
                height = 0 if not height
            end

            has_width = width
            has_height = height
            if options[:flip] and not has_width and not has_height
                width = "-0"
                height = '0' if not has_height and not options[:flop]
            end
            if options[:flop] and not has_width and not has_height
                height = "-0"
                width = '0' if not has_width and not options[:flip]
            end

            if width or height
                width = width.to_s
                height = height.to_s
                url_parts.push(width << 'x' << height)
            end
        end

        def url_for(options, include_hash = true)
            if not options[:image]
                raise 'image is a required argument.'
            end

            url_parts = Array.new

            if options[:meta]
                url_parts.push('meta')
            end

            crop = options[:crop]
            if crop
                crop_left = crop[0]
                crop_top = crop[1]
                crop_right = crop[2]
                crop_bottom = crop[3]

                if crop_left > 0 or crop_top > 0 or crop_bottom > 0 or crop_right > 0
                    url_parts.push(crop_left.to_s << 'x' << crop_top.to_s << ':' << crop_right.to_s << 'x' << crop_bottom.to_s)
                end
            end

            if options[:fit_in]
                url_parts.push('fit-in')
            end

            calculate_width_and_height(url_parts, options)

            if options[:halign] and options[:halign] != :center
                url_parts.push(options[:halign])
            end

            if options[:valign] and options[:valign] != :middle
                url_parts.push(options[:valign])
            end

            if options[:smart]
                url_parts.push('smart')
            end

            if options[:trim]
                trim_options  = ['trim']
                trim_options << options[:trim] unless options[:trim] == true or options[:trim][0] == true
                url_parts.push(trim_options.join(':'))
            end

            if options[:filters] && !options[:filters].empty?
              filter_parts = []
              options[:filters].each do |filter|
                filter_parts.push(filter)
              end

              url_parts.push("filters:#{ filter_parts.join(':') }")
            end

            if include_hash
                image_hash = Digest::MD5.hexdigest(options[:image])
                url_parts.push(image_hash)
            end

            return url_parts.join('/')
        end

        def url_safe_base64(str)
            Base64.encode64(str).gsub('+', '-').gsub('/', '_').gsub!(/[\n]/, '')
        end

        def generate_old(options)
            url = pad(url_for(options))
            cipher = OpenSSL::Cipher::Cipher.new('aes-128-ecb').encrypt
            cipher.key = @computed_key
            encrypted = cipher.update(url)
            based = url_safe_base64(encrypted)

            "/#{based}/#{options[:image]}"
        end

        def generate_new(options)
            url_options = url_for(options, false)
            url = "#{url_options}/#{options[:image]}"

            signature = OpenSSL::HMAC.digest('sha1', Thumbor.key, url)
            signature = url_safe_base64(signature)

            "/#{signature}/#{url}"
        end

        def generate(options)
            return generate_old(options) if options[:old]
            generate_new(options)
        end
    end
end