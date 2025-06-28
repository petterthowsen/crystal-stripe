# PaymentIntent Resource

The `Stripe::Resources::PaymentIntent` module provides methods for managing payment intents in the Stripe API. Payment Intents guide you through the process of collecting a payment from your customer, handling authentication flows, and finalizing charges.

## Basic Usage

### Creating a Payment Intent

```crystal
require "stripe"

# Configure Stripe with your API key
Stripe.api_key = "sk_test_your_test_key"
client = Stripe::Client.new

# Create a basic payment intent for $20.00 USD
payment_intent = Stripe::Resources::PaymentIntent.create(
  client,
  amount: 2000,          # Amount in smallest currency unit (cents)
  currency: "usd",
  payment_method_types: ["card"]
)

# Get the client secret (for client-side confirmation)
client_secret = payment_intent["client_secret"].as_s
puts "Payment Intent ID: #{payment_intent["id"].as_s}"
puts "Client Secret: #{client_secret}"
```

### Retrieving a Payment Intent

```crystal
require "stripe"

Stripe.api_key = "sk_test_your_test_key"
client = Stripe::Client.new

# Retrieve an existing payment intent
payment_intent = Stripe::Resources::PaymentIntent.retrieve(client, "pi_123456789")

# Display payment intent information
puts "Status: #{payment_intent["status"].as_s}"
puts "Amount: #{payment_intent["amount"].as_i / 100.0} #{payment_intent["currency"].as_s.upcase}"
```

### Updating a Payment Intent

You can update certain properties of a PaymentIntent before it's confirmed:

```crystal
require "stripe"

Stripe.api_key = "sk_test_your_test_key"
client = Stripe::Client.new

# Update a payment intent
updated_intent = Stripe::Resources::PaymentIntent.update(
  client,
  "pi_123456789",
  description: "Updated payment for order #6735",
  metadata: {"order_id" => "6735"}
)
```

## Advanced Usage

### Creating and Confirming in One Step

```crystal
require "stripe"

Stripe.api_key = "sk_test_your_test_key"
client = Stripe::Client.new

# Create a payment method (or use an existing one)
payment_method = Stripe::Resources::PaymentMethod.create(
  client,
  type: "card",
  card: {
    token: "tok_visa"  # Using a test token
  }
)

# Create and confirm a payment intent in one step
payment_intent = Stripe::Resources::PaymentIntent.create(
  client,
  amount: 2000,
  currency: "usd",
  payment_method: payment_method["id"].as_s,
  payment_method_types: ["card"],
  confirm: true        # This confirms the payment intent immediately
)

if payment_intent["status"].as_s == "succeeded"
  puts "Payment succeeded!"
elsif payment_intent["status"].as_s == "requires_action"
  puts "Additional authentication required: #{payment_intent["next_action"]}"
else
  puts "Payment status: #{payment_intent["status"].as_s}"
end
```

### Manual Confirmation

```crystal
require "stripe"

Stripe.api_key = "sk_test_your_test_key"
client = Stripe::Client.new

# Create a payment intent without confirming
payment_intent = Stripe::Resources::PaymentIntent.create(
  client,
  amount: 2000,
  currency: "usd",
  payment_method_types: ["card"]
)

# Later, attach a payment method and confirm
confirmed_intent = Stripe::Resources::PaymentIntent.confirm(
  client,
  payment_intent["id"].as_s,
  payment_method: "pm_123456789"
)
```

### Manual Capture

For two-step payments (authorization and capture):

```crystal
require "stripe"

Stripe.api_key = "sk_test_your_test_key"
client = Stripe::Client.new

# Create a payment intent with manual capture
payment_intent = Stripe::Resources::PaymentIntent.create(
  client,
  amount: 2000,
  currency: "usd",
  payment_method_types: ["card"],
  capture_method: "manual"  # Only authorizes the payment
)

# Later, confirm the payment
confirmed_intent = Stripe::Resources::PaymentIntent.confirm(
  client,
  payment_intent["id"].as_s,
  payment_method: "pm_123456789"
)

# After confirmation, the status should be "requires_capture"
if confirmed_intent["status"].as_s == "requires_capture"
  # Capture the full amount
  captured_intent = Stripe::Resources::PaymentIntent.capture(
    client,
    confirmed_intent["id"].as_s
  )
  
  # Or capture a partial amount
  # captured_intent = Stripe::Resources::PaymentIntent.capture(
  #   client,
  #   confirmed_intent["id"].as_s,
  #   amount_to_capture: 1500  # Capture only $15.00
  # )
end
```

### Canceling a Payment Intent

```crystal
require "stripe"

Stripe.api_key = "sk_test_your_test_key"
client = Stripe::Client.new

# Cancel a payment intent
canceled_intent = Stripe::Resources::PaymentIntent.cancel(
  client,
  "pi_123456789",
  cancellation_reason: "requested_by_customer"  # Optional reason
)
```

### Listing Payment Intents

```crystal
require "stripe"

Stripe.api_key = "sk_test_your_test_key"
client = Stripe::Client.new

# List all payment intents, limited to 3
payment_intents = Stripe::Resources::PaymentIntent.list(
  client,
  limit: 3
)

# List payment intents for a specific customer
customer_intents = Stripe::Resources::PaymentIntent.list(
  client,
  customer: "cus_123456789",
  limit: 10
)

# Iterate through the results
payment_intents["data"].as_a.each do |intent|
  puts "#{intent["id"].as_s}: #{intent["amount"].as_i / 100.0} #{intent["currency"].as_s.upcase} (#{intent["status"].as_s})"
end
```

## Error Handling

When working with Payment Intents, handle potential errors appropriately:

```crystal
require "stripe"

Stripe.api_key = "sk_test_your_test_key"
client = Stripe::Client.new

begin
  payment_intent = Stripe::Resources::PaymentIntent.create(
    client,
    amount: 2000,
    currency: "usd",
    payment_method_types: ["card"]
  )
  
  # Process payment intent...
  
rescue Stripe::CardError => e
  # Handle card errors (e.g., declined card)
  puts "Card Error: #{e.message}"
  puts "Error Code: #{e.code}" if e.code
  
rescue Stripe::InvalidRequestError => e
  # Handle invalid parameters
  puts "Invalid Request: #{e.message}"
  
rescue Stripe::AuthenticationError => e
  # Handle authentication errors
  puts "Authentication Error: #{e.message}"
  
rescue Stripe::APIError => e
  # Handle API errors
  puts "API Error: #{e.message}"
  
rescue Exception => e
  # Handle any other unexpected errors
  puts "Error: #{e.message}"
end
```

## Best Practices

1. **Create one PaymentIntent per order**: Create exactly one PaymentIntent for each order or customer session to track the payment lifecycle properly.

2. **Store the PaymentIntent ID**: Store the PaymentIntent ID with your order information to easily track payment status.

3. **Use webhooks**: Set up webhooks to receive real-time updates about payment status changes, especially for asynchronous payment methods.

4. **Idempotency keys**: For critical operations, use idempotency keys to prevent duplicate charges during network issues:

   ```crystal
   client.idempotency_key = "unique-key-for-this-order-123"
   payment_intent = Stripe::Resources::PaymentIntent.create(...)
   ```

5. **Manual capture for pre-authorization**: Use `capture_method: "manual"` when you want to authorize a payment but capture it later (e.g., when fulfilling an order).

6. **Error handling**: Always implement proper error handling to gracefully handle failed payments.

7. **Test mode**: Always test your integration using test mode and test cards before going to production.

8. **Metadata**: Use the metadata field to attach order information to payment intents for easier reconciliation:

   ```crystal
   payment_intent = Stripe::Resources::PaymentIntent.create(
     client,
     # ... other parameters
     metadata: {
       "order_id" => "6735",
       "customer_email" => "customer@example.com"
     }
   )
   ```

9. **Security**: Never log full payment intent objects as they may contain sensitive information. Only log the ID and status.

10. **Handling authentication**: Be prepared to handle additional authentication steps required for 3D Secure or other SCA requirements.

## Status Lifecycle

Understanding the payment intent status is crucial:

- `requires_payment_method`: Initial status, waiting for payment method
- `requires_confirmation`: Ready to be confirmed
- `requires_action`: Additional action needed (like 3D Secure authentication)
- `processing`: Payment is being processed
- `requires_capture`: Payment authorized and ready to be captured
- `succeeded`: Payment completed successfully
- `canceled`: Payment intent was canceled

Always check the status of the payment intent to determine the next steps in your payment flow.
