# Working with Coupons in Crystal Stripe

This guide explains how to use the Crystal Stripe API library to manage coupons for discounts.

## Overview

Coupons in Stripe represent discounts that can be applied to a customer's invoice. They can provide percentage-based or fixed-amount discounts, and can apply to one-time charges or recurring subscriptions.

Key coupon features:
1. Create percentage or fixed-amount discounts
2. Set discount duration (once, multiple periods, or forever)
3. Add restrictions such as redemption limits or expiration dates
4. Apply to invoices and subscriptions

## Basic Usage

### Creating a Coupon

```crystal
require "stripe"

client = Stripe::Client.new(api_key: ENV["STRIPE_API_KEY"])

# Create a percentage discount coupon
percent_coupon = Stripe::Resources::Coupon.create(
  client,
  duration: "forever",
  percent_off: 25.0,
  name: "25% Off Forever"
)

puts "Coupon created: #{percent_coupon["id"]}"
puts "Discount amount: #{percent_coupon["percent_off"]}%"

# Create a fixed amount discount coupon
amount_coupon = Stripe::Resources::Coupon.create(
  client,
  duration: "once",
  amount_off: 1000, # $10.00
  currency: "usd",
  name: "$10 Off One-time"
)

puts "Coupon created: #{amount_coupon["id"]}"
puts "Discount amount: $#{amount_coupon["amount_off"].as_i / 100.0}"
```

> **Important:** When creating a fixed-amount discount coupon with `amount_off`, you must also specify the `currency`.

### Creating a Coupon with Limited Duration

```crystal
# Create a coupon that lasts for 3 months
repeating_coupon = Stripe::Resources::Coupon.create(
  client,
  duration: "repeating",
  duration_in_months: 3,
  percent_off: 15.0,
  name: "15% Off for 3 months"
)

puts "Coupon created: #{repeating_coupon["id"]}"
puts "Duration in months: #{repeating_coupon["duration_in_months"]}"
```

### Creating a Coupon with Redemption Limits

```crystal
# Create a coupon with maximum redemptions
limited_coupon = Stripe::Resources::Coupon.create(
  client,
  duration: "once",
  percent_off: 50.0,
  name: "50% Off First Purchase",
  max_redemptions: 100 # Can only be used 100 times
)

puts "Coupon created: #{limited_coupon["id"]}"
puts "Max redemptions: #{limited_coupon["max_redemptions"]}"
```

### Creating a Coupon with an Expiration Date

```crystal
# Create a coupon that expires in 30 days
expiration_date = Time.utc.at_beginning_of_day + 30.days
expiring_coupon = Stripe::Resources::Coupon.create(
  client,
  duration: "once",
  percent_off: 30.0,
  name: "30% Off Limited Time",
  redeem_by: expiration_date.to_unix
)

puts "Coupon created: #{expiring_coupon["id"]}"
puts "Redeem by: #{Time.unix(expiring_coupon["redeem_by"].as_i)}"
```

### Retrieving a Coupon

```crystal
coupon = Stripe::Resources::Coupon.retrieve(client, "25OFF")
puts "Coupon: #{coupon["id"]}"
puts "Valid: #{coupon["valid"]}"
```

### Updating a Coupon

You can only update the metadata and name of an existing coupon:

```crystal
updated_coupon = Stripe::Resources::Coupon.update(
  client,
  "25OFF",
  name: "New Discount Name",
  metadata: {"campaign_id" => "summer_2025"}
)

puts "Updated coupon name: #{updated_coupon["name"]}"
puts "Updated metadata: #{updated_coupon["metadata"]["campaign_id"]}"
```

### Deleting a Coupon

```crystal
deleted_coupon = Stripe::Resources::Coupon.delete(client, "25OFF")
puts "Deleted: #{deleted_coupon["deleted"]}" # Should be true
```

> **Note:** Deleting a coupon does not affect any customers who have already redeemed it. It only prevents new customers from redeeming the coupon.

### Listing Coupons

```crystal
# List all coupons (default 10 at a time)
coupons = Stripe::Resources::Coupon.list(client)

# List with pagination
coupons = Stripe::Resources::Coupon.list(
  client,
  limit: 5
)

# Iterate through coupon data
coupons["data"].as_a.each do |coupon|
  puts "Coupon: #{coupon["id"]}"
  
  if coupon["percent_off"]?
    puts "Percent off: #{coupon["percent_off"]}%"
  elsif coupon["amount_off"]?
    puts "Amount off: #{coupon["amount_off"].as_i / 100.0} #{coupon["currency"]}"
  end
  
  puts "Duration: #{coupon["duration"]}"
  puts "Valid: #{coupon["valid"]}"
  puts "---"
end
```

## Advanced Usage

### Applying Coupons to Customers

Coupons can be applied directly when creating or updating a customer:

```crystal
customer = client.request(
  :post,
  "/v1/customers",
  email: "customer@example.com",
  coupon: "25OFF"
)

puts "Customer created with coupon: #{customer["discount"]["coupon"]["id"]}"
```

### Applying Coupons to Subscriptions

```crystal
subscription = client.request(
  :post,
  "/v1/subscriptions",
  customer: "cus_12345",
  items: [{price: "price_12345"}],
  coupon: "25OFF"
)

puts "Subscription created with coupon: #{subscription["discount"]["coupon"]["id"]}"
```

### Applying Coupons to Invoices

```crystal
# First create an invoice
invoice = Stripe::Resources::Invoice.create(
  client,
  customer: "cus_12345",
  discounts: [{coupon: "25OFF"}]
)

puts "Invoice created with coupon: #{invoice["id"]}"
```

### Removing Coupons

To remove a coupon from a customer or subscription:

```crystal
# Remove from customer
customer = client.request(
  :delete,
  "/v1/customers/cus_12345/discount"
)

# Remove from subscription
subscription = client.request(
  :delete,
  "/v1/subscriptions/sub_12345/discount"
)
```

## Error Handling

```crystal
begin
  coupon = Stripe::Resources::Coupon.create(
    client,
    duration: "forever",
    percent_off: 150.0 # Invalid value, must be between 0 and 100
  )
rescue ex : Stripe::Error
  puts "Error creating coupon: #{ex.message}"
  
  if ex.is_a?(Stripe::InvalidRequestError)
    puts "Invalid request: #{ex.message}"
  end
end
```

## Coupon Best Practices

1. **Use descriptive names**: Make coupon codes descriptive and easy to remember.

2. **Set appropriate limits**: Use `max_redemptions` to prevent overuse of promotional discounts.

3. **Set expiration dates**: Use `redeem_by` to create urgency and limit promotion duration.

4. **Track usage with metadata**: Add metadata to track marketing campaigns.

5. **Test thoroughly**: Use Stripe's test mode to verify coupon logic before going live.

6. **Monitor redemptions**: Regularly check `times_redeemed` to track coupon usage.

## Complete Example: Subscription with Coupon

```crystal
require "stripe"

client = Stripe::Client.new(api_key: ENV["STRIPE_API_KEY"])

# 1. Create a coupon
coupon = Stripe::Resources::Coupon.create(
  client,
  duration: "forever",
  percent_off: 20.0,
  name: "20% Off Forever",
  metadata: {"campaign" => "new_launch_2025"}
)
coupon_id = coupon["id"].as_s

# 2. Create a customer
customer = client.request(
  :post,
  "/v1/customers",
  email: "customer@example.com",
  name: "New Customer",
  payment_method: "pm_card_visa", # Token from Stripe.js
  invoice_settings: {default_payment_method: "pm_card_visa"}
)
customer_id = customer["id"].as_s

# 3. Create a subscription with the coupon
subscription = client.request(
  :post,
  "/v1/subscriptions",
  customer: customer_id,
  items: [{price: "price_12345"}],
  coupon: coupon_id
)

# 4. Verify the discount is applied
discount = subscription["discount"]
applied_coupon = discount["coupon"]

puts "Subscription created: #{subscription["id"]}"
puts "Applied coupon: #{applied_coupon["id"]}"
puts "Discount percentage: #{applied_coupon["percent_off"]}%"
puts "Discount duration: #{applied_coupon["duration"]}"
```

## Next Steps

- Implement promotion codes for customer-facing coupon redemption
- Create a customer portal for coupon redemption
- Set up webhook handling for discount events
- Implement advanced coupon analytics
