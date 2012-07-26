require 'openssl'
require 'base64'

module Thumbor
  module Crypto
    def encrypt old = false
      return encrypt_old if old

      url         = "#{plain}/#{@image}"
      signature   = OpenSSL::HMAC.digest('sha1', @key, url)
      signature   = url_safe_base64(signature)

      "/#{signature}/#{url}"
    end

    def encrypt_old
      url         = pad(plain)
      cipher      = OpenSSL::Cipher::AES128.new(:ECB).encrypt
      cipher.key  = @computed_key
      encrypted   = cipher.update(url)
      based       = url_safe_base64(encrypted)

      "/#{based}/#{@image}"
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
