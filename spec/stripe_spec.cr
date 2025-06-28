require "./spec_helper"

describe Stripe do
  it "has a VERSION" do
    Stripe::VERSION.should_not be_nil
  end
  
  it "can initialize a client" do
    client = Stripe::Client.new(api_key: StripeTest::TEST_API_KEY)
    client.should be_a(Stripe::Client)
  end
end
