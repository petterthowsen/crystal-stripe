# Price Resource Implementation

This document explains how to use the Price resource in the Crystal Stripe API implementation.

## Overview

Prices in Stripe define how much and how often customers pay for your products. Each Price is associated with a Product and can be either one-time or recurring. Prices are used in conjunction with Products for Checkout sessions, Payment Links, and Subscriptions.

## Basic Usage

### Initialize the Stripe Client

```crystal
require "stripe"

# Initialize with API key from environment variable
client = Stripe::Client.new(api_key: ENV["STRIPE_API_KEY"])

# Or initialize with direct API key (not recommended for production code)
client = Stripe::Client.new(api_key: "sk_test_...")
```

### Creating a Price

```crystal
# Create a one-time price
one_time_price = Stripe::Resources::Price.create(
  client,
  product: "prod_12345",
  unit_amount: 2000,  # $20.00
  currency: "usd"
)

# Create a recurring monthly price
monthly_price = Stripe::Resources::Price.create(
  client,
  product: "prod_12345",
  unit_amount: 1000,  # $10.00
  currency: "usd",
  recurring: {
    interval: "month",
    interval_count: 1  # Bill every 1 month
  }
)

# Create a recurring yearly price with metadata
yearly_price = Stripe::Resources::Price.create(
  client,
  product: "prod_12345",
  unit_amount: 10000,  # $100.00
  currency: "usd",
  recurring: {
    interval: "year"
  },
  nickname: "Annual plan",
  metadata: {
    "discount" => "16%",  # Compared to monthly
    "plan_type" => "standard"
  }
)

# Access price attributes
price_id = monthly_price["id"].as_s
amount = monthly_price["unit_amount"].as_i
interval = monthly_price["recurring"]["interval"].as_s
```

### Retrieving a Price

```crystal
# Retrieve price by ID
price = Stripe::Resources::Price.retrieve(client, "price_12345")

# Access price attributes
if price["active"].as_bool
  puts "Price is active: $#{price["unit_amount"].as_i / 100.0}"
  if price["type"].as_s == "recurring"
    puts "Billing interval: #{price["recurring"]["interval"]}"
  end
end
```

### Updating a Price

```crystal
# Update price details (only limited fields can be updated)
updated_price = Stripe::Resources::Price.update(
  client,
  "price_12345",
  nickname: "Premium Monthly Plan",
  active: true,
  metadata: {"updated_on" => Time.utc.to_s}
)
```

### Listing Prices

```crystal
# List all prices (default limit 10)
all_prices = Stripe::Resources::Price.list(client)

# List with filtering and pagination
active_prices = Stripe::Resources::Price.list(
  client,
  active: true,
  limit: 20
)

# List prices for a specific product
product_prices = Stripe::Resources::Price.list(
  client,
  product: "prod_12345"
)

# List only recurring prices
recurring_prices = Stripe::Resources::Price.list(
  client,
  type: "recurring"
)

# Access prices from list
product_prices["data"].as_a.each do |price|
  currency = price["currency"].as_s
  amount = price["unit_amount"].as_i / 100.0
  puts "Price: #{currency.upcase} #{amount}"
end
```

### Searching Prices

```crystal
# Search for prices with specific criteria
search_results = Stripe::Resources::Price.search(
  client,
  query: "active:'true' AND type:'recurring' AND product:'prod_12345'"
)

# Process search results
search_results["data"].as_a.each do |price|
  puts "Found price: #{price["nickname"]} - #{price["currency"].upcase} #{price["unit_amount"].as_i / 100.0}"
end
```

## Price Types and Structures

### One-time Prices

```crystal
one_time_price = Stripe::Resources::Price.create(
  client,
  product: "prod_12345",
  unit_amount: 5000,
  currency: "usd"
)
```

### Recurring Prices

```crystal
# Monthly recurring price
monthly_price = Stripe::Resources::Price.create(
  client,
  product: "prod_12345",
  unit_amount: 1000,
  currency: "usd",
  recurring: {
    interval: "month"
  }
)

# Weekly recurring price
weekly_price = Stripe::Resources::Price.create(
  client,
  product: "prod_12345",
  unit_amount: 300,
  currency: "usd",
  recurring: {
    interval: "week"
  }
)

# Quarterly recurring price (every 3 months)
quarterly_price = Stripe::Resources::Price.create(
  client,
  product: "prod_12345",
  unit_amount: 2700,
  currency: "usd",
  recurring: {
    interval: "month",
    interval_count: 3
  }
)

# Biennial price (every 2 years)
biennial_price = Stripe::Resources::Price.create(
  client,
  product: "prod_12345",
  unit_amount: 18000,
  currency: "usd",
  recurring: {
    interval: "year",
    interval_count: 2
  }
)
```

### Tiered Pricing

```crystal
# Create a tiered price for volume-based pricing
tiered_price = Stripe::Resources::Price.create(
  client,
  product: "prod_12345",
  currency: "usd",
  billing_scheme: "tiered",
  recurring: {
    interval: "month"
  },
  tiers_mode: "volume",
  tiers: [
    {
      up_to: 10,
      unit_amount: 1000,  # $10 per unit for 1-10 units
    },
    {
      up_to: 100,
      unit_amount: 800,   # $8 per unit for 11-100 units
    },
    {
      up_to: "inf",
      unit_amount: 600,   # $6 per unit for 101+ units
    }
  ]
)
```

## Error Handling

```crystal
begin
  price = Stripe::Resources::Price.retrieve(client, "price_nonexistent")
rescue ex : Stripe::Error
  case ex
  when Stripe::InvalidRequestError
    puts "Price not found: #{ex.message}"
  when Stripe::AuthenticationError
    puts "Authentication failed: #{ex.message}"
  else
    puts "An error occurred: #{ex.message}"
  end
end
```

## Best Practices

1. **Set Appropriate Active Status**: When replacing prices, set the old ones to inactive (`active: false`) rather than deleting them.

2. **Use Descriptive Nicknames**: Add clear nicknames to your prices to make them easier to identify in the dashboard and reports.

3. **Use Metadata for Organization**: Store additional information in metadata for easier querying and organization.

4. **Consider Currency Precision**: Remember that `unit_amount` is in the smallest currency unit (cents for USD, pence for GBP, etc.).

5. **Plan Your Price Structure**: Think about the different types of prices you'll need (one-time, recurring, different intervals) before implementation.

6. **Immutable Attributes**: Remember that most price attributes cannot be changed after creation, so plan carefully.

7. **Test with Stripe Test Mode**: Always test your price creation and management in Stripe test mode before going to production.

## Example Workflows

### Creating a Basic Subscription Plan

```crystal
# Create a product for the subscription
product = Stripe::Resources::Product.create(
  client,
  name: "Premium Subscription",
  description: "Access to all premium features"
)

# Create monthly and annual prices for the product
monthly = Stripe::Resources::Price.create(
  client,
  product: product["id"].as_s,
  unit_amount: 1500,
  currency: "usd",
  recurring: {
    interval: "month"
  },
  nickname: "Premium Monthly"
)

# Annual plan with ~16% discount compared to monthly
annual = Stripe::Resources::Price.create(
  client,
  product: product["id"].as_s,
  unit_amount: 15000,  # $150 instead of $180 for 12 months
  currency: "usd",
  recurring: {
    interval: "year"
  },
  nickname: "Premium Annual"
)

# Set the default price for the product
Stripe::Resources::Product.update(
  client, 
  product["id"].as_s,
  default_price: monthly["id"].as_s
)
```

### Creating Multi-currency Prices

```crystal
# Create a product
product = Stripe::Resources::Product.create(
  client,
  name: "Global Service"
)

# Create prices in different currencies
currencies = [
  {code: "usd", amount: 1000},  # $10.00
  {code: "eur", amount: 900},   # €9.00
  {code: "gbp", amount: 800}    # £8.00
]

currencies.each do |currency|
  Stripe::Resources::Price.create(
    client,
    product: product["id"].as_s,
    unit_amount: currency[:amount],
    currency: currency[:code],
    recurring: {
      interval: "month"
    },
    nickname: "Monthly (#{currency[:code].upcase})"
  )
end
```

## Related Resources

- [Product Resource](./product.md) - For creating and managing products associated with prices
- [Subscription Resource](./subscription.md) - For setting up recurring billing using products and prices
- [Customer Resource](./customer.md) - For associating customers with products via subscriptions
