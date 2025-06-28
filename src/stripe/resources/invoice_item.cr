require "../client"

module Stripe::Resources::InvoiceItem
  # Creates a new invoice item object.
  # 
  # See Stripe API docs: https://docs.stripe.com/api/invoiceitems/create
  #
  # ```
  # client = Stripe::Client.new(api_key: ENV["STRIPE_API_KEY"])
  # 
  # # Create an invoice item with direct amount
  # invoice_item = Stripe::Resources::InvoiceItem.create(
  #   client,
  #   customer: "cus_12345",
  #   unit_amount: 2000,
  #   currency: "usd"
  # )
  # 
  # # Create an invoice item with price reference
  # invoice_item = Stripe::Resources::InvoiceItem.create(
  #   client,
  #   customer: "cus_12345",
  #   price: "price_12345"
  # )
  # 
  # # Create an invoice item for a specific invoice
  # invoice_item = Stripe::Resources::InvoiceItem.create(
  #   client,
  #   customer: "cus_12345",
  #   unit_amount: 1500,
  #   currency: "usd",
  #   invoice: "in_12345"
  # )
  # ```
  def self.create(client : Stripe::Client, **params) : JSON::Any
    client.request(:post, "/v1/invoiceitems", params)
  end

  # Retrieves the invoice item with the given ID.
  #
  # See Stripe API docs: https://docs.stripe.com/api/invoiceitems/retrieve
  #
  # ```
  # client = Stripe::Client.new(api_key: ENV["STRIPE_API_KEY"])
  # invoice_item = Stripe::Resources::InvoiceItem.retrieve(client, "ii_12345")
  # ```
  def self.retrieve(client : Stripe::Client, id : String, **params) : JSON::Any
    client.request(:get, "/v1/invoiceitems/#{id}", params)
  end

  # Updates an existing invoice item.
  #
  # See Stripe API docs: https://docs.stripe.com/api/invoiceitems/update
  #
  # ```
  # client = Stripe::Client.new(api_key: ENV["STRIPE_API_KEY"])
  # 
  # # Update invoice item description
  # invoice_item = Stripe::Resources::InvoiceItem.update(
  #   client,
  #   "ii_12345",
  #   description: "Updated description"
  # )
  # 
  # # Update invoice item metadata
  # invoice_item = Stripe::Resources::InvoiceItem.update(
  #   client,
  #   "ii_12345",
  #   metadata: {"order_id" => "6735"}
  # )
  # ```
  def self.update(client : Stripe::Client, id : String, **params) : JSON::Any
    client.request(:post, "/v1/invoiceitems/#{id}", params)
  end

  # Deletes an invoice item, removing it from an invoice.
  #
  # See Stripe API docs: https://docs.stripe.com/api/invoiceitems/delete
  #
  # ```
  # client = Stripe::Client.new(api_key: ENV["STRIPE_API_KEY"])
  # deleted_invoice_item = Stripe::Resources::InvoiceItem.delete(client, "ii_12345")
  # ```
  def self.delete(client : Stripe::Client, id : String, **params) : JSON::Any
    client.request(:delete, "/v1/invoiceitems/#{id}", params)
  end

  # Returns a list of invoice items.
  #
  # See Stripe API docs: https://docs.stripe.com/api/invoiceitems/list
  #
  # ```
  # client = Stripe::Client.new(api_key: ENV["STRIPE_API_KEY"])
  # 
  # # List all invoice items
  # invoice_items = Stripe::Resources::InvoiceItem.list(client)
  #
  # # List invoice items for a specific customer
  # invoice_items = Stripe::Resources::InvoiceItem.list(
  #   client,
  #   customer: "cus_12345",
  #   limit: 5
  # )
  #
  # # List pending invoice items
  # invoice_items = Stripe::Resources::InvoiceItem.list(
  #   client,
  #   pending: true
  # )
  # ```
  def self.list(client : Stripe::Client, **params) : JSON::Any
    client.request(:get, "/v1/invoiceitems", params)
  end
end
