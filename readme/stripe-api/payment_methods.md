# Payment Methods

PaymentMethod objects represent your customer's payment instruments. You can use them with [PaymentIntents](https://docs.stripe.com/payments/payment-intents) to collect payments or save them to Customer objects to store instrument details for future payments.

Related guides: Payment Methods and [More Payment Scenarios](https://docs.stripe.com/payments/more-payment-scenarios).

## API Operations

- `POST /v1/payment_methods` - [Create a PaymentMethod](#create-a-paymentmethod)
- `POST /v1/payment_methods/:id` - [Update a PaymentMethod](#update-a-paymentmethod)
- `GET /v1/customers/:id/payment_methods/:id` - [Retrieve a Customer's PaymentMethod](#retrieve-a-customers-paymentmethod)
- `GET /v1/payment_methods/:id` - [Retrieve a PaymentMethod](#retrieve-a-paymentmethod)
- `GET /v1/customers/:id/payment_methods` - [List a Customer's PaymentMethods](#list-a-customers-paymentmethods) 
- `GET /v1/payment_methods` - [List PaymentMethods](#list-paymentmethods)
- `POST /v1/payment_methods/:id/attach` - [Attach a PaymentMethod to a Customer](#attach-a-paymentmethod-to-a-customer)
- `POST /v1/payment_methods/:id/detach` - [Detach a PaymentMethod from a Customer](#detach-a-paymentmethod-from-a-customer)

## The PaymentMethod object

### Attributes

| Field | Type | Description |
| ----- | ---- | ----------- |
| `id` | string | Unique identifier for the object. |
| `billing_details` | object | Billing information associated with the PaymentMethod that may be used or required by particular types of payment methods. |
| `customer` | nullable string, expandable | The ID of the Customer to which this PaymentMethod is saved. This will not be set when the PaymentMethod has not been saved to a Customer. |
| `metadata` | nullable object | Set of key-value pairs that you can attach to an object. This can be useful for storing additional information about the object in a structured format. |
| `type` | enum | The type of the PaymentMethod. An additional hash is included on the PaymentMethod with a name matching this value. It contains additional information specific to the PaymentMethod type. |

#### Payment Method Types

- `acss_debit` - Pre-authorized debit payments are used to debit Canadian bank accounts through the Automated Clearing Settlement System (ACSS).
- `affirm` - Affirm is a buy now, pay later payment method in the US.
- `afterpay_clearpay` - Afterpay / Clearpay is a buy now, pay later payment method used in Australia, Canada, France, New Zealand, Spain, the UK, and the US.
- `alipay` - Alipay is a digital wallet payment method used in China.
- `alma` - Alma is a Buy Now, Pay Later payment method that lets customers pay in 2, 3, or 4 installments.
- `amazon_pay` - Amazon Pay is a Wallet payment method that lets hundreds of millions of Amazon customers pay their way, every day.
- `au_becs_debit` - BECS Direct Debit is used to debit Australian bank accounts through the Bulk Electronic Clearing System (BECS).
- `bacs_debit` - Bacs Direct Debit is used to debit UK bank accounts.
- `bancontact` - Bancontact is a bank redirect payment method used in Belgium.
- `billie` - Billie is a payment method.
- `card` - Cards are a common way to pay worldwide, accounting for about 40% of online spending.

(Note: There are 40+ more payment method types available; this is an abbreviated list)

## Create a PaymentMethod

Creates a PaymentMethod object. Read the [Stripe.js reference](https://docs.stripe.com/stripe-js/reference) to learn how to create PaymentMethods via Stripe.js.

Instead of creating a PaymentMethod directly, we recommend using the PaymentIntents API to accept a payment immediately or the [SetupIntent](https://docs.stripe.com/payments/save-and-reuse) API to collect payment method details ahead of a future payment.

### HTTP Request

```
POST https://api.stripe.com/v1/payment_methods
```

### Parameters

| Parameter | Type | Description |
| --------- | ---- | ----------- |
| `type` | required string | The type of the PaymentMethod. |
| `billing_details` | optional object | Billing information associated with the PaymentMethod that may be used or required by particular types of payment methods. |
| `metadata` | optional object | Set of key-value pairs that you can attach to an object. This can be useful for storing additional information about the object in a structured format. |
| `[payment_method_type]` | optional object | Additional parameters specific to the payment method type. For example, if type=card, you would include a `card` object with parameters like token, number, exp_month, exp_year, etc. |

### Returns

Returns a PaymentMethod object if successful. Returns an error if the parameters are invalid.

## Update a PaymentMethod

Updates a PaymentMethod object. A PaymentMethod must be attached to a customer to be updated.

### HTTP Request

```
POST https://api.stripe.com/v1/payment_methods/{id}
```

### Parameters

| Parameter | Type | Description |
| --------- | ---- | ----------- |
| `billing_details` | optional object | Billing information associated with the PaymentMethod that may be used or required by particular types of payment methods. |
| `metadata` | optional object | Set of key-value pairs that you can attach to an object. This can be useful for storing additional information about the object in a structured format. |
| `[payment_method_type]` | optional object | Additional parameters specific to the payment method type. |

### Returns

Returns the updated PaymentMethod object if successful. Returns an error otherwise.

## Retrieve a PaymentMethod

Retrieves a PaymentMethod object.

### HTTP Request

```
GET https://api.stripe.com/v1/payment_methods/{id}
```

### Returns

Returns a PaymentMethod object if a valid identifier was provided, and returns an error otherwise.

## List PaymentMethods

Returns a list of PaymentMethods for a given Customer.

### HTTP Request

```
GET https://api.stripe.com/v1/payment_methods
```

### Parameters

| Parameter | Type | Description |
| --------- | ---- | ----------- |
| `customer` | required string | The ID of the customer whose PaymentMethods will be retrieved. |
| `type` | required string | A required filter on the list, based on the object type field. |
| `limit` | optional integer | A limit on the number of objects to be returned. |
| `starting_after` | optional string | A cursor for use in pagination. |
| `ending_before` | optional string | A cursor for use in pagination. |

### Returns

A dictionary with a data property that contains an array of up to limit PaymentMethods, starting after starting_after. Each entry in the array is a separate PaymentMethod object. If no more PaymentMethods are available, the resulting array will be empty.

## Attach a PaymentMethod to a Customer

Attaches a PaymentMethod object to a Customer.

### HTTP Request

```
POST https://api.stripe.com/v1/payment_methods/{id}/attach
```

### Parameters

| Parameter | Type | Description |
| --------- | ---- | ----------- |
| `customer` | required string | The ID of the customer to which to attach the PaymentMethod. |

### Returns

Returns the attached PaymentMethod object if successful. Returns an error if the PaymentMethod or Customer does not exist, or if the operation is invalid.

## Detach a PaymentMethod from a Customer

Detaches a PaymentMethod object from a Customer.

### HTTP Request

```
POST https://api.stripe.com/v1/payment_methods/{id}/detach
```

### Returns

Returns the detached PaymentMethod object if successful. Returns an error if the PaymentMethod is not attached to a customer, does not exist, or if the operation is invalid.

## List a Customer's PaymentMethods

Returns a list of PaymentMethods for a given Customer.

### HTTP Request

```
GET https://api.stripe.com/v1/customers/{customer}/payment_methods
```

### Parameters

| Parameter | Type | Description |
| --------- | ---- | ----------- |
| `type` | required string | A required filter on the list, based on the object type field. |
| `limit` | optional integer | A limit on the number of objects to be returned. |
| `starting_after` | optional string | A cursor for use in pagination. |
| `ending_before` | optional string | A cursor for use in pagination. |

### Returns

A dictionary with a data property that contains an array of up to limit PaymentMethods, starting after starting_after. Each entry in the array is a separate PaymentMethod object. If no more PaymentMethods are available, the resulting array will be empty.
