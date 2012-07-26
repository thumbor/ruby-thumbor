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

        @@key = nil
        def self.key= key
          @@key = key
        end

        def initialize(key = nil)
            @key          = (key or @@key) 
            @computed_key = (@key * 16)[0..15]
            @url_parts    = {}
            @image        = ''
        end

        def image image_option
          @image                  = image_option
          @url_parts[:image_hash] = Digest::MD5.hexdigest(image_option)
          self
        end

        def meta
          @url_parts[:meta] = 'meta'
          self
        end

        def fit_in
          @url_parts[:fit_in] = 'fit-in'
          self
        end

        def crop crop_options
          if crop_options and crop_options.length == 4 and crop_options.reduce(:+).nonzero?
            crop_left, crop_top, crop_right, crop_bottom = crop_options
            @url_parts[:crop] = "#{crop_left}x#{crop_top}:#{crop_right}x#{crop_bottom}"
          end
          self
        end

        def size options
          return unless (options.keys & [:width, :height, :flip, :flop]).any?

          options               = {:width => 0, :height => 0}.merge(options)
          width, height         = options[:width].to_s, options[:height].to_s
          has_width, has_height = width.to_i.nonzero?, height.to_i.nonzero?

          width  = width.insert  0, '-' if options[:flip]
          height = height.insert 0, '-' if options[:flop]

          @url_parts[:size] = "#{width}x#{height}"
          self
        end

        def halign alignment
          @url_parts[:halign] = alignment if [:left, :right].include? alignment
          self
        end

        def valign alignment
          @url_parts[:valign] = alignment if [:top, :bottom].include? alignment
          self
        end

        def smart
          @url_parts[:smart] = 'smart'
          self
        end

        def filters filter_options
          @url_parts[:filters] = "filters:#{ filter_options.join(':') }" if filter_options and filter_options.any?
          self
        end

        def url_for(options, include_hash = true)
            raise ArgumentError.new('image is a required argument.') if not options[:image]

            #reading options
            meta    if options[:meta]
            fit_in  if options[:fit_in]
            smart   if options[:smart]
            crop(options[:crop])
            size(options)
            halign(options[:halign])
            valign(options[:valign])
            filters options[:filters]
            image(options[:image])

            to_s include_hash
        end

        def to_s image_hash = true
          raise 'image is required, try call method image before it' if @image.empty?

          #ordering url parts
          ordered_pieces =  [:meta, :fit_in, :crop, :size, :halign,
                            :valign, :smart, :filters]

          ordered_pieces << :image_hash if image_hash

          ordered_pieces.map {|piece| @url_parts[piece] }.reject(&:nil?).join('/')
        end

        def encrypt old = false
          return encrypt_old if old

          url         = "#{to_s(false)}/#{@image}"
          signature   = OpenSSL::HMAC.digest('sha1', @key, url)
          signature   = url_safe_base64(signature)

          "/#{signature}/#{url}"
        end

        def encrypt_old
          url         =  pad(to_s)
          cipher      = OpenSSL::Cipher::AES128.new(:ECB).encrypt
          cipher.key  = @computed_key
          encrypted   = cipher.update(url)
          based       = url_safe_base64(encrypted)

          "/#{based}/#{@image}"
        end

        def generate_old(options)
            url_for options
            encrypt_old
        end

        def generate_new(options)
            url_for options
            encrypt
        end

        def generate(options)
            return generate_old(options) if options[:old]
            generate_new(options)
        end

        private
        def url_safe_base64(str)
            Base64.encode64(str).tr('+/', '-_').delete "\n"
        end

        def pad(s)
            s + ("{" * (16 - s.length % 16))
        end
    end
end
