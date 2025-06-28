require "json"

module Stripe
  module Resources
    # The Customer resource allows you to create, retrieve, update, and delete
    # customer objects in the Stripe API.
    #
    # API reference: https://docs.stripe.com/api/customers
    module Customer
      # Retrieves a customer by ID
      #
      # ```
      # customer = Stripe::Resources::Customer.retrieve(client, "cus_123456")
      # ```
      #
      # API reference: https://docs.stripe.com/api/customers/retrieve
      def self.retrieve(client : Stripe::Client, id : String, **params) : JSON::Any
        client.request(:get, "/v1/customers/#{id}", params)
      end

      # Creates a new customer
      #
      # ```
      # customer = Stripe::Resources::Customer.create(
      #   client,
      #   email: "customer@example.com",
      #   name: "Jenny Rosen",
      #   payment_method: "pm_card_visa"
      # )
      # ```
      #
      # API reference: https://docs.stripe.com/api/customers/create
      def self.create(client : Stripe::Client, **params) : JSON::Any
        client.request(:post, "/v1/customers", params)
      end

      # Updates an existing customer
      #
      # ```
      # customer = Stripe::Resources::Customer.update(
      #   client,
      #   "cus_123456",
      #   email: "new_email@example.com",
      #   metadata: {"order_id" => "6735"}
      # )
      # ```
      #
      # API reference: https://docs.stripe.com/api/customers/update
      def self.update(client : Stripe::Client, id : String, **params) : JSON::Any
        client.request(:post, "/v1/customers/#{id}", params)
      end

      # Deletes a customer
      #
      # ```
      # deleted = Stripe::Resources::Customer.delete(client, "cus_123456")
      # ```
      #
      # API reference: https://docs.stripe.com/api/customers/delete
      def self.delete(client : Stripe::Client, id : String) : JSON::Any
        client.request(:delete, "/v1/customers/#{id}")
      end

      # Lists all customers
      #
      # ```
      # # Basic list
      # customers = Stripe::Resources::Customer.list(client)
      #
      # # With filters and pagination
      # customers = Stripe::Resources::Customer.list(
      #   client,
      #   limit: 20,
      #   email: "test@example.com",
      #   created: {gt: Time.utc(2023, 1, 1).to_unix}
      # )
      # ```
      #
      # API reference: https://docs.stripe.com/api/customers/list
      def self.list(client : Stripe::Client, **params) : JSON::Any
        client.request(:get, "/v1/customers", params)
      end

      # Search for customers
      #
      # ```
      # # Search by email
      # customers = Stripe::Resources::Customer.search(
      #   client,
      #   query: "email:'customer@example.com'"
      # )
      #
      # # Search by metadata
      # customers = Stripe::Resources::Customer.search(
      #   client,
      #   query: "metadata['order_id']:'6735'"
      # )
      # ```
      #
      # API reference: https://docs.stripe.com/api/customers/search
      def self.search(client : Stripe::Client, query : String, **params) : JSON::Any
        search_params = params.to_h.merge({"query" => query})
        client.request(:get, "/v1/customers/search", search_params)
      end
    end
  end
end
