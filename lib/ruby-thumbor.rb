$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'openssl'
require 'base64'
require 'digest/md5'

module Thumbor
    VERSION = '0.0.1'

    class CryptoURL
        attr_accessor :key

        def initialize(key)
            @key = (key * 16)[0..16]
        end

        def pad(s)
            s + ("{" * (16 - s.length % 16))
        end

        def generate(options)
            image_hash = Digest::MD5.hexdigest(options[:image])
            url = pad(options[:width].to_s << 'x' << options[:height].to_s << '/' << image_hash)
            cipher = OpenSSL::Cipher::Cipher.new('aes-128-ecb').encrypt
            cipher.key = @key
            encrypted = cipher.update(url)
            based = Base64.encode64(encrypted).gsub('+', '-').gsub('/', '_').gsub!(/[\n]/, '')

            '/' << based << '/' << options[:image]
        end
    end

end
