require File.dirname(__FILE__) + '/spec_helper.rb'
require 'json'

image_url = 'my.domain.com/some/image/url.jpg'
image_md5 = 'f33af67e41168e80fcc5b00f8bd8061a'
key = 'my-security-key'

def decrypt_in_thumbor(str)
    command = "python -c 'from thumbor.crypto import Cryptor; cr = Cryptor(\"my-security-keymy\"); print cr.decrypt(\"" << str << "\")'"
    result = Array.new
    IO.popen(command) { |f| result.push(f.gets) } 
    result = result.join('').strip
    JSON.parse(result.gsub('"', "@@@").gsub("'", '"').gsub("@@@", '\\"').gsub('True', 'true').gsub('False', 'false'))
end

describe Thumbor::CryptoURL, "#new" do

    it "should create a new instance passing key and keep it" do
        crypto = Thumbor::CryptoURL.new key
        crypto.computed_key.should == 'my-security-keym'
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

        expect { crypto.url_for Hash.new }.to raise_error(ArgumentError)
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

    it "should ignore filters if empty" do
        crypto = Thumbor::CryptoURL.new key

        url = crypto.url_for :image => image_url, :filters => []

        url.should == image_md5
    end
end

describe Thumbor::CryptoURL, "#generate" do

    before :each do
        @crypto = Thumbor::CryptoURL.new key
    end

    it "should create a new instance passing key and keep it" do
        url = @crypto.generate :width => 300, :height => 200, :image => image_url

        url.should == '/TQfyd3H36Z3srcNcLOYiM05YNO8=/300x200/my.domain.com/some/image/url.jpg'
    end

    it "should create a new instance passing key and keep it" do
        url = @crypto.generate :width => 300, :height => 200, :meta => true, :image => image_url

        url.should == '/YBQEWd3g_WRMnVEG73zfzcr8Zj0=/meta/300x200/my.domain.com/some/image/url.jpg'
    end

    it "should create a new instance passing key and keep it" do
        url = @crypto.generate :width => 300, :height => 200, :meta => true, :image => image_url, :smart => true

        url.should == '/jP89J0qOWHgPlm_lOA28GtOh5GU=/meta/300x200/smart/my.domain.com/some/image/url.jpg'
    end

    it "should create a new instance passing key and keep it" do
        url = @crypto.generate :width => 300, :height => 200, :meta => true, :image => image_url, :smart => true, :fit_in => true

        url.should == '/zrrOh_TtTs4kiLLEQq1w4bcTYdc=/meta/fit-in/300x200/smart/my.domain.com/some/image/url.jpg'
    end

    it "should create a new instance passing key and keep it" do
        url = @crypto.generate :width => 300, :height => 200, :meta => true, :image => image_url, :smart => true, :fit_in => true, :flip => true

        url.should == '/4t1XK1KH43cOb1QJ9tU00-W2_k8=/meta/fit-in/-300x200/smart/my.domain.com/some/image/url.jpg'
    end

    it "should create a new instance passing key and keep it" do
        url = @crypto.generate :width => 300, :height => 200, :meta => true, :image => image_url, :smart => true, :fit_in => true, :flip => true, :flop => true

        url.should == '/HJnvjZU69PkPOhyZGu-Z3Uc_W_A=/meta/fit-in/-300x-200/smart/my.domain.com/some/image/url.jpg'
    end

    it "should create a new instance passing key and keep it" do
        url = @crypto.generate :filters => ["quality(20)", "brightness(10)"], :image => image_url

        url.should == '/q0DiFg-5-eFZIqyN3lRoCvg2K0s=/filters:quality(20):brightness(10)/my.domain.com/some/image/url.jpg'
    end

end

describe Thumbor::CryptoURL, "#generate :old => true" do

    before :each do
        @crypto = Thumbor::CryptoURL.new key
    end

    it "should create a new instance passing key and keep it" do
        url = @crypto.generate :width => 300, :height => 200, :image => image_url, :old => true

        url.should == '/qkLDiIbvtiks0Up9n5PACtmpOfX6dPXw4vP4kJU-jTfyF6y1GJBJyp7CHYh1H3R2/' << image_url
    end

    it "should allow thumbor to decrypt it properly" do
        url = @crypto.generate :width => 300, :height => 200, :image => image_url, :old => true

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
        url = @crypto.generate :width => 300, :height => 200, :meta => true, :image => image_url, :old => true

        encrypted = url.split('/')[1]

        decrypted = decrypt_in_thumbor(encrypted)

        decrypted["meta"].should == true
        decrypted["image_hash"].should == image_md5
        decrypted["width"].should == 300
        decrypted["height"].should == 200

    end

    it "should allow thumbor to decrypt it properly with smart" do
        url = @crypto.generate :width => 300, :height => 200, :meta => true, :image => image_url, :smart => true, :old => true

        encrypted = url.split('/')[1]

        decrypted = decrypt_in_thumbor(encrypted)

        decrypted["meta"].should == true
        decrypted["smart"].should == true
        decrypted["image_hash"].should == image_md5
        decrypted["width"].should == 300
        decrypted["height"].should == 200

    end

    it "should allow thumbor to decrypt it properly with fit-in" do
        url = @crypto.generate :width => 300, :height => 200, :fit_in => true, :image => image_url, :old => true

        encrypted = url.split('/')[1]

        decrypted = decrypt_in_thumbor(encrypted)

        decrypted["fit_in"].should == true
        decrypted["image_hash"].should == image_md5
        decrypted["width"].should == 300
        decrypted["height"].should == 200

    end

    it "should allow thumbor to decrypt it properly with flip" do
        url = @crypto.generate :width => 300, :height => 200, :meta => true, :image => image_url, :smart => true, :flip => true, :old => true

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
        url = @crypto.generate :width => 300, :height => 200, :meta => true, :image => image_url, :smart => true, :flip => true, :flop => true, :old => true

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
        url = @crypto.generate :width => 300, :height => 200, :meta => true, :image => image_url, :smart => true, :flip => true, :flop => true,
                              :halign => :left, :old => true

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
        url = @crypto.generate :width => 300, :height => 200, :meta => true, :image => image_url, :smart => true, :flip => true, :flop => true,
                              :halign => :left, :valign => :top, :old => true

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
        url = @crypto.generate :width => 300, :height => 200, :image => image_url, :crop => [10, 20, 30, 40], :old => true

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
        url = @crypto.generate :filters => ["quality(20)", "brightness(10)"], :image => image_url, :old => true

        encrypted = url.split('/')[1]

        decrypted = decrypt_in_thumbor(encrypted)

        decrypted["filters"].should == "quality(20):brightness(10)"
    end


end
