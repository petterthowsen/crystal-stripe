# Stripe Invoice Items API

Invoice Items represent line items that have been or will be added to an invoice. They're created via the API or when a customer is charged for a subscription.

## The Invoice Item object

### Attributes

- **id** `string` - Unique identifier for the object.

- **amount** `integer` - Amount (in the currency specified) of the invoice item. This should always be equal to unit_amount * quantity.

- **currency** `enum` - Three-letter ISO currency code, in lowercase. Must be a supported currency.

- **customer** `string` - The ID of the customer who will be billed when this invoice item is billed.

- **description** `nullable string` - An arbitrary string attached to the object. Often useful for displaying to users.

- **metadata** `nullable object` - Set of key-value pairs that you can attach to an object. This can be useful for storing additional information about the object in a structured format.

- **parent** `nullable object` - The parent that generated this invoice item.

- **period** `object` - The period associated with this invoice item. When set to different values, the period will be rendered on the invoice. If you have Stripe Revenue Recognition enabled, the period will be used to recognize and defer revenue.

- **pricing** `nullable object` - The pricing information of the invoice item.

- **proration** `boolean` - Whether the invoice item was created automatically as a proration adjustment when the customer switched plans.

## API Operations

### Create an invoice item

```
POST /v1/invoiceitems
```

#### Parameters

- **customer** `string` - Required. The ID of the customer who will be billed when this invoice item is billed.

- **amount** `integer` - Required if pricing is not provided. The integer amount in the currency specified. If a pricing object is provided, the quantity and pricing will be used to calculate the amount.

- **currency** `string` - Required if amount is provided. Three-letter ISO currency code, in lowercase. Must be a supported currency.

- **description** `string` - An arbitrary string attached to the object. Often useful for displaying to users.

- **discountable** `boolean` - Controls whether discounts apply to this invoice item. Defaults to false for prorations or negative invoice items, and true for all other invoice items. Cannot be set to true for prorations.

- **invoice** `string` - The ID of an existing invoice to add this invoice item to. When left blank, the invoice item will be added to the next upcoming scheduled invoice. This is useful when adding invoice items in response to an invoice.created webhook. When set, the invoice item will be added to the specified invoice.

- **metadata** `object` - Set of key-value pairs that you can attach to an object. This can be useful for storing additional information about the object in a structured format.

- **period** `object` - The period associated with this invoice item.
  - **end** `integer` - Required. The end of the period, which must be greater than or equal to the start.
  - **start** `integer` - Required. The start of the period.

- **price** `string` - The ID of a price object. When provided, the price will be used to determine the amount, currency, and the product associated with this invoice item.

- **quantity** `integer` - Non-negative integer. The quantity of units for the invoice item. Defaults to 1.

- **unit_amount** `integer` - The integer unit amount in cents of the charge to be applied to the upcoming invoice. This unit_amount will be multiplied by the quantity to get the full amount. Defaults to 0 if not provided.

- **unit_amount_decimal** `string` - Same as unit_amount, but accepts a decimal value with at most 12 decimal places. Only one of unit_amount and unit_amount_decimal can be set.

### Update an invoice item

```
POST /v1/invoiceitems/{invoiceitem}
```

### Retrieve an invoice item

```
GET /v1/invoiceitems/{invoiceitem}
```

### Delete an invoice item

```
DELETE /v1/invoiceitems/{invoiceitem}
```

### List all invoice items

```
GET /v1/invoiceitems
```

#### Parameters

- **created** `object` - A filter on the list based on the object created field. The value can be a string with an integer Unix timestamp, or a dictionary with the following options:
  - **gt** `integer` - Return results where the created field is greater than this value.
  - **gte** `integer` - Return results where the created field is greater than or equal to this value.
  - **lt** `integer` - Return results where the created field is less than this value.
  - **lte** `integer` - Return results where the created field is less than or equal to this value.

- **customer** `string` - Only return invoice items for the customer specified by this customer ID.

- **ending_before** `string` - A cursor for use in pagination. ending_before is an object ID that defines your place in the list. For instance, if you make a list request and receive 100 objects, starting with obj_bar, your subsequent call can include ending_before=obj_bar in order to fetch the previous page of the list.

- **invoice** `string` - Only return invoice items belonging to this invoice. If none is provided, returns invoice items for all invoices.

- **limit** `integer` - A limit on the number of objects to be returned. Limit can range between 1 and 100, and the default is 10.

- **pending** `boolean` - Set to true to only show pending invoice items, which are not yet attached to any invoices. Set to false to show only invoice items that are already attached to invoices. If unspecified, no filter is applied.

- **starting_after** `string` - A cursor for use in pagination. starting_after is an object ID that defines your place in the list. For instance, if you make a list request and receive 100 objects, ending with obj_foo, your subsequent call can include starting_after=obj_foo in order to fetch the next page of the list.
