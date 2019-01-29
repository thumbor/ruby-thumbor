require 'spec_helper'
require 'json'
require 'ruby-thumbor'

describe Thumbor::Cascade do
  let(:image_url) { 'my.domain.com/some/image/url.jpg' }
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

  describe '#generate' do

    it "should create an unsafe url" do
      url = Thumbor::Cascade.new(false, image_url).width(300).height(200).generate
      expect(url).to eq '/unsafe/300x200/my.domain.com/some/image/url.jpg'
    end

    it "should create an url with debug" do
      url = subject.debug(true).height(200).generate
      expect(url).to eq '/5_eX4HHQYk81HQVkc1gBIAvPbLo=/debug/0x200/my.domain.com/some/image/url.jpg'
    end

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

    it "should return just the image hash if no arguments passed" do
      url = subject.generate
      expect(url).to eq '/964rCTkAEDtvjy_a572k7kRa0SU=/my.domain.com/some/image/url.jpg'
    end

    it "should raise if no image passed" do
      expect { Thumbor::Cascade.new.generate }.to raise_error(RuntimeError)
    end

    it "should return proper url for width-only" do
      url = subject.width(300).generate
      expect(url).to eq '/eFwrBWryxtRw9hDSbQPhi5iLpo8=/300x0/my.domain.com/some/image/url.jpg'
    end

    it "should return proper url for height-only" do
      url = subject.height(300).generate
      expect(url).to eq '/-VGIgp7g8cMKcfF2gFK9ZpmB_5w=/0x300/my.domain.com/some/image/url.jpg'
    end

    it "should return proper url for width and height" do
      url = subject.width(200).height(300).generate
      expect(url).to eq '/TrM0qqfcivb6VxS3Hxlxn43W21k=/200x300/my.domain.com/some/image/url.jpg'
    end

    it "should return proper smart url" do
      url = subject.width(200).height(300).smart(true).generate
      expect(url).to eq '/hdzhxXzK45DzNTru5urV6x6xxSs=/200x300/smart/my.domain.com/some/image/url.jpg'
    end

    it "should return proper fit-in url" do
      url = subject.width(200).height(300).fit_in(true).generate
      expect(url).to eq '/LOv6ArMOJA2VRpfMQjjs4xSyZpM=/fit-in/200x300/my.domain.com/some/image/url.jpg'
    end

    it "should return proper adaptive-fit-in url" do
      url = subject.width(200).height(300).adaptive_fit_in(true).generate
      expect(url).to eq '/V2xmSmQZm4i5-0Flx8iuRtawOkg=/adaptive-fit-in/200x300/my.domain.com/some/image/url.jpg'
    end

    it "should return proper full-fit-in url" do
      url = subject.width(200).height(300).full_fit_in(true).generate
      expect(url).to eq '/geXhR7ZFxztQTsKzmkDxYCX-HHg=/full-fit-in/200x300/my.domain.com/some/image/url.jpg'
    end

    it "should return proper adaptive-full-fit-in url" do
      url = subject.width(200).height(300).adaptive_full_fit_in(true).generate
      expect(url).to eq '/jlUfjdC-6rG6jmuHgFp6eKgPy2g=/adaptive-full-fit-in/200x300/my.domain.com/some/image/url.jpg'
    end

    [:fit_in, :full_fit_in].each do |fit|
      it "should raise error when using #{fit} without width or height" do
        subject.send(fit, true)
        expect{subject.generate}.to raise_error(ArgumentError)
      end
    end

    it "should return proper flip url if no width and height" do
      url = subject.flip(true).generate
      expect(url).to eq '/rlI4clPR-p-PR2QAxj5ZWiTfvH4=/-0x0/my.domain.com/some/image/url.jpg'
    end

    it "should return proper flop url if no width and height" do
      url = subject.flop(true).generate
      expect(url).to eq '/-4dmGj-TwIEqTAL9_9yEqUM8cks=/0x-0/my.domain.com/some/image/url.jpg'
    end

    it "should return proper flip-flop url if no width and height" do
      url = subject.flip(true).flop(true).generate
      expect(url).to eq '/FnMxpQMmxiMpdG219Dsj8pD_4Xc=/-0x-0/my.domain.com/some/image/url.jpg'
    end

    it "should return proper flip url if width" do
      url = subject.width(300).flip(true).generate
      expect(url).to eq '/ccr2PoSYcTEGL4_Wzt4u3wWVRKU=/-300x0/my.domain.com/some/image/url.jpg'
    end

    it "should return proper flop url if height" do
      url = subject.height(300).flop(true).generate
      expect(url).to eq '/R5K91tkyNgXO65F6E0txgA6C9lY=/0x-300/my.domain.com/some/image/url.jpg'
    end

    it "should return horizontal align" do
      url = subject.halign(:left).generate
      expect(url).to eq '/GTJE3wUt3sURik0O9Nae8sfI928=/left/my.domain.com/some/image/url.jpg'
    end

    it "should not return horizontal align if it is center" do
      url = subject.halign(:center).generate
      expect(url).to eq '/964rCTkAEDtvjy_a572k7kRa0SU=/my.domain.com/some/image/url.jpg'
    end

    it "should return vertical align" do
      url = subject.valign(:top).generate
      expect(url).to eq '/1QQo5ihObuhgwl95--Z3g78vjiE=/top/my.domain.com/some/image/url.jpg'
    end

    it "should not return vertical align if it is middle" do
      url = subject.valign(:middle).generate
      expect(url).to eq '/964rCTkAEDtvjy_a572k7kRa0SU=/my.domain.com/some/image/url.jpg'
    end

    it "should return halign and valign properly" do
      url = subject.halign(:left).valign(:top).generate
      expect(url).to eq '/yA2rmtWv_uzHd9klz5OuMIZ5auI=/left/top/my.domain.com/some/image/url.jpg'
    end

    it "should return meta properly" do
      url = subject.meta(true).generate
      expect(url).to eq '/WvIJFDJDePgIl5hZcLgtrzIPxfY=/meta/my.domain.com/some/image/url.jpg'
    end

    it "should return proper crop url when param is array" do
      url = subject.crop([10, 20, 30, 40]).generate
      expect(url).to eq '/QcnhqNfHwiP6BHLbD6UvneX7K28=/10x20:30x40/my.domain.com/some/image/url.jpg'
    end

    it "should return proper crop url" do
      url = subject.crop(10, 20, 30, 40).generate
      expect(url).to eq '/QcnhqNfHwiP6BHLbD6UvneX7K28=/10x20:30x40/my.domain.com/some/image/url.jpg'
    end

    it "should ignore crop if all zeros" do
      url = subject.crop(0, 0, 0, 0).generate
      expect(url).to eq '/964rCTkAEDtvjy_a572k7kRa0SU=/my.domain.com/some/image/url.jpg'
    end

    it "should have smart after halign and valign" do
      url = subject.halign(:left).valign(:top).smart(true).generate
      expect(url).to eq '/KS6mVuzlGE3hJ75n3JUonfGgSFM=/left/top/smart/my.domain.com/some/image/url.jpg'
    end

    it "should have quality filter" do
      url = subject.quality_filter(20).generate
      expect(url).to eq '/NyA-is4NojxiRqo0NcmJDhB6GTs=/filters:quality(20)/my.domain.com/some/image/url.jpg'
    end

    it "should have brightness filter" do
      url = subject.brightness_filter(30).generate
      expect(url).to eq '/oXDmnGD7vQV-rXcj8kCl1tcS3jc=/filters:brightness(30)/my.domain.com/some/image/url.jpg'
    end

    it "should have 2 filters" do
      url = subject.brightness_filter(30).quality_filter(20).generate
      expect(url).to eq '/SW9o4xQG1QAzE69WzEzarL_G3MI=/filters:brightness(30):quality(20)/my.domain.com/some/image/url.jpg'
    end

    it "should escape url args" do
      url = subject.watermark_filter('http://my-server.com/image.png', 30).quality_filter(20).generate
      expect(url).to eq '/4b9kwg0-zsojf7Ed01TPKPYOel4=/filters:watermark(http%3A%2F%2Fmy-server.com%2Fimage.png,30):quality(20)/my.domain.com/some/image/url.jpg'
    end

    it "should have trim without params" do
      url = subject.trim.generate
      expect(url).to eq '/w23BC0dUiYBFrUnuoYJe8XROuyw=/trim/my.domain.com/some/image/url.jpg'
    end

    it "should have trim with direction param" do
      url = subject.trim('bottom-right').generate
      expect(url).to eq '/kXPwSmqEvPFQezgzBCv9BtPWmBY=/trim:bottom-right/my.domain.com/some/image/url.jpg'
    end

    it "should have trim with direction and tolerance param" do
      url = subject.trim('bottom-right', 15).generate
      expect(url).to eq '/TUCEIhtWfI1Uv9zjavCSl_i0A_8=/trim:bottom-right:15/my.domain.com/some/image/url.jpg'
    end

    it "should have the right crop when cropping horizontally and given a left center" do
      url = subject.original_width(100).original_height(100).width(40).height(50).center(0, 50).generate
      expect(url).to eq '/SZIT3w4Qgebv5DuVJ8G1IH1mkCU=/0x0:80x100/40x50/my.domain.com/some/image/url.jpg'
    end

    it "should have the right crop when cropping horizontally and given a right center" do
      url = subject.original_width(100).original_height(100).width(40).height(50).center(100, 50).generate
      expect(url).to eq '/NEtCYehaISE7qR3zFj15CxnZoCs=/20x0:100x100/40x50/my.domain.com/some/image/url.jpg'
    end

    it "should have the right crop when cropping horizontally and given the actual center" do
      url = subject.original_width(100).original_height(100).width(40).height(50).center(50, 50).generate
      expect(url).to eq '/JLH65vJTu6d-cXBmqe5hYoSD4ho=/10x0:90x100/40x50/my.domain.com/some/image/url.jpg'
    end

    it "should have the right crop when cropping vertically and given a top center" do
      url = subject.original_width(100).original_height(100).width(50).height(40).center(50, 0).generate
      expect(url).to eq '/FIMZcLatW6bjgSRH9xTkEwUZAZ8=/0x0:100x80/50x40/my.domain.com/some/image/url.jpg'
    end

    it "should have the right crop when cropping vertically and given a bottom center" do
      url = subject.original_width(100).original_height(100).width(50).height(40).center(50, 100).generate
      expect(url).to eq '/9Ud0sVo6i9DLOjlKbQP_4JXgFmA=/0x20:100x100/50x40/my.domain.com/some/image/url.jpg'
    end

    it "should have the right crop when cropping vertically and given the actual center" do
      url = subject.original_width(100).original_height(100).width(50).height(40).center(50, 50).generate
      expect(url).to eq '/WejLJn8djJLn7DkMUq3S0zZCvZE=/0x10:100x90/50x40/my.domain.com/some/image/url.jpg'
    end

    it "should have the no crop when not necessary" do
      url = subject.original_width(100).original_height(100).width(50).height(50).center(50, 0).generate
      expect(url).to eq '/trIjfr513nkGkCpKXK6qgox2jPA=/50x50/my.domain.com/some/image/url.jpg'
    end

    it "should blow up with a bad center" do
      expect { subject.original_width(100).original_height(100).width(50).height(50).center(50).generate }.to raise_error(RuntimeError)
    end

    it "should have no crop with a missing original_height" do
      url = subject.original_width(100).width(50).height(40).center(50, 0).generate
      expect(url).to eq '/veYlY0msKmemAaXpeav2kCNftmU=/50x40/my.domain.com/some/image/url.jpg'
    end

    it "should have no crop with a missing original_width" do
      url = subject.original_height(100).width(50).height(40).center(50, 0).generate
      expect(url).to eq '/veYlY0msKmemAaXpeav2kCNftmU=/50x40/my.domain.com/some/image/url.jpg'
    end

    it "should have no crop with out a width and height" do
      url = subject.original_width(100).original_height(100).center(50, 50).generate
      expect(url).to eq '/964rCTkAEDtvjy_a572k7kRa0SU=/my.domain.com/some/image/url.jpg'
    end

    it "should use the original width with a missing width" do
      url = subject.original_width(100).original_height(100).height(80).center(50, 50).generate
      expect(url).to eq '/02BNIIJ9NYNV9Q03JHPtlP0DIDg=/0x10:100x90/0x80/my.domain.com/some/image/url.jpg'
    end

    it "should use the original height with a missing height" do
      url = subject.original_width(100).original_height(100).width(80).center(50, 50).generate
      expect(url).to eq '/0XL5BmMi3vlJQfw6aGOVW-M1vVI=/10x0:90x100/80x0/my.domain.com/some/image/url.jpg'
    end

    it "should have the right crop with a negative width" do
      url = subject.original_width(100).original_height(100).width(-50).height(40).center(50, 50).generate
      expect(url).to eq '/IuRNPlFlpTVol45bDkOm2PGvneo=/0x10:100x90/-50x40/my.domain.com/some/image/url.jpg'
    end

    it "should have the right crop with a negative height" do
      url = subject.original_width(100).original_height(100).width(50).height(-40).center(50, 50).generate
      expect(url).to eq '/-8IhWGEeXaY1uv945i9EHLVjwuk=/0x10:100x90/50x-40/my.domain.com/some/image/url.jpg'
    end

    it "should have the right crop with a negative height and width" do
      url = subject.original_width(100).original_height(100).width(-50).height(-40).center(50, 50).generate
      expect(url).to eq '/lfjGLTTEaW_Rcvc1q0ZhfYup2jg=/0x10:100x90/-50x-40/my.domain.com/some/image/url.jpg'
    end
  end
end
