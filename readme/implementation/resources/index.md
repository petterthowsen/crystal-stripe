# Stripe Resources

This directory contains documentation for the various Stripe API resources implemented in the Crystal Stripe library.

## Available Resources

- [Balance](balance.md) - Access to the Stripe Balance API

## Resource Implementation Pattern

Resources in the Crystal Stripe library follow a consistent pattern:

1. **Namespace**: All resources are under the `Stripe::Resources` namespace
2. **Class Methods**: Resources provide class methods for their operations, taking a `Stripe::Client` instance
3. **Return Values**: Methods return `JSON::Any` objects representing the parsed JSON response
4. **Error Handling**: Resource methods let errors from the client propagate up to the caller

## Common Resource Methods

Most resources implement some combination of the following methods:

- `retrieve`: Get a single resource by ID
- `list`: Get a list of resources, often with pagination
- `create`: Create a new resource
- `update`: Modify an existing resource
- `delete`: Delete a resource

## Example Resource Usage

```crystal
# Initialize the client
client = Stripe::Client.new(api_key: ENV["STRIPE_API_KEY"])

# Retrieve the balance
balance = Stripe::Resources::Balance.retrieve(client)

# List balance transactions
transactions = Stripe::Resources::Balance.list_transactions(
  client,
  limit: 10,
  starting_after: "txn_123456"
)

# Get a single transaction
transaction = Stripe::Resources::Balance.retrieve_transaction(client, "txn_123456")
```
