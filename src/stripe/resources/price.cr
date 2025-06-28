require "../client"

module Stripe::Resources::Price
  # Creates a new price for an existing product.
  # 
  # See Stripe API docs: https://docs.stripe.com/api/prices/create
  #
  # ```
  # client = Stripe::Client.new(api_key: ENV["STRIPE_API_KEY"])
  # 
  # # Create a one-time price
  # price = Stripe::Resources::Price.create(client, 
  #   product: "prod_12345",
  #   unit_amount: 2000,
  #   currency: "usd"
  # )
  #
  # # Create a recurring monthly price
  # subscription_price = Stripe::Resources::Price.create(client,
  #   product: "prod_12345",
  #   unit_amount: 1500,
  #   currency: "usd",
  #   recurring: {
  #     interval: "month",
  #     interval_count: 1
  #   }
  # )
  # ```
  def self.create(client : Stripe::Client, **params) : JSON::Any
    client.request(:post, "/v1/prices", params)
  end

  # Retrieves the details of an existing price.
  #
  # See Stripe API docs: https://docs.stripe.com/api/prices/retrieve
  #
  # ```
  # client = Stripe::Client.new(api_key: ENV["STRIPE_API_KEY"])
  # price = Stripe::Resources::Price.retrieve(client, "price_12345")
  # ```
  def self.retrieve(client : Stripe::Client, id : String) : JSON::Any
    client.request(:get, "/v1/prices/#{id}")
  end

  # Updates the specified price by setting the values of the parameters passed.
  # Only metadata, active, and nickname attributes can be updated.
  #
  # See Stripe API docs: https://docs.stripe.com/api/prices/update
  #
  # ```
  # client = Stripe::Client.new(api_key: ENV["STRIPE_API_KEY"])
  # 
  # # Update price nickname and active status
  # price = Stripe::Resources::Price.update(client, "price_12345",
  #   nickname: "Premium Monthly",
  #   active: false
  # )
  # ```
  def self.update(client : Stripe::Client, id : String, **params) : JSON::Any
    client.request(:post, "/v1/prices/#{id}", params)
  end
  
  # Returns a list of your prices.
  #
  # See Stripe API docs: https://docs.stripe.com/api/prices/list
  #
  # ```
  # client = Stripe::Client.new(api_key: ENV["STRIPE_API_KEY"])
  # 
  # # List all active prices for a specific product
  # prices = Stripe::Resources::Price.list(client, 
  #   active: true,
  #   product: "prod_12345"
  # )
  #
  # # List prices with a limit and type filter
  # prices = Stripe::Resources::Price.list(client, 
  #   limit: 5,
  #   type: "recurring"
  # )
  # ```
  def self.list(client : Stripe::Client, **params) : JSON::Any
    client.request(:get, "/v1/prices", params)
  end

  # Search for prices using Stripe's Search Query Language.
  #
  # See Stripe API docs: https://docs.stripe.com/api/prices/search
  #
  # ```
  # client = Stripe::Client.new(api_key: ENV["STRIPE_API_KEY"])
  # 
  # # Search for active recurring prices for a specific product
  # prices = Stripe::Resources::Price.search(client, 
  #   query: "active:'true' AND type:'recurring' AND product:'prod_12345'"
  # )
  # ```
  def self.search(client : Stripe::Client, **params) : JSON::Any
    client.request(:get, "/v1/prices/search", params)
  end
end
