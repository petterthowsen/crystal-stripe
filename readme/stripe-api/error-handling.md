# Stripe Error Handling

This document details how errors are represented in the Stripe API and how they should be handled in the Crystal Stripe library.

## HTTP Status Codes

Stripe uses conventional HTTP response codes to indicate the success or failure of an API request:

- **200 - OK**: Request succeeded
- **400 - Bad Request**: Request failed due to invalid parameters
- **401 - Unauthorized**: Authentication failed
- **402 - Request Failed**: The parameters were valid but the request failed
- **403 - Forbidden**: The API key doesn't have permissions to perform the request
- **404 - Not Found**: The requested resource doesn't exist
- **409 - Conflict**: The request conflicts with another request
- **429 - Too Many Requests**: Too many requests hit the API too quickly
- **5XX - Server Errors**: Something went wrong on Stripe's end (rare)

## Error Types

Stripe errors are categorized into several types:

| Error Type | Description |
|------------|-------------|
| `api_error` | API errors cover any other type of problem (e.g., a temporary problem with Stripe's servers) |
| `card_error` | Card errors are the most common type of error. They happen when the user enters a card that can't be charged for some reason |
| `idempotency_error` | Idempotency errors occur when an `Idempotency-Key` is re-used on a request that does not match the first request's API endpoint and parameters |
| `invalid_request_error` | Invalid request errors arise when your request has invalid parameters |

## Error Object Structure

When an error occurs, Stripe returns an error object with the following attributes:

| Attribute | Type | Description |
|-----------|------|-------------|
| `code` | string (nullable) | Error code for programmatic handling |
| `decline_code` | string (nullable) | Card issuer's reason for decline |
| `message` | string (nullable) | Human-readable error message |
| `param` | string (nullable) | Parameter related to the error |
| `payment_intent` | object (nullable) | PaymentIntent object for errors on a PaymentIntent request |
| `type` | enum | Type of error |

Additional attributes that may be present:

- `advice_code`: Additional advice about the error
- `charge`: ID of the failed charge
- `doc_url`: URL to documentation about the error
- `payment_method`: Details about the payment method
- `request_log_url`: URL to the request logs

## Error Handling in Crystal

The Crystal Stripe library will provide structured error handling through exception classes:

```crystal
module Stripe
  # Base error class
  class StripeError < Exception
    property http_status : Int32
    property error : ErrorObject
    
    def initialize(@http_status, @error)
      super(@error.message || "Unknown error")
    end
  end
  
  # Specific error types
  class APIError < StripeError; end
  class CardError < StripeError; end
  class IdempotencyError < StripeError; end
  class InvalidRequestError < StripeError; end
  class AuthenticationError < StripeError; end
  class APIConnectionError < StripeError; end
  class RateLimitError < StripeError; end
end
```

## Error Handling Example

Here's how error handling will work in the Crystal library:

```crystal
begin
  charge = stripe_client.charges.create(
    amount: 2000,
    currency: "usd",
    source: "tok_visa", # Use a token or source ID
    description: "My First Test Charge"
  )
  # Handle successful charge
rescue Stripe::CardError => e
  # Handle card error
  puts "Status: #{e.http_status}"
  puts "Type: #{e.error.type}"
  puts "Code: #{e.error.code}"
  puts "Message: #{e.error.message}"
  # Take appropriate action based on the error
rescue Stripe::InvalidRequestError => e
  # Handle invalid parameters
  puts "Invalid parameters: #{e.error.param} - #{e.error.message}"
rescue Stripe::AuthenticationError => e
  # Handle authentication error
  puts "Authentication failed: #{e.error.message}"
rescue Stripe::APIConnectionError => e
  # Handle network error
  puts "Network error: #{e.message}"
rescue Stripe::StripeError => e
  # Handle generic error
  puts "Error: #{e.message}"
end
```

## Best Practices for Error Handling

1. **Catch Specific Exceptions**: Catch specific exception types before catching the general `StripeError`.

2. **Check Error Codes**: For card errors, check the `code` and `decline_code` to handle specific cases.

3. **Display User-Friendly Messages**: Use the `message` field for card errors to display to users.

4. **Log Detailed Information**: Log detailed error information for debugging.

5. **Implement Retry Logic**: For network errors or server errors, implement retry logic with exponential backoff.

6. **Handle Idempotency**: When retrying requests, use idempotency keys to prevent duplicate processing.

## Common Error Codes

### Card Error Codes

- `card_declined`: The card was declined
- `expired_card`: The card has expired
- `incorrect_cvc`: The CVC number is incorrect
- `processing_error`: An error occurred while processing the card
- `incorrect_number`: The card number is incorrect

### API Error Codes

- `rate_limit_exceeded`: Too many requests made to the API too quickly
- `invalid_request_error`: The request contains invalid parameters
- `authentication_required`: The card requires authentication
- `api_connection_error`: Failed to connect to Stripe's API

For a complete list of error codes, refer to the [Stripe API Error Codes documentation](https://docs.stripe.com/error-codes).
