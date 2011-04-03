$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

module RubyThumbor
  VERSION = '0.0.1'
end

class CryptoURL
    attr_accessor :key

    def initialize(key)
        @key = key
    end

end
