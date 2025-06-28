require "../client"

module Stripe::Resources::Product
  # Creates a new product object.
  # 
  # See Stripe API docs: https://docs.stripe.com/api/products/create
  #
  # ```
  # client = Stripe::Client.new(api_key: ENV["STRIPE_API_KEY"])
  # 
  # # Create a standard product
  # product = Stripe::Resources::Product.create(client, 
  #   name: "Gold Plan",
  #   description: "Premium subscription plan with all features",
  #   active: true,
  #   metadata: {"category" => "subscription"}
  # )
  # ```
  def self.create(client : Stripe::Client, **params) : JSON::Any
    client.request(:post, "/v1/products", params)
  end

  # Retrieves the details of an existing product.
  #
  # See Stripe API docs: https://docs.stripe.com/api/products/retrieve
  #
  # ```
  # client = Stripe::Client.new(api_key: ENV["STRIPE_API_KEY"])
  # product = Stripe::Resources::Product.retrieve(client, "prod_12345")
  # ```
  def self.retrieve(client : Stripe::Client, id : String) : JSON::Any
    client.request(:get, "/v1/products/#{id}")
  end

  # Updates the specified product by setting the values of the parameters passed.
  #
  # See Stripe API docs: https://docs.stripe.com/api/products/update
  #
  # ```
  # client = Stripe::Client.new(api_key: ENV["STRIPE_API_KEY"])
  # 
  # # Update product name and description
  # product = Stripe::Resources::Product.update(client, "prod_12345",
  #   name: "Platinum Plan",
  #   description: "New improved features"
  # )
  # ```
  def self.update(client : Stripe::Client, id : String, **params) : JSON::Any
    client.request(:post, "/v1/products/#{id}", params)
  end
  
  # Delete a product. Deleting a product is only possible if it has no prices associated with it.
  #
  # See Stripe API docs: https://docs.stripe.com/api/products/delete
  #
  # ```
  # client = Stripe::Client.new(api_key: ENV["STRIPE_API_KEY"])
  # deleted_product = Stripe::Resources::Product.delete(client, "prod_12345")
  # ```
  def self.delete(client : Stripe::Client, id : String) : JSON::Any
    client.request(:delete, "/v1/products/#{id}")
  end

  # Returns a list of your products.
  #
  # See Stripe API docs: https://docs.stripe.com/api/products/list
  #
  # ```
  # client = Stripe::Client.new(api_key: ENV["STRIPE_API_KEY"])
  # 
  # # List all active products
  # products = Stripe::Resources::Product.list(client, active: true)
  #
  # # Limit to 5 products with a specific name
  # products = Stripe::Resources::Product.list(client, 
  #   limit: 5,
  #   name: "Gold Plan"
  # )
  # ```
  def self.list(client : Stripe::Client, **params) : JSON::Any
    client.request(:get, "/v1/products", params)
  end

  # Search for products using Stripe's Search Query Language.
  #
  # See Stripe API docs: https://docs.stripe.com/api/products/search
  #
  # ```
  # client = Stripe::Client.new(api_key: ENV["STRIPE_API_KEY"])
  # 
  # # Search for active products containing "Gold" in the name
  # products = Stripe::Resources::Product.search(client, 
  #   query: "active:'true' AND name:'Gold'"
  # )
  # ```
  def self.search(client : Stripe::Client, **params) : JSON::Any
    client.request(:get, "/v1/products/search", params)
  end
end
