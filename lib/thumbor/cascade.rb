require 'forwardable'
require 'openssl'
require 'base64'
require 'digest/md5'
require 'cgi'

module Thumbor
  class Cascade
    attr_accessor :image, :old_crypto, :options, :filters

    extend Forwardable

    def_delegators :@old_crypto, :computed_key

    def initialize(image=nil)
      @image = image
      @options = {}
      @filters = []
      @old_crypto = Thumbor::CryptoURL.new Thumbor.key
    end

    def url_for
      @old_crypto.url_for prepare_options(@options).merge({:image => @image, :filters => @filters})
    end

    def generate
      @old_crypto.generate prepare_options(@options).merge({:image => @image, :filters => @filters})
    end

    def method_missing(m, *args)
      if /^(.+)_filter$/.match(m.to_s)
        @filters << "#{$1}(#{args[0]})"
      else
        @options[m] = args
      end
      self
    end

    private

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