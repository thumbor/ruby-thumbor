require 'spec_helper'
require 'json'
require 'ruby-thumbor'
require 'util/thumbor'

describe Thumbor::Cascade do
  let(:image_url) { 'my.domain.com/some/image/url.jpg' }
  let(:image_md5) { 'f33af67e41168e80fcc5b00f8bd8061a' }
  let(:key) { 'my-security-key' }

  subject { Thumbor::Cascade.new key, image_url }

  describe '#new' do

    it "should create a new instance passing key and keep it" do
      expect(subject.computed_key).to eq 'my-security-keym'
    end
  end

  it 'should raise an error' do
    expect{ subject.god_of_war_crop }.to raise_error(NoMethodError)
  end

  describe '#url_for' do

    it "should return just the image hash if no arguments passed" do
      url = subject.url_for
      expect(url).to eq image_md5
    end

    it "should raise if no image passed" do
      expect { Thumbor::Cascade.new.url_for }.to raise_error(RuntimeError)
    end

    it "should return proper url for width-only" do
      url = subject.width(300).url_for
      expect(url).to eq '300x0/' << image_md5
    end

    it "should return proper url for height-only" do
      url = subject.height(300).url_for
      expect(url).to eq '0x300/' << image_md5
    end

    it "should return proper url for width and height" do
      url = subject.width(200).height(300).url_for
      expect(url).to eq '200x300/' << image_md5
    end

    it "should return proper smart url" do
      url = subject.width(200).height(300).smart(true).url_for
      expect(url).to eq '200x300/smart/' << image_md5
    end

    it "should return proper fit-in url" do
      url = subject.width(200).height(300).fit_in(true).url_for
      expect(url).to eq 'fit-in/200x300/' << image_md5
    end

    it "should return proper adaptive-fit-in url" do
      url = subject.width(200).height(300).adaptive_fit_in(true).url_for
      expect(url).to eq 'adaptive-fit-in/200x300/' << image_md5
    end

    it "should return proper full-fit-in url" do
      url = subject.width(200).height(300).full_fit_in(true).url_for
      expect(url).to eq 'full-fit-in/200x300/' << image_md5
    end

    it "should return proper adaptive-full-fit-in url" do
      url = subject.width(200).height(300).adaptive_full_fit_in(true).url_for
      expect(url).to eq 'adaptive-full-fit-in/200x300/' << image_md5
    end

    [:fit_in, :full_fit_in].each do |fit|
      it "should raise error when using #{fit} without width or height" do
        subject.send(fit, true)
        expect{subject.url_for}.to raise_error(ArgumentError)
      end
    end

    it "should return proper flip url if no width and height" do
      url = subject.flip(true).url_for
      expect(url).to eq '-0x0/' << image_md5
    end

    it "should return proper flop url if no width and height" do
      url = subject.flop(true).url_for
      expect(url).to eq '0x-0/' << image_md5
    end

    it "should return proper flip-flop url if no width and height" do
      url = subject.flip(true).flop(true).url_for
      expect(url).to eq '-0x-0/' << image_md5
    end

    it "should return proper flip url if width" do
      url = subject.width(300).flip(true).url_for
      expect(url).to eq '-300x0/' << image_md5
    end

    it "should return proper flop url if height" do
      url = subject.height(300).flop(true).url_for
      expect(url).to eq '0x-300/' << image_md5
    end

    it "should return horizontal align" do
      url = subject.halign(:left).url_for
      expect(url).to eq 'left/' << image_md5
    end

    it "should not return horizontal align if it is center" do
      url = subject.halign(:center).url_for
      expect(url).to eq image_md5
    end

    it "should return vertical align" do
      url = subject.valign(:top).url_for
      expect(url).to eq 'top/' << image_md5
    end

    it "should not return vertical align if it is middle" do
      url = subject.valign(:middle).url_for
      expect(url).to eq image_md5
    end

    it "should return halign and valign properly" do
      url = subject.halign(:left).valign(:top).url_for
      expect(url).to eq 'left/top/' << image_md5
    end

    it "should return meta properly" do
      url = subject.meta(true).url_for
      expect(url).to eq 'meta/' << image_md5
    end

    it "should return proper crop url when param is array" do
      url = subject.crop([10, 20, 30, 40]).url_for
      expect(url).to eq '10x20:30x40/' << image_md5
    end

    it "should return proper crop url" do
      url = subject.crop(10, 20, 30, 40).url_for
      expect(url).to eq '10x20:30x40/' << image_md5
    end

    it "should ignore crop if all zeros" do
      url = subject.crop(0, 0, 0, 0).url_for
      expect(url).to eq image_md5
    end

    it "should have smart after halign and valign" do
      url = subject.halign(:left).valign(:top).smart(true).url_for
      expect(url).to eq 'left/top/smart/' << image_md5
    end

    it "should have quality filter" do
      url = subject.quality_filter(20).url_for
      expect(url).to eq 'filters:quality(20)/' << image_md5
    end

    it "should have brightness filter" do
      url = subject.brightness_filter(30).url_for
      expect(url).to eq 'filters:brightness(30)/' << image_md5
    end

    it "should have 2 filters" do
      url = subject.brightness_filter(30).quality_filter(20).url_for
      expect(url).to eq 'filters:brightness(30):quality(20)/' << image_md5
    end

    it "should escape url args" do
      url = subject.watermark_filter('http://my-server.com/image.png', 30).quality_filter(20).url_for
      expect(url).to eq 'filters:watermark(http%3A%2F%2Fmy-server.com%2Fimage.png,30):quality(20)/' << image_md5
    end

    it "should have trim without params" do
      url = subject.trim.url_for
      expect(url).to eq 'trim/' << image_md5
    end

    it "should have trim with direction param" do
      url = subject.trim('bottom-right').url_for
      expect(url).to eq 'trim:bottom-right/' << image_md5
    end

    it "should have trim with direction and tolerance param" do
      url = subject.trim('bottom-right', 15).url_for
      expect(url).to eq 'trim:bottom-right:15/' << image_md5
    end

    it "should have the right crop when cropping horizontally and given a left center" do
      url = subject.original_width(100).original_height(100).width(40).height(50).center(0, 50).url_for
      expect(url).to eq '0x0:80x100/40x50/' << image_md5
    end

    it "should have the right crop when cropping horizontally and given a right center" do
      url = subject.original_width(100).original_height(100).width(40).height(50).center(100, 50).url_for
      expect(url).to eq '20x0:100x100/40x50/' << image_md5
    end

    it "should have the right crop when cropping horizontally and given the actual center" do
      url = subject.original_width(100).original_height(100).width(40).height(50).center(50, 50).url_for
      expect(url).to eq '10x0:90x100/40x50/' << image_md5
    end

    it "should have the right crop when cropping vertically and given a top center" do
      url = subject.original_width(100).original_height(100).width(50).height(40).center(50, 0).url_for
      expect(url).to eq '0x0:100x80/50x40/' << image_md5
    end

    it "should have the right crop when cropping vertically and given a bottom center" do
      url = subject.original_width(100).original_height(100).width(50).height(40).center(50, 100).url_for
      expect(url).to eq '0x20:100x100/50x40/' << image_md5
    end

    it "should have the right crop when cropping vertically and given the actual center" do
      url = subject.original_width(100).original_height(100).width(50).height(40).center(50, 50).url_for
      expect(url).to eq '0x10:100x90/50x40/' << image_md5
    end

    it "should have the no crop when not necessary" do
      url = subject.original_width(100).original_height(100).width(50).height(50).center(50, 0).url_for
      expect(url).to eq '50x50/' << image_md5
    end

    it "should blow up with a bad center" do
      expect { subject.original_width(100).original_height(100).width(50).height(50).center(50).url_for }.to raise_error(RuntimeError)
    end

    it "should have no crop with a missing original_height" do
      url = subject.original_width(100).width(50).height(40).center(50, 0).url_for
      expect(url).to eq '50x40/' << image_md5
    end

    it "should have no crop with a missing original_width" do
      url = subject.original_height(100).width(50).height(40).center(50, 0).url_for
      expect(url).to eq '50x40/' << image_md5
    end

    it "should have no crop with out a width and height" do
      url = subject.original_width(100).original_height(100).center(50, 50).url_for
      expect(url).to eq image_md5
    end

    it "should use the original width with a missing width" do
      url = subject.original_width(100).original_height(100).height(80).center(50, 50).url_for
      expect(url).to eq '0x10:100x90/0x80/' << image_md5
    end

    it "should use the original height with a missing height" do
      url = subject.original_width(100).original_height(100).width(80).center(50, 50).url_for
      expect(url).to eq '10x0:90x100/80x0/' << image_md5
    end

    it "should have the right crop with a negative width" do
      url = subject.original_width(100).original_height(100).width(-50).height(40).center(50, 50).url_for
      expect(url).to eq '0x10:100x90/-50x40/' << image_md5
    end

    it "should have the right crop with a negative height" do
      url = subject.original_width(100).original_height(100).width(50).height(-40).center(50, 50).url_for
      expect(url).to eq '0x10:100x90/50x-40/' << image_md5
    end

    it "should have the right crop with a negative height and width" do
      url = subject.original_width(100).original_height(100).width(-50).height(-40).center(50, 50).url_for
      expect(url).to eq '0x10:100x90/-50x-40/' << image_md5
    end
  end

  describe '#generate' do

    it "should create a new instance passing key and keep it" do
      url = subject.width(300).height(200).generate
      expect(url).to eq '/TQfyd3H36Z3srcNcLOYiM05YNO8=/300x200/my.domain.com/some/image/url.jpg'
    end

    it "should be able to change the Thumbor key" do
      url1 = subject.width(300).height(200).generate
      url2 = Thumbor::Cascade.new('another-thumbor-key', image_url).width(300).height(200).generate
      expect(url1).not_to eq url2
    end

    it "should create a new instance passing key and keep it" do
      url = subject.width(300).height(200).meta(true).generate
      expect(url).to eq '/YBQEWd3g_WRMnVEG73zfzcr8Zj0=/meta/300x200/my.domain.com/some/image/url.jpg'
    end

    it "should create a new instance passing key and keep it" do
      url = subject.width(300).height(200).meta(true).smart(true).generate
      expect(url).to eq '/jP89J0qOWHgPlm_lOA28GtOh5GU=/meta/300x200/smart/my.domain.com/some/image/url.jpg'
    end

    it "should create a new instance passing key and keep it" do
      url = subject.width(300).height(200).meta(true).smart(true).fit_in(true).generate
      expect(url).to eq '/zrrOh_TtTs4kiLLEQq1w4bcTYdc=/meta/fit-in/300x200/smart/my.domain.com/some/image/url.jpg'
    end

    it "should create a new instance passing key and keep it" do
      url = subject.width(300).height(200).meta(true).smart(true).fit_in(true).flip(true).generate
      expect(url).to eq '/4t1XK1KH43cOb1QJ9tU00-W2_k8=/meta/fit-in/-300x200/smart/my.domain.com/some/image/url.jpg'
    end

    it "should create a new instance passing key and keep it" do
      url = subject.width(300).height(200).meta(true).smart(true).fit_in(true).flip(true).flop(true).generate
      expect(url).to eq '/HJnvjZU69PkPOhyZGu-Z3Uc_W_A=/meta/fit-in/-300x-200/smart/my.domain.com/some/image/url.jpg'
    end

    it "should create a new instance passing key and keep it" do
      url = subject.quality_filter(20).brightness_filter(10).generate
      expect(url).to eq '/q0DiFg-5-eFZIqyN3lRoCvg2K0s=/filters:quality(20):brightness(10)/my.domain.com/some/image/url.jpg'
    end
  end

  describe "#generate :old => true" do

    subject { Thumbor::Cascade.new(key, image_url).old(true) }

    it "should create a new instance passing key and keep it" do
      url = subject.width(300).height(200).generate
      expect(url).to eq '/qkLDiIbvtiks0Up9n5PACtmpOfX6dPXw4vP4kJU-jTfyF6y1GJBJyp7CHYh1H3R2/' << image_url
    end

    it "should allow thumbor to decrypt it properly" do
      url = subject.width(300).height(200).generate

      encrypted = url.split('/')[1]

      decrypted = decrypt_in_thumbor(encrypted)

      expect(decrypted["horizontal_flip"]).to be_falsy
      expect(decrypted["vertical_flip"]).to be_falsy
      expect(decrypted["smart"]).to be_falsy
      expect(decrypted["meta"]).to be_falsy
      expect(decrypted["fit_in"]).to be_falsy
      expect(decrypted["crop"]["left"]).to eq 0
      expect(decrypted["crop"]["top"]).to eq 0
      expect(decrypted["crop"]["right"]).to eq 0
      expect(decrypted["crop"]["bottom"]).to eq 0
      expect(decrypted["valign"]).to eq 'middle'
      expect(decrypted["halign"]).to eq 'center'
      expect(decrypted["image_hash"]).to eq image_md5
      expect(decrypted["width"]).to eq 300
      expect(decrypted["height"]).to eq 200

    end

    it "should allow thumbor to decrypt it properly with meta" do
      url = subject.width(300).height(200).meta(true).generate

      encrypted = url.split('/')[1]

      decrypted = decrypt_in_thumbor(encrypted)

      expect(decrypted["meta"]).to be_truthy
      expect(decrypted["image_hash"]).to eq image_md5
      expect(decrypted["width"]).to eq 300
      expect(decrypted["height"]).to eq 200

    end

    it "should allow thumbor to decrypt it properly with smart" do
      url = subject.width(300).height(200).meta(true).smart(true).generate

      encrypted = url.split('/')[1]

      decrypted = decrypt_in_thumbor(encrypted)

      expect(decrypted["meta"]).to be_truthy
      expect(decrypted["smart"]).to be_truthy
      expect(decrypted["image_hash"]).to eq image_md5
      expect(decrypted["width"]).to eq 300
      expect(decrypted["height"]).to eq 200

    end

    it "should allow thumbor to decrypt it properly with fit-in" do
      url = subject.width(300).height(200).fit_in(true).generate

      encrypted = url.split('/')[1]

      decrypted = decrypt_in_thumbor(encrypted)

      expect(decrypted["fit_in"]).to be_truthy
      expect(decrypted["image_hash"]).to eq image_md5
      expect(decrypted["width"]).to eq 300
      expect(decrypted["height"]).to eq 200

    end

    it "should allow thumbor to decrypt it properly with flip" do
      url = subject.width(300).height(200).meta(true).smart(true).flip(true).generate

      encrypted = url.split('/')[1]

      decrypted = decrypt_in_thumbor(encrypted)

      expect(decrypted["meta"]).to be_truthy
      expect(decrypted["smart"]).to be_truthy
      expect(decrypted["image_hash"]).to eq image_md5
      expect(decrypted["width"]).to eq 300
      expect(decrypted["height"]).to eq 200
      expect(decrypted["horizontal_flip"]).to be_truthy

    end

    it "should allow thumbor to decrypt it properly with flop" do
      url = subject.width(300).height(200).meta(true).smart(true).flip(true).flop(true).generate

      encrypted = url.split('/')[1]

      decrypted = decrypt_in_thumbor(encrypted)

      expect(decrypted["meta"]).to be_truthy
      expect(decrypted["smart"]).to be_truthy
      expect(decrypted["image_hash"]).to eq image_md5
      expect(decrypted["width"]).to eq 300
      expect(decrypted["height"]).to eq 200
      expect(decrypted["horizontal_flip"]).to be_truthy
      expect(decrypted["vertical_flip"]).to be_truthy

    end

    it "should allow thumbor to decrypt it properly with halign" do
      url = subject.width(300).height(200).meta(true).smart(true).flip(true).flop(true).
            halign(:left).generate

      encrypted = url.split('/')[1]

      decrypted = decrypt_in_thumbor(encrypted)

      expect(decrypted["meta"]).to be_truthy
      expect(decrypted["smart"]).to be_truthy
      expect(decrypted["image_hash"]).to eq image_md5
      expect(decrypted["width"]).to eq 300
      expect(decrypted["height"]).to eq 200
      expect(decrypted["horizontal_flip"]).to be_truthy
      expect(decrypted["vertical_flip"]).to be_truthy
      expect(decrypted["halign"]).to eq "left"

    end

    it "should allow thumbor to decrypt it properly with valign" do
      url = subject.width(300).height(200).meta(true).smart(true).flip(true).flop(true).
            halign(:left).valign(:top).generate

      encrypted = url.split('/')[1]

      decrypted = decrypt_in_thumbor(encrypted)

      expect(decrypted["meta"]).to be_truthy
      expect(decrypted["smart"]).to be_truthy
      expect(decrypted["image_hash"]).to eq image_md5
      expect(decrypted["width"]).to eq 300
      expect(decrypted["height"]).to eq 200
      expect(decrypted["horizontal_flip"]).to be_truthy
      expect(decrypted["vertical_flip"]).to be_truthy
      expect(decrypted["halign"]).to eq "left"
      expect(decrypted["valign"]).to eq "top"

    end

    it "should allow thumbor to decrypt it properly with cropping" do
      url = subject.width(300).height(200).crop([10, 20, 30, 40]).generate

      encrypted = url.split('/')[1]

      decrypted = decrypt_in_thumbor(encrypted)

      expect(decrypted["horizontal_flip"]).to be_falsy
      expect(decrypted["vertical_flip"]).to be_falsy
      expect(decrypted["smart"]).to be_falsy
      expect(decrypted["meta"]).to be_falsy
      expect(decrypted["crop"]["left"]).to eq 10
      expect(decrypted["crop"]["top"]).to eq 20
      expect(decrypted["crop"]["right"]).to eq 30
      expect(decrypted["crop"]["bottom"]).to eq 40
      expect(decrypted["valign"]).to eq 'middle'
      expect(decrypted["halign"]).to eq 'center'
      expect(decrypted["image_hash"]).to eq image_md5
      expect(decrypted["width"]).to eq 300
      expect(decrypted["height"]).to eq 200

    end

    it "should allow thumbor to decrypt it properly with filters" do
      url = subject.quality_filter(20).brightness_filter(10).generate

      encrypted = url.split('/')[1]

      decrypted = decrypt_in_thumbor(encrypted)

      expect(decrypted["filters"]).to eq "quality(20):brightness(10)"
    end
  end
end
