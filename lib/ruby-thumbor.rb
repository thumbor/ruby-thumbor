require 'thumbor/crypto_url'
require 'thumbor/cascade'

module Thumbor
  @@key = nil

  def self.key=(key)
    @@key = key
  end

  def self.key
    @@key
  end
end

