# Working with Subscriptions in Crystal Stripe

This guide explains how to use the Crystal Stripe API library to manage subscription billing for your customers.

## Overview

Subscriptions in Stripe allow you to charge customers on a recurring basis. The Subscription resource connects a customer to a product and price you've created, establishing when and how much they will be charged.

Key subscription workflow steps:
1. Create a customer
2. Create products and prices 
3. Create a subscription with the customer and price
4. Manage the subscription lifecycle (update, cancel, etc.)
5. Handle subscription events via webhooks

## Basic Usage

### Creating a Subscription

To create a subscription, you need:
- A customer ID
- A price ID (which is associated with a product)

```crystal
require "stripe"

client = Stripe::Client.new(api_key: ENV["STRIPE_API_KEY"])

# Create a subscription for an existing customer
subscription = Stripe::Resources::Subscription.create(
  client,
  customer: "cus_12345",
  items: [
    {price: "price_12345"}
  ]
)

puts "Subscription created: #{subscription["id"]}"
puts "Status: #{subscription["status"]}"
puts "Current period end: #{Time.unix(subscription["current_period_end"].as_i)}"
```

### Creating a Subscription with a Trial Period

```crystal
subscription = Stripe::Resources::Subscription.create(
  client,
  customer: "cus_12345",
  items: [
    {price: "price_12345"}
  ],
  trial_period_days: 14
)

puts "Subscription created: #{subscription["id"]}"
puts "Status: #{subscription["status"]}" # Should be "trialing"
puts "Trial ends: #{Time.unix(subscription["trial_end"].as_i)}"
```

### Retrieving a Subscription

```crystal
subscription = Stripe::Resources::Subscription.retrieve(client, "sub_12345")
```

### Updating a Subscription

You can modify an existing subscription in various ways:

```crystal
# Update subscription metadata
subscription = Stripe::Resources::Subscription.update(
  client,
  "sub_12345",
  metadata: {"order_id" => "6735"}
)

# Change the subscription price
subscription = Stripe::Resources::Subscription.update(
  client,
  "sub_12345",
  items: [
    {
      id: "si_12345", # Subscription item ID
      price: "price_67890" # New price to switch to
    }
  ],
  proration_behavior: "create_prorations" # Apply prorations for the price change
)

# Add another product/price to the subscription
subscription = Stripe::Resources::Subscription.update(
  client,
  "sub_12345",
  items: [
    # Keep existing item (don't include this if you want to replace it)
    {id: "si_existing"},
    # Add a new item
    {price: "price_new"}
  ]
)
```

### Canceling a Subscription

```crystal
# Cancel immediately
canceled_subscription = Stripe::Resources::Subscription.cancel(client, "sub_12345")

# Cancel at the end of the billing period
canceled_subscription = Stripe::Resources::Subscription.cancel(
  client,
  "sub_12345",
  at_period_end: true
)
```

### Listing Subscriptions

```crystal
# List all subscriptions (default 10 at a time)
subscriptions = Stripe::Resources::Subscription.list(client)

# List active subscriptions for a specific customer
subscriptions = Stripe::Resources::Subscription.list(
  client,
  customer: "cus_12345",
  status: "active",
  limit: 5
)

# Iterate through subscription data
subscriptions["data"].as_a.each do |subscription|
  puts "Subscription: #{subscription["id"]}"
  puts "Status: #{subscription["status"]}"
  puts "Amount: #{subscription["items"]["data"][0]["price"]["unit_amount"]}"
end
```

### Searching Subscriptions

```crystal
# Search for active subscriptions created in the past month
result = Stripe::Resources::Subscription.search(
  client,
  query: "status:'active' AND created>#{Time.utc.at_beginning_of_month.to_unix}"
)

result["data"].as_a.each do |subscription|
  puts "Subscription: #{subscription["id"]}"
end
```

## Advanced Usage

### Working with Subscription Items

Subscription items represent the specific price and product combinations in a subscription. A subscription can have multiple items.

```crystal
# Get subscription item details
subscription = Stripe::Resources::Subscription.retrieve(client, "sub_12345")
subscription["items"]["data"].as_a.each do |item|
  puts "Item ID: #{item["id"]}"
  puts "Price: #{item["price"]["id"]}"
  puts "Quantity: #{item["quantity"]}"
end
```

### Handling Subscription Status Changes

Subscriptions move through various states during their lifecycle:

```crystal
subscription = Stripe::Resources::Subscription.retrieve(client, "sub_12345")
status = subscription["status"].as_s

case status
when "trialing"
  # Subscription in trial period
  trial_end = Time.unix(subscription["trial_end"].as_i)
  puts "Trial ends on #{trial_end}"
when "active"
  # Subscription is active and in good standing
  current_period_end = Time.unix(subscription["current_period_end"].as_i)
  puts "Next billing date: #{current_period_end}"
when "past_due"
  # Payment failed but subscription still active
  puts "Payment issue! Last invoice: #{subscription["latest_invoice"]}"
when "canceled"
  # Subscription has been canceled
  puts "Subscription was canceled"
when "unpaid"
  # Payment failed and subscription is no longer active
  puts "Subscription is unpaid and inactive"
end
```

## Error Handling

```crystal
begin
  subscription = Stripe::Resources::Subscription.create(
    client,
    customer: "cus_nonexistent",
    items: [
      {price: "price_12345"}
    ]
  )
rescue ex : Stripe::Error
  puts "Error creating subscription: #{ex.message}"
  if ex.is_a?(Stripe::InvalidRequestError)
    puts "Invalid request: #{ex.message}"
  elsif ex.is_a?(Stripe::CardError)
    puts "Card error: #{ex.message}"
  end
end
```

## Recurring Billing Best Practices

1. **Always use webhooks**: Set up webhook endpoints to handle asynchronous events such as:
   - `customer.subscription.created`
   - `customer.subscription.updated`
   - `customer.subscription.deleted`
   - `invoice.payment_succeeded`
   - `invoice.payment_failed`

2. **Trial periods**: Consider offering trial periods to increase conversions.

3. **Email notifications**: Send customers emails before charging them, especially for higher-value subscriptions.

4. **Upgrade/downgrade paths**: Design your subscription system to handle plan changes seamlessly.

5. **Dunning management**: Implement retry logic for failed payments to prevent subscription cancellations.

6. **Tax handling**: Configure tax settings in Stripe or handle tax calculations appropriately.

7. **Testing**: Use Stripe's test mode and test clock feature to test subscription lifecycles.

## Complete Example: Setting Up a Subscription System

```crystal
require "stripe"

client = Stripe::Client.new(api_key: ENV["STRIPE_API_KEY"])

# 1. Create a customer
customer = client.request(
  :post,
  "/v1/customers",
  email: "jane@example.com",
  name: "Jane Smith",
  payment_method: "pm_card_visa", # Token from Stripe.js
  invoice_settings: {default_payment_method: "pm_card_visa"}
)
customer_id = customer["id"].as_s

# 2. Create a product
product = Stripe::Resources::Product.create(
  client,
  name: "Premium Plan",
  description: "Monthly subscription to premium features"
)
product_id = product["id"].as_s

# 3. Create a price for the product
price = Stripe::Resources::Price.create(
  client,
  product: product_id,
  unit_amount: 1999, # $19.99
  currency: "usd",
  recurring: {
    interval: "month"
  }
)
price_id = price["id"].as_s

# 4. Create a subscription
subscription = Stripe::Resources::Subscription.create(
  client,
  customer: customer_id,
  items: [
    {price: price_id}
  ],
  trial_period_days: 14
)
subscription_id = subscription["id"].as_s

puts "Created subscription #{subscription_id} for customer #{customer_id}"
puts "Status: #{subscription["status"]}"
puts "Trial ends: #{Time.unix(subscription["trial_end"].as_i)}"
```

## Next Steps

- Implement webhook handling to respond to subscription lifecycle events
- Set up invoicing and receipt emails
- Create a customer portal for subscription management
- Implement metered billing if needed
- Add support for coupon codes and promotions
