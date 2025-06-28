# Customer Resource

The Customer resource allows you to create, update, retrieve, and manage your Stripe customers. This document explains how to work with customers using the Crystal Stripe library.

## Overview

Customers are at the core of Stripe's payments platform. They allow you to:
- Store payment information securely for future use
- Charge customers for one-time purchases
- Set up subscriptions for recurring billing
- Track customer behavior and purchase history

## Usage

### Initializing the Client

```crystal
client = Stripe::Client.new(api_key: ENV["STRIPE_API_KEY"])
```

### Creating a Customer

Create a new customer with basic information:

```crystal
customer = Stripe::Resources::Customer.create(
  client,
  email: "customer@example.com",
  name: "Jenny Rosen",
  description: "Customer from Crystal Stripe library documentation"
)

customer_id = customer["id"].as_s # => "cus_..."
```

You can also attach metadata to customers:

```crystal
customer = Stripe::Resources::Customer.create(
  client,
  email: "customer@example.com",
  name: "Jenny Rosen",
  metadata: {
    "order_id" => "6735",
    "reference" => "crystal-test"
  }
)
```

### Retrieving a Customer

Retrieve a customer by their ID:

```crystal
customer = Stripe::Resources::Customer.retrieve(client, "cus_123456")

# Access customer properties
name = customer["name"].as_s
email = customer["email"].as_s
```

### Updating a Customer

Update an existing customer:

```crystal
updated_customer = Stripe::Resources::Customer.update(
  client,
  "cus_123456",
  name: "New Name",
  metadata: {"order_id" => "6735"}
)
```

### Deleting a Customer

Delete a customer:

```crystal
deleted = Stripe::Resources::Customer.delete(client, "cus_123456")
deleted["deleted"].as_bool # => true
```

### Listing Customers

List all customers with pagination:

```crystal
# Basic list
customers = Stripe::Resources::Customer.list(client)

# With pagination
customers = Stripe::Resources::Customer.list(
  client,
  limit: 3,
  starting_after: "cus_previousLastId"
)

# Access list data
customers["data"].as_a.each do |customer|
  puts "#{customer["id"].as_s}: #{customer["name"].as_s}"
end
```

Check for pagination:

```crystal
if customers["has_more"].as_bool
  # There are more customers to retrieve
  next_customers = Stripe::Resources::Customer.list(
    client,
    starting_after: customers["data"].as_a.last["id"].as_s
  )
end
```

### Searching Customers

Search customers with a query string (if your account has search capabilities):

```crystal
# Search by email
customers = Stripe::Resources::Customer.search(
  client,
  query: "email:'customer@example.com'"
)

# Search by metadata
customers = Stripe::Resources::Customer.search(
  client,
  query: "metadata['order_id']:'6735'"
)

# Access search results
customers["data"].as_a.each do |customer|
  puts "#{customer["id"].as_s}: #{customer["name"].as_s}"
end
```

## Error Handling

Handle errors when working with customers:

```crystal
begin
  customer = Stripe::Resources::Customer.retrieve(client, "cus_nonexistent")
rescue e : Stripe::InvalidRequestError
  puts "Customer not found: #{e.message}"
rescue e : Stripe::Error
  puts "Error: #{e.message}"
end
```

## Best Practices

1. **Secure API Keys**: Always keep your Stripe API key secure and never expose it in client-side code.

2. **Use Metadata**: Add metadata to track important business information, but don't store sensitive data.

3. **Search Capabilities**: Search functionality might not be available on all Stripe accounts. Handle the case where search is not enabled gracefully.

4. **Rate Limiting**: Be aware of Stripe's rate limits when making many API requests in quick succession.

5. **Pagination**: Always check and handle pagination for list operations to ensure you retrieve all necessary data.
