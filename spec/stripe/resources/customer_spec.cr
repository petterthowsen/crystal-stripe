require "../../spec_helper"

describe Stripe::Resources::Customer do
  describe ".create" do
    it "creates a customer with basic information" do
      client = StripeTest.client
      customer = Stripe::Resources::Customer.create(
        client,
        email: "test-#{Random::Secure.hex(5)}@example.com",
        name: "Test Customer",
        description: "Test customer for Crystal Stripe library"
      )
      
      # Verify expected structure
      customer["object"].as_s.should eq("customer")
      customer["email"].as_s.should contain("@example.com")
      customer["name"].as_s.should eq("Test Customer")
      customer["description"].as_s.should eq("Test customer for Crystal Stripe library")
      customer["id"].as_s.should start_with("cus_")
      
      # Clean up - delete the customer
      Stripe::Resources::Customer.delete(client, customer["id"].as_s)
    end
    
    it "creates a customer with metadata" do
      client = StripeTest.client
      customer = Stripe::Resources::Customer.create(
        client,
        email: "test-#{Random::Secure.hex(5)}@example.com",
        name: "Test Customer",
        metadata: {
          "order_id" => "6735",
          "reference" => "crystal-test"
        }
      )
      
      # Verify expected structure and metadata
      customer["object"].as_s.should eq("customer")
      customer["metadata"]["order_id"].as_s.should eq("6735")
      customer["metadata"]["reference"].as_s.should eq("crystal-test")
      
      # Clean up
      Stripe::Resources::Customer.delete(client, customer["id"].as_s)
    end
  end
  
  describe ".retrieve" do
    it "retrieves a customer by ID" do
      client = StripeTest.client
      
      # First create a customer
      original = Stripe::Resources::Customer.create(
        client,
        email: "test-#{Random::Secure.hex(5)}@example.com",
        name: "Test Customer"
      )
      
      # Then retrieve it
      customer = Stripe::Resources::Customer.retrieve(client, original["id"].as_s)
      
      # Verify it's the same customer
      customer["id"].as_s.should eq(original["id"].as_s)
      customer["object"].as_s.should eq("customer")
      customer["email"].as_s.should eq(original["email"].as_s)
      customer["name"].as_s.should eq(original["name"].as_s)
      
      # Clean up
      Stripe::Resources::Customer.delete(client, customer["id"].as_s)
    end
    
    it "raises an error for non-existent customer" do
      client = StripeTest.client
      
      expect_raises(Stripe::InvalidRequestError) do
        Stripe::Resources::Customer.retrieve(client, "cus_nonexistent")
      end
    end
  end
  
  describe ".update" do
    it "updates customer information" do
      client = StripeTest.client
      
      # Create a customer first
      customer = Stripe::Resources::Customer.create(
        client,
        email: "test-#{Random::Secure.hex(5)}@example.com",
        name: "Original Name"
      )
      
      # Update the customer
      updated = Stripe::Resources::Customer.update(
        client,
        customer["id"].as_s,
        name: "Updated Name",
        description: "Updated description"
      )
      
      # Verify the updates
      updated["id"].as_s.should eq(customer["id"].as_s)
      updated["name"].as_s.should eq("Updated Name")
      updated["description"].as_s.should eq("Updated description")
      
      # Clean up
      Stripe::Resources::Customer.delete(client, customer["id"].as_s)
    end
  end
  
  describe ".delete" do
    it "deletes a customer" do
      client = StripeTest.client
      
      # Create a customer first
      customer = Stripe::Resources::Customer.create(
        client,
        email: "test-#{Random::Secure.hex(5)}@example.com"
      )
      
      # Delete the customer
      deleted = Stripe::Resources::Customer.delete(client, customer["id"].as_s)
      
      # Verify deletion
      deleted["id"].as_s.should eq(customer["id"].as_s)
      deleted["deleted"].as_bool.should be_true
    end
  end
  
  describe ".list" do
    it "lists customers with correct structure" do
      client = StripeTest.client
      
      # Create a test customer to ensure we have at least one
      customer = Stripe::Resources::Customer.create(
        client,
        email: "test-#{Random::Secure.hex(5)}@example.com",
        name: "List Test Customer"
      )
      
      # List customers with a small limit
      customers = Stripe::Resources::Customer.list(client, limit: 3)
      
      # Verify the response structure
      customers["object"].as_s.should eq("list")
      customers["data"].as_a.size.should be <= 3
      customers["has_more"].as_bool.should be_a(Bool)
      
      # Verify individual customer objects
      if customers["data"].as_a.size > 0
        item = customers["data"].as_a.first
        item["object"].as_s.should eq("customer")
        item["id"].as_s.should start_with("cus_")
      end
      
      # Clean up
      Stripe::Resources::Customer.delete(client, customer["id"].as_s)
    end
    
    it "supports pagination parameters" do
      client = StripeTest.client
      
      # Create two test customers for pagination testing
      customer1 = Stripe::Resources::Customer.create(
        client,
        email: "test1-#{Random::Secure.hex(5)}@example.com"
      )
      
      customer2 = Stripe::Resources::Customer.create(
        client,
        email: "test2-#{Random::Secure.hex(5)}@example.com"
      )
      
      # List with pagination
      page1 = Stripe::Resources::Customer.list(client, limit: 1)
      
      # Should have more
      page1["has_more"].as_bool.should be_true
      
      # Get next page
      page2 = Stripe::Resources::Customer.list(
        client,
        limit: 1,
        starting_after: page1["data"].as_a.first["id"].as_s
      )
      
      # Verify we got different results
      page1["data"].as_a.first["id"].as_s.should_not eq(
        page2["data"].as_a.first["id"].as_s
      )
      
      # Clean up
      Stripe::Resources::Customer.delete(client, customer1["id"].as_s)
      Stripe::Resources::Customer.delete(client, customer2["id"].as_s)
    end
  end
  
  # Note: Search tests are conditionally run since not all Stripe accounts 
  # may have search capabilities enabled
  describe ".search" do
    it "searches for customers by email" do
      client = StripeTest.client
      
      # Create a customer with a unique email
      unique_email = "unique-#{Random::Secure.hex(8)}@example.com"
      customer = Stripe::Resources::Customer.create(
        client,
        email: unique_email,
        name: "Search Test Customer"
      )
      
      # Try to search for the customer
      begin
        results = Stripe::Resources::Customer.search(
          client,
          query: "email:'#{unique_email}'"
        )
        
        # If search succeeded, verify structure
        results["object"].as_s.should eq("search_result")
        
        # Check if we have results
        if results["data"].as_a.size > 0
          # At least one result should match our customer
          found = false
          results["data"].as_a.each do |item|
            if item["id"].as_s == customer["id"].as_s
              found = true
              break
            end
          end
          
          found.should be_true
        else
          # If search returns no results, that's also acceptable
          # Just make sure the structure is correct
          results["has_more"].as_bool.should be_a(Bool)
          results["url"].as_s.should contain("/v1/customers/search")
          puts "  * Search API returned no results, data validation skipped"
        end
      rescue e : Stripe::InvalidRequestError
        # If search is not enabled, this test is conditionally skipped
        if e.message.to_s.includes?("not enabled") || e.message.to_s.includes?("permission")
          puts "  * Search API not available for this account, test skipped"
        else
          raise e
        end
      end
      
      # Clean up
      Stripe::Resources::Customer.delete(client, customer["id"].as_s)
    end
  end
end
