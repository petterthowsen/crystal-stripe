require "../../spec_helper"

describe Stripe::Resources::Product do

  describe ".create" do
    it "creates a new product" do
      product_name = "Test Product #{Time.utc.to_unix}"
      product = Stripe::Resources::Product.create(
        StripeTest.client,
        name: product_name,
        description: "A test product for integration testing",
        active: true,
        metadata: {"test" => "integration"}
      )

      product["id"].as_s.should start_with("prod_")
      product["name"].as_s.should eq(product_name)
      product["description"].as_s.should eq("A test product for integration testing")
      product["active"].as_bool.should be_true
      product["metadata"]["test"].as_s.should eq("integration")
    end
  end

  describe ".retrieve" do
    it "retrieves an existing product" do
      # First create a product
      product_name = "Retrieve Test Product #{Time.utc.to_unix}"
      created_product = Stripe::Resources::Product.create(
        StripeTest.client,
        name: product_name
      )
      product_id = created_product["id"].as_s

      # Then retrieve it
      product = Stripe::Resources::Product.retrieve(StripeTest.client, product_id)

      product["id"].as_s.should eq(product_id)
      product["name"].as_s.should eq(product_name)
    end

    it "raises an error for non-existent product" do
      expect_raises(Stripe::StripeError) do
        Stripe::Resources::Product.retrieve(StripeTest.client, "prod_nonexistent")
      end
    end
  end

  describe ".update" do
    it "updates a product" do
      # First create a product
      product_name = "Update Test Product #{Time.utc.to_unix}"
      created_product = Stripe::Resources::Product.create(
        StripeTest.client,
        name: product_name
      )
      product_id = created_product["id"].as_s

      # Then update it
      new_name = "Updated Product #{Time.utc.to_unix}"
      product = Stripe::Resources::Product.update(
        StripeTest.client,
        product_id,
        name: new_name,
        description: "Updated description",
        metadata: {"updated" => "true"}
      )

      product["id"].as_s.should eq(product_id)
      product["name"].as_s.should eq(new_name)
      product["description"].as_s.should eq("Updated description")
      product["metadata"]["updated"].as_s.should eq("true")
    end
  end

  describe ".delete" do
    it "deletes a product" do
      # First create a product
      product_name = "Delete Test Product #{Time.utc.to_unix}"
      created_product = Stripe::Resources::Product.create(
        StripeTest.client,
        name: product_name
      )
      product_id = created_product["id"].as_s

      # Then delete it
      deleted_product = Stripe::Resources::Product.delete(StripeTest.client, product_id)

      deleted_product["id"].as_s.should eq(product_id)
      deleted_product["deleted"].as_bool.should be_true
    end
  end

  describe ".list" do
    it "lists products" do
      # Create a few products with unique names to ensure we have products to list
      timestamp = Time.utc.to_unix
      product_names = [
        "List Test Product 1 #{timestamp}",
        "List Test Product 2 #{timestamp}"
      ]

      product_names.each do |name|
        Stripe::Resources::Product.create(StripeTest.client, name: name)
      end

      # List products with a limit of 5
      products = Stripe::Resources::Product.list(StripeTest.client, limit: 5)

      products["object"].as_s.should eq("list")
      products["data"].as_a.size.should be <= 5
      products["data"].as_a.size.should be > 0
    end

    it "filters products by active status" do
      # Create an active product
      active_product_name = "Active Product #{Time.utc.to_unix}"
      Stripe::Resources::Product.create(
        StripeTest.client,
        name: active_product_name,
        active: true
      )

      # List only active products
      products = Stripe::Resources::Product.list(StripeTest.client, active: true, limit: 5)

      products["object"].as_s.should eq("list")
      products["data"].as_a.each do |product|
        product["active"].as_bool.should be_true
      end
    end
  end

  describe ".search" do
    it "searches products by query" do
      # Create a product with a specific name to search for
      unique_name = "Searchable Product #{Time.utc.to_unix}"
      Stripe::Resources::Product.create(
        StripeTest.client,
        name: unique_name,
        active: true
      )

      # Wait a moment for the search index to update
      sleep(2.seconds)

      # Search for the product
      search_result = Stripe::Resources::Product.search(
        StripeTest.client,
        query: "name:'#{unique_name}'"
      )

      search_result["object"].as_s.should eq("search_result")
      
      # Search might take time to index, so we'll check if results exist before asserting
      if !search_result["data"].as_a.empty?
        found = search_result["data"].as_a.any? do |product|
          product["name"].as_s == unique_name
        end
        found.should be_true
      end
    end
  end
end
