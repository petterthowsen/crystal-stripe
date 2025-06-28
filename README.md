# stripe

A Crystal library for interacting with the Stripe API. This library provides a clean and idiomatic Crystal interface to the Stripe payment processing platform.

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  stripe:
    github: petterthowsen/stripe
```

Then run:

```bash
shards install
```

## Usage

```crystal
require "stripe"

# Initialize the client with your API key
client = Stripe::Client.new(api_key: ENV["STRIPE_API_KEY"])

# Create a customer
```

## Contributing

1. Fork it (<https://github.com/your-github-user/stripe/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Petter Thowsen](https://github.com/petterthowsen) - creator and maintainer
