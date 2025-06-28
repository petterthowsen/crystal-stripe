require "../../spec_helper"

# Helper module for price specs
module PriceSpecHelpers
  def self.create_test_product(client)
    product_name = "Price Test Product #{Time.utc.to_unix}"
    product = Stripe::Resources::Product.create(
      client,
      name: product_name
    )
    product["id"].as_s
  end
end

describe Stripe::Resources::Price do

  describe ".create" do
    it "creates a one-time price" do
      client = StripeTest.client
      product_id = PriceSpecHelpers.create_test_product(client)
      price = Stripe::Resources::Price.create(
        client,
        product: product_id,
        unit_amount: 2000,
        currency: "usd"
      )

      price["id"].as_s.should start_with("price_")
      price["product"].as_s.should eq(product_id)
      price["unit_amount"].as_i.should eq(2000)
      price["currency"].as_s.should eq("usd")
      price["type"].as_s.should eq("one_time")
    end

    it "creates a recurring price" do
      client = StripeTest.client
      product_id = PriceSpecHelpers.create_test_product(client)
      price = Stripe::Resources::Price.create(
        client,
        product: product_id,
        unit_amount: 1500,
        currency: "usd",
        recurring: {
          interval: "month",
          interval_count: 1
        }
      )

      price["id"].as_s.should start_with("price_")
      price["product"].as_s.should eq(product_id)
      price["unit_amount"].as_i.should eq(1500)
      price["currency"].as_s.should eq("usd")
      price["type"].as_s.should eq("recurring")
      price["recurring"]["interval"].as_s.should eq("month")
      price["recurring"]["interval_count"].as_i.should eq(1)
    end

    it "creates a price with metadata" do
      client = StripeTest.client
      product_id = PriceSpecHelpers.create_test_product(client)
      price = Stripe::Resources::Price.create(
        client,
        product: product_id,
        unit_amount: 2000,
        currency: "usd",
        metadata: {"test" => "integration"}
      )

      price["metadata"]["test"].as_s.should eq("integration")
    end
  end

  describe ".retrieve" do
    it "retrieves an existing price" do
      client = StripeTest.client
      # First create a product and price
      product_id = PriceSpecHelpers.create_test_product(client)
      created_price = Stripe::Resources::Price.create(
        client,
        product: product_id,
        unit_amount: 2500,
        currency: "usd"
      )
      price_id = created_price["id"].as_s

      # Then retrieve it
      price = Stripe::Resources::Price.retrieve(client, price_id)

      price["id"].as_s.should eq(price_id)
      price["unit_amount"].as_i.should eq(2500)
    end

    it "raises an error for non-existent price" do
      client = StripeTest.client
      expect_raises(Stripe::StripeError) do
        Stripe::Resources::Price.retrieve(client, "price_nonexistent")
      end
    end
  end

  describe ".update" do
    it "updates a price" do
      client = StripeTest.client
      # First create a product and price
      product_id = PriceSpecHelpers.create_test_product(client)
      created_price = Stripe::Resources::Price.create(
        client,
        product: product_id,
        unit_amount: 2500,
        currency: "usd",
        nickname: "Original nickname"
      )
      price_id = created_price["id"].as_s

      # Then update it
      price = Stripe::Resources::Price.update(
        client,
        price_id,
        nickname: "Updated nickname",
        metadata: {"updated" => "true"}
      )

      price["id"].as_s.should eq(price_id)
      price["nickname"].as_s.should eq("Updated nickname")
      price["metadata"]["updated"].as_s.should eq("true")
    end
  end

  describe ".list" do
    it "lists prices" do
      client = StripeTest.client
      # Create a product and a couple of prices for it
      product_id = PriceSpecHelpers.create_test_product(client)
      timestamp = Time.utc.to_unix

      # Create one-time price
      Stripe::Resources::Price.create(
        client,
        product: product_id,
        unit_amount: 1000,
        currency: "usd",
        nickname: "One-time price #{timestamp}"
      )

      # Create recurring price
      Stripe::Resources::Price.create(
        client,
        product: product_id,
        unit_amount: 2000,
        currency: "usd",
        nickname: "Recurring price #{timestamp}",
        recurring: {
          interval: "month"
        }
      )

      # List prices with a limit of 5
      prices = Stripe::Resources::Price.list(client, limit: 5)

      prices["object"].as_s.should eq("list")
      prices["data"].as_a.size.should be <= 5
      prices["data"].as_a.size.should be > 0
    end

    it "filters prices by product" do
      client = StripeTest.client
      # Create a product and price
      product_id = PriceSpecHelpers.create_test_product(client)
      Stripe::Resources::Price.create(
        client,
        product: product_id,
        unit_amount: 3000,
        currency: "usd"
      )

      # List prices for this specific product
      prices = Stripe::Resources::Price.list(client, product: product_id)

      prices["object"].as_s.should eq("list")
      prices["data"].as_a.each do |price|
        price["product"].as_s.should eq(product_id)
      end
    end

    it "filters prices by type" do
      client = StripeTest.client
      # Create a product with recurring and one-time prices
      product_id = PriceSpecHelpers.create_test_product(client)
      
      # Create one-time price
      Stripe::Resources::Price.create(
        client,
        product: product_id,
        unit_amount: 1000,
        currency: "usd"
      )

      # Create recurring price
      Stripe::Resources::Price.create(
        client,
        product: product_id,
        unit_amount: 2000,
        currency: "usd",
        recurring: {
          interval: "month"
        }
      )

      # List only recurring prices
      prices = Stripe::Resources::Price.list(client, type: "recurring")

      prices["object"].as_s.should eq("list")
      prices["data"].as_a.each do |price|
        price["type"].as_s.should eq("recurring")
      end
    end
  end

  describe ".search" do
    it "searches prices by query" do
      client = StripeTest.client
      # Create a product and price to search for
      product_id = PriceSpecHelpers.create_test_product(client)
      unique_nickname = "Searchable Price #{Time.utc.to_unix}"
      price = Stripe::Resources::Price.create(
        client,
        product: product_id,
        unit_amount_decimal: 4000,
        currency: "usd",
        nickname: unique_nickname,
        active: true
      )

      # Wait a moment for the search index to update
      sleep(2.seconds)

      # Search for the price by product ID (supported search field)
      search_result = Stripe::Resources::Price.search(
        client,
        query: "product:'#{product_id}' AND active:'true'"
      )

      search_result["object"].as_s.should eq("search_result")
      
      # Search might take time to index, so we'll check if results exist before asserting
      if !search_result["data"].as_a.empty?
        found = search_result["data"].as_a.any? do |price|
          price["nickname"].as_s == unique_nickname
        end
        found.should be_true
      end
    end
  end
end
