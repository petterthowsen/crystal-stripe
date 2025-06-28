# Crystal Stripe Library Implementation

This directory contains documentation for the Crystal Stripe library implementation. The documentation explains how the library is structured, how to use it, and how to contribute to it.

## Table of Contents

- [Client Implementation](client.md) - Details on the core client for making Stripe API requests
- [Error Handling](error-handling.md) - Explanation of error types and handling strategies
- [Resources](resources/index.md) - Documentation on implemented Stripe API resources
  - [Balance](resources/balance.md) - Documentation on the Balance API resource

## Architecture Overview

The Crystal Stripe library follows a simple and idiomatic architecture:

1. **Core Client** - `Stripe::Client` handles authentication, request formatting, and response parsing
2. **Error Classes** - Custom error types to represent different Stripe API error scenarios
3. **Resource Wrappers** - Classes that provide type-safe methods for interacting with specific Stripe resources

## Using the Library

### Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  stripe:
    github: your-org/crystal-stripe
    version: ~> 0.1.0
```

### Basic Usage

```crystal
require "stripe"

# Initialize the client
client = Stripe::Client.new(api_key: ENV["STRIPE_API_KEY"])

# Use resource methods
balance = Stripe::Resources::Balance.retrieve(client)
puts balance["available"].as_a.first["amount"]
```

## Testing

The library uses Stripe's test mode for integration testing. To run the tests, you need a Stripe test API key:

1. Create a file `spec/stripe_key.txt` with your test API key
2. Run `crystal spec`

The library avoids mocking HTTP responses in favor of real integration tests, ensuring compatibility with the actual Stripe API.
