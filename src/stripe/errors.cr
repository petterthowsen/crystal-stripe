module Stripe
  # Base exception class for all Stripe errors
  class StripeError < Exception
    # HTTP status code from the Stripe API response
    getter status_code : Int32
    
    # Creates a new Stripe error
    # @param status_code [Int32] HTTP status code
    # @param message [String] Error message
    def initialize(@status_code : Int32, message : String)
      super(message)
    end
  end
  
  # Error raised when there's a problem with your Stripe account authentication
  class AuthenticationError < StripeError
  end
  
  # Error raised when the Stripe API returns a server error
  class APIError < StripeError
  end
  
  # Error raised when a card operation is declined
  class CardError < StripeError
    # Error code explaining the reason for the card error
    getter code : String?
    
    # The parameter that caused the error, if applicable
    getter param : String?
    
    # The decline code from the card issuer, if available
    getter decline_code : String?
    
    # Creates a new card error
    # @param status_code [Int32] HTTP status code
    # @param message [String] Error message
    # @param code [String?] Card error code
    # @param param [String?] The parameter that caused the error
    # @param decline_code [String?] The decline code from the card issuer
    def initialize(
      status_code : Int32,
      message : String,
      @code : String? = nil,
      @param : String? = nil,
      @decline_code : String? = nil
    )
      super(status_code, message)
    end
  end
  
  # Error raised when making an invalid request to the Stripe API
  class InvalidRequestError < StripeError
    # The parameter that caused the error, if applicable
    getter param : String?
    
    # Creates a new invalid request error
    # @param status_code [Int32] HTTP status code
    # @param message [String] Error message
    # @param param [String?] The parameter that caused the error
    def initialize(
      status_code : Int32,
      message : String,
      @param : String? = nil
    )
      super(status_code, message)
    end
  end
  
  # Error raised when you've hit Stripe's rate limit
  class RateLimitError < StripeError
  end
  
  # Error raised when there's an issue with idempotency
  class IdempotencyError < StripeError
  end
  
  # Error raised when there's an issue with a connection to Stripe's API
  class APIConnectionError < StripeError
    # @param message [String] Error message
    # @param status_code [Int32] HTTP status code if available
    def initialize(message : String, status_code : Int32 = 0)
      super(status_code, message)
    end
  end
  
  # Error raised when there's an issue with permissions for a Connect account
  class PermissionError < StripeError
  end
  
  # Error raised when there's an issue with signing a webhook event
  class SignatureVerificationError < StripeError
    # HTTP status code (always 401 for signature errors)
    def initialize(message : String)
      super(401, message)
    end
  end
end
