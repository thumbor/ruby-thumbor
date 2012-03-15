require File.dirname(__FILE__) + '/spec_helper.rb'
require 'json'

image_url = 'my.domain.com/some/image/url.jpg'
image_md5 = 'f33af67e41168e80fcc5b00f8bd8061a'
key = 'my-security-key'

def decrypt_in_thumbor(str)
    command = "python -c 'from thumbor.crypto import Crypto; cr = Crypto(\"my-security-keymy\"); print cr.decrypt(\"" << str << "\")'"
    result = Array.new
    IO.popen(command) { |f| result.push(f.gets) } 
    result = result.join('').strip
    JSON.parse(result.gsub('"', "@@@").gsub("'", '"').gsub("@@@", '\\"').gsub('True', 'true').gsub('False', 'false'))
end

describe Thumbor::CryptoURL, "#new" do

    it "should create a new instance passing key and keep it" do
        crypto = Thumbor::CryptoURL.new key
        crypto.key.should == 'my-security-keym'
    end

end

describe Thumbor::CryptoURL, "#url_for" do
    it "should return just the image hash if no arguments passed" do
        crypto = Thumbor::CryptoURL.new key

        url = crypto.url_for :image => image_url

        url.should == image_md5
    end

    it "should raise if no image passed" do
        crypto = Thumbor::CryptoURL.new key

        expect { crypto.url_for Hash.new }.to raise_error(RuntimeError)
    end

    it "should return proper url for width-only" do
        crypto = Thumbor::CryptoURL.new key

        url = crypto.url_for :image => image_url, :width => 300

        url.should == '300x0/' << image_md5
    end

    it "should return proper url for height-only" do
        crypto = Thumbor::CryptoURL.new key

        url = crypto.url_for :image => image_url, :height => 300

        url.should == '0x300/' << image_md5
    end

    it "should return proper url for width and height" do
        crypto = Thumbor::CryptoURL.new key

        url = crypto.url_for :image => image_url, :width => 200, :height => 300

        url.should == '200x300/' << image_md5
    end

    it "should return proper smart url" do
        crypto = Thumbor::CryptoURL.new key

        url = crypto.url_for :image => image_url, :width => 200, :height => 300, :smart => true

        url.should == '200x300/smart/' << image_md5
    end

    it "should return proper fit-in url" do
        crypto = Thumbor::CryptoURL.new key

        url = crypto.url_for :image => image_url, :width => 200, :height => 300, :fit_in => true

        url.should == 'fit-in/200x300/' << image_md5
    end

    it "should return proper flip url if no width and height" do
        crypto = Thumbor::CryptoURL.new key

        url = crypto.url_for :image => image_url, :flip => true

        url.should == '-0x0/' << image_md5
    end

    it "should return proper flop url if no width and height" do
        crypto = Thumbor::CryptoURL.new key

        url = crypto.url_for :image => image_url, :flop => true

        url.should == '0x-0/' << image_md5
    end

    it "should return proper flip-flop url if no width and height" do
        crypto = Thumbor::CryptoURL.new key

        url = crypto.url_for :image => image_url, :flip => true, :flop => true

        url.should == '-0x-0/' << image_md5
    end

    it "should return proper flip url if width" do
        crypto = Thumbor::CryptoURL.new key

        url = crypto.url_for :image => image_url, :width => 300, :flip => true

        url.should == '-300x0/' << image_md5
    end

    it "should return proper flop url if height" do
        crypto = Thumbor::CryptoURL.new key

        url = crypto.url_for :image => image_url, :height => 300, :flop => true

        url.should == '0x-300/' << image_md5
    end

    it "should return horizontal align" do
        crypto = Thumbor::CryptoURL.new key

        url = crypto.url_for :image => image_url, :halign => :left

        url.should == 'left/' << image_md5
    end

    it "should not return horizontal align if it is center" do
        crypto = Thumbor::CryptoURL.new key

        url = crypto.url_for :image => image_url, :halign => :center

        url.should == image_md5
    end

    it "should return vertical align" do
        crypto = Thumbor::CryptoURL.new key

        url = crypto.url_for :image => image_url, :valign => :top

        url.should == 'top/' << image_md5
    end

    it "should not return vertical align if it is middle" do
        crypto = Thumbor::CryptoURL.new key

        url = crypto.url_for :image => image_url, :valign => :middle

        url.should == image_md5
    end

    it "should return halign and valign properly" do
        crypto = Thumbor::CryptoURL.new key

        url = crypto.url_for :image => image_url, :halign => :left, :valign => :top

        url.should == 'left/top/' << image_md5
    end

    it "should return meta properly" do
        crypto = Thumbor::CryptoURL.new key

        url = crypto.url_for :image => image_url, :meta => true

        url.should == 'meta/' << image_md5
    end

    it "should return proper crop url" do
        crypto = Thumbor::CryptoURL.new key

        url = crypto.url_for :image => image_url, :crop => [10, 20, 30, 40]

        url.should == '10x20:30x40/' << image_md5
    end

    it "should ignore crop if all zeros" do
        crypto = Thumbor::CryptoURL.new key

        url = crypto.url_for :image => image_url, :crop => [0, 0, 0, 0]

        url.should == image_md5
    end

    it "should have smart after halign and valign" do
        crypto = Thumbor::CryptoURL.new key

        url = crypto.url_for :image => image_url, :halign => :left, :valign => :top, :smart => true

        url.should == 'left/top/smart/' << image_md5
    end

end

describe Thumbor::CryptoURL, "#generate" do

    it "should create a new instance passing key and keep it" do
        crypto = Thumbor::CryptoURL.new key

        url = crypto.generate :width => 300, :height => 200, :image => image_url

        url.should == '/qkLDiIbvtiks0Up9n5PACtmpOfX6dPXw4vP4kJU-jTfyF6y1GJBJyp7CHYh1H3R2/' << image_url
    end

    it "should allow thumbor to decrypt it properly" do
        crypto = Thumbor::CryptoURL.new key

        url = crypto.generate :width => 300, :height => 200, :image => image_url

        encrypted = url.split('/')[1]

        decrypted = decrypt_in_thumbor(encrypted)

        decrypted["horizontal_flip"].should == false
        decrypted["vertical_flip"].should == false
        decrypted["smart"].should == false
        decrypted["meta"].should == false
        decrypted["fit_in"].should == false
        decrypted["crop"]["left"].should == 0
        decrypted["crop"]["top"].should == 0
        decrypted["crop"]["right"].should == 0
        decrypted["crop"]["bottom"].should == 0
        decrypted["valign"].should == 'middle'
        decrypted["halign"].should == 'center'
        decrypted["image_hash"].should == image_md5
        decrypted["width"].should == 300
        decrypted["height"].should == 200

    end

    it "should allow thumbor to decrypt it properly with meta" do
        crypto = Thumbor::CryptoURL.new key

        url = crypto.generate :width => 300, :height => 200, :meta => true, :image => image_url

        encrypted = url.split('/')[1]

        decrypted = decrypt_in_thumbor(encrypted)

        decrypted["meta"].should == true
        decrypted["image_hash"].should == image_md5
        decrypted["width"].should == 300
        decrypted["height"].should == 200

    end

    it "should allow thumbor to decrypt it properly with smart" do
        crypto = Thumbor::CryptoURL.new key

        url = crypto.generate :width => 300, :height => 200, :meta => true, :image => image_url, :smart => true

        encrypted = url.split('/')[1]

        decrypted = decrypt_in_thumbor(encrypted)

        decrypted["meta"].should == true
        decrypted["smart"].should == true
        decrypted["image_hash"].should == image_md5
        decrypted["width"].should == 300
        decrypted["height"].should == 200

    end

    it "should allow thumbor to decrypt it properly with fit-in" do

        crypto = Thumbor::CryptoURL.new key

        url = crypto.generate :width => 300, :height => 200, :fit_in => true, :image => image_url

        encrypted = url.split('/')[1]

        decrypted = decrypt_in_thumbor(encrypted)

        decrypted["fit_in"].should == true
        decrypted["image_hash"].should == image_md5
        decrypted["width"].should == 300
        decrypted["height"].should == 200

    end

    it "should allow thumbor to decrypt it properly with flip" do
        crypto = Thumbor::CryptoURL.new key

        url = crypto.generate :width => 300, :height => 200, :meta => true, :image => image_url, :smart => true, :flip => true

        encrypted = url.split('/')[1]

        decrypted = decrypt_in_thumbor(encrypted)

        decrypted["meta"].should == true
        decrypted["smart"].should == true
        decrypted["image_hash"].should == image_md5
        decrypted["width"].should == 300
        decrypted["height"].should == 200
        decrypted["flip_horizontally"] == true

    end

    it "should allow thumbor to decrypt it properly with flop" do
        crypto = Thumbor::CryptoURL.new key

        url = crypto.generate :width => 300, :height => 200, :meta => true, :image => image_url, :smart => true, :flip => true, :flop => true

        encrypted = url.split('/')[1]

        decrypted = decrypt_in_thumbor(encrypted)

        decrypted["meta"].should == true
        decrypted["smart"].should == true
        decrypted["image_hash"].should == image_md5
        decrypted["width"].should == 300
        decrypted["height"].should == 200
        decrypted["flip_horizontally"] == true
        decrypted["flip_vertically"] == true

    end

    it "should allow thumbor to decrypt it properly with halign" do
        crypto = Thumbor::CryptoURL.new key

        url = crypto.generate :width => 300, :height => 200, :meta => true, :image => image_url, :smart => true, :flip => true, :flop => true,
                              :halign => :left

        encrypted = url.split('/')[1]

        decrypted = decrypt_in_thumbor(encrypted)

        decrypted["meta"].should == true
        decrypted["smart"].should == true
        decrypted["image_hash"].should == image_md5
        decrypted["width"].should == 300
        decrypted["height"].should == 200
        decrypted["flip_horizontally"] == true
        decrypted["flip_vertically"] == true
        decrypted["halign"] == "left"

    end

    it "should allow thumbor to decrypt it properly with valign" do
        crypto = Thumbor::CryptoURL.new key

        url = crypto.generate :width => 300, :height => 200, :meta => true, :image => image_url, :smart => true, :flip => true, :flop => true,
                              :halign => :left, :valign => :top

        encrypted = url.split('/')[1]

        decrypted = decrypt_in_thumbor(encrypted)

        decrypted["meta"].should == true
        decrypted["smart"].should == true
        decrypted["image_hash"].should == image_md5
        decrypted["width"].should == 300
        decrypted["height"].should == 200
        decrypted["flip_horizontally"] == true
        decrypted["flip_vertically"] == true
        decrypted["halign"] == "left"
        decrypted["valign"] == "top"

    end

    it "should allow thumbor to decrypt it properly with cropping" do
        crypto = Thumbor::CryptoURL.new key

        url = crypto.generate :width => 300, :height => 200, :image => image_url, :crop => [10, 20, 30, 40]

        encrypted = url.split('/')[1]

        decrypted = decrypt_in_thumbor(encrypted)

        decrypted["horizontal_flip"].should == false
        decrypted["vertical_flip"].should == false
        decrypted["smart"].should == false
        decrypted["meta"].should == false
        decrypted["crop"]["left"].should == 10
        decrypted["crop"]["top"].should == 20
        decrypted["crop"]["right"].should == 30
        decrypted["crop"]["bottom"].should == 40
        decrypted["valign"].should == 'middle'
        decrypted["halign"].should == 'center'
        decrypted["image_hash"].should == image_md5
        decrypted["width"].should == 300
        decrypted["height"].should == 200

    end

    it "should allow thumbor to decrypt it properly with filters" do
        crypto = Thumbor::CryptoURL.new key

        url = crypto.generate :filters => ["quality(20)", "brightness(10)"], :image => image_url

        encrypted = url.split('/')[1]

        decrypted = decrypt_in_thumbor(encrypted)

        decrypted["filters"].should == "quality(20):brightness(10)"
    end


end
