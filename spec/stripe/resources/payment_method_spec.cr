require "../../spec_helper"

describe Stripe::Resources::PaymentMethod do
  describe ".create" do
    it "creates a card payment method" do
      client = StripeTest.client
      
      payment_method = Stripe::Resources::PaymentMethod.create(
        client,
        type: "card",
        # Use payment method token instead of raw card data
        card: {
          token: "tok_visa"
        },
        billing_details: {
          name: "Test User"
        }
      )
      
      # Verify expected structure
      payment_method["object"].as_s.should eq("payment_method")
      payment_method["type"].as_s.should eq("card")
      payment_method["card"]["brand"].as_s.should eq("visa")
      payment_method["card"]["last4"].as_s.should eq("4242")
      payment_method["id"].as_s.should start_with("pm_")
      
      # No need to clean up unattached payment methods
    end
    
    it "creates a payment method with metadata" do
      client = StripeTest.client
      
      payment_method = Stripe::Resources::PaymentMethod.create(
        client,
        type: "card",
        # Use payment method token instead of raw card data
        card: {
          token: "tok_visa"
        },
        metadata: {
          "order_id" => "6735",
          "reference" => "crystal-test"
        }
      )
      
      # Verify expected structure and metadata
      payment_method["object"].as_s.should eq("payment_method")
      payment_method["metadata"]["order_id"].as_s.should eq("6735")
      payment_method["metadata"]["reference"].as_s.should eq("crystal-test")
    end
  end
  
  describe ".retrieve" do
    it "retrieves a payment method by ID" do
      client = StripeTest.client
      
      # First create a payment method
      original = Stripe::Resources::PaymentMethod.create(
        client,
        type: "card",
        # Use payment method token instead of raw card data
        card: {
          token: "tok_visa"
        }
      )
      
      # Then retrieve it
      payment_method = Stripe::Resources::PaymentMethod.retrieve(client, original["id"].as_s)
      
      # Verify it's the same payment method
      payment_method["id"].as_s.should eq(original["id"].as_s)
      payment_method["object"].as_s.should eq("payment_method")
      payment_method["type"].as_s.should eq(original["type"].as_s)
      payment_method["card"]["last4"].as_s.should eq(original["card"]["last4"].as_s)
    end
    
    it "raises an error for non-existent payment method" do
      client = StripeTest.client
      
      expect_raises(Stripe::InvalidRequestError) do
        Stripe::Resources::PaymentMethod.retrieve(client, "pm_nonexistent")
      end
    end
  end
  
  describe ".update" do
    it "updates payment method information" do
      client = StripeTest.client
      
      # Create a customer first
      customer = Stripe::Resources::Customer.create(
        client,
        email: "test-#{Random::Secure.hex(5)}@example.com"
      )
      
      # Create a payment method first
      payment_method = Stripe::Resources::PaymentMethod.create(
        client,
        type: "card",
        # Use payment method token instead of raw card data
        card: {
          token: "tok_visa"
        },
        billing_details: {
          name: "Original Name"
        }
      )
      
      # Attach payment method to customer (required for update)
      Stripe::Resources::PaymentMethod.attach(
        client,
        payment_method["id"].as_s,
        customer["id"].as_s
      )
      
      # Update the payment method
      updated = Stripe::Resources::PaymentMethod.update(
        client,
        payment_method["id"].as_s,
        billing_details: {
          name: "Updated Name",
          email: "test@example.com"
        },
        metadata: {"order_id" => "12345"}
      )
      
      # Verify the updates
      updated["id"].as_s.should eq(payment_method["id"].as_s)
      updated["billing_details"]["name"].as_s.should eq("Updated Name")
      updated["billing_details"]["email"].as_s.should eq("test@example.com")
      updated["metadata"]["order_id"].as_s.should eq("12345")
      
      # Clean up
      Stripe::Resources::PaymentMethod.detach(client, payment_method["id"].as_s)
      Stripe::Resources::Customer.delete(client, customer["id"].as_s)
    end
  end
  
  describe ".attach and .detach" do
    it "attaches and detaches a payment method to a customer" do
      client = StripeTest.client
      
      # Create a customer
      customer = Stripe::Resources::Customer.create(
        client,
        email: "test-#{Random::Secure.hex(5)}@example.com"
      )
      
      # Create a payment method
      payment_method = Stripe::Resources::PaymentMethod.create(
        client,
        type: "card",
        # Use payment method token instead of raw card data
        card: {
          token: "tok_visa"
        }
      )
      
      # Attach the payment method to the customer
      attached = Stripe::Resources::PaymentMethod.attach(
        client, 
        payment_method["id"].as_s,
        customer["id"].as_s
      )
      
      # Verify attachment
      attached["id"].as_s.should eq(payment_method["id"].as_s)
      attached["customer"].as_s.should eq(customer["id"].as_s)
      
      # Now detach the payment method
      detached = Stripe::Resources::PaymentMethod.detach(client, payment_method["id"].as_s)
      
      # Verify detachment
      detached["id"].as_s.should eq(payment_method["id"].as_s)
      # The API may return null or undefined for customer after detach
      (detached["customer"]?.nil? || detached["customer"]? == JSON::Any.new(nil)).should be_true
      
      # Clean up - delete the customer
      Stripe::Resources::Customer.delete(client, customer["id"].as_s)
    end
  end
  
  describe ".list" do
    it "lists payment methods with correct structure" do
      client = StripeTest.client
      
      # Create a customer and attach a payment method to ensure we have at least one
      customer = Stripe::Resources::Customer.create(
        client,
        email: "test-#{Random::Secure.hex(5)}@example.com"
      )
      
      payment_method = Stripe::Resources::PaymentMethod.create(
        client,
        type: "card",
        # Use payment method token instead of raw card data
        card: {
          token: "tok_visa"
        }
      )
      
      Stripe::Resources::PaymentMethod.attach(
        client, 
        payment_method["id"].as_s,
        customer["id"].as_s
      )
      
      # List payment methods
      payment_methods = Stripe::Resources::PaymentMethod.list(
        client,
        customer: customer["id"].as_s,
        type: "card"
      )
      
      # Verify the response structure
      payment_methods["object"].as_s.should eq("list")
      payment_methods["data"].as_a.size.should be >= 1
      payment_methods["has_more"].as_bool.should be_a(Bool)
      
      # Verify individual payment method objects
      item = payment_methods["data"].as_a.first
      item["object"].as_s.should eq("payment_method")
      item["type"].as_s.should eq("card")
      item["id"].as_s.should start_with("pm_")
      
      # Clean up
      Stripe::Resources::PaymentMethod.detach(client, payment_method["id"].as_s)
      Stripe::Resources::Customer.delete(client, customer["id"].as_s)
    end
  end
  
  describe ".list_for_customer" do
    it "lists payment methods for a specific customer" do
      client = StripeTest.client
      
      # Create a customer and attach a payment method to ensure we have at least one
      customer = Stripe::Resources::Customer.create(
        client,
        email: "test-#{Random::Secure.hex(5)}@example.com"
      )
      
      payment_method = Stripe::Resources::PaymentMethod.create(
        client,
        type: "card",
        # Use payment method token instead of raw card data
        card: {
          token: "tok_visa"
        }
      )
      
      Stripe::Resources::PaymentMethod.attach(
        client, 
        payment_method["id"].as_s,
        customer["id"].as_s
      )
      
      # List payment methods for customer
      payment_methods = Stripe::Resources::PaymentMethod.list_for_customer(
        client,
        customer["id"].as_s,
        type: "card"
      )
      
      # Verify the response structure
      payment_methods["object"].as_s.should eq("list")
      payment_methods["data"].as_a.size.should be >= 1
      payment_methods["has_more"].as_bool.should be_a(Bool)
      
      # Verify individual payment method objects
      item = payment_methods["data"].as_a.first
      item["object"].as_s.should eq("payment_method")
      item["customer"].as_s.should eq(customer["id"].as_s)
      
      # Clean up
      Stripe::Resources::PaymentMethod.detach(client, payment_method["id"].as_s)
      Stripe::Resources::Customer.delete(client, customer["id"].as_s)
    end
  end
end
