require File.dirname(__FILE__) + '/spec_helper.rb'
require 'json'

describe Thumbor::CryptoURL do 
  let(:image_url)     { 'my.domain.com/some/image/url.jpg' }
  let(:image_md5)     { 'f33af67e41168e80fcc5b00f8bd8061a' }
  let(:key)           { 'my-security-key' }
  let(:computed_key)  { 'my-security-keym' }

  before  { Thumbor::CryptoURL.key = key }
  subject { Thumbor::CryptoURL.new }

  describe "#new" do
    it "should create a new instance passing key and keep it" do
      subject.computed_key.should == computed_key
    end
  end

  describe "#url_for" do
    it "should return just the image hash if no arguments passed" do
      subject.url_for(:image => image_url).should == image_md5
    end

    it "should raise if no image passed" do
      expect { subject.url_for {} }.to raise_error(ArgumentError)
    end

    it "should return proper url for width-only" do
      subject.url_for(:image => image_url,
                      :width => 300).should == "300x0/#{image_md5}"
    end

    it "should return proper url for height-only" do
      subject.url_for(:image => image_url,
                      :height => 300).should == "0x300/#{image_md5}"
    end

    it "should return proper url for width and height" do
      subject.url_for(:image => image_url,
                      :width => 200,
                      :height => 300).should == "200x300/#{image_md5}"
    end

    it "should return proper smart url" do
      subject.url_for(:image => image_url,
                      :width => 200,
                      :height => 300,
                      :smart => true).should == "200x300/smart/#{image_md5}"
    end

    it "should return proper fit-in url" do
      subject.url_for(:image => image_url,
                      :width => 200,
                      :height => 300,
                      :fit_in => true).should == "fit-in/200x300/#{image_md5}"
    end

    it "should return proper flip url if no width and height" do
      subject.url_for(:image => image_url,
                      :flip => true).should == "-0x0/#{image_md5}"
    end

    it "should return proper flop url if no width and height" do
      subject.url_for(:image => image_url,
                      :flop => true).should == "0x-0/#{image_md5}"
    end

    it "should return proper flip-flop url if no width and height" do
      subject.url_for(:image => image_url,
                      :flip => true, :flop => true).should == "-0x-0/#{image_md5}"
    end

    it "should return proper flip url if width" do
      subject.url_for(:image => image_url,
                      :width => 300, :flip => true).should == "-300x0/#{image_md5}"
    end

    it "should return proper flop url if height" do
      subject.url_for(:image => image_url,
                      :height => 300,
                      :flop => true).should == "0x-300/#{image_md5}"
    end

    it "should return horizontal align" do
      subject.url_for(:image => image_url,
                      :halign => :left).should == "left/#{image_md5}"
    end

    it "should not return horizontal align if it is center" do
      subject.url_for(:image => image_url,
                      :halign => :center).should == image_md5
    end

    it "should return vertical align" do
      subject.url_for(:image => image_url,
                      :valign => :top).should == "top/#{image_md5}"
    end

    it "should not return vertical align if it is middle" do
      subject.url_for(:image => image_url,
                      :valign => :middle).should == image_md5
    end

    it "should return halign and valign properly" do
      subject.url_for(:image => image_url,
                     :halign => :left,
                     :valign => :top).should == "left/top/#{image_md5}"
    end

    it "should return meta properly" do
      subject.url_for(:image => image_url,
                      :meta => true).should == "meta/#{image_md5}"
    end

    it "should return proper crop url" do
      subject.url_for(:image => image_url,
                      :crop => [10, 20, 30, 40]).should == "10x20:30x40/#{image_md5}"
    end

    it "should ignore crop if all zeros" do
      subject.url_for(:image => image_url,
                      :crop => [0, 0, 0, 0]).should == image_md5
    end

    it "should have smart after halign and valign" do
      subject.url_for(:image => image_url,
                      :halign => :left,
                      :valign => :top,
                      :smart => true).should == "left/top/smart/#{image_md5}"
    end

    it "should ignore filters if empty" do
      subject.url_for(:image => image_url, :filters => []).should == image_md5
    end
  end

  describe 'cascade methods' do
    before { subject.image(image_url) }

    describe 'when I define the size' do
      before { subject.size(:width => 300, :height => 200) }

      it "should create a new instance passing key and keep it" do
        subject.encrypt.to_s.should == '/TQfyd3H36Z3srcNcLOYiM05YNO8=/300x200/my.domain.com/some/image/url.jpg'
      end

      it "should create a new instance passing key and keep it" do
        subject.meta.encrypt.to_s.should == '/YBQEWd3g_WRMnVEG73zfzcr8Zj0=/meta/300x200/my.domain.com/some/image/url.jpg'
      end

      it "should create a new instance passing key and keep it" do
        subject.meta.smart.encrypt.to_s.should == '/jP89J0qOWHgPlm_lOA28GtOh5GU=/meta/300x200/smart/my.domain.com/some/image/url.jpg'
      end

      it "should create a new instance passing key and keep it" do
        subject.meta.smart.fit_in.encrypt.to_s.should == '/zrrOh_TtTs4kiLLEQq1w4bcTYdc=/meta/fit-in/300x200/smart/my.domain.com/some/image/url.jpg'
      end

      it "should create a new instance passing key and keep it" do
        url = subject.size(:width => 300, :height => 200, :flip => true).meta.smart.fit_in.encrypt
        url.to_s.should == '/4t1XK1KH43cOb1QJ9tU00-W2_k8=/meta/fit-in/-300x200/smart/my.domain.com/some/image/url.jpg'
      end
    end

    it "should create a new instance passing key and keep it" do
      url = subject.filters(["quality(20)", "brightness(10)"]).encrypt
      url.to_s.should == '/q0DiFg-5-eFZIqyN3lRoCvg2K0s=/filters:quality(20):brightness(10)/my.domain.com/some/image/url.jpg'
    end
  end

  describe "#generate" do

    it "should create a new instance passing key and keep it" do
      url = subject.generate :width => 300, :height => 200, :image => image_url

      url.should == '/TQfyd3H36Z3srcNcLOYiM05YNO8=/300x200/my.domain.com/some/image/url.jpg'
    end

    it "should create a new instance passing key and keep it" do
      url = subject.generate :width => 300, :height => 200, :meta => true, :image => image_url

      url.should == '/YBQEWd3g_WRMnVEG73zfzcr8Zj0=/meta/300x200/my.domain.com/some/image/url.jpg'
    end

    it "should create a new instance passing key and keep it" do
      url = subject.generate  :width => 300, :height => 200, :meta => true,
                              :image => image_url, :smart => true

      url.should == '/jP89J0qOWHgPlm_lOA28GtOh5GU=/meta/300x200/smart/my.domain.com/some/image/url.jpg'
    end

    it "should create a new instance passing key and keep it" do
      url = subject.generate  :width => 300, :height => 200, :meta => true, :image => image_url,
                              :smart => true, :fit_in => true

      url.should == '/zrrOh_TtTs4kiLLEQq1w4bcTYdc=/meta/fit-in/300x200/smart/my.domain.com/some/image/url.jpg'
    end

    it "should create a new instance passing key and keep it" do
      url = subject.generate  :width => 300, :height => 200, :meta => true, :image => image_url,
                              :smart => true, :fit_in => true, :flip => true

      url.should == '/4t1XK1KH43cOb1QJ9tU00-W2_k8=/meta/fit-in/-300x200/smart/my.domain.com/some/image/url.jpg'
    end

    it "should create a new instance passing key and keep it" do
      url = subject.generate  :width => 300, :height => 200, :meta => true, :image => image_url,
                              :smart => true, :fit_in => true, :flip => true, :flop => true

      url.should == '/HJnvjZU69PkPOhyZGu-Z3Uc_W_A=/meta/fit-in/-300x-200/smart/my.domain.com/some/image/url.jpg'
    end

    it "should create a new instance passing key and keep it" do
      url = subject.generate :filters => ["quality(20)", "brightness(10)"], :image => image_url

      url.should == '/q0DiFg-5-eFZIqyN3lRoCvg2K0s=/filters:quality(20):brightness(10)/my.domain.com/some/image/url.jpg'
    end
  end

  describe "#generate :old => true" do
    #helpers
    def decrypt_in_thumbor(str)
      result = %x[python -c 'from thumbor.crypto import Cryptor; cr = Cryptor("my-security-keymy"); print cr.decrypt("#{str}")']

      JSON.parse(result.gsub('"',     "@@@").
                        gsub("'",     '"').
                        gsub("@@@",   '\\"').
                        gsub('True',  'true').
                        gsub('False', 'false'))
    end

    def generate_and_decrypt options
      url = subject.generate options
      decrypt_in_thumbor url.split('/')[1]
    end

    it "should create a new instance passing key and keep it" do
      url = subject.generate :width => 300, :height => 200, :image => image_url, :old => true

      url.should == '/qkLDiIbvtiks0Up9n5PACtmpOfX6dPXw4vP4kJU-jTfyF6y1GJBJyp7CHYh1H3R2/' << image_url
    end

    it "should allow thumbor to decrypt it properly" do
      decrypted = generate_and_decrypt :width => 300, :height => 200, :image => image_url, :old => true

      decrypted["horizontal_flip"].should be_false
      decrypted["vertical_flip"].should   be_false
      decrypted["smart"].should           be_false
      decrypted["meta"].should            be_false
      decrypted["fit_in"].should          be_false
      decrypted["crop"]["left"].should    be_zero
      decrypted["crop"]["top"].should     be_zero
      decrypted["crop"]["right"].should   be_zero
      decrypted["crop"]["bottom"].should  be_zero
      decrypted["valign"].should          == 'middle'
      decrypted["halign"].should          == 'center'
      decrypted["image_hash"].should      == image_md5
      decrypted["width"].should           == 300
      decrypted["height"].should          == 200
    end

    it "should allow thumbor to decrypt it properly with meta" do
      decrypted = generate_and_decrypt :width => 300, :height => 200,
                                        :meta => true, :image => image_url,
                                        :old => true

      decrypted["meta"].should        be_true
      decrypted["image_hash"].should  == image_md5
      decrypted["width"].should       == 300
      decrypted["height"].should      == 200
    end

    it "should allow thumbor to decrypt it properly with smart" do
      decrypted = generate_and_decrypt  :width => 300, :height => 200, :meta => true,
                                        :image => image_url, :smart => true, :old => true

      decrypted["meta"].should        be_true
      decrypted["smart"].should       be_true
      decrypted["image_hash"].should  == image_md5
      decrypted["width"].should       == 300
      decrypted["height"].should      == 200

    end

    it "should allow thumbor to decrypt it properly with fit-in" do
      decrypted = generate_and_decrypt  :width => 300, :height => 200, :fit_in => true,
                                        :image => image_url, :old => true

      decrypted["fit_in"].should      be_true
      decrypted["image_hash"].should  == image_md5
      decrypted["width"].should       == 300
      decrypted["height"].should      == 200
    end

    it "should allow thumbor to decrypt it properly with flip" do
      decrypted = generate_and_decrypt  :width => 300, :height => 200, :meta => true,
                                        :image => image_url, :smart => true,
                                        :flip => true, :old => true

      decrypted["meta"].should              be_true
      decrypted["smart"].should             be_true
      decrypted["image_hash"].should        == image_md5
      decrypted["width"].should             == 300
      decrypted["height"].should            == 200
      decrypted["horizontal_flip"].should   be_true
    end

    it "should allow thumbor to decrypt it properly with flop" do
      decrypted = generate_and_decrypt  :width => 300, :height => 200, :meta => true,
                                        :image => image_url, :smart => true,
                                        :flip => true, :flop => true, :old => true

      decrypted["meta"].should                be_true
      decrypted["smart"].should               be_true
      decrypted["image_hash"].should          == image_md5
      decrypted["width"].should               == 300
      decrypted["height"].should              == 200
      decrypted["horizontal_flip"].should     be_true
      decrypted["vertical_flip"].should       be_true

    end

    it "should allow thumbor to decrypt it properly with halign" do
      decrypted = generate_and_decrypt  :width => 300, :height => 200,
                                        :meta => true, :image => image_url,
                                        :smart => true, :flip => true,
                                        :flop => true, :halign => :left, :old => true

      decrypted["meta"].should            be_true
      decrypted["smart"].should           be_true
      decrypted["image_hash"].should      == image_md5
      decrypted["width"].should           == 300
      decrypted["height"].should          == 200
      decrypted["horizontal_flip"].should be_true
      decrypted["vertical_flip"].should   be_true
      decrypted["halign"].should          == "left"

    end

    it "should allow thumbor to decrypt it properly with valign" do
      decrypted = generate_and_decrypt  :width => 300, :height => 200, :meta => true,
                                        :image => image_url, :smart => true,
                                        :flip => true, :flop => true,
                                        :halign => :left, :valign => :top, :old => true

      decrypted["meta"].should                be_true
      decrypted["smart"].should               be_true
      decrypted["image_hash"].should          == image_md5
      decrypted["width"].should               == 300
      decrypted["height"].should              == 200
      decrypted["horizontal_flip"].should     be_true
      decrypted["vertical_flip"].should       be_true
      decrypted["halign"].should              == "left"
      decrypted["valign"].should              == "top"

    end

    it "should allow thumbor to decrypt it properly with cropping" do
      decrypted = generate_and_decrypt  :width => 300, :height => 200,
                                        :image => image_url, :crop => [10, 20, 30, 40], :old => true

      decrypted["horizontal_flip"].should be_false
      decrypted["vertical_flip"].should   be_false
      decrypted["smart"].should           be_false
      decrypted["meta"].should            be_false
      decrypted["crop"]["left"].should    == 10
      decrypted["crop"]["top"].should     == 20
      decrypted["crop"]["right"].should   == 30
      decrypted["crop"]["bottom"].should  == 40
      decrypted["valign"].should          == 'middle'
      decrypted["halign"].should          == 'center'
      decrypted["image_hash"].should      == image_md5
      decrypted["width"].should           == 300
      decrypted["height"].should          == 200
    end

    #FIXME
    xit "should allow thumbor to decrypt it properly with filters" do
      decrypted = generate_and_decrypt  :filters => ["quality(20)", "brightness(10)"],
                                        :image => image_url, :old => true

      decrypted["filters"].should == "quality(20):brightness(10)"
    end
  end
end
