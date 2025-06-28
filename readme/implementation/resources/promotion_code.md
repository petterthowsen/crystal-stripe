# Working with Promotion Codes in Crystal Stripe

This guide explains how to use the Crystal Stripe API library to manage promotion codes for your customers.

## Overview

Promotion codes in Stripe are customer-facing codes that can be used to apply coupons. While coupons define the actual discount, promotion codes provide a way to distribute and manage access to these discounts.

Key promotion code features:
1. Create multiple promotion codes for a single coupon
2. Restrict codes to specific customers
3. Set maximum redemption limits
4. Create custom, memorable codes for marketing
5. Set expiration dates
6. Add restrictions like minimum purchase amounts

## Basic Usage

### Creating a Promotion Code

Before creating a promotion code, you need a coupon:

```crystal
require "stripe"

client = Stripe::Client.new(api_key: ENV["STRIPE_API_KEY"])

# First create a coupon
coupon = Stripe::Resources::Coupon.create(
  client,
  duration: "once",
  percent_off: 25.0,
  name: "25% Off First Purchase"
)
coupon_id = coupon["id"].as_s

# Then create a promotion code for that coupon
promotion_code = Stripe::Resources::PromotionCode.create(
  client,
  coupon: coupon_id
)

puts "Promotion Code created: #{promotion_code["id"]}"
puts "Customer-facing code: #{promotion_code["code"]}"
puts "Associated coupon: #{promotion_code["coupon"]["id"]}"
```

> **Note:** If you don't specify a code, Stripe generates a random code automatically.

### Creating a Promotion Code with a Custom Code

```crystal
promotion_code = Stripe::Resources::PromotionCode.create(
  client,
  coupon: "25OFF",
  code: "SUMMER25" # Custom code for marketing
)

puts "Promotion Code created: #{promotion_code["id"]}"
puts "Customer-facing code: #{promotion_code["code"]}" # "SUMMER25"
```

> **Important:** Custom codes must be unique across all active promotion codes.

### Creating a Promotion Code with Restrictions

```crystal
# Create a promotion code with minimum purchase amount
promotion_code = Stripe::Resources::PromotionCode.create(
  client,
  coupon: "25OFF",
  code: "MIN50",
  restrictions: {
    minimum_amount: 5000, # $50.00
    minimum_amount_currency: "usd"
  }
)

puts "Promotion Code created: #{promotion_code["id"]}"
puts "Minimum amount: $#{promotion_code["restrictions"]["minimum_amount"].as_i / 100.0}"
```

### Creating a First-time Customer Promotion Code

```crystal
# Create a promotion code for first-time customers only
promotion_code = Stripe::Resources::PromotionCode.create(
  client,
  coupon: "25OFF",
  code: "FIRSTTIME",
  restrictions: {
    first_time_transaction: true
  }
)

puts "First-time transaction required: #{promotion_code["restrictions"]["first_time_transaction"]}"
```

### Retrieving a Promotion Code

```crystal
promotion_code = Stripe::Resources::PromotionCode.retrieve(client, "promo_12345")
puts "Promotion Code: #{promotion_code["code"]}"
puts "Active: #{promotion_code["active"]}"
```

### Updating a Promotion Code

You can update the active status and metadata of an existing promotion code:

```crystal
updated_promotion_code = Stripe::Resources::PromotionCode.update(
  client,
  "promo_12345",
  active: false,
  metadata: {"campaign" => "discontinued"}
)

puts "Active status: #{updated_promotion_code["active"]}"
puts "Metadata campaign: #{updated_promotion_code["metadata"]["campaign"]}"
```

> **Note:** You cannot update the actual code value or the associated coupon after creation.

### Listing Promotion Codes

```crystal
# List all promotion codes (default 10 at a time)
promotion_codes = Stripe::Resources::PromotionCode.list(client)

# List with pagination
promotion_codes = Stripe::Resources::PromotionCode.list(
  client,
  limit: 5
)

# Filter by active status
active_codes = Stripe::Resources::PromotionCode.list(
  client,
  active: true
)

# Filter by specific coupon
coupon_codes = Stripe::Resources::PromotionCode.list(
  client,
  coupon: "25OFF"
)

# Iterate through promotion code data
promotion_codes["data"].as_a.each do |promo_code|
  puts "Promotion code: #{promo_code["code"]}"
  puts "Active: #{promo_code["active"]}"
  puts "Coupon: #{promo_code["coupon"]["id"]}"
  puts "Times redeemed: #{promo_code["times_redeemed"]}"
  puts "---"
end
```

## Advanced Usage

### Creating a Promotion Code for a Specific Customer

```crystal
# Create a promotion code that only a specific customer can redeem
customer_promotion_code = Stripe::Resources::PromotionCode.create(
  client,
  coupon: "50OFF",
  code: "VIP50",
  customer: "cus_12345" # Restricted to this customer
)

puts "Customer-specific code: #{customer_promotion_code["code"]}"
puts "Restricted to customer: #{customer_promotion_code["customer"]}"
```

### Creating a Promotion Code with Limited Redemptions

```crystal
# Create a promotion code with maximum redemptions
limited_promotion_code = Stripe::Resources::PromotionCode.create(
  client,
  coupon: "25OFF",
  code: "LIMITED25",
  max_redemptions: 50 # Can only be used 50 times
)

puts "Promotion code: #{limited_promotion_code["code"]}"
puts "Max redemptions: #{limited_promotion_code["max_redemptions"]}"
```

### Creating a Promotion Code with an Expiration Date

```crystal
# Create a promotion code that expires in 30 days
expiration_date = Time.utc.at_beginning_of_day + 30.days
expiring_promotion_code = Stripe::Resources::PromotionCode.create(
  client,
  coupon: "25OFF",
  code: "EXPIRES30",
  expires_at: expiration_date.to_unix
)

puts "Promotion code: #{expiring_promotion_code["code"]}"
puts "Expires at: #{Time.unix(expiring_promotion_code["expires_at"].as_i)}"
```

### Applying Promotion Codes in Checkout

In your frontend, customers can enter promotion codes during checkout. Here's how to validate and apply them:

```javascript
// Client-side JavaScript using Stripe.js
const {error} = await stripe.confirmCardPayment('pi_12345', {
  payment_method: {
    card: cardElement,
  },
  payment_method_data: {
    billing_details: {
      name: 'Customer Name',
    },
  },
  promotion_code: 'SUMMER25',
});

if (error) {
  // Handle error
} else {
  // Payment succeeded with promotion code applied
}
```

### Applying Promotion Codes to Subscriptions

When creating a subscription, you can apply a promotion code:

```crystal
subscription = client.request(
  :post,
  "/v1/subscriptions",
  customer: "cus_12345",
  items: [{price: "price_12345"}],
  promotion_code: "promo_12345" # Use promotion code ID, not the code itself
)

puts "Subscription created with promotion code: #{subscription["id"]}"
```

## Error Handling

```crystal
begin
  promotion_code = Stripe::Resources::PromotionCode.create(
    client,
    coupon: "NONEXISTENT", # Non-existent coupon ID
    code: "INVALID"
  )
rescue ex : Stripe::Error
  puts "Error creating promotion code: #{ex.message}"
  
  if ex.is_a?(Stripe::InvalidRequestError)
    puts "Invalid request: #{ex.message}"
  end
end
```

## Promotion Code Best Practices

1. **Use memorable codes**: Create codes that are easy to remember and type (e.g., "SUMMER25", "WELCOME20").

2. **Set appropriate restrictions**: Use restrictions to prevent misuse and target specific customer segments.

3. **Add expiration dates**: Create urgency with time-limited promotion codes.

4. **Track with metadata**: Add metadata to monitor marketing campaign performance.

5. **Customer-specific codes**: Create special codes for VIP customers or for customer service recovery.

6. **First-time purchase codes**: Use `first_time_transaction: true` to target new customers.

7. **Minimum amount requirements**: Encourage larger purchases with minimum amount restrictions.

## Complete Example: Marketing Campaign with Promotion Codes

```crystal
require "stripe"

client = Stripe::Client.new(api_key: ENV["STRIPE_API_KEY"])

# 1. Create a coupon
coupon = Stripe::Resources::Coupon.create(
  client,
  duration: "once",
  percent_off: 20.0,
  name: "20% Off Campaign"
)
coupon_id = coupon["id"].as_s

# 2. Create different promotion codes for different marketing channels
email_code = Stripe::Resources::PromotionCode.create(
  client,
  coupon: coupon_id,
  code: "EMAIL20",
  metadata: {"channel" => "email"}
)

social_code = Stripe::Resources::PromotionCode.create(
  client,
  coupon: coupon_id,
  code: "SOCIAL20",
  metadata: {"channel" => "social_media"}
)

partner_code = Stripe::Resources::PromotionCode.create(
  client,
  coupon: coupon_id,
  code: "PARTNER20",
  metadata: {"channel" => "partner"}
)

puts "Created promotion codes for marketing campaign:"
puts "Email: #{email_code["code"]}"
puts "Social: #{social_code["code"]}"
puts "Partner: #{partner_code["code"]}"

# 3. After some time, check usage across channels
promotion_codes = Stripe::Resources::PromotionCode.list(
  client, 
  coupon: coupon_id,
  limit: 100
)

# 4. Analyze performance
channels = {
  "email" => 0,
  "social_media" => 0,
  "partner" => 0
}

promotion_codes["data"].as_a.each do |code|
  if code["metadata"]["channel"]?
    channel = code["metadata"]["channel"].as_s
    channels[channel] += code["times_redeemed"].as_i if channels.has_key?(channel)
  end
end

puts "\nCampaign Performance:"
channels.each do |channel, redemptions|
  puts "#{channel}: #{redemptions} redemptions"
end
```

## Next Steps

- Implement A/B testing for different promotion codes
- Create time-based promotional campaigns (e.g., flash sales)
- Build a customer-facing portal for promotion code redemption
- Set up webhook handling for promotion code events
- Implement advanced analytics for tracking promotion code performance
