# Balance Resource

The `Stripe::Resources::Balance` class provides access to the Stripe Balance API, allowing you to retrieve your Stripe account balance and list balance history.

## Available Methods

### Retrieving the Account Balance

```crystal
# Initialize the client
client = Stripe::Client.new(api_key: "sk_test_...")

# Get the current balance
balance = Stripe::Resources::Balance.retrieve(client)

# Access balance information
available_amount = balance["available"].as_a.first["amount"].as_i
available_currency = balance["available"].as_a.first["currency"].as_s

puts "Available balance: #{available_amount / 100.0} #{available_currency.upcase}"
```

The response includes:
- `object`: Always "balance"
- `available`: Array of funds available for payout
- `pending`: Array of funds pending to be available
- `connect_reserved`: For Connect accounts, funds held in reserve

Each balance entry contains:
- `amount`: The amount in the smallest currency unit (e.g., cents)
- `currency`: The three-letter ISO currency code
- `source_types`: Breakdown of balance by source types

### Listing Balance Transactions

```crystal
# Get all balance transactions
transactions = Stripe::Resources::Balance.list_transactions(client)

# Get transactions with pagination parameters
transactions = Stripe::Resources::Balance.list_transactions(
  client,
  limit: 10,
  starting_after: "txn_123456",
  ending_before: "txn_789012",
  source: "ch_123456",
  type: "charge",
  created: {gt: Time.utc(2023, 1, 1).to_unix}
)

# Iterate through transaction items
transactions["data"].as_a.each do |txn|
  puts "#{txn["id"]} - #{txn["amount"]/100.0} #{txn["currency"]}: #{txn["description"]}"
end
```

Available parameters for `list_transactions`:
- `limit`: Maximum number of transactions to return
- `starting_after`: Pagination cursor for after which object the listing should start
- `ending_before`: Pagination cursor for before which object the listing should end
- `created`: Filter by created timestamp (using comparison operators)
- `available_on`: Filter by when funds become available
- `currency`: Filter by currency
- `source`: Filter by source ID
- `type`: Filter by transaction type

### Retrieving a Specific Transaction

```crystal
# Get a single transaction by ID
transaction = Stripe::Resources::Balance.retrieve_transaction(client, "txn_123456")

# Access transaction information
amount = transaction["amount"].as_i
currency = transaction["currency"].as_s
status = transaction["status"].as_s

puts "Transaction #{transaction["id"]}: #{amount / 100.0} #{currency} (#{status})"
```

The transaction object includes details like:
- `id`: The transaction identifier
- `object`: Always "balance_transaction"
- `amount`: The transaction amount
- `available_on`: When the funds become available
- `created`: When the transaction was created
- `currency`: The three-letter ISO currency code
- `description`: Description of the transaction
- `fee`: Fees associated with the transaction
- `net`: Net amount after fees
- `status`: Status of the transaction (e.g., "available", "pending")
- `type`: Type of transaction (e.g., "charge", "refund")

## Error Handling

All Balance resource methods propagate errors from the underlying `Stripe::Client`, so you should handle potential exceptions:

```crystal
begin
  balance = Stripe::Resources::Balance.retrieve(client)
rescue e : Stripe::AuthenticationError
  puts "Authentication failed: #{e.message}"
rescue e : Stripe::APIError
  puts "API error: #{e.message}"
end
```

See [Error Handling](../error-handling.md) for more details on the available error types.
