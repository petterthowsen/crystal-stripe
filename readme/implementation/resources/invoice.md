# Working with Invoices in Crystal Stripe

This guide explains how to use the Crystal Stripe API library to manage invoices for your customers.

## Overview

Invoices in Stripe are documents that show what a customer owes for a collection of line items. Invoices can be created manually, or they can be generated automatically when a subscription renews. They can also be used for one-time charges.

Key invoice workflow steps:
1. Create invoice items (optional)
2. Create an invoice
3. Finalize the invoice
4. Send the invoice or collect payment
5. Handle invoice states (paid, uncollectible, void)

## Basic Usage

### Creating an Invoice

To create an invoice, you need a customer ID:

```crystal
require "stripe"

client = Stripe::Client.new(api_key: ENV["STRIPE_API_KEY"])

# Create a draft invoice for a customer
invoice = Stripe::Resources::Invoice.create(
  client,
  customer: "cus_12345"
)

puts "Invoice created: #{invoice["id"]}"
puts "Status: #{invoice["status"]}" # Should be "draft"
```

### Creating an Invoice with Custom Collection Method

```crystal
invoice = Stripe::Resources::Invoice.create(
  client,
  customer: "cus_12345",
  collection_method: "send_invoice", # Options: "charge_automatically" or "send_invoice"
  days_until_due: 30 # Required when using "send_invoice" collection method
)

puts "Invoice created: #{invoice["id"]}"
puts "Collection method: #{invoice["collection_method"]}"
puts "Days until due: #{invoice["days_until_due"]}"
```

> **Important:** The `days_until_due` parameter is required when using `collection_method: "send_invoice"`. Omitting this parameter will result in an API error.

### Retrieving an Invoice

```crystal
invoice = Stripe::Resources::Invoice.retrieve(client, "in_12345")
```

### Updating an Invoice

You can modify a draft invoice in various ways:

```crystal
# Update invoice metadata
invoice = Stripe::Resources::Invoice.update(
  client,
  "in_12345",
  metadata: {"order_id" => "6735"}
)

# Update invoice description
invoice = Stripe::Resources::Invoice.update(
  client,
  "in_12345",
  description: "Monthly subscription charge"
)

# Update custom fields
invoice = Stripe::Resources::Invoice.update(
  client,
  "in_12345",
  custom_fields: [
    {name: "Project", value: "Website Redesign"}
  ]
)
```

### Deleting a Draft Invoice

```crystal
deleted_invoice = Stripe::Resources::Invoice.delete(client, "in_12345")
```

### Listing Invoices

```crystal
# List all invoices (default 10 at a time)
invoices = Stripe::Resources::Invoice.list(client)

# List invoices for a specific customer
invoices = Stripe::Resources::Invoice.list(
  client,
  customer: "cus_12345",
  limit: 5
)

# List invoices with specific status
invoices = Stripe::Resources::Invoice.list(
  client,
  status: "draft"
)

# Iterate through invoice data
invoices["data"].as_a.each do |invoice|
  puts "Invoice: #{invoice["id"]}"
  puts "Status: #{invoice["status"]}"
  puts "Amount due: #{invoice["amount_due"]}"
end
```

### Searching Invoices

```crystal
# Search for paid invoices created in the past month
result = Stripe::Resources::Invoice.search(
  client,
  query: "status:'paid' AND created>#{Time.utc.at_beginning_of_month.to_unix}"
)

result["data"].as_a.each do |invoice|
  puts "Invoice: #{invoice["id"]}"
end
```

## Invoice Actions

### Finalizing an Invoice

```crystal
finalized_invoice = Stripe::Resources::Invoice.finalize(client, "in_12345")
puts "Invoice status: #{finalized_invoice["status"]}" # Should be "open" if collection method is "send_invoice", or "paid"/"uncollectible" if "charge_automatically"
```

### Paying an Invoice

```crystal
# First ensure the invoice is in 'open' status
invoice = Stripe::Resources::Invoice.retrieve(client, "in_12345")
if invoice["status"].as_s == "open"
  paid_invoice = Stripe::Resources::Invoice.pay(client, "in_12345")
  puts "Invoice status: #{paid_invoice["status"]}" # Should be "paid"
else
  puts "Cannot pay an invoice that is not open. Current status: #{invoice["status"]}"
end
```

> **Important:** Only invoices with status "open" can be paid. Invoices created with `collection_method: "charge_automatically"` might be paid automatically upon finalization.

### Sending an Invoice

```crystal
sent_invoice = Stripe::Resources::Invoice.send(client, "in_12345")
puts "Invoice sent to: #{sent_invoice["customer_email"]}"
```

### Voiding an Invoice

```crystal
# First ensure the invoice is in 'open' status
invoice = Stripe::Resources::Invoice.retrieve(client, "in_12345")
if invoice["status"].as_s == "open"
  voided_invoice = Stripe::Resources::Invoice.void(client, "in_12345")
  puts "Invoice status: #{voided_invoice["status"]}" # Should be "void"
else
  puts "Cannot void an invoice that is not open. Current status: #{invoice["status"]}"
end
```

> **Important:** Only invoices with status "open" can be voided. Draft invoices should be deleted instead.

### Marking an Invoice as Uncollectible

```crystal
# First ensure the invoice is in 'open' status
invoice = Stripe::Resources::Invoice.retrieve(client, "in_12345")
if invoice["status"].as_s == "open"
  uncollectible_invoice = Stripe::Resources::Invoice.mark_uncollectible(client, "in_12345")
  puts "Invoice status: #{uncollectible_invoice["status"]}" # Should be "uncollectible"
else
  puts "Cannot mark an invoice as uncollectible if it's not open. Current status: #{invoice["status"]}"
end
```

> **Important:** Only invoices with status "open" can be marked as uncollectible.

## Advanced Usage

### Getting the Invoice PDF URL

```crystal
# The invoice should be finalized for best results
pdf_url = Stripe::Resources::Invoice.pdf_url(client, "in_12345")

# Handle cases where URL might not be available
if pdf_url
  puts "PDF URL: #{pdf_url}"
  # You could now download the PDF or redirect user to this URL
else
  puts "PDF URL not available for this invoice"
end
```

> **Important:** The PDF URL may not be available for draft invoices. The method returns `nil` if no URL is available.

### Working with Invoice Line Items

Invoice line items represent the individual charges on an invoice:

```crystal
# Note: When adding invoice items directly, use one-time prices (not recurring)
invoice = Stripe::Resources::Invoice.retrieve(client, "in_12345")
invoice["lines"]["data"].as_a.each do |line|
  puts "Line item description: #{line["description"]}"
  puts "Amount: #{line["amount"]}"
  puts "Period: #{Time.unix(line["period"]["start"].as_i)} to #{Time.unix(line["period"]["end"].as_i)}"
end
```

### Handling Invoice Status Changes

Invoices move through various states during their lifecycle:

```crystal
invoice = Stripe::Resources::Invoice.retrieve(client, "in_12345")
status = invoice["status"].as_s

case status
when "draft"
  puts "Invoice is still a draft and can be modified"
when "open"
  puts "Invoice has been finalized but not paid"
  puts "Due date: #{Time.unix(invoice["due_date"].as_i)}" if invoice["due_date"]?
when "paid"
  puts "Invoice has been paid"
  puts "Paid at: #{Time.unix(invoice["paid_at"].as_i) if invoice["paid_at"]?}"
when "uncollectible"
  puts "Invoice has been marked as uncollectible"
when "void"
  puts "Invoice has been voided"
end
```

## Error Handling

```crystal
begin
  invoice = Stripe::Resources::Invoice.pay(
    client,
    "in_12345"
  )
rescue ex : Stripe::Error
  puts "Error paying invoice: #{ex.message}"
  if ex.is_a?(Stripe::InvalidRequestError)
    puts "Invalid request: #{ex.message}"
  elsif ex.is_a?(Stripe::CardError)
    puts "Card error: #{ex.message}"
  end
end
```

## Invoicing Best Practices

1. **Use webhooks**: Set up webhook endpoints to handle asynchronous events such as:
   - `invoice.created`
   - `invoice.finalized`
   - `invoice.payment_succeeded`
   - `invoice.payment_failed`

2. **Customize invoices**: Use custom fields, footer text, and company information to create professional-looking invoices.

3. **Automate invoicing**: Set up automatic invoicing with subscriptions to streamline billing.

4. **Include detailed descriptions**: Add clear descriptions to make it easy for customers to understand charges.

5. **Set appropriate due dates**: Consider your business needs and customer relationships when setting payment terms.

6. **Handle tax properly**: Configure tax settings in Stripe or handle tax calculations appropriately.

7. **Test thoroughly**: Use Stripe's test mode to verify all invoice flows before going live.

## Complete Example: Manual Invoice Creation and Management

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

# 2. Create some invoice items
item1 = Stripe::Resources::InvoiceItem.create(
  client,
  customer: customer_id,
  description: "Consulting services",
  unit_amount: 15000, # $150.00
  currency: "usd"
)

item2 = Stripe::Resources::InvoiceItem.create(
  client,
  customer: customer_id,
  description: "Web development",
  unit_amount: 20000, # $200.00
  currency: "usd"
)

# 3. Create an invoice to collect all pending invoice items
invoice = Stripe::Resources::Invoice.create(
  client,
  customer: customer_id,
  auto_advance: false, # Don't automatically finalize the invoice
  collection_method: "send_invoice",
  days_until_due: 30,
  description: "Professional services - April 2023",
  footer: "Thank you for your business!"
)
invoice_id = invoice["id"].as_s

# 4. Finalize the invoice
finalized = Stripe::Resources::Invoice.finalize(client, invoice_id)

# 5. Send the invoice to the customer
sent = Stripe::Resources::Invoice.send(client, invoice_id)

puts "Created and sent invoice #{invoice_id} for customer #{customer_id}"
puts "Status: #{sent["status"]}"
puts "Amount due: $#{sent["amount_due"].as_i / 100.0}"
puts "Due date: #{Time.unix(sent["due_date"].as_i)}"
```

## Next Steps

- Implement webhook handling to respond to invoice events
- Set up automatic reminders for unpaid invoices
- Create a customer portal for invoice management
- Implement discounts and promotions
- Add support for multiple currencies
