# Stripe Client Implementation

The `Stripe::Client` class is the core component of the library, handling authentication, request formatting, and response parsing for all Stripe API interactions.

## Client Initialization

```crystal
# Basic initialization with API key
client = Stripe::Client.new(api_key: "sk_test_your_test_key")

# With custom API version
client = Stripe::Client.new(
  api_key: "sk_test_your_test_key",
  api_version: "2023-10-16"
)

# For connected accounts
client = Stripe::Client.new(
  api_key: "sk_test_your_test_key",
  stripe_account: "acct_1032D82eZvKYlo2C"
)
```

## Making API Requests

The client provides a low-level `request` method for making any type of request to the Stripe API:

```crystal
# GET request
response = client.request(:get, "/v1/balance")

# POST request with parameters
response = client.request(
  :post, 
  "/v1/charges", 
  {
    "amount" => 2000,
    "currency" => "usd",
    "source" => "tok_visa",
    "description" => "My First Test Charge (created for API docs)"
  }
)

# DELETE request
response = client.request(:delete, "/v1/subscriptions/sub_12345")
```

The `response` is a `JSON::Any` object that provides access to the parsed JSON response from the Stripe API.

## Parameter Handling

The client automatically handles the conversion of parameters to the format expected by the Stripe API, including:

- Converting nested Hash/NamedTuple objects to `param[key]` format
- Converting arrays to indexed parameters
- Converting all values to strings
- Skipping nil values

Example of parameter flattening:

```crystal
params = {
  "amount" => 2000,
  "currency" => "usd",
  "customer" => {
    "email" => "customer@example.com",
    "metadata" => {
      "order_id" => "6735"
    }
  },
  "items" => [
    { "price" => "price_1", "quantity" => 2 },
    { "price" => "price_2", "quantity" => 1 }
  ]
}

# Will be flattened to:
# {
#   "amount" => "2000",
#   "currency" => "usd",
#   "customer[email]" => "customer@example.com",
#   "customer[metadata][order_id]" => "6735",
#   "items[0][price]" => "price_1",
#   "items[0][quantity]" => "2",
#   "items[1][price]" => "price_2",
#   "items[1][quantity]" => "1"
# }
```

## Idempotency Keys

For POST requests, you can provide an idempotency key to prevent duplicate processing:

```crystal
response = client.request(
  :post, 
  "/v1/charges", 
  {
    "amount" => 2000,
    "currency" => "usd",
    "source" => "tok_visa"
  },
  idempotency_key: "a-unique-key"
)
```

## Error Handling

The client automatically raises appropriate error types for different API error scenarios:

```crystal
begin
  client.request(:post, "/v1/charges", {"currency" => "usd"})
rescue e : Stripe::InvalidRequestError
  puts "Invalid request: #{e.message}"
rescue e : Stripe::AuthenticationError
  puts "Authentication error: #{e.message}"
rescue e : Stripe::APIError
  puts "API error: #{e.message}"
end
```

See [Error Handling](error-handling.md) for more details on the available error types.
