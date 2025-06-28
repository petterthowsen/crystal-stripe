require "spec"
require "../src/stripe"

# Helper module for testing the Stripe API client
module StripeTest
  # Read the Stripe API key from external file or use fallback test key
  TEST_API_KEY = begin
    key_path = File.join(File.dirname(__FILE__), "stripe_key.txt")
    if File.exists?(key_path)
      File.read(key_path).strip
    else
      # Fallback test key (Stripe's public test key)
      "sk_test_4eC39HqLyjWDarjtT1zdp7dc"
    end
  end
  
  # Initialize Stripe with the test API key for all tests
  def self.setup
    Stripe.api_key = TEST_API_KEY
  end
  
  # Create a test client with default settings
  def self.client
    Stripe::Client.new(api_key: TEST_API_KEY)
  end
  
  # Run the given block with VCR-style test recordings
  # This is a placeholder for potential future implementation of request recording
  def self.with_vcr_recording(cassette_name, &block)
    # In the future, this could be implemented with a VCR-like library
    # For now, just run the block directly
    yield
  end
  
  # Helper method to create a mock HTTP response (for unit tests only)
  def self.mock_response(status_code : Int32, body : String)
    HTTP::Client::Response.new(status_code: status_code, body: body)
  end
  
  # Helper method to create a mock success response (for unit tests only)
  def self.mock_success_response(data : String | Hash | NamedTuple)
    body = data.is_a?(String) ? data : data.to_json
    mock_response(200, body)
  end
  
  # Helper method to create a mock error response (for unit tests only)
  def self.mock_error_response(type : String, message : String, status_code : Int32 = 400)
    body = {
      error: {
        type: type,
        message: message
      }
    }.to_json
    mock_response(status_code, body)
  end
  
  # Clean test data that might have been created
  def self.cleanup
    # Add cleanup code as needed when we have more resource types
  end
end

# Configure global test setup
StripeTest.setup

# Run cleanup after all tests
Spec.after_suite { StripeTest.cleanup }
