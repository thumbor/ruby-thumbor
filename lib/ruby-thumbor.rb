require 'thumbor/crypto_url'
require 'thumbor/cascade'

module Thumbor
  def self.key=(key)
    @@key = key
  end

  def self.key
    @@key
  end
end

