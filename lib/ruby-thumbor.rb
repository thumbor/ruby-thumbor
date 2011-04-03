$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'openssl'
require 'base64'
require 'digest/md5'

module Thumbor
    VERSION = '0.0.2'

    class CryptoURL
        attr_accessor :key

        def initialize(key)
            @key = (key * 16)[0..16]
        end

        def pad(s)
            s + ("{" * (16 - s.length % 16))
        end

        def url_for(options)
            if not options[:image]
                raise 'image is a required argument.'
            end

            url_parts = Array.new

            if options[:width] and options[:height]
                url_parts.push(options[:width].to_s << 'x' << options[:height].to_s)
            else
                if options[:width]
                    url_parts.push(options[:width].to_s << 'x0')
                end
                if options[:height]
                    url_parts.push('0x' << options[:height].to_s)
                end
            end

            if options[:smart]
                url_parts.push('smart')
            end

            image_hash = Digest::MD5.hexdigest(options[:image])
            url_parts.push(image_hash)

            return url_parts.join('/')
        end

        def url_safe_base64(str)
            Base64.encode64(str).gsub('+', '-').gsub('/', '_').gsub!(/[\n]/, '')
        end

        def generate(options)
            url = pad(url_for(options))
            cipher = OpenSSL::Cipher::Cipher.new('aes-128-ecb').encrypt
            cipher.key = @key
            encrypted = cipher.update(url)
            based = url_safe_base64(encrypted)

            '/' << based << '/' << options[:image]
        end
    end

end
