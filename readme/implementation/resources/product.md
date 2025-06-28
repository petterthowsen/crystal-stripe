# Product Resource Implementation

This document explains how to use the Product resource in the Crystal Stripe API implementation.

## Overview

Products in Stripe represent the goods or services you offer to your customers. They are used as the foundation for Prices and Subscriptions. A Product can have multiple Prices associated with it, allowing for different billing options (such as monthly vs. annual plans or different currencies).

## Basic Usage

### Initialize the Stripe Client

```crystal
require "stripe"

# Initialize with API key from environment variable
client = Stripe::Client.new(api_key: ENV["STRIPE_API_KEY"])

# Or initialize with direct API key (not recommended for production code)
client = Stripe::Client.new(api_key: "sk_test_...")
```

### Creating a Product

```crystal
# Create a simple product
product = Stripe::Resources::Product.create(
  client,
  name: "Premium Plan"
)

# Create a product with more details
product = Stripe::Resources::Product.create(
  client,
  name: "Gold Subscription",
  description: "Our premium subscription tier with all features",
  active: true,
  metadata: {
    "plan_level" => "premium",
    "features" => "all"
  }
)

# Access product attributes
product_id = product["id"].as_s
product_name = product["name"].as_s
```

### Retrieving a Product

```crystal
# Retrieve product by ID
product = Stripe::Resources::Product.retrieve(client, "prod_12345")

# Access product attributes
if product["active"].as_bool
  puts "Product is active: #{product["name"]}"
end
```

### Updating a Product

```crystal
# Update product details
updated_product = Stripe::Resources::Product.update(
  client,
  "prod_12345",
  name: "Platinum Plan",
  description: "Updated description with new features",
  metadata: {"updated" => Time.utc.to_s}
)
```

### Deleting a Product

```crystal
# Delete a product (only if it has no associated prices)
deleted_product = Stripe::Resources::Product.delete(client, "prod_12345")

# Check if successfully deleted
if deleted_product["deleted"].as_bool
  puts "Product deleted successfully"
end
```

### Listing Products

```crystal
# List all products (default limit 10)
all_products = Stripe::Resources::Product.list(client)

# List with filtering and pagination
active_products = Stripe::Resources::Product.list(
  client,
  active: true,
  limit: 20
)

# Access products from list
active_products["data"].as_a.each do |product|
  puts "Product: #{product["name"]} (#{product["id"]})"
end
```

### Searching Products

```crystal
# Search for products with specific criteria
search_results = Stripe::Resources::Product.search(
  client,
  query: "active:'true' AND name:'Gold'"
)

# Process search results
search_results["data"].as_a.each do |product|
  puts "Found product: #{product["name"]}"
end
```

## Working with Product and Prices

Products are typically used in conjunction with Prices to define what you're selling and how much it costs:

```crystal
# Create a product
product = Stripe::Resources::Product.create(
  client,
  name: "Premium Subscription"
)

# Create a one-time price for this product
one_time_price = Stripe::Resources::Price.create(
  client,
  product: product["id"].as_s,
  unit_amount: 5000,  # $50.00
  currency: "usd"
)

# Create a recurring monthly price for the same product
monthly_price = Stripe::Resources::Price.create(
  client,
  product: product["id"].as_s,
  unit_amount: 1000,  # $10.00
  currency: "usd",
  recurring: {
    interval: "month"
  }
)

# Create an annual price with a discount
annual_price = Stripe::Resources::Price.create(
  client,
  product: product["id"].as_s,
  unit_amount: 10000,  # $100.00 (instead of $120 for 12 months)
  currency: "usd",
  recurring: {
    interval: "year"
  }
)
```

## Error Handling

```crystal
begin
  product = Stripe::Resources::Product.retrieve(client, "prod_nonexistent")
rescue ex : Stripe::Error
  case ex
  when Stripe::InvalidRequestError
    puts "Product not found: #{ex.message}"
  when Stripe::AuthenticationError
    puts "Authentication failed: #{ex.message}"
  else
    puts "An error occurred: #{ex.message}"
  end
end
```

## Best Practices

1. **Use Meaningful Names and Descriptions**: Provide clear, descriptive names and detailed descriptions for your products.

2. **Leverage Metadata**: Use the metadata field to store additional information about your products for easier querying and organization.

3. **Product Lifecycle Management**: Instead of deleting products that are no longer offered, consider setting them to inactive (`active: false`).

4. **Organize Product Hierarchy**: For complex offerings, consider using metadata to establish relationships between products.

5. **Keep Products Focused**: Each product should represent a distinct offering. Use prices to represent different billing options for the same product.

6. **Consider SEO**: If your products will be displayed on customer-facing pages, include relevant keywords in names and descriptions.

7. **Audit and Maintenance**: Periodically review your product catalog to ensure all products are up-to-date and relevant.

## Example Workflow

Here's a typical workflow for creating and managing products and prices for a SaaS application:

```crystal
# Create tiered products
basic = Stripe::Resources::Product.create(client, name: "Basic Plan", metadata: {"tier" => "1"})
pro = Stripe::Resources::Product.create(client, name: "Professional Plan", metadata: {"tier" => "2"})
enterprise = Stripe::Resources::Product.create(client, name: "Enterprise Plan", metadata: {"tier" => "3"})

# Create monthly and annual prices for each product
[basic, pro, enterprise].each do |product|
  product_id = product["id"].as_s
  tier = product["metadata"]["tier"].as_s
  
  # Set price based on tier
  monthly_amount = case tier
    when "1" then 1000  # $10.00
    when "2" then 2500  # $25.00
    when "3" then 5000  # $50.00
    else 1000
  end
  
  # Create monthly price
  Stripe::Resources::Price.create(
    client,
    product: product_id,
    unit_amount: monthly_amount,
    currency: "usd",
    recurring: {interval: "month"},
    nickname: "#{product["name"]} Monthly"
  )
  
  # Create annual price (with ~10% discount)
  annual_amount = (monthly_amount * 12 * 0.9).to_i
  Stripe::Resources::Price.create(
    client,
    product: product_id,
    unit_amount: annual_amount,
    currency: "usd",
    recurring: {interval: "year"},
    nickname: "#{product["name"]} Annual"
  )
end
```

## Related Resources

- [Price Resource](./price.md) - For creating and managing prices associated with products
- [Subscription Resource](./subscription.md) - For setting up recurring billing using products and prices
- [Customer Resource](./customer.md) - For associating customers with products via subscriptions
