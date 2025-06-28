# Stripe Authentication

This document provides detailed information about authentication in the Stripe API for the Crystal Stripe library implementation.

## API Keys

Stripe uses API keys for authentication. There are several types of API keys:

### Secret API Keys

- **Test mode**: Keys with prefix `sk_test_`
- **Live mode**: Keys with prefix `sk_live_`

Secret keys should be kept secure and never exposed in client-side code or public repositories.

### Publishable API Keys

- **Test mode**: Keys with prefix `pk_test_`
- **Live mode**: Keys with prefix `pk_live_`

Publishable keys can be included in client-side code and are used for operations that don't require server-side access.

### Restricted API Keys

Restricted API keys provide granular permissions to limit access to specific resources or operations. These are useful for:

- Limiting access for specific services or microservices
- Providing third-party vendors with limited access
- Creating role-based access within your organization

## Authentication Methods

### Basic Authentication

Stripe uses HTTP Basic Authentication with your API key as the username and no password:

```crystal
# Example of basic authentication in Crystal
require "http/client"

api_key = "sk_test_your_test_key"
headers = HTTP::Headers{
  "Authorization" => "Basic #{Base64.strict_encode("#{api_key}:")}"
}

# This will be abstracted in the library
client = Stripe::Client.new(api_key: api_key)
```

### Bearer Authentication

Some Stripe APIs use Bearer authentication:

```crystal
# Example of bearer authentication in Crystal
headers = HTTP::Headers{
  "Authorization" => "Bearer #{api_key}"
}
```

## Connected Accounts

When working with Connect, you can make API requests on behalf of connected accounts using the `Stripe-Account` header:

```crystal
# Making requests on behalf of a connected account
headers = HTTP::Headers{
  "Authorization" => "Basic #{Base64.strict_encode("#{api_key}:")}",
  "Stripe-Account" => "acct_1032D82eZvKYlo2C"
}

# In the library, this will be simplified to:
client = Stripe::Client.new(
  api_key: api_key,
  stripe_account: "acct_1032D82eZvKYlo2C"
)
```

## Best Practices

1. **Secure Storage**: Store API keys securely, using environment variables or a secure key management service.

2. **Least Privilege**: Use restricted API keys with the minimum permissions needed.

3. **Key Rotation**: Regularly rotate your API keys, especially after team member departures.

4. **Monitor Usage**: Monitor API key usage for unusual patterns that might indicate compromise.

5. **HTTPS Only**: Always make API requests over HTTPS.

## Implementation in Crystal

The Crystal Stripe library will handle authentication automatically when you initialize the client:

```crystal
# Basic usage
client = Stripe::Client.new(api_key: ENV["STRIPE_API_KEY"])

# With API version specified
client = Stripe::Client.new(
  api_key: ENV["STRIPE_API_KEY"],
  api_version: "2025-05-28.basil"
)

# For Connect accounts
client = Stripe::Client.new(
  api_key: ENV["STRIPE_API_KEY"],
  stripe_account: "acct_1032D82eZvKYlo2C"
)
```

All subsequent requests made through this client will include the appropriate authentication headers.
