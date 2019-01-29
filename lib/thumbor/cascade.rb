require 'forwardable'
require 'openssl'
require 'base64'
require 'digest/md5'
require 'cgi'

module Thumbor
  class Cascade
    attr_accessor :image, :crypto, :options, :filters

    @available_options = [
      :meta, :crop, :center,
      :original_width, :original_height,
      :width, :height, :flip,
      :flop, :halign, :valign,
      :smart, :fit_in, :adaptive_fit_in,
      :full_fit_in, :adaptive_full_fit_in,
      :trim, :debug]

    extend Forwardable

    def_delegators :@crypto, :computed_key

    @available_options.each do |opt|
      define_method(opt) do |*args|
        args = [true] if args.empty?
        @options[opt] = args
        self
      end
    end

    def initialize(key=false, image=nil)
      @key = key
      @image = image
      @options = {}
      @filters = []
      @crypto = Thumbor::CryptoURL.new @key
    end

    def generate
      @crypto.generate prepare_options(@options).merge({image: @image, filters: @filters})
    end

    def method_missing(m, *args)
      if /^(.+)_filter$/.match(m.to_s)
        @filters << "#{$1}(#{escape_args(args).join(',')})"
        self
      else
        super
      end
    end

    private

    def escape_args(args)
      args.map do |arg|
        arg = CGI::escape(arg) if arg.is_a? String and arg.match(/^https?:\/\//)
        arg
      end
    end

    def prepare_options(options)
      options.reduce({}) do |final_options, item|
        value = if item[1].length == 1
          item[1].first
        else
          item[1]
        end
        final_options[item[0]] = value
        final_options
      end
    end
  end
end
