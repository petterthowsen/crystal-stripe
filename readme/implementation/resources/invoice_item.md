# Working with Invoice Items in Crystal Stripe

This guide explains how to use the Crystal Stripe API library to manage invoice items for your customers.

## Overview

Invoice Items in Stripe represent individual line items that can be added to a customer's upcoming invoice or included in an existing invoice. They are useful for one-off charges or adjustments to a customer's balance.

Key invoice item workflow steps:
1. Create invoice items for a customer
2. Either let them be automatically included in the next invoice, or specify a particular invoice
3. Modify or delete invoice items as needed

## Basic Usage

### Creating an Invoice Item

To create an invoice item, you need a customer ID and either a price ID or a direct amount and currency:

```crystal
require "stripe"

client = Stripe::Client.new(api_key: ENV["STRIPE_API_KEY"])

# Create an invoice item with direct amount
invoice_item = Stripe::Resources::InvoiceItem.create(
  client,
  customer: "cus_12345",
  unit_amount: 2000, # $20.00
  currency: "usd",
  description: "One-time setup fee"
)

puts "Invoice item created: #{invoice_item["id"]}"
puts "Amount: #{invoice_item["unit_amount"]}"
puts "Description: #{invoice_item["description"]}"
```

### Creating an Invoice Item with Price Reference

```crystal
invoice_item = Stripe::Resources::InvoiceItem.create(
  client,
  customer: "cus_12345",
  price: "price_12345" # Reference to a previously created price
)

puts "Invoice item created: #{invoice_item["id"]}"
puts "Price: #{invoice_item["price"]["id"]}"
```

### Creating an Invoice Item for a Specific Invoice

```crystal
invoice_item = Stripe::Resources::InvoiceItem.create(
  client,
  customer: "cus_12345",
  unit_amount: 1500, # $15.00
  currency: "usd",
  description: "Rush fee",
  invoice: "in_12345" # Specific invoice to add this item to
)

puts "Invoice item created: #{invoice_item["id"]}"
puts "Invoice: #{invoice_item["invoice"]}"
```

### Creating an Invoice Item with Specific Period

```crystal
start_time = Time.utc.to_unix
end_time = start_time + 30.days.total_seconds.to_i

invoice_item = Stripe::Resources::InvoiceItem.create(
  client,
  customer: "cus_12345",
  unit_amount: 5000,
  currency: "usd",
  description: "Monthly service fee",
  period: {
    start: start_time,
    end: end_time
  }
)

puts "Invoice item created: #{invoice_item["id"]}"
puts "Period start: #{Time.unix(invoice_item["period"]["start"].as_i)}"
puts "Period end: #{Time.unix(invoice_item["period"]["end"].as_i)}"
```

### Creating an Invoice Item with Metadata

```crystal
invoice_item = Stripe::Resources::InvoiceItem.create(
  client,
  customer: "cus_12345",
  unit_amount: 3000,
  currency: "usd",
  description: "Custom service",
  metadata: {
    "order_id" => "order_123",
    "project" => "Website Redesign"
  }
)

puts "Invoice item created: #{invoice_item["id"]}"
puts "Order ID: #{invoice_item["metadata"]["order_id"]}"
```

### Retrieving an Invoice Item

```crystal
invoice_item = Stripe::Resources::InvoiceItem.retrieve(client, "ii_12345")
```

### Updating an Invoice Item

You can modify an invoice item that hasn't been added to a finalized invoice:

```crystal
# Update invoice item description
invoice_item = Stripe::Resources::InvoiceItem.update(
  client,
  "ii_12345",
  description: "Updated service description"
)

# Update invoice item metadata
invoice_item = Stripe::Resources::InvoiceItem.update(
  client,
  "ii_12345",
  metadata: {"status" => "revised"}
)

# Update invoice item amount
invoice_item = Stripe::Resources::InvoiceItem.update(
  client,
  "ii_12345",
  unit_amount: 2500 # $25.00
)
```

### Deleting an Invoice Item

```crystal
deleted_invoice_item = Stripe::Resources::InvoiceItem.delete(client, "ii_12345")
puts "Invoice item deleted: #{deleted_invoice_item["id"]}"
puts "Deleted status: #{deleted_invoice_item["deleted"]}"
```

### Listing Invoice Items

```crystal
# List all invoice items (default 10 at a time)
invoice_items = Stripe::Resources::InvoiceItem.list(client)

# List invoice items for a specific customer
invoice_items = Stripe::Resources::InvoiceItem.list(
  client,
  customer: "cus_12345",
  limit: 5
)

# List only pending invoice items (not yet included in an invoice)
invoice_items = Stripe::Resources::InvoiceItem.list(
  client,
  pending: true
)

# Iterate through invoice item data
invoice_items["data"].as_a.each do |item|
  puts "Invoice Item: #{item["id"]}"
  puts "Description: #{item["description"]}"
  puts "Amount: #{item["unit_amount"]}"
  puts "Associated Invoice: #{item["invoice"] || "Not yet invoiced"}"
end
```

## Advanced Usage

### Working with Different Currencies

```crystal
# Create invoice items in different currencies
eur_item = Stripe::Resources::InvoiceItem.create(
  client,
  customer: "cus_12345",
  unit_amount: 1800,
  currency: "eur",
  description: "European services"
)

jpy_item = Stripe::Resources::InvoiceItem.create(
  client,
  customer: "cus_12345",
  unit_amount: 2000,
  currency: "jpy", # Note: JPY is a zero-decimal currency
  description: "Japanese services"
)
```

### Handling Quantity and Discounts

```crystal
invoice_item = Stripe::Resources::InvoiceItem.create(
  client,
  customer: "cus_12345",
  price: "price_12345",
  quantity: 5,
  discounts: ["dis_12345"] # Reference to a previously created discount
)

puts "Invoice item created: #{invoice_item["id"]}"
puts "Quantity: #{invoice_item["quantity"]}"
```

## Error Handling

```crystal
begin
  invoice_item = Stripe::Resources::InvoiceItem.create(
    client,
    customer: "cus_nonexistent",
    unit_amount: 2000,
    currency: "usd"
  )
rescue ex : Stripe::Error
  puts "Error creating invoice item: #{ex.message}"
  if ex.is_a?(Stripe::InvalidRequestError)
    puts "Invalid request: #{ex.message}"
  elsif ex.is_a?(Stripe::AuthenticationError)
    puts "Authentication error: #{ex.message}"
  end
end
```

## Invoice Item Best Practices

1. **Add clear descriptions**: Make invoice items descriptive so customers understand what they're being charged for.

2. **Use metadata**: Add relevant metadata to help with internal record keeping and reporting.

3. **Consider timing**: Create invoice items when the service is rendered rather than waiting until invoice time.

4. **Be careful with edits**: Avoid modifying invoice items that might already be visible to customers.

5. **Use pending items strategically**: Create pending invoice items throughout a billing period and consolidate them in a single invoice.

6. **Consider taxes**: Set the appropriate tax behavior for each invoice item if you handle tax separately.

7. **Test thoroughly**: Use Stripe's test mode to verify invoice item creation and billing flows.

## Complete Example: Creating Multiple Invoice Items and an Invoice

```crystal
require "stripe"

client = Stripe::Client.new(api_key: ENV["STRIPE_API_KEY"])

# 1. Create a customer
customer = client.request(
  :post,
  "/v1/customers",
  email: "john@example.com",
  name: "John Doe",
  payment_method: "pm_card_visa", # Token from Stripe.js
  invoice_settings: {default_payment_method: "pm_card_visa"}
)
customer_id = customer["id"].as_s

# 2. Create product and price for recurring service
product = Stripe::Resources::Product.create(
  client,
  name: "Consulting Service",
  description: "Professional consulting services"
)

price = Stripe::Resources::Price.create(
  client,
  product: product["id"].as_s,
  unit_amount: 10000, # $100.00
  currency: "usd"
)

# 3. Create invoice items
# Main service
service_item = Stripe::Resources::InvoiceItem.create(
  client,
  customer: customer_id,
  price: price["id"].as_s,
  quantity: 2,
  description: "Consulting hours (2 hours)"
)

# Additional charges
materials_item = Stripe::Resources::InvoiceItem.create(
  client,
  customer: customer_id,
  unit_amount: 2500, # $25.00
  currency: "usd",
  description: "Materials fee"
)

# Discount (negative amount)
discount_item = Stripe::Resources::InvoiceItem.create(
  client,
  customer: customer_id,
  unit_amount: -1000, # -$10.00
  currency: "usd",
  description: "New client discount"
)

# 4. Create an invoice to collect all pending invoice items
invoice = Stripe::Resources::Invoice.create(
  client,
  customer: customer_id,
  collection_method: "charge_automatically"
)

# 5. Finalize and pay the invoice
finalized = Stripe::Resources::Invoice.finalize(client, invoice["id"].as_s)
paid = Stripe::Resources::Invoice.pay(client, invoice["id"].as_s)

puts "Created and charged invoice #{invoice["id"].as_s} with multiple line items"
puts "Status: #{paid["status"]}"
puts "Amount paid: $#{paid["amount_paid"].as_i / 100.0}"
```

## Next Steps

- Implement webhook handling for invoice and invoice item events
- Create a customer portal for viewing invoice items and invoices
- Implement proration for subscription changes
- Set up automatic invoice item creation for usage-based billing
- Create reporting for revenue recognition
