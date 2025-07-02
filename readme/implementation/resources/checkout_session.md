# Checkout Sessions

## Overview

A Checkout Session represents a customer's session as they pay for one-time purchases or subscriptions through Stripe Checkout or Payment Links. The Checkout Session API allows you to create and manage these sessions.

API reference: [https://docs.stripe.com/api/checkout/sessions](https://docs.stripe.com/api/checkout/sessions)

## The Checkout Session Object

A Checkout Session includes the following key attributes:

| Attribute | Type | Description |
| --- | --- | --- |
| `id` | string | Unique identifier for the object. |
| `automatic_tax` | dictionary | Details on the state of automatic tax for the session. |
| `client_reference_id` | string | A unique string to reference the Checkout Session for reconciliation. |
| `currency` | string | Three-letter ISO currency code. |
| `customer` | string | The ID of the customer for this session. |
| `customer_email` | string | Email address for the customer. |
| `line_items` | array | The line items purchased by the customer. |
| `metadata` | dictionary | Set of key-value pairs for additional information. |
| `mode` | string | The mode of the Checkout Session (payment, setup, subscription). |
| `payment_intent` | string | The ID of the PaymentIntent for payment mode. |
| `payment_status` | string | The payment status (paid, unpaid, no_payment_required). |
| `return_url` | string | The URL to redirect customers after authentication. |
| `status` | string | The status of the Checkout Session (open, complete, expired). |
| `success_url` | string | The URL customers are directed to after successful payment. |
| `ui_mode` | string | The UI mode of the Session (hosted, embedded, custom). |
| `url` | string | The URL to the Checkout Session for hosted mode. |

## Checkout Sessions API

### Create a Checkout Session

Creates a new Checkout Session object.

**Required Parameters:**
- `mode`: The mode of the Checkout Session (payment, setup, subscription).
- For payment and subscription mode:
  - `line_items`: A list of items the customer is purchasing.
- For hosted mode:
  - `success_url`: URL to redirect after successful payment.
- For embedded or custom mode with redirect payment methods:
  - `return_url`: URL to redirect after authentication.

**Optional Parameters:**
- `automatic_tax`: Settings for automatic tax lookup.
- `client_reference_id`: A unique string to reference the session.
- `customer`: ID of an existing Customer.
- `customer_email`: Email address to prefill.
- `metadata`: Set of key-value pairs for additional information.
- `ui_mode`: The UI mode of the Session (defaults to hosted).

### Retrieve a Checkout Session

Retrieves a Checkout Session by its ID.

### Update a Checkout Session

Updates an existing Checkout Session.

### List Line Items

Retrieves a list of line items for a Checkout Session.

### List Checkout Sessions

Returns a list of Checkout Sessions.

### Expire a Checkout Session

Expires a Checkout Session.

## Implementation in Crystal

The `Stripe::Resources::CheckoutSession` module provides methods to interact with the Checkout Sessions API:

```crystal
# Create a new Checkout Session
checkout_session = Stripe::Resources::CheckoutSession.create(
  client,
  mode: "payment",
  success_url: "https://example.com/success",
  line_items: [
    {
      price: "price_1234",
      quantity: 1
    }
  ]
)

# Retrieve a Checkout Session
checkout_session = Stripe::Resources::CheckoutSession.retrieve(client, "cs_test_123456")

# Update a Checkout Session
checkout_session = Stripe::Resources::CheckoutSession.update(
  client,
  "cs_test_123456",
  metadata: {"order_id" => "6735"}
)

# List line items for a Checkout Session
line_items = Stripe::Resources::CheckoutSession.list_line_items(client, "cs_test_123456")

# List Checkout Sessions
checkout_sessions = Stripe::Resources::CheckoutSession.list(client, limit: 5)

# Expire a Checkout Session
expired_session = Stripe::Resources::CheckoutSession.expire(client, "cs_test_123456")
```
