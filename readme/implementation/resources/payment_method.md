# Payment Method Resource

The PaymentMethod resource allows you to create, update, retrieve, and manage payment methods in the Stripe API. Payment Methods represent your customer's payment instruments and can be attached to Customers for future use.

## Overview

Payment Methods enable secure handling of:
- Credit and debit cards
- Bank accounts
- Digital wallets like Apple Pay and Google Pay
- Various local payment methods

They provide a unified interface for different payment types while keeping sensitive payment details off your server.

## Usage

### Initializing the Client

```crystal
client = Stripe::Client.new(api_key: ENV["STRIPE_API_KEY"])
```

### Creating a Payment Method

Create a new card payment method:

```crystal
payment_method = Stripe::Resources::PaymentMethod.create(
  client,
  type: "card",
  card: {
    number: "4242424242424242",
    exp_month: 8,
    exp_year: 2025,
    cvc: "314"
  },
  billing_details: {
    name: "Jenny Rosen",
    email: "jennyrosen@example.com",
    address: {
      line1: "123 Main St",
      city: "San Francisco",
      state: "CA",
      postal_code: "94111",
      country: "US"
    }
  }
)

payment_method_id = payment_method["id"].as_s # => "pm_..."
```

You can also attach metadata to payment methods:

```crystal
payment_method = Stripe::Resources::PaymentMethod.create(
  client,
  type: "card",
  card: { ... },
  metadata: {
    "order_id" => "6735",
    "reference" => "crystal-test"
  }
)
```

### Retrieving a Payment Method

Retrieve a payment method by its ID:

```crystal
payment_method = Stripe::Resources::PaymentMethod.retrieve(client, "pm_123456")

# Access payment method properties
type = payment_method["type"].as_s
last4 = payment_method["card"]["last4"].as_s
exp_month = payment_method["card"]["exp_month"].as_i
exp_year = payment_method["card"]["exp_year"].as_i
```

### Updating a Payment Method

Update an existing payment method:

```crystal
updated_payment_method = Stripe::Resources::PaymentMethod.update(
  client,
  "pm_123456",
  billing_details: {
    name: "New Name"
  },
  metadata: {"order_id" => "6735"}
)
```

### Attaching to a Customer

Attach a payment method to a customer for reuse:

```crystal
payment_method = Stripe::Resources::PaymentMethod.attach(
  client,
  "pm_123456",
  "cus_123456"
)
```

### Detaching from a Customer

Detach a payment method from a customer:

```crystal
payment_method = Stripe::Resources::PaymentMethod.detach(client, "pm_123456")
```

### Listing Customer's Payment Methods

List all payment methods attached to a customer:

```crystal
# List all cards belonging to a customer - using list method
payment_methods = Stripe::Resources::PaymentMethod.list(
  client,
  customer: "cus_123456",
  type: "card"
)

# Using the more convenient list_for_customer method
payment_methods = Stripe::Resources::PaymentMethod.list_for_customer(
  client,
  "cus_123456",
  type: "card"
)

# Access list data
payment_methods["data"].as_a.each do |payment_method|
  puts "#{payment_method["id"].as_s}: #{payment_method["card"]["last4"].as_s}"
end
```

With pagination:

```crystal
payment_methods = Stripe::Resources::PaymentMethod.list_for_customer(
  client,
  "cus_123456",
  type: "card",
  limit: 3
)

if payment_methods["has_more"].as_bool
  # There are more payment methods to retrieve
  next_payment_methods = Stripe::Resources::PaymentMethod.list_for_customer(
    client,
    "cus_123456",
    type: "card",
    limit: 3,
    starting_after: payment_methods["data"].as_a.last["id"].as_s
  )
end
```

## Error Handling

Handle errors when working with payment methods:

```crystal
begin
  payment_method = Stripe::Resources::PaymentMethod.retrieve(client, "pm_nonexistent")
rescue e : Stripe::InvalidRequestError
  puts "Payment method not found: #{e.message}"
rescue e : Stripe::Error
  puts "Error: #{e.message}"
end
```

## Security Considerations

1. **Never log full card details**: Always redact sensitive information when logging or debugging.

2. **Use Stripe Elements**: In web applications, use Stripe Elements (client-side) to collect card information directly, so card details never hit your server.

3. **Restrict API key access**: Only use restricted API keys in production environments.

## Best Practices

1. **Save payment methods to customers**: Attach payment methods to customers for future use rather than storing raw payment method IDs.

2. **Validate cards before charging**: For card payments, consider using setup intents to validate card details before charging.

3. **Use metadata**: Add metadata to track important business information without storing sensitive data.

4. **Handle expired cards**: Implement mechanisms to handle expired cards and update customer payment methods.

5. **Internationalization**: When collecting billing information, adapt your forms to handle international address formats correctly.

6. **Idempotency keys**: Always use idempotency keys when creating payment methods to prevent duplicate creation due to network errors.
