# frozen_string_literal: true

require 'spec_helper'
require 'json'
require 'ruby-thumbor'

describe Thumbor::Cascade do
  subject(:cascade_instance) { described_class.new key, image_url }

  let(:image_url) { 'my.domain.com/some/image/url.jpg' }
  let(:key) { 'my-security-key' }

  it 'raises an error' do
    expect { cascade_instance.god_of_war_crop }.to raise_error(NoMethodError)
  end

  it 'responds to filter methods' do
    expect(cascade_instance).to respond_to('quality_filter')
  end

  describe '#generate' do
    it 'creates an unsafe url' do
      url = described_class.new(nil, image_url).width(300).height(200).generate
      expect(url).to eq '/unsafe/300x200/my.domain.com/some/image/url.jpg'
    end

    it 'creates an url with debug' do
      url = cascade_instance.debug(true).height(200).generate
      expect(url).to eq '/5_eX4HHQYk81HQVkc1gBIAvPbLo=/debug/0x200/my.domain.com/some/image/url.jpg'
    end

    it 'creates a new instance with width and height' do
      url = cascade_instance.width(300).height(200).generate
      expect(url).to eq '/TQfyd3H36Z3srcNcLOYiM05YNO8=/300x200/my.domain.com/some/image/url.jpg'
    end

    it 'is able to change the Thumbor key' do
      url1 = cascade_instance.width(300).height(200).generate
      url2 = described_class.new('another-thumbor-key', image_url).width(300).height(200).generate
      expect(url1).not_to eq url2
    end

    it 'creates a new instance with width, height and meta' do
      url = cascade_instance.width(300).height(200).meta(true).generate
      expect(url).to eq '/YBQEWd3g_WRMnVEG73zfzcr8Zj0=/meta/300x200/my.domain.com/some/image/url.jpg'
    end

    it 'creates a new instance with width, height, meta and smart' do
      url = cascade_instance.width(300).height(200).meta(true).smart(true).generate
      expect(url).to eq '/jP89J0qOWHgPlm_lOA28GtOh5GU=/meta/300x200/smart/my.domain.com/some/image/url.jpg'
    end

    it 'creates a new instance with width, height, meta, smart and fit_in' do
      url = cascade_instance.width(300).height(200).meta(true).smart(true).fit_in(true).generate
      expect(url).to eq '/zrrOh_TtTs4kiLLEQq1w4bcTYdc=/meta/fit-in/300x200/smart/my.domain.com/some/image/url.jpg'
    end

    it 'creates a new instance with width, height, meta, smart, fit_in and flip' do
      url = cascade_instance.width(300).height(200).meta(true).smart(true).fit_in(true).flip(true).generate
      expect(url).to eq '/4t1XK1KH43cOb1QJ9tU00-W2_k8=/meta/fit-in/-300x200/smart/my.domain.com/some/image/url.jpg'
    end

    it 'creates a new instance with width, height, meta, smart, fit_in, flip and flop' do
      url = cascade_instance.width(300).height(200).meta(true).smart(true).fit_in(true).flip(true).flop(true).generate
      expect(url).to eq '/HJnvjZU69PkPOhyZGu-Z3Uc_W_A=/meta/fit-in/-300x-200/smart/my.domain.com/some/image/url.jpg'
    end

    it 'creates a new instance with quality and brigthness filter' do
      url = cascade_instance.quality_filter(20).brightness_filter(10).generate
      expect(url).to eq '/q0DiFg-5-eFZIqyN3lRoCvg2K0s=/filters:quality(20):brightness(10)/my.domain.com/some/image/url.jpg'
    end

    it 'returns just the image hash if no arguments passed' do
      url = cascade_instance.generate
      expect(url).to eq '/964rCTkAEDtvjy_a572k7kRa0SU=/my.domain.com/some/image/url.jpg'
    end

    it 'raises if no image passed' do
      expect { described_class.new.generate }.to raise_error(RuntimeError)
    end

    it 'returns proper url for width-only' do
      url = cascade_instance.width(300).generate
      expect(url).to eq '/eFwrBWryxtRw9hDSbQPhi5iLpo8=/300x0/my.domain.com/some/image/url.jpg'
    end

    it 'returns proper url for height-only' do
      url = cascade_instance.height(300).generate
      expect(url).to eq '/-VGIgp7g8cMKcfF2gFK9ZpmB_5w=/0x300/my.domain.com/some/image/url.jpg'
    end

    it 'returns proper url for width and height' do
      url = cascade_instance.width(200).height(300).generate
      expect(url).to eq '/TrM0qqfcivb6VxS3Hxlxn43W21k=/200x300/my.domain.com/some/image/url.jpg'
    end

    it 'returns proper smart url' do
      url = cascade_instance.width(200).height(300).smart(true).generate
      expect(url).to eq '/hdzhxXzK45DzNTru5urV6x6xxSs=/200x300/smart/my.domain.com/some/image/url.jpg'
    end

    it 'returns proper fit-in url' do
      url = cascade_instance.width(200).height(300).fit_in(true).generate
      expect(url).to eq '/LOv6ArMOJA2VRpfMQjjs4xSyZpM=/fit-in/200x300/my.domain.com/some/image/url.jpg'
    end

    it 'returns proper adaptive-fit-in url' do
      url = cascade_instance.width(200).height(300).adaptive_fit_in(true).generate
      expect(url).to eq '/V2xmSmQZm4i5-0Flx8iuRtawOkg=/adaptive-fit-in/200x300/my.domain.com/some/image/url.jpg'
    end

    it 'returns proper full-fit-in url' do
      url = cascade_instance.width(200).height(300).full_fit_in(true).generate
      expect(url).to eq '/geXhR7ZFxztQTsKzmkDxYCX-HHg=/full-fit-in/200x300/my.domain.com/some/image/url.jpg'
    end

    it 'returns proper adaptive-full-fit-in url' do
      url = cascade_instance.width(200).height(300).adaptive_full_fit_in(true).generate
      expect(url).to eq '/jlUfjdC-6rG6jmuHgFp6eKgPy2g=/adaptive-full-fit-in/200x300/my.domain.com/some/image/url.jpg'
    end

    %i[fit_in full_fit_in].each do |fit|
      it "raises error when using #{fit} without width or height" do
        cascade_instance.send(fit, true)
        expect { cascade_instance.generate }.to raise_error(ArgumentError)
      end
    end

    it 'returns proper flip url if no width and height' do
      url = cascade_instance.flip(true).generate
      expect(url).to eq '/rlI4clPR-p-PR2QAxj5ZWiTfvH4=/-0x0/my.domain.com/some/image/url.jpg'
    end

    it 'returns proper flop url if no width and height' do
      url = cascade_instance.flop(true).generate
      expect(url).to eq '/-4dmGj-TwIEqTAL9_9yEqUM8cks=/0x-0/my.domain.com/some/image/url.jpg'
    end

    it 'returns proper flip-flop url if no width and height' do
      url = cascade_instance.flip(true).flop(true).generate
      expect(url).to eq '/FnMxpQMmxiMpdG219Dsj8pD_4Xc=/-0x-0/my.domain.com/some/image/url.jpg'
    end

    it 'returns proper flip url if width' do
      url = cascade_instance.width(300).flip(true).generate
      expect(url).to eq '/ccr2PoSYcTEGL4_Wzt4u3wWVRKU=/-300x0/my.domain.com/some/image/url.jpg'
    end

    it 'returns proper flop url if height' do
      url = cascade_instance.height(300).flop(true).generate
      expect(url).to eq '/R5K91tkyNgXO65F6E0txgA6C9lY=/0x-300/my.domain.com/some/image/url.jpg'
    end

    it 'returns horizontal align' do
      url = cascade_instance.halign(:left).generate
      expect(url).to eq '/GTJE3wUt3sURik0O9Nae8sfI928=/left/my.domain.com/some/image/url.jpg'
    end

    it 'does not return horizontal align if it is center' do
      url = cascade_instance.halign(:center).generate
      expect(url).to eq '/964rCTkAEDtvjy_a572k7kRa0SU=/my.domain.com/some/image/url.jpg'
    end

    it 'returns vertical align' do
      url = cascade_instance.valign(:top).generate
      expect(url).to eq '/1QQo5ihObuhgwl95--Z3g78vjiE=/top/my.domain.com/some/image/url.jpg'
    end

    it 'does not return vertical align if it is middle' do
      url = cascade_instance.valign(:middle).generate
      expect(url).to eq '/964rCTkAEDtvjy_a572k7kRa0SU=/my.domain.com/some/image/url.jpg'
    end

    it 'returns halign and valign properly' do
      url = cascade_instance.halign(:left).valign(:top).generate
      expect(url).to eq '/yA2rmtWv_uzHd9klz5OuMIZ5auI=/left/top/my.domain.com/some/image/url.jpg'
    end

    it 'returns meta properly' do
      url = cascade_instance.meta(true).generate
      expect(url).to eq '/WvIJFDJDePgIl5hZcLgtrzIPxfY=/meta/my.domain.com/some/image/url.jpg'
    end

    it 'returns proper crop url when param is array' do
      url = cascade_instance.crop([10, 20, 30, 40]).generate
      expect(url).to eq '/QcnhqNfHwiP6BHLbD6UvneX7K28=/10x20:30x40/my.domain.com/some/image/url.jpg'
    end

    it 'returns proper crop url' do
      url = cascade_instance.crop(10, 20, 30, 40).generate
      expect(url).to eq '/QcnhqNfHwiP6BHLbD6UvneX7K28=/10x20:30x40/my.domain.com/some/image/url.jpg'
    end

    it 'ignores crop if all zeros' do
      url = cascade_instance.crop(0, 0, 0, 0).generate
      expect(url).to eq '/964rCTkAEDtvjy_a572k7kRa0SU=/my.domain.com/some/image/url.jpg'
    end

    it 'has smart after halign and valign' do
      url = cascade_instance.halign(:left).valign(:top).smart(true).generate
      expect(url).to eq '/KS6mVuzlGE3hJ75n3JUonfGgSFM=/left/top/smart/my.domain.com/some/image/url.jpg'
    end

    it 'has quality filter' do
      url = cascade_instance.quality_filter(20).generate
      expect(url).to eq '/NyA-is4NojxiRqo0NcmJDhB6GTs=/filters:quality(20)/my.domain.com/some/image/url.jpg'
    end

    it 'has brightness filter' do
      url = cascade_instance.brightness_filter(30).generate
      expect(url).to eq '/oXDmnGD7vQV-rXcj8kCl1tcS3jc=/filters:brightness(30)/my.domain.com/some/image/url.jpg'
    end

    it 'has 2 filters' do
      url = cascade_instance.brightness_filter(30).quality_filter(20).generate
      expect(url).to eq '/SW9o4xQG1QAzE69WzEzarL_G3MI=/filters:brightness(30):quality(20)/my.domain.com/some/image/url.jpg'
    end

    it 'escapes url args' do
      url = cascade_instance.watermark_filter('http://my-server.com/image.png', 30).quality_filter(20).generate
      expect(url).to eq '/4b9kwg0-zsojf7Ed01TPKPYOel4=/filters:watermark(http%3A%2F%2Fmy-server.com%2Fimage.png,30):quality(20)/my.domain.com/some/image/url.jpg'
    end

    it 'has trim without params' do
      url = cascade_instance.trim.generate
      expect(url).to eq '/w23BC0dUiYBFrUnuoYJe8XROuyw=/trim/my.domain.com/some/image/url.jpg'
    end

    it 'has trim with direction param' do
      url = cascade_instance.trim('bottom-right').generate
      expect(url).to eq '/kXPwSmqEvPFQezgzBCv9BtPWmBY=/trim:bottom-right/my.domain.com/some/image/url.jpg'
    end

    it 'has trim with direction and tolerance param' do
      url = cascade_instance.trim('bottom-right', 15).generate
      expect(url).to eq '/TUCEIhtWfI1Uv9zjavCSl_i0A_8=/trim:bottom-right:15/my.domain.com/some/image/url.jpg'
    end

    it 'has the right crop when cropping horizontally and given a left center' do
      url = cascade_instance.original_width(100).original_height(100).width(40).height(50).center(0, 50).generate
      expect(url).to eq '/SZIT3w4Qgebv5DuVJ8G1IH1mkCU=/0x0:80x100/40x50/my.domain.com/some/image/url.jpg'
    end

    it 'has the right crop when cropping horizontally and given a right center' do
      url = cascade_instance.original_width(100).original_height(100).width(40).height(50).center(100, 50).generate
      expect(url).to eq '/NEtCYehaISE7qR3zFj15CxnZoCs=/20x0:100x100/40x50/my.domain.com/some/image/url.jpg'
    end

    it 'has the right crop when cropping horizontally and given the actual center' do
      url = cascade_instance.original_width(100).original_height(100).width(40).height(50).center(50, 50).generate
      expect(url).to eq '/JLH65vJTu6d-cXBmqe5hYoSD4ho=/10x0:90x100/40x50/my.domain.com/some/image/url.jpg'
    end

    it 'has the right crop when cropping vertically and given a top center' do
      url = cascade_instance.original_width(100).original_height(100).width(50).height(40).center(50, 0).generate
      expect(url).to eq '/FIMZcLatW6bjgSRH9xTkEwUZAZ8=/0x0:100x80/50x40/my.domain.com/some/image/url.jpg'
    end

    it 'has the right crop when cropping vertically and given a bottom center' do
      url = cascade_instance.original_width(100).original_height(100).width(50).height(40).center(50, 100).generate
      expect(url).to eq '/9Ud0sVo6i9DLOjlKbQP_4JXgFmA=/0x20:100x100/50x40/my.domain.com/some/image/url.jpg'
    end

    it 'has the right crop when cropping vertically and given the actual center' do
      url = cascade_instance.original_width(100).original_height(100).width(50).height(40).center(50, 50).generate
      expect(url).to eq '/WejLJn8djJLn7DkMUq3S0zZCvZE=/0x10:100x90/50x40/my.domain.com/some/image/url.jpg'
    end

    it 'has the no crop when not necessary' do
      url = cascade_instance.original_width(100).original_height(100).width(50).height(50).center(50, 0).generate
      expect(url).to eq '/trIjfr513nkGkCpKXK6qgox2jPA=/50x50/my.domain.com/some/image/url.jpg'
    end

    it 'blows up with a bad center' do
      expect do
        cascade_instance.original_width(100).original_height(100).width(50).height(50).center(50).generate
      end.to raise_error(RuntimeError)
    end

    it 'has no crop with a missing original_height' do
      url = cascade_instance.original_width(100).width(50).height(40).center(50, 0).generate
      expect(url).to eq '/veYlY0msKmemAaXpeav2kCNftmU=/50x40/my.domain.com/some/image/url.jpg'
    end

    it 'has no crop with a missing original_width' do
      url = cascade_instance.original_height(100).width(50).height(40).center(50, 0).generate
      expect(url).to eq '/veYlY0msKmemAaXpeav2kCNftmU=/50x40/my.domain.com/some/image/url.jpg'
    end

    it 'has no crop with out a width and height' do
      url = cascade_instance.original_width(100).original_height(100).center(50, 50).generate
      expect(url).to eq '/964rCTkAEDtvjy_a572k7kRa0SU=/my.domain.com/some/image/url.jpg'
    end

    it 'uses the original width with a missing width' do
      url = cascade_instance.original_width(100).original_height(100).height(80).center(50, 50).generate
      expect(url).to eq '/02BNIIJ9NYNV9Q03JHPtlP0DIDg=/0x10:100x90/0x80/my.domain.com/some/image/url.jpg'
    end

    it 'uses the original height with a missing height' do
      url = cascade_instance.original_width(100).original_height(100).width(80).center(50, 50).generate
      expect(url).to eq '/0XL5BmMi3vlJQfw6aGOVW-M1vVI=/10x0:90x100/80x0/my.domain.com/some/image/url.jpg'
    end

    it 'has the right crop with a negative width' do
      url = cascade_instance.original_width(100).original_height(100).width(-50).height(40).center(50, 50).generate
      expect(url).to eq '/IuRNPlFlpTVol45bDkOm2PGvneo=/0x10:100x90/-50x40/my.domain.com/some/image/url.jpg'
    end

    it 'has the right crop with a negative height' do
      url = cascade_instance.original_width(100).original_height(100).width(50).height(-40).center(50, 50).generate
      expect(url).to eq '/-8IhWGEeXaY1uv945i9EHLVjwuk=/0x10:100x90/50x-40/my.domain.com/some/image/url.jpg'
    end

    it 'has the right crop with a negative height and width' do
      url = cascade_instance.original_width(100).original_height(100).width(-50).height(-40).center(50, 50).generate
      expect(url).to eq '/lfjGLTTEaW_Rcvc1q0ZhfYup2jg=/0x10:100x90/-50x-40/my.domain.com/some/image/url.jpg'
    end
  end
end
