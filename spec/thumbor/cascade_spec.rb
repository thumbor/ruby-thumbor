require 'spec_helper'
require 'json'
require 'ruby-thumbor'
require 'util/thumbor'

describe Thumbor::Cascade do
  let(:image_url) { 'my.domain.com/some/image/url.jpg' }
  let(:image_md5) { 'f33af67e41168e80fcc5b00f8bd8061a' }
  let(:key) { 'my-security-key' }

  before do
    Thumbor.key = key 
  end

  subject { Thumbor::Cascade.new image_url }

  describe '#new' do
    it "should create a new instance passing key and keep it" do
      subject.computed_key.should == 'my-security-keym'
    end
  end

  it 'should raise an error' do
    expect{ subject.god_of_war_crop }.to raise_error(NoMethodError)
  end

  describe '#url_for' do

    it "should return just the image hash if no arguments passed" do
      url = subject.url_for
      url.should == image_md5
    end

    it "should raise if no image passed" do
      expect { Thumbor::Cascade.new.url_for }.to raise_error(RuntimeError)
    end

    it "should return proper url for width-only" do
      url = subject.width(300).url_for 
      url.should == '300x0/' << image_md5
    end

    it "should return proper url for height-only" do
      url = subject.height(300).url_for
      url.should == '0x300/' << image_md5
    end

    it "should return proper url for width and height" do
      url = subject.width(200).height(300).url_for
      url.should == '200x300/' << image_md5
    end

    it "should return proper smart url" do
      url = subject.width(200).height(300).smart(true).url_for
      url.should == '200x300/smart/' << image_md5
    end

    it "should return proper fit-in url" do
      url = subject.width(200).height(300).fit_in(true).url_for
      url.should == 'fit-in/200x300/' << image_md5
    end

    it "should return proper flip url if no width and height" do
      url = subject.flip(true).url_for
      url.should == '-0x0/' << image_md5
    end

    it "should return proper flop url if no width and height" do
      url = subject.flop(true).url_for
      url.should == '0x-0/' << image_md5
    end

    it "should return proper flip-flop url if no width and height" do
      url = subject.flip(true).flop(true).url_for
      url.should == '-0x-0/' << image_md5
    end

    it "should return proper flip url if width" do
      url = subject.width(300).flip(true).url_for
      url.should == '-300x0/' << image_md5
    end

    it "should return proper flop url if height" do
      url = subject.height(300).flop(true).url_for
      url.should == '0x-300/' << image_md5
    end

    it "should return horizontal align" do
      url = subject.halign(:left).url_for
      url.should == 'left/' << image_md5
    end

    it "should not return horizontal align if it is center" do
      url = subject.halign(:center).url_for
      url.should == image_md5
    end

    it "should return vertical align" do
      url = subject.valign(:top).url_for
      url.should == 'top/' << image_md5
    end

    it "should not return vertical align if it is middle" do
      url = subject.valign(:middle).url_for
      url.should == image_md5
    end

    it "should return halign and valign properly" do
      url = subject.halign(:left).valign(:top).url_for
      url.should == 'left/top/' << image_md5
    end

    it "should return meta properly" do
      url = subject.meta(true).url_for
      url.should == 'meta/' << image_md5
    end

    it "should return proper crop url when param is array" do
      url = subject.crop([10, 20, 30, 40]).url_for
      url.should == '10x20:30x40/' << image_md5
    end

    it "should return proper crop url" do
      url = subject.crop(10, 20, 30, 40).url_for
      url.should == '10x20:30x40/' << image_md5
    end

    it "should ignore crop if all zeros" do
      url = subject.crop(0, 0, 0, 0).url_for
      url.should == image_md5
    end

    it "should have smart after halign and valign" do
      url = subject.halign(:left).valign(:top).smart(true).url_for
      url.should == 'left/top/smart/' << image_md5
    end

    it "should have quality filter" do
      url = subject.quality_filter(20).url_for
      url.should == 'filters:quality(20)/' << image_md5
    end

    it "should have brightness filter" do
      url = subject.brightness_filter(30).url_for
      url.should == 'filters:brightness(30)/' << image_md5
    end

    it "should have 2 filters" do
      url = subject.brightness_filter(30).quality_filter(20).url_for
      url.should == 'filters:brightness(30):quality(20)/' << image_md5
    end

    it "should escape url args" do
      url = subject.watermark_filter('http://my-server.com/image.png', 30).quality_filter(20).url_for
      url.should == 'filters:watermark(http%3A%2F%2Fmy-server.com%2Fimage.png,30):quality(20)/' << image_md5
    end

    it "should have trim without params" do
      url = subject.trim.url_for
      url.should == 'trim/' << image_md5
    end

    it "should have trim with direction param" do
      url = subject.trim('bottom-right').url_for
      url.should == 'trim:bottom-right/' << image_md5
    end

    it "should have trim with direction and tolerance param" do
      url = subject.trim('bottom-right', 15).url_for
      url.should == 'trim:bottom-right:15/' << image_md5
    end
  end

  describe '#generate' do

    it "should create a new instance passing key and keep it" do
      url = subject.width(300).height(200).generate
      url.should == '/TQfyd3H36Z3srcNcLOYiM05YNO8=/300x200/my.domain.com/some/image/url.jpg'
    end

    it "should create a new instance passing key and keep it" do
      url = subject.width(300).height(200).meta(true).generate
      url.should == '/YBQEWd3g_WRMnVEG73zfzcr8Zj0=/meta/300x200/my.domain.com/some/image/url.jpg'
    end

    it "should create a new instance passing key and keep it" do
      url = subject.width(300).height(200).meta(true).smart(true).generate
      url.should == '/jP89J0qOWHgPlm_lOA28GtOh5GU=/meta/300x200/smart/my.domain.com/some/image/url.jpg'
    end

    it "should create a new instance passing key and keep it" do
      url = subject.width(300).height(200).meta(true).smart(true).fit_in(true).generate
      url.should == '/zrrOh_TtTs4kiLLEQq1w4bcTYdc=/meta/fit-in/300x200/smart/my.domain.com/some/image/url.jpg'
    end

    it "should create a new instance passing key and keep it" do
      url = subject.width(300).height(200).meta(true).smart(true).fit_in(true).flip(true).generate
      url.should == '/4t1XK1KH43cOb1QJ9tU00-W2_k8=/meta/fit-in/-300x200/smart/my.domain.com/some/image/url.jpg'
    end

    it "should create a new instance passing key and keep it" do
      url = subject.width(300).height(200).meta(true).smart(true).fit_in(true).flip(true).flop(true).generate
      url.should == '/HJnvjZU69PkPOhyZGu-Z3Uc_W_A=/meta/fit-in/-300x-200/smart/my.domain.com/some/image/url.jpg'
    end

    it "should create a new instance passing key and keep it" do
      url = subject.quality_filter(20).brightness_filter(10).generate
      url.should == '/q0DiFg-5-eFZIqyN3lRoCvg2K0s=/filters:quality(20):brightness(10)/my.domain.com/some/image/url.jpg'
    end
  end

  describe "#generate :old => true" do
    subject { Thumbor::Cascade.new(image_url).old(true) }

    it "should create a new instance passing key and keep it" do
      url = subject.width(300).height(200).generate
      url.should == '/qkLDiIbvtiks0Up9n5PACtmpOfX6dPXw4vP4kJU-jTfyF6y1GJBJyp7CHYh1H3R2/' << image_url
    end

    it "should allow thumbor to decrypt it properly" do
      url = subject.width(300).height(200).generate

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
      url = subject.width(300).height(200).meta(true).generate

      encrypted = url.split('/')[1]

      decrypted = decrypt_in_thumbor(encrypted)

      decrypted["meta"].should == true
      decrypted["image_hash"].should == image_md5
      decrypted["width"].should == 300
      decrypted["height"].should == 200

    end

    it "should allow thumbor to decrypt it properly with smart" do
      url = subject.width(300).height(200).meta(true).smart(true).generate

      encrypted = url.split('/')[1]

      decrypted = decrypt_in_thumbor(encrypted)

      decrypted["meta"].should == true
      decrypted["smart"].should == true
      decrypted["image_hash"].should == image_md5
      decrypted["width"].should == 300
      decrypted["height"].should == 200

    end

    it "should allow thumbor to decrypt it properly with fit-in" do
      url = subject.width(300).height(200).fit_in(true).generate

      encrypted = url.split('/')[1]

      decrypted = decrypt_in_thumbor(encrypted)

      decrypted["fit_in"].should == true
      decrypted["image_hash"].should == image_md5
      decrypted["width"].should == 300
      decrypted["height"].should == 200

    end

    it "should allow thumbor to decrypt it properly with flip" do
      url = subject.width(300).height(200).meta(true).smart(true).flip(true).generate

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
      url = subject.width(300).height(200).meta(true).smart(true).flip(true).flop(true).generate

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
      url = subject.width(300).height(200).meta(true).smart(true).flip(true).flop(true).
            halign(:left).generate

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
      url = subject.width(300).height(200).meta(true).smart(true).flip(true).flop(true).
            halign(:left).valign(:top).generate

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
      url = subject.width(300).height(200).crop([10, 20, 30, 40]).generate

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
      url = subject.quality_filter(20).brightness_filter(10).generate

      encrypted = url.split('/')[1]

      decrypted = decrypt_in_thumbor(encrypted)

      decrypted["filters"].should == "quality(20):brightness(10)"
    end
  end
end
