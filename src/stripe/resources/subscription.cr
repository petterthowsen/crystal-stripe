require "../client"

module Stripe::Resources::Subscription
  # Creates a new subscription on a customer.
  # 
  # See Stripe API docs: https://docs.stripe.com/api/subscriptions/create
  #
  # ```
  # client = Stripe::Client.new(api_key: ENV["STRIPE_API_KEY"])
  # 
  # # Create a subscription for a customer
  # subscription = Stripe::Resources::Subscription.create(
  #   client,
  #   customer: "cus_12345",
  #   items: [
  #     {price: "price_12345"}
  #   ]
  # )
  # 
  # # Create a subscription with trial period
  # subscription = Stripe::Resources::Subscription.create(
  #   client, 
  #   customer: "cus_12345",
  #   items: [
  #     {price: "price_12345"}
  #   ],
  #   trial_period_days: 14
  # )
  # ```
  def self.create(client : Stripe::Client, **params) : JSON::Any
    client.request(:post, "/v1/subscriptions", params)
  end

  # Retrieves the subscription with the given ID.
  #
  # See Stripe API docs: https://docs.stripe.com/api/subscriptions/retrieve
  #
  # ```
  # client = Stripe::Client.new(api_key: ENV["STRIPE_API_KEY"])
  # subscription = Stripe::Resources::Subscription.retrieve(client, "sub_12345")
  # ```
  def self.retrieve(client : Stripe::Client, id : String, **params) : JSON::Any
    client.request(:get, "/v1/subscriptions/#{id}", params)
  end

  # Updates an existing subscription on a customer to match the specified parameters.
  #
  # See Stripe API docs: https://docs.stripe.com/api/subscriptions/update
  #
  # ```
  # client = Stripe::Client.new(api_key: ENV["STRIPE_API_KEY"])
  # 
  # # Update subscription metadata
  # subscription = Stripe::Resources::Subscription.update(
  #   client,
  #   "sub_12345",
  #   metadata: {"order_id" => "6735"}
  # )
  # 
  # # Update subscription items
  # subscription = Stripe::Resources::Subscription.update(
  #   client,
  #   "sub_12345",
  #   items: [
  #     {
  #       id: "si_12345",
  #       price: "price_67890" # New price to switch to
  #     }
  #   ],
  #   proration_behavior: "create_prorations"
  # )
  # ```
  def self.update(client : Stripe::Client, id : String, **params) : JSON::Any
    client.request(:post, "/v1/subscriptions/#{id}", params)
  end

  # Cancels a customer's subscription.
  #
  # See Stripe API docs: https://docs.stripe.com/api/subscriptions/cancel
  #
  # ```
  # client = Stripe::Client.new(api_key: ENV["STRIPE_API_KEY"])
  # 
  # # Cancel immediately
  # canceled_subscription = Stripe::Resources::Subscription.cancel(client, "sub_12345")
  # 
  # # Cancel at period end
  # canceled_subscription = Stripe::Resources::Subscription.cancel(
  #   client,
  #   "sub_12345",
  #   at_period_end: true
  # )
  # ```
  def self.cancel(client : Stripe::Client, id : String, **params) : JSON::Any
    client.request(:delete, "/v1/subscriptions/#{id}", params)
  end

  # Returns a list of subscriptions.
  #
  # See Stripe API docs: https://docs.stripe.com/api/subscriptions/list
  #
  # ```
  # client = Stripe::Client.new(api_key: ENV["STRIPE_API_KEY"])
  # 
  # # List all active subscriptions
  # subscriptions = Stripe::Resources::Subscription.list(
  #   client,
  #   status: "active"
  # )
  #
  # # List subscriptions for a specific customer
  # subscriptions = Stripe::Resources::Subscription.list(
  #   client,
  #   customer: "cus_12345",
  #   limit: 5
  # )
  # ```
  def self.list(client : Stripe::Client, **params) : JSON::Any
    client.request(:get, "/v1/subscriptions", params)
  end

  # Resume a paused or inactive subscription.
  #
  # See Stripe API docs: https://docs.stripe.com/api/subscriptions/resume
  #
  # ```
  # client = Stripe::Client.new(api_key: ENV["STRIPE_API_KEY"])
  # resumed_subscription = Stripe::Resources::Subscription.resume(client, "sub_12345")
  # ```
  def self.resume(client : Stripe::Client, id : String, **params) : JSON::Any
    client.request(:post, "/v1/subscriptions/#{id}/resume", params)
  end

  # Search for subscriptions.
  #
  # See Stripe API docs: https://docs.stripe.com/api/subscriptions/search
  #
  # ```
  # client = Stripe::Client.new(api_key: ENV["STRIPE_API_KEY"])
  # 
  # # Search for active subscriptions created in the past month
  # result = Stripe::Resources::Subscription.search(
  #   client,
  #   query: "status:'active' AND created>#{Time.utc.at_beginning_of_month.to_unix}"
  # )
  # ```
  def self.search(client : Stripe::Client, **params) : JSON::Any
    client.request(:get, "/v1/subscriptions/search", params)
  end
end
