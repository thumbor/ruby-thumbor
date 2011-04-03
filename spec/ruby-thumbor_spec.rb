require File.dirname(__FILE__) + '/spec_helper.rb'

describe CryptoURL, "#new" do
  
  it "should create a new instance passing key and keep it" do
    crypto = CryptoURL.new 'my-security-key'
    crypto.key.should == 'my-security-key'
  end
  
end
