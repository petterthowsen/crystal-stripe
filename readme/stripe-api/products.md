# Stripe Products API

Products describe the specific goods or services you offer to your customers. For example, you might offer a Standard and Premium version of your goods or service; each version would be a separate Product. They can be used in conjunction with Prices to configure pricing in Payment Links, Checkout, and Subscriptions.

## API Reference

### The Product Object

The Product object contains information about a specific product, including its name, description, and whether it's active.

Key attributes:
- `id`: Unique identifier for the object
- `active`: Whether the product is currently available for purchase
- `default_price`: The ID of the Price object that is the default price for this product
- `description`: The product's description, meant to be displayable to the customer
- `metadata`: Set of key-value pairs for storing additional information
- `name`: The product's name, meant to be displayable to the customer
- `tax_code`: A tax code ID
- `images`: Array of image URLs
- `created`: Timestamp when the product was created
- `updated`: Timestamp when the product was last updated

### Create a Product

```
POST /v1/products
```

Creates a new product object.

Parameters:
- `name` (required): The product's name
- `active` (optional): Whether the product is available for purchase
- `description` (optional): The product's description
- `metadata` (optional): Set of key-value pairs
- `default_price` (optional): The ID of the default price for this product
- `images` (optional): A list of up to 8 URLs of images for this product
- `tax_code` (optional): A tax code ID
- `shippable` (optional): Whether this product is shipped
- `unit_label` (optional): A label for units of this product
- `url` (optional): A URL of a publicly-accessible webpage for this product

### Retrieve a Product

```
GET /v1/products/:id
```

Retrieves the details of an existing product.

### Update a Product

```
POST /v1/products/:id
```

Updates the specific product by setting the values of the parameters passed.

### Delete a Product

```
DELETE /v1/products/:id
```

Delete a product. Deleting a product is only possible if it has no prices associated with it.

### List Products

```
GET /v1/products
```

Returns a list of your products.

### Search Products

```
GET /v1/products/search
```

Search for products you've previously created using Stripe's Search Query Language.

## Best Practices

1. Create Products for distinct offerings in your business
2. Use Products in conjunction with Prices to define different pricing options
3. Store relevant product information in metadata for easier querying
4. Use clear, descriptive names and descriptions for products
5. Link products to appropriate tax codes for correct tax calculation
