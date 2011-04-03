require File.dirname(__FILE__) + '/spec_helper.rb'

image_url = 'my.domain.com/some/image/url.jpg'
image_md5 = 'f33af67e41168e80fcc5b00f8bd8061a'
key = 'my-security-key'

describe Thumbor::CryptoURL, "#new" do

    it "should create a new instance passing key and keep it" do
        crypto = Thumbor::CryptoURL.new key
        crypto.key.should == 'my-security-keymy'
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
end

describe Thumbor::CryptoURL, "#generate" do

    it "should create a new instance passing key and keep it" do
        crypto = Thumbor::CryptoURL.new key

        url = crypto.generate :width => 300, :height => 200, :image => image_url

        url.should == '/qkLDiIbvtiks0Up9n5PACtmpOfX6dPXw4vP4kJU-jTfyF6y1GJBJyp7CHYh1H3R2/' << image_url
    end

end
