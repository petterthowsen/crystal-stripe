# Stripe Invoices API

Invoices are statements of amounts owed by a customer, and are either generated one-off, or generated periodically from a subscription. They contain invoice items, and proration adjustments that may be caused by subscription upgrades/downgrades (if necessary).

## The Invoice object

### Attributes

- **id** `string` - Unique identifier for the object. For preview invoices created using the create preview endpoint, this id will be prefixed with `upcoming_in`.

- **auto_advance** `boolean` - Controls whether Stripe performs automatic collection of the invoice. If false, the invoice's state doesn't automatically advance without an explicit action.

- **automatic_tax** `object` - Settings and latest results for automatic tax lookup for this invoice.

- **collection_method** `enum` - Either `charge_automatically`, or `send_invoice`. When charging automatically, Stripe will attempt to pay this invoice using the default source attached to the customer. When sending an invoice, Stripe will email this invoice to the customer with payment instructions.
  - `charge_automatically` - Attempt payment using the default source attached to the customer.
  - `send_invoice` - Email payment instructions to the customer.

- **confirmation_secret** `nullable object` - The confirmation secret associated with this invoice. Currently, this contains the client_secret of the PaymentIntent that Stripe creates during invoice finalization.

- **currency** `enum` - Three-letter ISO currency code, in lowercase. Must be a supported currency.

- **customer** `string` - The ID of the customer who will be billed.

- **description** `nullable string` - An arbitrary string attached to the object. Often useful for displaying to users. Referenced as 'memo' in the Dashboard.

- **hosted_invoice_url** `nullable string` - The URL for the hosted invoice page, which allows customers to view and pay an invoice. If the invoice has not been finalized yet, this will be null.

- **lines** `object` - The individual line items that make up the invoice. lines is sorted as follows: (1) pending invoice items (including prorations) in reverse chronological order, (2) subscription items in reverse chronological order, and (3) invoice items added after invoice creation in chronological order.

- **metadata** `nullable object` - Set of key-value pairs that you can attach to an object. This can be useful for storing additional information about the object in a structured format.

- **parent** `nullable object` - The parent that generated this invoice

- **period_end** `timestamp` - End of the usage period during which invoice items were added to this invoice. This looks back one period for a subscription invoice. Use the line item period to get the service period for each price.

- **period_start** `timestamp` - Start of the usage period during which invoice items were added to this invoice. This looks back one period for a subscription invoice. Use the line item period to get the service period for each price.

- **status** `nullable enum` - The status of the invoice, one of draft, open, paid, uncollectible, or void.

- **total** `integer` - Total after discounts and taxes.

## API Operations

### Create an invoice

```
POST /v1/invoices
```

#### Parameters

- **auto_advance** `boolean` - Controls whether Stripe performs automatic collection of the invoice. If false, the invoice's state doesn't automatically advance without an explicit action.

- **automatic_tax** `object` - Settings for automatic tax lookup for this invoice.

- **collection_method** `enum` - Either `charge_automatically`, or `send_invoice`. When charging automatically, Stripe will attempt to pay this invoice using the default source attached to the customer. When sending an invoice, Stripe will email this invoice to the customer with payment instructions. Defaults to `charge_automatically`.
  - `charge_automatically`
  - `send_invoice`

- **customer** `string` - Required unless from_invoice is provided. The ID of the customer who will be billed.

- **description** `string` - An arbitrary string attached to the object. Often useful for displaying to users. Referenced as 'memo' in the Dashboard.

- **metadata** `object` - Set of key-value pairs that you can attach to an object. This can be useful for storing additional information about the object in a structured format. Individual keys can be unset by posting an empty value to them. All keys can be unset by posting an empty value to metadata.

- **subscription** `string` - The ID of the subscription to invoice, if any. If set, the created invoice will only include pending invoice items for that subscription. The subscription's billing cycle and regular subscription events won't be affected.

### Update an invoice

```
POST /v1/invoices/{invoice}
```

### Retrieve an invoice

```
GET /v1/invoices/{invoice}
```

### Delete an invoice

```
DELETE /v1/invoices/{invoice}
```

### List all invoices

```
GET /v1/invoices
```

### Finalize an invoice

```
POST /v1/invoices/{invoice}/finalize
```

### Pay an invoice

```
POST /v1/invoices/{invoice}/pay
```

### Send an invoice

```
POST /v1/invoices/{invoice}/send
```

### Void an invoice

```
POST /v1/invoices/{invoice}/void
```

### Mark an invoice as uncollectible

```
POST /v1/invoices/{invoice}/mark_uncollectible
```
