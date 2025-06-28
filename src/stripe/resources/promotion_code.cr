require "../client"

module Stripe::Resources::PromotionCode
  # Creates a new promotion code object.
  # 
  # See Stripe API docs: https://docs.stripe.com/api/promotion_codes/create
  #
  # ```
  # client = Stripe::Client.new(api_key: ENV["STRIPE_API_KEY"])
  # 
  # # Create a promotion code for a coupon
  # promotion_code = Stripe::Resources::PromotionCode.create(
  #   client,
  #   coupon: "25OFF" 
  # )
  # 
  # # Create a promotion code with a custom code
  # promotion_code = Stripe::Resources::PromotionCode.create(
  #   client,
  #   coupon: "25OFF",
  #   code: "SUMMER2025"
  # )
  # 
  # # Create a promotion code with restrictions
  # promotion_code = Stripe::Resources::PromotionCode.create(
  #   client,
  #   coupon: "25OFF",
  #   restrictions: {
  #     first_time_transaction: true,
  #     minimum_amount: 1000,
  #     minimum_amount_currency: "usd"
  #   }
  # )
  # ```
  def self.create(client : Stripe::Client, **params) : JSON::Any
    client.request(:post, "/v1/promotion_codes", params)
  end

  # Retrieves the promotion code with the given ID.
  #
  # See Stripe API docs: https://docs.stripe.com/api/promotion_codes/retrieve
  #
  # ```
  # client = Stripe::Client.new(api_key: ENV["STRIPE_API_KEY"])
  # promotion_code = Stripe::Resources::PromotionCode.retrieve(client, "promo_12345")
  # ```
  def self.retrieve(client : Stripe::Client, id : String, **params) : JSON::Any
    client.request(:get, "/v1/promotion_codes/#{id}", params)
  end

  # Updates an existing promotion code.
  #
  # See Stripe API docs: https://docs.stripe.com/api/promotion_codes/update
  #
  # ```
  # client = Stripe::Client.new(api_key: ENV["STRIPE_API_KEY"])
  # 
  # # Disable a promotion code
  # promotion_code = Stripe::Resources::PromotionCode.update(
  #   client,
  #   "promo_12345",
  #   active: false
  # )
  # 
  # # Update promotion code metadata
  # promotion_code = Stripe::Resources::PromotionCode.update(
  #   client,
  #   "promo_12345",
  #   metadata: {"campaign_id" => "summer_2025"}
  # )
  # ```
  def self.update(client : Stripe::Client, id : String, **params) : JSON::Any
    client.request(:post, "/v1/promotion_codes/#{id}", params)
  end

  # Returns a list of promotion codes.
  #
  # See Stripe API docs: https://docs.stripe.com/api/promotion_codes/list
  #
  # ```
  # client = Stripe::Client.new(api_key: ENV["STRIPE_API_KEY"])
  # 
  # # List all promotion codes
  # promotion_codes = Stripe::Resources::PromotionCode.list(client)
  #
  # # List active promotion codes with pagination
  # promotion_codes = Stripe::Resources::PromotionCode.list(
  #   client, 
  #   active: true,
  #   limit: 5
  # )
  #
  # # List promotion codes for a specific coupon
  # promotion_codes = Stripe::Resources::PromotionCode.list(
  #   client,
  #   coupon: "25OFF"
  # )
  #
  # # List promotion codes for a specific customer
  # promotion_codes = Stripe::Resources::PromotionCode.list(
  #   client,
  #   customer: "cus_12345"
  # )
  # ```
  def self.list(client : Stripe::Client, **params) : JSON::Any
    client.request(:get, "/v1/promotion_codes", params)
  end
end
