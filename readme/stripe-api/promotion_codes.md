# Promotion Codes

Promotion codes are customer-facing codes that can be used to apply a coupon to a customer.

## The Promotion Code Object

```json
{
  "id": "promo_1MiM6KLkdIwHu7ixrIaX4wgn",
  "object": "promotion_code",
  "active": true,
  "code": "A1H1Q1MG",
  "coupon": {
    "id": "nVJYDOag",
    "object": "coupon",
    "amount_off": null,
    "created": 1678040164,
    "currency": null,
    "duration": "repeating",
    "duration_in_months": 3,
    "livemode": false,
    "max_redemptions": null,
    "metadata": {},
    "name": null,
    "percent_off": 25.5,
    "redeem_by": null,
    "times_redeemed": 0,
    "valid": true
  },
  "created": 1678040164,
  "customer": null,
  "expires_at": null,
  "livemode": false,
  "max_redemptions": null,
  "metadata": {},
  "restrictions": {
    "first_time_transaction": false,
    "minimum_amount": null,
    "minimum_amount_currency": null
  },
  "times_redeemed": 0
}
```

### Attributes

| Field | Type | Description |
| ----- | ---- | ----------- |
| `id` | string | Unique identifier for the object. |
| `object` | string | String representing the object's type. Value is "promotion_code". |
| `active` | boolean | Whether the promotion code is currently active. |
| `code` | string | The customer-facing code. Regardless of case, this code must be unique across all active promotion codes for a specific customer. |
| `coupon` | object | The coupon attached to this promotion code. |
| `created` | timestamp | Time at which the object was created. |
| `customer` | string | The customer that this promotion code can be used by. |
| `expires_at` | timestamp | Date after which the promotion code can no longer be redeemed. |
| `livemode` | boolean | Has the value `true` if the object exists in live mode or the value `false` if the object exists in test mode. |
| `max_redemptions` | integer | Maximum number of times this promotion code can be redeemed. |
| `metadata` | object | Set of key-value pairs that can be attached to an object. |
| `restrictions` | object | Object representing restrictions on promotion code redemption. |
| `restrictions.first_time_transaction` | boolean | A Boolean indicating if the Promotion Code should only be redeemed for Customers without any successful payments or invoices. |
| `restrictions.minimum_amount` | integer | Minimum amount required to redeem this Promotion Code into a Coupon. |
| `restrictions.minimum_amount_currency` | string | Three-letter ISO code for the minimum_amount currency. |
| `times_redeemed` | integer | Number of times this promotion code has been used. |

## Create a Promotion Code

```
POST /v1/promotion_codes
```

### Parameters

| Field | Type | Description |
| ----- | ---- | ----------- |
| `coupon` | string | The coupon for this promotion code. Required. |
| `active` | boolean | Whether the promotion code is currently active. Default is true. |
| `code` | string | The customer-facing code. Must be unique across all active promotion codes. If left blank, we will generate one automatically. |
| `customer` | string | The customer that this promotion code can be used by. |
| `expires_at` | timestamp | The timestamp at which this promotion code will expire. |
| `max_redemptions` | integer | Maximum number of times this promotion code can be redeemed. |
| `metadata` | object | Set of key-value pairs that you can attach to an object. |
| `restrictions` | object | Restrictions on the promotion code. |
| `restrictions.first_time_transaction` | boolean | A Boolean indicating if the Promotion Code should only be redeemed for Customers without any successful payments or invoices. |
| `restrictions.minimum_amount` | integer | Minimum amount required to redeem this Promotion Code into a Coupon. |
| `restrictions.minimum_amount_currency` | string | Three-letter ISO code for the minimum_amount currency. |

## Retrieve a Promotion Code

```
GET /v1/promotion_codes/{promotion_code}
```

## Update a Promotion Code

```
POST /v1/promotion_codes/{promotion_code}
```

### Parameters

| Field | Type | Description |
| ----- | ---- | ----------- |
| `active` | boolean | Whether the promotion code is currently active. |
| `metadata` | object | Set of key-value pairs that you can attach to an object. |

## List all Promotion Codes

```
GET /v1/promotion_codes
```

### Parameters

| Field | Type | Description |
| ----- | ---- | ----------- |
| `active` | boolean | Filter promotion codes by whether they are active or not. |
| `code` | string | Only return promotion codes with the given code. |
| `coupon` | string | Only return promotion codes for the given coupon. |
| `created` | object | Filter by creation date. |
| `customer` | string | Only return promotion codes that can be used by the given customer. |
| `ending_before` | string | A cursor for pagination. |
| `limit` | integer | A limit on the number of objects to be returned, between 1 and 100. |
| `starting_after` | string | A cursor for pagination. |
