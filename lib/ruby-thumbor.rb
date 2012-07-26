$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'ruby-thumbor/cascade'
require 'ruby-thumbor/crypto'

module Thumbor
    VERSION = '1.0.0'

    class CryptoURL
        include Cascade
        include Crypto

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
            @image_hash   = false
        end

        def << options
          image_hash  if options[:hash]
          meta        if options[:meta]
          fit_in      if options[:fit_in]
          smart       if options[:smart]
          crop(options[:crop])
          size(options)
          halign(options[:halign])
          valign(options[:valign])
          filters options[:filters]
          image(options[:image])
        end

        def url_for(options, include_hash = true)
            raise ArgumentError.new('image is a required argument.') unless options[:image] or not @image.empty?

            options[:hash] = include_hash

            self << options

            plain
        end

        def plain
          raise 'image is required, try call method image before it' if @image.empty?

          #ordering url parts
          ordered_pieces =  [:meta, :fit_in, :crop, :size, :halign,
                            :valign, :smart, :filters]

          ordered_pieces << :image_hash if @image_hash

          ordered_pieces.map {|piece| @url_parts[piece] }.reject(&:nil?).join('/')
        end

        def to_s old = false
          encrypt old
        end

        def generate_old(options)
            url_for options
            encrypt_old
        end

        def generate_new(options)
            url_for options, false
            encrypt
        end

        def generate(options)
            return generate_old(options) if options[:old]
            generate_new(options)
        end
    end
end
