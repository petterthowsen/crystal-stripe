require "../spec_helper"

# Helper module for test-only methods to make testing easier
module TestHelpers
  # Wrapper for a client to expose private methods for testing
  class ClientWrapper
    def initialize(@client : Stripe::Client)
    end
    
    # Expose the private method for testing
    def flatten_params(params)
      # In Crystal, we can call private methods directly in spec files
      # by using the special syntax with underscore prefix
      @client.__flatten_params(params)
    end
  end
end

describe Stripe::Client do
  describe "#initialize" do
    it "initializes with API key" do
      client = Stripe::Client.new(api_key: StripeTest::TEST_API_KEY)
      client.api_key.should eq(StripeTest::TEST_API_KEY)
    end

    it "initializes with default API version" do
      client = Stripe::Client.new(api_key: StripeTest::TEST_API_KEY)
      client.api_version.should eq(Stripe::Client::API_VERSION)
    end

    it "initializes with custom API version" do
      custom_version = "2023-10-16"
      client = Stripe::Client.new(
        api_key: StripeTest::TEST_API_KEY,
        api_version: custom_version
      )
      client.api_version.should eq(custom_version)
    end

    it "initializes with stripe_account" do
      stripe_account = "acct_123456789"
      client = Stripe::Client.new(
        api_key: StripeTest::TEST_API_KEY,
        stripe_account: stripe_account
      )
      client.stripe_account.should eq(stripe_account)
    end
  end

  describe "#request" do
    # Instead of mocking, we're using Stripe's test mode to test real API behavior
    
    it "successfully makes GET requests" do
      client = StripeTest.client
      response = client.request(:get, "/v1/balance")
      
      # Verify the response structure
      response["object"].as_s.should eq("balance")
      # Check that available and pending are arrays without expecting specific object types
      response["available"].as_a.size.should be >= 0
      response["pending"].as_a.size.should be >= 0
    end
    
    it "raises InvalidRequestError for invalid requests" do
      client = StripeTest.client
      
      # Attempt to create a charge without required parameters
      # The exact error message depends on Stripe's API version and may change
      expect_raises(Stripe::InvalidRequestError) do
        client.request(:post, "/v1/charges", {"currency" => "usd"})
      end
    end

    it "raises error with invalid API key" do
      # Create a client with an invalid key
      client = Stripe::Client.new(api_key: "sk_test_invalid")
      
      # Stripe's API might return different error types for authentication issues
      # depending on the API version, so we'll check for either type of error
      begin
        client.request(:get, "/v1/balance")
        fail("Expected to raise an error with invalid API key")
      rescue e : Stripe::InvalidRequestError | Stripe::AuthenticationError
        e.message.to_s.should contain("Invalid API Key")
      end
    end

    it "handles idempotency keys correctly" do
      # This is a simple test to check that the idempotency mechanism doesn't break
      # We're not actually testing full idempotency behavior here
      client = StripeTest.client
      
      # Use a random idempotency key
      idempotency_key = "test-key-#{Random.new.rand(10000)}"
      
      # Make a simple request with idempotency key
      # This should not raise any errors related to idempotency keys
      response = client.request(:get, "/v1/balance", nil, nil, idempotency_key)
      response["object"].as_s.should eq("balance")
    end
  end

  # Testing methods exposed by TestHelpers module
  
  # Testing private methods for better coverage
  describe "#flatten_params" do
    it "flattens simple parameters" do
      client = Stripe::Client.new(api_key: StripeTest::TEST_API_KEY)
      wrapper = TestHelpers::ClientWrapper.new(client)
      params = {
        "amount" => 2000,
        "currency" => "usd"
      }
      
      result = wrapper.flatten_params(params)
      result.should eq({
        "amount" => "2000",
        "currency" => "usd"
      })
    end

    it "flattens nested parameters" do
      client = Stripe::Client.new(api_key: StripeTest::TEST_API_KEY)
      wrapper = TestHelpers::ClientWrapper.new(client)
      params = {
        "amount" => 2000,
        "customer" => {
          "email" => "customer@example.com",
          "metadata" => {
            "order_id" => "6735"
          }
        }
      }
      
      result = wrapper.flatten_params(params)
      result.should eq({
        "amount" => "2000",
        "customer[email]" => "customer@example.com",
        "customer[metadata][order_id]" => "6735"
      })
    end

    it "flattens array parameters" do
      client = Stripe::Client.new(api_key: StripeTest::TEST_API_KEY)
      wrapper = TestHelpers::ClientWrapper.new(client)
      params = {
        "items" => [
          { "price" => "price_1", "quantity" => 2 },
          { "price" => "price_2", "quantity" => 1 }
        ]
      }
      
      result = wrapper.flatten_params(params)
      result.should eq({
        "items[0][price]" => "price_1",
        "items[0][quantity]" => "2",
        "items[1][price]" => "price_2",
        "items[1][quantity]" => "1"
      })
    end
  end
end
