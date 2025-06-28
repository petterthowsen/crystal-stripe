require "json"

module Stripe
  module Resources
    # The PaymentIntent resource allows you to create, retrieve, update, confirm, capture, 
    # cancel, and list payment intents in the Stripe API.
    #
    # API reference: https://docs.stripe.com/api/payment_intents
    module PaymentIntent
      # Retrieves a PaymentIntent by ID
      #
      # ```
      # payment_intent = Stripe::Resources::PaymentIntent.retrieve(client, "pi_123456")
      # ```
      #
      # API reference: https://docs.stripe.com/api/payment_intents/retrieve
      def self.retrieve(client : Stripe::Client, id : String) : JSON::Any
        client.request(:get, "/v1/payment_intents/#{id}")
      end

      # Creates a new PaymentIntent
      #
      # ```
      # payment_intent = Stripe::Resources::PaymentIntent.create(
      #   client,
      #   amount: 2000,
      #   currency: "usd",
      #   payment_method_types: ["card"],
      #   payment_method: "pm_123456",
      #   confirm: true
      # )
      # ```
      #
      # API reference: https://docs.stripe.com/api/payment_intents/create
      def self.create(client : Stripe::Client, **params) : JSON::Any
        client.request(:post, "/v1/payment_intents", params)
      end

      # Updates a PaymentIntent
      #
      # ```
      # payment_intent = Stripe::Resources::PaymentIntent.update(
      #   client,
      #   "pi_123456",
      #   metadata: {"order_id" => "6735"},
      #   description: "Updated payment for order #6735"
      # )
      # ```
      #
      # API reference: https://docs.stripe.com/api/payment_intents/update
      def self.update(client : Stripe::Client, id : String, **params) : JSON::Any
        client.request(:post, "/v1/payment_intents/#{id}", params)
      end

      # Confirms a PaymentIntent
      #
      # ```
      # payment_intent = Stripe::Resources::PaymentIntent.confirm(
      #   client,
      #   "pi_123456",
      #   payment_method: "pm_123456"
      # )
      # ```
      #
      # API reference: https://docs.stripe.com/api/payment_intents/confirm
      def self.confirm(client : Stripe::Client, id : String, **params) : JSON::Any
        client.request(:post, "/v1/payment_intents/#{id}/confirm", params)
      end

      # Captures a PaymentIntent
      #
      # ```
      # payment_intent = Stripe::Resources::PaymentIntent.capture(
      #   client,
      #   "pi_123456",
      #   amount_to_capture: 1500
      # )
      # ```
      #
      # API reference: https://docs.stripe.com/api/payment_intents/capture
      def self.capture(client : Stripe::Client, id : String, **params) : JSON::Any
        client.request(:post, "/v1/payment_intents/#{id}/capture", params)
      end

      # Cancels a PaymentIntent
      #
      # ```
      # payment_intent = Stripe::Resources::PaymentIntent.cancel(
      #   client,
      #   "pi_123456",
      #   cancellation_reason: "requested_by_customer"
      # )
      # ```
      #
      # API reference: https://docs.stripe.com/api/payment_intents/cancel
      def self.cancel(client : Stripe::Client, id : String, **params) : JSON::Any
        client.request(:post, "/v1/payment_intents/#{id}/cancel", params)
      end

      # Lists PaymentIntents
      #
      # ```
      # payment_intents = Stripe::Resources::PaymentIntent.list(
      #   client,
      #   limit: 3,
      #   customer: "cus_123456"
      # )
      # ```
      #
      # API reference: https://docs.stripe.com/api/payment_intents/list
      def self.list(client : Stripe::Client, **params) : JSON::Any
        client.request(:get, "/v1/payment_intents", params)
      end
    end
  end
end
