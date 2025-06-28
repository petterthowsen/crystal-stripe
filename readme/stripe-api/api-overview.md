# Stripe API Overview

This document provides an overview of the Stripe API for the Crystal Stripe library implementation.

## Base URL

All API requests are made to:

```
https://api.stripe.com
```

## Authentication

The Stripe API uses API keys to authenticate requests. You can view and manage your API keys in the [Stripe Dashboard](https://dashboard.stripe.com/apikeys).

### API Keys

- **Test mode keys**: Have the prefix `sk_test_`
- **Live mode keys**: Have the prefix `sk_live_`
- **Restricted API keys**: Can be used for granular permissions

### Security Best Practices

- Keep your API keys secure and do not share them in publicly accessible areas
- All API requests must be made over HTTPS
- API requests without authentication will fail

### Authentication Example

```crystal
# Example of how authentication will work in the Crystal library
client = Stripe::Client.new(api_key: "sk_test_your_test_key")
```

## API Versioning

Stripe uses API versioning to ensure backward compatibility. Each major release includes changes that aren't backward-compatible with previous releases.

### Current Version

The current version as of this writing is `2025-05-28.basil`.

### Version Specification

You can specify the API version in your requests:

```crystal
# Example of how to specify API version in the Crystal library
client = Stripe::Client.new(
  api_key: "sk_test_your_test_key",
  api_version: "2025-05-28.basil"
)
```

### Versioning Best Practices

- Test new API versions before committing to an upgrade
- Check the [API changelog](https://docs.stripe.com/changelog) for information on all API versions

## Error Handling

Stripe uses conventional HTTP response codes to indicate success or failure of an API request:

- **2xx**: Success
- **4xx**: Error based on provided information (e.g., missing parameter, card declined)
- **5xx**: Stripe server error (rare)

### Error Object Attributes

| Attribute | Type | Description |
|-----------|------|-------------|
| `code` | string (nullable) | Short string indicating the error code |
| `decline_code` | string (nullable) | For card errors, indicates the card issuer's reason for decline |
| `message` | string (nullable) | Human-readable message about the error |
| `param` | string (nullable) | Parameter related to the error |
| `payment_intent` | object (nullable) | PaymentIntent object for errors on a PaymentIntent request |
| `type` | enum | Type of error: `api_error`, `card_error`, `idempotency_error`, or `invalid_request_error` |

### Error Handling Example

```crystal
# Example of how error handling will work in the Crystal library
begin
  charge = client.charges.create(amount: 2000, currency: "usd", source: "tok_visa")
rescue Stripe::CardError => e
  # Handle card error
  puts "Status: #{e.http_status}"
  puts "Type: #{e.error.type}"
  puts "Code: #{e.error.code}"
  puts "Message: #{e.error.message}"
rescue Stripe::InvalidRequestError => e
  # Handle invalid parameters
rescue Stripe::AuthenticationError => e
  # Handle authentication error
rescue Stripe::APIConnectionError => e
  # Handle network error
rescue Stripe::StripeError => e
  # Handle generic error
rescue Exception => e
  # Handle other errors
end
```

## Connected Accounts

To act as connected accounts, clients can issue requests using the `Stripe-Account` header. This header should contain a Stripe account ID, which usually starts with the `acct_` prefix.

```crystal
# Example of how to make requests on behalf of a connected account
client = Stripe::Client.new(
  api_key: "sk_test_your_test_key",
  stripe_account: "acct_1032D82eZvKYlo2C"
)
```

## Idempotency

To avoid duplicate processing of requests, Stripe supports idempotency keys. By providing an idempotent key, you can make the same request multiple times without performing the action multiple times.

```crystal
# Example of how to use idempotency keys in the Crystal library
client.charges.create(
  amount: 2000,
  currency: "usd",
  source: "tok_visa",
  idempotency_key: "a-unique-idempotency-key"
)
```

## Next Steps

For more detailed information on specific API endpoints and resources, refer to the other documentation files in this directory.
