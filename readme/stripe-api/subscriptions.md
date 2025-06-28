# Stripe Subscriptions API

Subscriptions allow you to charge a customer on a recurring basis. A subscription ties a customer to a particular product and price you've created.

## API Reference

### The Subscription Object

The Subscription object contains information about a recurring payment, including what product/price combination the customer is subscribing to, and when the customer will be charged.

Key attributes:
- `id`: Unique identifier for the object
- `customer`: The ID of the customer who owns the subscription
- `status`: Current status of the subscription (active, canceled, incomplete, etc.)
- `current_period_start`: Start of the current period the subscription has been invoiced for
- `current_period_end`: End of the current period the subscription has been invoiced for
- `cancel_at_period_end`: If true, the subscription will be canceled at the end of the current period
- `items`: List of subscription items, each with its own price
- `default_payment_method`: ID of the default payment method for the subscription
- `latest_invoice`: ID of the latest invoice generated for this subscription
- `billing_cycle_anchor`: Determines billing frequency
- `billing_thresholds`: Configure when to advance the billing cycle
- `collection_method`: Either `charge_automatically` or `send_invoice`
- `default_source`: ID of the default payment source
- `metadata`: Set of key-value pairs for storing additional information
- `payment_settings`: Payment-related settings for this subscription

### Create a Subscription

```
POST /v1/subscriptions
```

Creates a new subscription for a customer.

Parameters:
- `customer` (required): The ID of the customer to subscribe
- `items` (required): List of items the customer is subscribing to
  - `price` (required): The ID of the price to subscribe the customer to
  - `quantity` (optional): Quantity of the item to subscribe to
- `payment_behavior` (optional): Controls subscription behavior on payment processing
- `payment_settings` (optional): Payment settings to apply to this subscription
- `trial_end` (optional): End date of the trial period
- `cancel_at_period_end` (optional): Indicates if this subscription should be canceled at the end of the current period
- `metadata` (optional): Set of key-value pairs for storing additional information
- `default_payment_method` (optional): ID of the payment method to be set as default
- `collection_method` (optional): Method of collecting payment
- `trial_from_plan` (optional): Inherit trial from plan if it exists
- `billing_cycle_anchor` (optional): Anchor of the billing cycle

### Retrieve a Subscription

```
GET /v1/subscriptions/:id
```

Retrieves the subscription with the given ID.

### Update a Subscription

```
POST /v1/subscriptions/:id
```

Updates an existing subscription on a customer to match the specified parameters.

### Cancel a Subscription

```
DELETE /v1/subscriptions/:id
```

Cancels a customer's subscription. If you set the `at_period_end` parameter to true, the subscription will remain active until the end of the period, at which point it will be canceled and not renewed.

### List Subscriptions

```
GET /v1/subscriptions
```

Returns a list of subscriptions.

## Specialized Methods

### Resume Subscription

```
POST /v1/subscriptions/:id/resume
```

Resumes a paused or inactive subscription.

### Set Subscription Items

```
POST /v1/subscription_items
```

Adds a new item to an existing subscription. Use this endpoint for subscription plan upgrades/downgrades.

## Best Practices

1. Consider using trial periods to let customers try your service before charging them
2. Offer multiple billing options (monthly, quarterly, annual) with appropriate discounts for longer commitments
3. Implement webhook handling for subscription events (payment failures, renewals, etc.)
4. Provide clear documentation on cancellation and refund policies
5. Set appropriate prorating behavior for subscription changes
6. Use metadata for tracking customer-specific details related to subscriptions
7. Configure dunning settings to handle failed payments gracefully
