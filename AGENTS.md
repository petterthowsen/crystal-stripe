# Crystal Stripe API Library - Agent Guide

This document serves as a guide for AI agents working on this Crystal Stripe API library project.

## Project Overview

This project aims to create a comprehensive Crystal programming language library for the Stripe payment gateway API. The library will provide a type-safe, idiomatic Crystal interface to interact with all Stripe API endpoints.

## Readme Structure

The project includes Stripe API documentation in the `./readme` directory:

- **index.md**: Navigation guide for all documentation
- **api-overview.md**: General overview of the Stripe API
- **authentication.md**: Details about API keys and authentication
- **error-handling.md**: Guide to Stripe error types and handling
- **versioning.md**: Information about Stripe's versioning system
- **request-response.md**: Details about making requests and handling responses

## Gathering Additional Documentation

When implementing new features or endpoints, always check if the necessary documentation exists in the `./readme` directory. If not, follow these steps:

1. Visit the Stripe API Reference at [https://docs.stripe.com/api?shell=true&api=true](https://docs.stripe.com/api?shell=true&api=true)

2. Navigate to the relevant section for the endpoint or feature you're implementing

3. Extract the necessary information

4. Create a new Markdown file in the `./readme` directory with a descriptive name, e.g., `payment-intents.md` for Payment Intents API

## Crystal Coding Style

Follow these Crystal coding style conventions in the library implementation:

### Naming

- **Types** (classes, modules, aliases, enums): Use `PascalCase`
  ```crystal
  class StripeClient < HTTP::Client
  module Stripe
  alias StripeResponse = JSON::Any | Hash(String, JSON::Any)
  enum PaymentStatus
  ```

- **Methods** and **variables**: Use `snake_case`
  ```crystal
  def process_payment(payment_intent, customer_id)
  payment_response = client.post("/v1/payment_intents", body)
  ```

- **Constants**: Use `SCREAMING_SNAKE_CASE`
  ```crystal
  API_VERSION = "2025-05-28.basil"
  DEFAULT_TIMEOUT = 30.seconds
  ```

- **Acronyms**: PascalCase for class names (HTTPClient) and snake_case for method names (parse_http_response)

- **Lib names**: Prefixed with `Lib`
  ```crystal
  lib LibStripe
  ```

### Directory Structure

- `/` - Project root with README and configuration files
- `src/` - Source code
- `spec/` - Test files
- `bin/` - Executables

File paths should match the namespace of their contents. For example:
- `Stripe::Client` is defined in `src/stripe/client.cr`
- `Stripe::Resources::Customer` is defined in `src/stripe/resources/customer.cr`

### Indentation and Formatting

- Use 2 spaces for indentation, not tabs
- Avoid trailing whitespace
- End each file with a newline
- Use spaces around operators
- Use a space after commas
- Keep lines to a reasonable length (aim for 80 characters, max 100)

### Documentation

- Document all public methods with [Crystal doc comments](https://crystal-lang.org/reference/latest/syntax_and_semantics/documenting_code.html)
- Include usage examples where appropriate
- Document all parameters and return values

## Testing Practices

The Crystal Stripe library should use Crystal's built-in spec framework for testing:

### Test Structure

- Place tests in the `spec/` directory
- All test files should require `"spec_helper.cr"` at the beginning
  ```crystal
  require "./spec_helper"
  ```
- The spec helper should set up the testing environment (mocks, configuration, etc.)

### Test Organization

- Use `describe` blocks for classes and methods
  ```crystal
  describe Stripe::Client do
    describe "#initialize" do
      # tests
    end
    
    describe "#request" do
      # tests
    end
  end
  ```

- Use `context` blocks for different scenarios
  ```crystal
  context "with valid API key" do
    # tests
  end
  
  context "with invalid API key" do
    # tests
  end
  ```

- Use descriptive `it` blocks for specific test cases
  ```crystal
  it "sends the correct headers" do
    # test
  end
  ```

### Expectations

Use Crystal's built-in expectations for assertions:

```crystal
# Equality
client.api_version.should eq("2025-05-28.basil")

# Truthiness
client.configured?.should be_true

# Type checking
response.should be_a(Stripe::Response)

# Error expectations
exception = expect_raises(Stripe::AuthenticationError) do
  client.request(:get, "/v1/balance")
end
exception.message.should contain("Invalid API key")
```

### Test Data

- Create factory methods for test data
- Use VCR-style fixtures for API responses when possible
- Consider implementing mock HTTP responses for tests

### Running Tests

Tests can be run using the Crystal spec command:

```bash
crystal spec
```

Or for specific tests:

```bash
crystal spec spec/stripe/client_spec.cr
```

## Continuous Integration

The Crystal Stripe library should use CI to ensure code quality. Here are recommended CI configurations:

### GitHub Actions

Create a `.github/workflows/ci.yml` file with the following content:

```yaml
name: Crystal Stripe CI

on:
  push:
    branches: [ main, master ]
  pull_request:
    branches: [ main, master ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    strategy:
      matrix:
        crystal: [latest, nightly]
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Crystal
        uses: crystal-lang/install-crystal@v1
        with:
          crystal: ${{ matrix.crystal }}
      
      - name: Install dependencies
        run: shards install
      
      - name: Run tests
        run: crystal spec
      
      - name: Check formatting
        run: crystal tool format --check
      
      # Optional static analysis
      - name: Run Ameba (Static Code Analysis)
        if: matrix.crystal == 'latest'
        run: |
          shards install
          bin/ameba
```

### CI Best Practices

- Cache dependencies to speed up builds
- Test against multiple Crystal versions
- Run static code analysis tools
- Check code formatting
- Generate and publish documentation on successful builds