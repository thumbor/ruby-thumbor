require File.dirname(__FILE__) + '/spec_helper.rb'

describe Thumbor::CryptoURL, "#new" do
  
  it "should create a new instance passing key and keep it" do
    crypto = Thumbor::CryptoURL.new 'my-security-key'
    crypto.key.should == 'my-security-keymy'
  end
  
end

describe Thumbor::CryptoURL, "#generate" do
  
  it "should create a new instance passing key and keep it" do
    crypto = Thumbor::CryptoURL.new 'my-security-key'

    url = crypto.generate :width => 300, :height => 200, :image => 'my.domain.com/some/image/url.jpg'

    url.should == '/qkLDiIbvtiks0Up9n5PACtmpOfX6dPXw4vP4kJU-jTfyF6y1GJBJyp7CHYh1H3R2/my.domain.com/some/image/url.jpg'
  end
  
end
