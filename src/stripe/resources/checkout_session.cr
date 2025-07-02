require "json"

module Stripe
  module Resources
    # The CheckoutSession resource allows you to create, retrieve, update, expire,
    # and list checkout sessions in the Stripe API.
    #
    # API reference: https://docs.stripe.com/api/checkout/sessions
    module CheckoutSession
      # Retrieves a CheckoutSession by ID
      #
      # ```
      # checkout_session = Stripe::Resources::CheckoutSession.retrieve(client, "cs_123456")
      # ```
      #
      # API reference: https://docs.stripe.com/api/checkout/sessions/retrieve
      def self.retrieve(client : Stripe::Client, id : String) : JSON::Any
        client.request(:get, "/v1/checkout/sessions/#{id}")
      end

      # Creates a new CheckoutSession
      #
      # ```
      # checkout_session = Stripe::Resources::CheckoutSession.create(
      #   client,
      #   mode: "payment",
      #   success_url: "https://example.com/success",
      #   line_items: [
      #     {
      #       price: "price_1234",
      #       quantity: 1
      #     }
      #   ]
      # )
      # ```
      #
      # API reference: https://docs.stripe.com/api/checkout/sessions/create
      def self.create(client : Stripe::Client, **params) : JSON::Any
        client.request(:post, "/v1/checkout/sessions", params)
      end

      # Updates a CheckoutSession
      #
      # ```
      # checkout_session = Stripe::Resources::CheckoutSession.update(
      #   client,
      #   "cs_123456",
      #   metadata: {"order_id" => "6735"}
      # )
      # ```
      #
      # API reference: https://docs.stripe.com/api/checkout/sessions/update
      def self.update(client : Stripe::Client, id : String, **params) : JSON::Any
        client.request(:post, "/v1/checkout/sessions/#{id}", params)
      end

      # Lists all CheckoutSessions
      #
      # ```
      # checkout_sessions = Stripe::Resources::CheckoutSession.list(
      #   client,
      #   limit: 5
      # )
      # ```
      #
      # API reference: https://docs.stripe.com/api/checkout/sessions/list
      def self.list(client : Stripe::Client, **params) : JSON::Any
        client.request(:get, "/v1/checkout/sessions", params)
      end

      # Lists all line items for a CheckoutSession
      #
      # ```
      # line_items = Stripe::Resources::CheckoutSession.list_line_items(
      #   client,
      #   "cs_123456",
      #   limit: 10
      # )
      # ```
      #
      # API reference: https://docs.stripe.com/api/checkout/sessions/line_items
      def self.list_line_items(client : Stripe::Client, id : String, **params) : JSON::Any
        client.request(:get, "/v1/checkout/sessions/#{id}/line_items", params)
      end

      # Expires a CheckoutSession
      #
      # ```
      # checkout_session = Stripe::Resources::CheckoutSession.expire(client, "cs_123456")
      # ```
      #
      # API reference: https://docs.stripe.com/api/checkout/sessions/expire
      def self.expire(client : Stripe::Client, id : String) : JSON::Any
        client.request(:post, "/v1/checkout/sessions/#{id}/expire")
      end
    end
  end
end
