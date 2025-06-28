# Stripe Error Handling

The Crystal Stripe library implements a comprehensive error handling system that maps Stripe API errors to specific Crystal exception classes.

## Error Hierarchy

All Stripe errors inherit from `Stripe::StripeError`, allowing you to catch any Stripe-related error or specific error types as needed:

```
Stripe::StripeError
├── Stripe::APIError
├── Stripe::AuthenticationError
├── Stripe::CardError
├── Stripe::InvalidRequestError
├── Stripe::RateLimitError
└── Stripe::APIConnectionError
```

## Error Types

### Stripe::APIError

A general API error that occurs when something unexpected happens on Stripe's end.

```crystal
begin
  client.request(:get, "/v1/balance")
rescue e : Stripe::APIError
  puts "An unexpected error occurred: #{e.message}"
end
```

### Stripe::AuthenticationError

Raised when authentication with the Stripe API fails, typically due to an invalid API key.

```crystal
begin
  client = Stripe::Client.new(api_key: "invalid_key")
  client.request(:get, "/v1/balance")
rescue e : Stripe::AuthenticationError
  puts "Authentication failed: #{e.message}"
end
```

### Stripe::CardError

Raised when a card payment fails for various reasons like insufficient funds, expired card, etc.

```crystal
begin
  client.request(:post, "/v1/charges", {
    "amount" => 2000,
    "currency" => "usd",
    "source" => "tok_chargeDeclined" # Test token for a declined card
  })
rescue e : Stripe::CardError
  puts "Card was declined: #{e.message}"
  puts "Decline code: #{e.code}"
end
```

### Stripe::InvalidRequestError

Raised when the request contains invalid parameters or is malformed.

```crystal
begin
  client.request(:post, "/v1/charges", {"currency" => "usd"})
rescue e : Stripe::InvalidRequestError
  puts "Invalid request: #{e.message}"
  puts "Parameter: #{e.param}" if e.param
end
```

### Stripe::RateLimitError

Raised when you've hit Stripe's rate limit for API requests.

```crystal
begin
  # Making too many requests in a short period
  100.times { client.request(:get, "/v1/balance") }
rescue e : Stripe::RateLimitError
  puts "Rate limited: #{e.message}"
end
```

### Stripe::APIConnectionError

Raised when the library can't connect to the Stripe API, typically due to network issues.

```crystal
begin
  # This would happen if Stripe's API is unreachable
  client.request(:get, "/v1/balance")
rescue e : Stripe::APIConnectionError
  puts "Connection error: #{e.message}"
end
```

## Error Attributes

Most Stripe errors include additional information:

- `message`: Human-readable error message
- `http_status`: The HTTP status code from the Stripe API
- `http_body`: The raw response body from Stripe
- `json_body`: The parsed JSON response (if available)
- `code`: Error code (for `CardError`)
- `param`: The parameter that caused the error (for `InvalidRequestError`)

## Handling Errors in Code

Best practice is to catch specific errors first, then handle more general error cases:

```crystal
begin
  client.request(:post, "/v1/charges", charge_params)
rescue e : Stripe::CardError
  # Handle declined card
  puts "Card was declined: #{e.message}"
rescue e : Stripe::InvalidRequestError
  # Handle invalid request parameters
  puts "Invalid request: #{e.message}"
rescue e : Stripe::AuthenticationError
  # Handle authentication errors
  puts "Authentication failed: #{e.message}"
rescue e : Stripe::APIError
  # Handle unexpected API errors
  puts "API error: #{e.message}"
rescue e : Stripe::StripeError
  # Catch any other Stripe errors
  puts "Something went wrong: #{e.message}"
end
```
