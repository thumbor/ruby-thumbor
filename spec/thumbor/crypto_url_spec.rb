require 'spec_helper'
require 'json'
require 'ruby-thumbor'
require 'util/thumbor'

image_url = 'my.domain.com/some/image/url.jpg'
image_md5 = 'f33af67e41168e80fcc5b00f8bd8061a'
key = 'my-security-key'

describe Thumbor::CryptoURL do
  subject { Thumbor::CryptoURL.new key }

  describe '#new' do
    it "should create a new instance passing key and keep it" do
      expect(subject.computed_key).to eq('my-security-keym')
    end
  end

  describe '#url_for' do

    it "should return just the image hash if no arguments passed" do
      url = subject.url_for :image => image_url
      expect(url).to eq(image_md5)
    end

    it "should raise if no image passed" do
      expect { subject.url_for Hash.new }.to raise_error(RuntimeError)
    end

    it "should return proper url for width-only" do
      url = subject.url_for :image => image_url, :width => 300
      expect(url).to eq('300x0/' << image_md5)
    end

    it "should return proper url for height-only" do
      url = subject.url_for :image => image_url, :height => 300
      expect(url).to eq('0x300/' << image_md5)
    end

    it "should return proper url for width and height" do
      url = subject.url_for :image => image_url, :width => 200, :height => 300
      expect(url).to eq('200x300/' << image_md5)
    end

    it "should return proper smart url" do
      url = subject.url_for :image => image_url, :width => 200, :height => 300, :smart => true
      expect(url).to eq('200x300/smart/' << image_md5)
    end

    it "should return proper fit-in url" do
      url = subject.url_for :image => image_url, :width => 200, :height => 300, :fit_in => true
      expect(url).to eq('fit-in/200x300/' << image_md5)
    end

    it "should return proper flip url if no width and height" do
      url = subject.url_for :image => image_url, :flip => true
      expect(url).to eq('-0x0/' << image_md5)
    end

    it "should return proper flop url if no width and height" do
      url = subject.url_for :image => image_url, :flop => true
      expect(url).to eq('0x-0/' << image_md5)
    end

    it "should return proper flip-flop url if no width and height" do
      url = subject.url_for :image => image_url, :flip => true, :flop => true
      expect(url).to eq('-0x-0/' << image_md5)
    end

    it "should return proper flip url if width" do
      url = subject.url_for :image => image_url, :width => 300, :flip => true
      expect(url).to eq('-300x0/' << image_md5)
    end

    it "should return proper flop url if height" do
      url = subject.url_for :image => image_url, :height => 300, :flop => true
      expect(url).to eq('0x-300/' << image_md5)
    end

    it "should return horizontal align" do
      url = subject.url_for :image => image_url, :halign => :left
      expect(url).to eq('left/' << image_md5)
    end

    it "should not return horizontal align if it is center" do
      url = subject.url_for :image => image_url, :halign => :center
      expect(url).to eq(image_md5)
    end

    it "should return vertical align" do
      url = subject.url_for :image => image_url, :valign => :top
      expect(url).to eq('top/' << image_md5)
    end

    it "should not return vertical align if it is middle" do
      url = subject.url_for :image => image_url, :valign => :middle
      expect(url).to eq(image_md5)
    end

    it "should return halign and valign properly" do
      url = subject.url_for :image => image_url, :halign => :left, :valign => :top
      expect(url).to eq('left/top/' << image_md5)
    end

    it "should return meta properly" do
      url = subject.url_for :image => image_url, :meta => true
      expect(url).to eq('meta/' << image_md5)
    end

    it "should return proper crop url" do
      url = subject.url_for :image => image_url, :crop => [10, 20, 30, 40]
      expect(url).to eq('10x20:30x40/' << image_md5)
    end

    it "should ignore crop if all zeros" do
      url = subject.url_for :image => image_url, :crop => [0, 0, 0, 0]
      expect(url).to eq(image_md5)
    end

    it "should have smart after halign and valign" do
      url = subject.url_for :image => image_url, :halign => :left, :valign => :top, :smart => true
      expect(url).to eq('left/top/smart/' << image_md5)
    end

    it "should ignore filters if empty" do
      url = subject.url_for :image => image_url, :filters => []
      expect(url).to eq(image_md5)
    end

    it "should have trim without params" do
      url = subject.url_for :image => image_url, :trim => true
      expect(url).to eq('trim/' << image_md5)
    end

    it "should have trim with direction param" do
      url = subject.url_for :image => image_url, :trim => ['bottom-right']
      expect(url).to eq('trim:bottom-right/' << image_md5)
    end

    it "should have trim with direction and tolerance param" do
      url = subject.url_for :image => image_url, :trim => ['bottom-right', 15]
      expect(url).to eq('trim:bottom-right:15/' << image_md5)
    end

    it "should have the trim option as the first one" do
      url = subject.url_for :image => image_url, :smart => true, :trim => true

      expect(url).to eq('trim/smart/f33af67e41168e80fcc5b00f8bd8061a')
    end


    it "should have the right crop when cropping horizontally and given a left center" do
      url = subject.url_for :image => image_url, :original_width => 100, :original_height => 100, :width => 40, :height => 50, :center => [0, 50]
      expect(url).to eq('0x0:80x100/40x50/' << image_md5)
    end

    it "should have the right crop when cropping horizontally and given a right center" do
      url = subject.url_for :image => image_url, :original_width => 100, :original_height => 100, :width => 40, :height => 50, :center => [100, 50]
      expect(url).to eq('20x0:100x100/40x50/' << image_md5)
    end

    it "should have the right crop when cropping horizontally and given the actual center" do
      url = subject.url_for :image => image_url, :original_width => 100, :original_height => 100, :width => 40, :height => 50, :center => [50, 50]
      expect(url).to eq('10x0:90x100/40x50/' << image_md5)
    end

    it "should have the right crop when cropping vertically and given a top center" do
      url = subject.url_for :image => image_url, :original_width => 100, :original_height => 100, :width => 50, :height => 40, :center => [50, 0]
      expect(url).to eq('0x0:100x80/50x40/' << image_md5)
    end

    it "should have the right crop when cropping vertically and given a bottom center" do
      url = subject.url_for :image => image_url, :original_width => 100, :original_height => 100, :width => 50, :height => 40, :center => [50, 100]
      expect(url).to eq('0x20:100x100/50x40/' << image_md5)
    end

    it "should have the right crop when cropping vertically and given the actual center" do
      url = subject.url_for :image => image_url, :original_width => 100, :original_height => 100, :width => 50, :height => 40, :center => [50, 50]
      expect(url).to eq('0x10:100x90/50x40/' << image_md5)
    end

    it "should have the no crop when not necessary" do
      url = subject.url_for :image => image_url, :original_width => 100, :original_height => 100, :width => 50, :height => 50, :center => [50, 0]
      expect(url).to eq('50x50/' << image_md5)
    end

    it "should blow up with a bad center" do
      expect { subject.url_for :image => image_url, :original_width => 100, :original_height => 100, :width => 50, :height => 40, :center => 50 }.to raise_error(RuntimeError)
    end

    it "should have no crop with a missing original_height" do
      url = subject.url_for :image => image_url, :original_width => 100, :width => 50, :height => 40, :center => [50, 50]
      expect(url).to eq('50x40/' << image_md5)
    end

    it "should have no crop with a missing original_width" do
      url = subject.url_for :image => image_url, :original_height => 100, :width => 50, :height => 40, :center => [50, 50]
      expect(url).to eq('50x40/' << image_md5)
    end

    it "should have no crop with out a width and height" do
      url = subject.url_for :image => image_url, :original_width => 100, :original_height => 100, :center => [50, 50]
      expect(url).to eq(image_md5)
    end

    it "should use the original width with a missing width" do
      url = subject.url_for :image => image_url, :original_width => 100, :original_height => 100, :height => 80, :center => [50, 50]
      expect(url).to eq('0x10:100x90/0x80/' << image_md5)
    end

    it "should use the original height with a missing height" do
      url = subject.url_for :image => image_url,:original_width => 100, :original_height => 100, :width => 80, :center => [50, 50]
      expect(url).to eq('10x0:90x100/80x0/' << image_md5)
    end

    it "should have the right crop with a negative width" do
      url = subject.url_for :image => image_url, :original_width => 100, :original_height => 100, :width => -50, :height => 40, :center => [50, 50]
      expect(url).to eq('0x10:100x90/-50x40/' << image_md5)
    end

    it "should have the right crop with a negative height" do
      url = subject.url_for :image => image_url, :original_width => 100, :original_height => 100, :width => 50, :height => -40, :center => [50, 50]
      expect(url).to eq('0x10:100x90/50x-40/' << image_md5)
    end

    it "should have the right crop with a negative height and width" do
      url = subject.url_for :image => image_url, :original_width => 100, :original_height => 100, :width => -50, :height => -40, :center => [50, 50]
      expect(url).to eq('0x10:100x90/-50x-40/' << image_md5)
    end

    it "should handle string values" do
      url = subject.url_for :image => image_url, :width => '40', :height => '50'
      expect(url).to eq('40x50/' << image_md5)
    end

    it "should never mutate its arguments" do
      opts = {:image => image_url, :width => '500'}
      subject.url_for opts
      expect(opts).to eq({:image => image_url, :width => '500'})
    end
  end

  describe '#generate' do
    it "should generate a proper url when only an image url is specified" do
      url = subject.generate :image => image_url

      expect(url).to eq("/964rCTkAEDtvjy_a572k7kRa0SU=/#{image_url}")
    end

    it "should create a new instance passing key and keep it" do
      url = subject.generate :width => 300, :height => 200, :image => image_url

      expect(url).to eq('/TQfyd3H36Z3srcNcLOYiM05YNO8=/300x200/my.domain.com/some/image/url.jpg')
    end

    it "should create a new instance passing key and keep it" do
      url = subject.generate :width => 300, :height => 200, :meta => true, :image => image_url

      expect(url).to eq('/YBQEWd3g_WRMnVEG73zfzcr8Zj0=/meta/300x200/my.domain.com/some/image/url.jpg')
    end

    it "should create a new instance passing key and keep it" do
      url = subject.generate :width => 300, :height => 200, :meta => true, :image => image_url, :smart => true

      expect(url).to eq('/jP89J0qOWHgPlm_lOA28GtOh5GU=/meta/300x200/smart/my.domain.com/some/image/url.jpg')
    end

    it "should create a new instance passing key and keep it" do
      url = subject.generate :width => 300, :height => 200, :meta => true, :image => image_url, :smart => true, :fit_in => true

      expect(url).to eq('/zrrOh_TtTs4kiLLEQq1w4bcTYdc=/meta/fit-in/300x200/smart/my.domain.com/some/image/url.jpg')
    end

    it "should create a new instance passing key and keep it" do
      url = subject.generate :width => 300, :height => 200, :meta => true, :image => image_url, :smart => true, :fit_in => true, :flip => true

      expect(url).to eq('/4t1XK1KH43cOb1QJ9tU00-W2_k8=/meta/fit-in/-300x200/smart/my.domain.com/some/image/url.jpg')
    end

    it "should create a new instance passing key and keep it" do
      url = subject.generate :width => 300, :height => 200, :meta => true, :image => image_url, :smart => true, :fit_in => true, :flip => true, :flop => true

      expect(url).to eq('/HJnvjZU69PkPOhyZGu-Z3Uc_W_A=/meta/fit-in/-300x-200/smart/my.domain.com/some/image/url.jpg')
    end

    it "should create a new instance passing key and keep it" do
      url = subject.generate :filters => ["quality(20)", "brightness(10)"], :image => image_url

      expect(url).to eq('/q0DiFg-5-eFZIqyN3lRoCvg2K0s=/filters:quality(20):brightness(10)/my.domain.com/some/image/url.jpg')
    end
  end

  describe "#generate :old => true" do

    it "should create a new instance passing key and keep it" do
      url = subject.generate :width => 300, :height => 200, :image => image_url, :old => true

      expect(url).to eq('/qkLDiIbvtiks0Up9n5PACtmpOfX6dPXw4vP4kJU-jTfyF6y1GJBJyp7CHYh1H3R2/' << image_url)
    end

    it "should allow thumbor to decrypt it properly" do
      url = subject.generate :width => 300, :height => 200, :image => image_url, :old => true

      encrypted = url.split('/')[1]

      decrypted = decrypt_in_thumbor(encrypted)

      expect(decrypted["horizontal_flip"]).to be_falsy
      expect(decrypted["vertical_flip"]).to be_falsy
      expect(decrypted["smart"]).to be_falsy
      expect(decrypted["meta"]).to be_falsy
      expect(decrypted["fit_in"]).to be_falsy
      expect(decrypted["crop"]["left"]).to eq(0)
      expect(decrypted["crop"]["top"]).to eq(0)
      expect(decrypted["crop"]["right"]).to eq(0)
      expect(decrypted["crop"]["bottom"]).to eq(0)
      expect(decrypted["valign"]).to eq('middle')
      expect(decrypted["halign"]).to eq('center')
      expect(decrypted["image_hash"]).to eq(image_md5)
      expect(decrypted["width"]).to eq(300)
      expect(decrypted["height"]).to eq(200)

    end

    it "should allow thumbor to decrypt it properly with meta" do
      url = subject.generate :width => 300, :height => 200, :meta => true, :image => image_url, :old => true

      encrypted = url.split('/')[1]

      decrypted = decrypt_in_thumbor(encrypted)

      expect(decrypted["meta"]).to be_truthy
      expect(decrypted["image_hash"]).to eq(image_md5)
      expect(decrypted["width"]).to eq(300)
      expect(decrypted["height"]).to eq(200)

    end

    it "should allow thumbor to decrypt it properly with smart" do
      url = subject.generate :width => 300, :height => 200, :meta => true, :image => image_url, :smart => true, :old => true

      encrypted = url.split('/')[1]

      decrypted = decrypt_in_thumbor(encrypted)

      expect(decrypted["meta"]).to be_truthy
      expect(decrypted["smart"]).to be_truthy
      expect(decrypted["image_hash"]).to eq(image_md5)
      expect(decrypted["width"]).to eq(300)
      expect(decrypted["height"]).to eq(200)

    end

    it "should allow thumbor to decrypt it properly with fit-in" do
      url = subject.generate :width => 300, :height => 200, :fit_in => true, :image => image_url, :old => true

      encrypted = url.split('/')[1]

      decrypted = decrypt_in_thumbor(encrypted)

      expect(decrypted["fit_in"]).to be_truthy
      expect(decrypted["image_hash"]).to eq(image_md5)
      expect(decrypted["width"]).to eq(300)
      expect(decrypted["height"]).to eq(200)

    end

    it "should allow thumbor to decrypt it properly with flip" do
      url = subject.generate :width => 300, :height => 200, :meta => true, :image => image_url, :smart => true, :flip => true, :old => true

      encrypted = url.split('/')[1]

      decrypted = decrypt_in_thumbor(encrypted)

      expect(decrypted["meta"]).to be_truthy
      expect(decrypted["smart"]).to be_truthy
      expect(decrypted["image_hash"]).to eq(image_md5)
      expect(decrypted["width"]).to eq(300)
      expect(decrypted["height"]).to eq(200)
      decrypted["flip_horizontally"] == true

    end

    it "should allow thumbor to decrypt it properly with flop" do
      url = subject.generate :width => 300, :height => 200, :meta => true, :image => image_url, :smart => true, :flip => true, :flop => true, :old => true

      encrypted = url.split('/')[1]

      decrypted = decrypt_in_thumbor(encrypted)

      expect(decrypted["meta"]).to be_truthy
      expect(decrypted["smart"]).to be_truthy
      expect(decrypted["image_hash"]).to eq(image_md5)
      expect(decrypted["width"]).to eq(300)
      expect(decrypted["height"]).to eq(200)
      decrypted["flip_horizontally"] == true
      decrypted["flip_vertically"] == true

    end

    it "should allow thumbor to decrypt it properly with halign" do
      url = subject.generate :width => 300, :height => 200, :meta => true, :image => image_url, :smart => true, :flip => true, :flop => true,
      :halign => :left, :old => true

      encrypted = url.split('/')[1]

      decrypted = decrypt_in_thumbor(encrypted)

      expect(decrypted["meta"]).to be_truthy
      expect(decrypted["smart"]).to be_truthy
      expect(decrypted["image_hash"]).to eq(image_md5)
      expect(decrypted["width"]).to eq(300)
      expect(decrypted["height"]).to eq(200)
      decrypted["flip_horizontally"] == true
      decrypted["flip_vertically"] == true
      decrypted["halign"] == "left"

    end

    it "should allow thumbor to decrypt it properly with valign" do
      url = subject.generate :width => 300, :height => 200, :meta => true, :image => image_url, :smart => true, :flip => true, :flop => true,
      :halign => :left, :valign => :top, :old => true

      encrypted = url.split('/')[1]

      decrypted = decrypt_in_thumbor(encrypted)

      expect(decrypted["meta"]).to be_truthy
      expect(decrypted["smart"]).to be_truthy
      expect(decrypted["image_hash"]).to eq(image_md5)
      expect(decrypted["width"]).to eq(300)
      expect(decrypted["height"]).to eq(200)
      decrypted["flip_horizontally"] == true
      decrypted["flip_vertically"] == true
      decrypted["halign"] == "left"
      decrypted["valign"] == "top"

    end

    it "should allow thumbor to decrypt it properly with cropping" do
      url = subject.generate :width => 300, :height => 200, :image => image_url, :crop => [10, 20, 30, 40], :old => true

      encrypted = url.split('/')[1]

      decrypted = decrypt_in_thumbor(encrypted)

      expect(decrypted["horizontal_flip"]).to be_falsy
      expect(decrypted["vertical_flip"]).to be_falsy
      expect(decrypted["smart"]).to be_falsy
      expect(decrypted["meta"]).to be_falsy
      expect(decrypted["crop"]["left"]).to eq(10)
      expect(decrypted["crop"]["top"]).to eq(20)
      expect(decrypted["crop"]["right"]).to eq(30)
      expect(decrypted["crop"]["bottom"]).to eq(40)
      expect(decrypted["valign"]).to eq('middle')
      expect(decrypted["halign"]).to eq('center')
      expect(decrypted["image_hash"]).to eq(image_md5)
      expect(decrypted["width"]).to eq(300)
      expect(decrypted["height"]).to eq(200)

    end

    it "should allow thumbor to decrypt it properly with filters" do
      url = subject.generate :filters => ["quality(20)", "brightness(10)"], :image => image_url, :old => true

      encrypted = url.split('/')[1]

      decrypted = decrypt_in_thumbor(encrypted)

      expect(decrypted["filters"]).to eq("quality(20):brightness(10)")
    end
  end

  describe "without security key" do
    subject { Thumbor::CryptoURL.new nil }
    it "should generate a unsafe url" do
      url = subject.generate :image => image_url

      expect(url).to eq("/unsafe/#{image_url}")
    end
  end
end
