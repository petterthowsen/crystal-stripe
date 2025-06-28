require "../client"

module Stripe::Resources::Coupon
  # Creates a new coupon object.
  # 
  # See Stripe API docs: https://docs.stripe.com/api/coupons/create
  #
  # ```
  # client = Stripe::Client.new(api_key: ENV["STRIPE_API_KEY"])
  # 
  # # Create a percent-off coupon
  # coupon = Stripe::Resources::Coupon.create(
  #   client,
  #   duration: "forever",
  #   percent_off: 25.5
  # )
  # 
  # # Create an amount-off coupon
  # coupon = Stripe::Resources::Coupon.create(
  #   client,
  #   duration: "once",
  #   amount_off: 1000,
  #   currency: "usd"
  # )
  # 
  # # Create a repeating coupon
  # coupon = Stripe::Resources::Coupon.create(
  #   client,
  #   duration: "repeating",
  #   duration_in_months: 3,
  #   percent_off: 10.0
  # )
  # ```
  def self.create(client : Stripe::Client, **params) : JSON::Any
    client.request(:post, "/v1/coupons", params)
  end

  # Retrieves the coupon with the given ID.
  #
  # See Stripe API docs: https://docs.stripe.com/api/coupons/retrieve
  #
  # ```
  # client = Stripe::Client.new(api_key: ENV["STRIPE_API_KEY"])
  # coupon = Stripe::Resources::Coupon.retrieve(client, "25OFF")
  # ```
  def self.retrieve(client : Stripe::Client, id : String, **params) : JSON::Any
    client.request(:get, "/v1/coupons/#{id}", params)
  end

  # Updates an existing coupon.
  #
  # See Stripe API docs: https://docs.stripe.com/api/coupons/update
  #
  # ```
  # client = Stripe::Client.new(api_key: ENV["STRIPE_API_KEY"])
  # 
  # # Update coupon name
  # coupon = Stripe::Resources::Coupon.update(
  #   client,
  #   "25OFF",
  #   name: "New Promotion Name"
  # )
  # 
  # # Update coupon metadata
  # coupon = Stripe::Resources::Coupon.update(
  #   client,
  #   "25OFF",
  #   metadata: {"campaign_id" => "summer_2025"}
  # )
  # ```
  def self.update(client : Stripe::Client, id : String, **params) : JSON::Any
    client.request(:post, "/v1/coupons/#{id}", params)
  end

  # Deletes a coupon.
  #
  # See Stripe API docs: https://docs.stripe.com/api/coupons/delete
  #
  # ```
  # client = Stripe::Client.new(api_key: ENV["STRIPE_API_KEY"])
  # deleted_coupon = Stripe::Resources::Coupon.delete(client, "25OFF")
  # ```
  def self.delete(client : Stripe::Client, id : String, **params) : JSON::Any
    client.request(:delete, "/v1/coupons/#{id}", params)
  end

  # Returns a list of coupons.
  #
  # See Stripe API docs: https://docs.stripe.com/api/coupons/list
  #
  # ```
  # client = Stripe::Client.new(api_key: ENV["STRIPE_API_KEY"])
  # 
  # # List all coupons
  # coupons = Stripe::Resources::Coupon.list(client)
  #
  # # List active coupons with pagination
  # coupons = Stripe::Resources::Coupon.list(
  #   client,
  #   limit: 5
  # )
  # ```
  def self.list(client : Stripe::Client, **params) : JSON::Any
    client.request(:get, "/v1/coupons", params)
  end
end
