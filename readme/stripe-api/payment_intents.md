# Stripe Payment Intent API

A PaymentIntent guides you through the process of collecting a payment from your customer. We recommend that you create exactly one PaymentIntent for each order or customer session in your system. You can reference the PaymentIntent later to see the history of payment attempts for a particular session.

A PaymentIntent transitions through multiple statuses throughout its lifetime as it interfaces with Stripe.js to perform authentication flows and ultimately creates at most one successful charge.

## API Reference

### The PaymentIntent Object

The PaymentIntent object contains information about a specific payment, including its status, amount, and associated payment methods.

### Create a PaymentIntent

```
POST /v1/payment_intents
```

Creates a PaymentIntent object. After the PaymentIntent is created, attach a payment method and confirm to continue the payment.

When you use `confirm=true` during creation, it's equivalent to creating and confirming the PaymentIntent in the same call.

### Retrieve a PaymentIntent

```
GET /v1/payment_intents/:id
```

Retrieves the details of a PaymentIntent that has previously been created.

### Update a PaymentIntent

```
POST /v1/payment_intents/:id
```

Updates properties on a PaymentIntent object without confirming.

### Confirm a PaymentIntent

```
POST /v1/payment_intents/:id/confirm
```

Confirm that your customer intends to pay with current or provided payment method. Upon confirmation, the PaymentIntent will attempt to initiate a payment.

If the selected payment method requires additional authentication steps, the PaymentIntent will transition to the `requires_action` status and suggest additional actions via `next_action`.

### Capture a PaymentIntent

```
POST /v1/payment_intents/:id/capture
```

Capture the funds of an existing uncaptured PaymentIntent when its status is `requires_capture`.

Uncaptured PaymentIntents are cancelled a set number of days (7 by default) after their creation.

### Cancel a PaymentIntent

```
POST /v1/payment_intents/:id/cancel
```

You can cancel a PaymentIntent object when it's in one of these statuses: `requires_payment_method`, `requires_capture`, `requires_confirmation`, `requires_action` or, in rare cases, `processing`.

After it's canceled, no additional charges are made by the PaymentIntent and any operations on the PaymentIntent fail with an error. For PaymentIntents with a status of `requires_capture`, the remaining `amount_capturable` is automatically refunded.

### List PaymentIntents

```
GET /v1/payment_intents
```

Returns a list of PaymentIntents.

## Payment Flow

1. **Create** a PaymentIntent with the expected payment amount and currency
2. **Attach** a payment method to the PaymentIntent
3. **Confirm** the PaymentIntent to initiate the payment
4. Handle any additional **authentication** steps if required
5. **Capture** the payment if using manual capture
6. Monitor the PaymentIntent's **status** to track the payment

## Common Parameters

- `amount`: A positive integer representing how much to charge in the smallest currency unit
- `currency`: Three-letter ISO currency code, in lowercase
- `payment_method_types`: The list of payment method types that this PaymentIntent is allowed to use
- `customer`: ID of the Customer this PaymentIntent belongs to, if one exists
- `payment_method`: ID of the payment method to attach to this PaymentIntent
- `capture_method`: Controls when the funds will be captured from the customer's account
- `confirmation_method`: Controls how payment methods are confirmed
- `description`: An arbitrary string attached to the object
- `metadata`: Set of key-value pairs that you can attach to an object

## Error Handling

Payment Intents can return a variety of error types depending on the specific issue:

- Card errors occur when the payment method is declined
- Authentication errors occur when the API key is invalid
- Rate limit errors occur when too many requests hit the API too quickly
- Invalid request errors occur when the request contains invalid parameters
- API errors occur when something unexpected happens on Stripe's end
