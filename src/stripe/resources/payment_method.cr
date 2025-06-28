require "json"

module Stripe
  module Resources
    # The PaymentMethod resource allows you to create, retrieve, update, attach, detach, 
    # and list payment methods in the Stripe API.
    #
    # API reference: https://docs.stripe.com/api/payment_methods
    module PaymentMethod
      # Retrieves a PaymentMethod by ID
      #
      # ```
      # payment_method = Stripe::Resources::PaymentMethod.retrieve(client, "pm_123456")
      # ```
      #
      # API reference: https://docs.stripe.com/api/payment_methods/retrieve
      def self.retrieve(client : Stripe::Client, id : String) : JSON::Any
        client.request(:get, "/v1/payment_methods/#{id}")
      end

      # Creates a new PaymentMethod
      #
      # ```
      # payment_method = Stripe::Resources::PaymentMethod.create(
      #   client,
      #   type: "card",
      #   card: {
      #     number: "4242424242424242",
      #     exp_month: 8,
      #     exp_year: 2025,
      #     cvc: "314"
      #   }
      # )
      # ```
      #
      # API reference: https://docs.stripe.com/api/payment_methods/create
      def self.create(client : Stripe::Client, **params) : JSON::Any
        client.request(:post, "/v1/payment_methods", params)
      end

      # Updates a PaymentMethod
      #
      # ```
      # payment_method = Stripe::Resources::PaymentMethod.update(
      #   client,
      #   "pm_123456",
      #   billing_details: {
      #     name: "Jane Doe"
      #   },
      #   metadata: {"order_id" => "6735"}
      # )
      # ```
      #
      # API reference: https://docs.stripe.com/api/payment_methods/update
      def self.update(client : Stripe::Client, id : String, **params) : JSON::Any
        client.request(:post, "/v1/payment_methods/#{id}", params)
      end

      # Lists all payment methods for a customer
      #
      # ```
      # # List all cards belonging to a customer
      # payment_methods = Stripe::Resources::PaymentMethod.list(
      #   client,
      #   customer: "cus_123456",
      #   type: "card"
      # )
      # ```
      #
      # API reference: https://docs.stripe.com/api/payment_methods/list
      def self.list(client : Stripe::Client, **params) : JSON::Any
        client.request(:get, "/v1/payment_methods", params)
      end

      # Lists all payment methods for a customer without requiring the type parameter
      #
      # ```
      # payment_methods = Stripe::Resources::PaymentMethod.list_for_customer(
      #   client,
      #   "cus_123456",
      #   type: "card"
      # )
      # ```
      #
      # API reference: https://docs.stripe.com/api/payment_methods/customer_list
      def self.list_for_customer(client : Stripe::Client, customer_id : String, **params) : JSON::Any
        client.request(:get, "/v1/customers/#{customer_id}/payment_methods", params)
      end

      # Attaches a PaymentMethod to a Customer
      #
      # ```
      # payment_method = Stripe::Resources::PaymentMethod.attach(
      #   client,
      #   "pm_123456",
      #   customer: "cus_123456"
      # )
      # ```
      #
      # API reference: https://docs.stripe.com/api/payment_methods/attach
      def self.attach(client : Stripe::Client, id : String, customer : String) : JSON::Any
        client.request(:post, "/v1/payment_methods/#{id}/attach", {customer: customer})
      end

      # Detaches a PaymentMethod from a Customer
      #
      # ```
      # payment_method = Stripe::Resources::PaymentMethod.detach(client, "pm_123456")
      # ```
      #
      # API reference: https://docs.stripe.com/api/payment_methods/detach
      def self.detach(client : Stripe::Client, id : String) : JSON::Any
        client.request(:post, "/v1/payment_methods/#{id}/detach")
      end
    end
  end
end
