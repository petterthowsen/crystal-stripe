# Coupons

Coupons represent discounts that can be applied to a Customer's Invoice. They can be applied to Subscriptions or one-off Invoices.

## The Coupon Object

```json
{
  "id": "jMT0WJUD", 
  "object": "coupon",
  "amount_off": null,
  "created": 1678037688,
  "currency": null,
  "duration": "forever",
  "duration_in_months": null,
  "livemode": false,
  "max_redemptions": null,
  "metadata": {},
  "name": null,
  "percent_off": 25.5,
  "redeem_by": null,
  "times_redeemed": 0,
  "valid": true
}
```

### Attributes

| Field | Type | Description |
| ----- | ---- | ----------- |
| `id` | string | Unique identifier for the object. |
| `object` | string | String representing the object's type. Value is "coupon". |
| `amount_off` | integer | Amount (in the currency specified) that will be taken off the subtotal of any invoices for this customer. |
| `created` | timestamp | Time at which the object was created. |
| `currency` | string | If `amount_off` has been set, the three-letter ISO code for the currency of the amount to take off. |
| `duration` | string | One of "forever", "once", or "repeating". Describes how long a customer who applies this coupon will get the discount. |
| `duration_in_months` | integer | If `duration` is "repeating", the number of months the coupon applies. |
| `livemode` | boolean | Has the value `true` if the object exists in live mode or the value `false` if the object exists in test mode. |
| `max_redemptions` | integer | Maximum number of times this coupon can be redeemed, in total, across all customers, before it's no longer valid. |
| `metadata` | object | Set of key-value pairs that can be attached to an object. |
| `name` | string | Name of the coupon displayed to customers on invoices or receipts. |
| `percent_off` | float | Percent that will be taken off the subtotal of any invoices for this customer for the duration of the coupon. |
| `redeem_by` | timestamp | Date after which the coupon can no longer be redeemed. |
| `times_redeemed` | integer | Number of times this coupon has been applied to a customer. |
| `valid` | boolean | Taking account of the above properties, whether this coupon can still be applied to a customer. |
| `applies_to` | object | A hash containing information about restrictions on this coupon's application. |

## Create a Coupon

```
POST /v1/coupons
```

### Parameters

| Field | Type | Description |
| ----- | ---- | ----------- |
| `amount_off` | integer | A positive integer representing the amount to subtract from an invoice total (required if `percent_off` is not passed). |
| `currency` | string | Three-letter ISO code for the currency of the `amount_off` parameter (required if `amount_off` is passed). |
| `duration` | string | Specifies how long the discount will be in effect. One of "forever", "once", or "repeating". Defaults to "once". |
| `duration_in_months` | integer | Required only if `duration` is "repeating", in which case it must be a positive integer that specifies the number of months the discount will be in effect. |
| `id` | string | Unique string of your choice that will be used to identify this coupon when applying it to a customer. |
| `max_redemptions` | integer | Maximum number of times this coupon can be redeemed, in total, across all customers, before it's no longer valid. |
| `metadata` | object | Set of key-value pairs that you can attach to an object. |
| `name` | string | Name of the coupon displayed to customers on invoices or receipts. |
| `percent_off` | float | A positive float larger than 0, and smaller or equal to 100, that represents the discount the coupon will apply (required if `amount_off` is not passed). |
| `redeem_by` | timestamp | Date after which the coupon can no longer be redeemed. |

## Retrieve a Coupon

```
GET /v1/coupons/{coupon}
```

## Update a Coupon

```
POST /v1/coupons/{coupon}
```

### Parameters

| Field | Type | Description |
| ----- | ---- | ----------- |
| `metadata` | object | Set of key-value pairs that you can attach to an object. |
| `name` | string | Name of the coupon displayed to customers on invoices or receipts. |

## Delete a Coupon

```
DELETE /v1/coupons/{coupon}
```

## List All Coupons

```
GET /v1/coupons
```

### Parameters

| Field | Type | Description |
| ----- | ---- | ----------- |
| `created` | object | Filter by creation date. |
| `ending_before` | string | A cursor for pagination. |
| `limit` | integer | A limit on the number of objects to be returned, between 1 and 100. |
| `starting_after` | string | A cursor for pagination. |
