require "../../spec_helper"

describe Stripe::Resources::PaymentIntent do
  describe ".create" do
    it "creates a payment intent" do
      client = StripeTest.client
      
      payment_intent = Stripe::Resources::PaymentIntent.create(
        client,
        amount: 2000,
        currency: "usd",
        payment_method_types: ["card"]
      )
      
      # Verify expected structure
      payment_intent["object"].as_s.should eq("payment_intent")
      payment_intent["amount"].as_i.should eq(2000)
      payment_intent["currency"].as_s.should eq("usd")
      payment_intent["status"].as_s.should eq("requires_payment_method")
      payment_intent["id"].as_s.should start_with("pi_")
      
      # Clean up
      Stripe::Resources::PaymentIntent.cancel(client, payment_intent["id"].as_s)
    end
    
    it "creates a payment intent with metadata" do
      client = StripeTest.client
      
      payment_intent = Stripe::Resources::PaymentIntent.create(
        client,
        amount: 2000,
        currency: "usd",
        payment_method_types: ["card"],
        metadata: {
          "order_id" => "6735",
          "reference" => "crystal-test"
        }
      )
      
      # Verify expected structure and metadata
      payment_intent["object"].as_s.should eq("payment_intent")
      payment_intent["metadata"]["order_id"].as_s.should eq("6735")
      payment_intent["metadata"]["reference"].as_s.should eq("crystal-test")
      
      # Clean up
      Stripe::Resources::PaymentIntent.cancel(client, payment_intent["id"].as_s)
    end
    
    it "creates and confirms a payment intent" do
      client = StripeTest.client
      
      # Create a payment method first
      payment_method = Stripe::Resources::PaymentMethod.create(
        client,
        type: "card",
        # Use payment method token instead of raw card data
        card: {
          token: "tok_visa"
        }
      )
      
      payment_intent = Stripe::Resources::PaymentIntent.create(
        client,
        amount: 2000,
        currency: "usd",
        payment_method: payment_method["id"].as_s,
        payment_method_types: ["card"],
        confirm: true
      )
      
      # Verify expected structure
      payment_intent["object"].as_s.should eq("payment_intent")
      payment_intent["status"].as_s.should eq("succeeded") # Confirmed payment intents with test cards should succeed
      payment_intent["payment_method"].as_s.should eq(payment_method["id"].as_s)
    end
  end
  
  describe ".retrieve" do
    it "retrieves a payment intent by ID" do
      client = StripeTest.client
      
      # First create a payment intent
      original = Stripe::Resources::PaymentIntent.create(
        client,
        amount: 2000,
        currency: "usd",
        payment_method_types: ["card"]
      )
      
      # Then retrieve it
      payment_intent = Stripe::Resources::PaymentIntent.retrieve(client, original["id"].as_s)
      
      # Verify it's the same payment intent
      payment_intent["id"].as_s.should eq(original["id"].as_s)
      payment_intent["object"].as_s.should eq("payment_intent")
      payment_intent["amount"].as_i.should eq(original["amount"].as_i)
      payment_intent["currency"].as_s.should eq(original["currency"].as_s)
      
      # Clean up
      Stripe::Resources::PaymentIntent.cancel(client, payment_intent["id"].as_s)
    end
    
    it "raises an error for non-existent payment intent" do
      client = StripeTest.client
      
      expect_raises(Stripe::InvalidRequestError) do
        Stripe::Resources::PaymentIntent.retrieve(client, "pi_nonexistent")
      end
    end
  end
  
  describe ".update" do
    it "updates payment intent information" do
      client = StripeTest.client
      
      # Create a payment intent first
      payment_intent = Stripe::Resources::PaymentIntent.create(
        client,
        amount: 2000,
        currency: "usd",
        payment_method_types: ["card"],
        description: "Original description"
      )
      
      # Update the payment intent
      updated = Stripe::Resources::PaymentIntent.update(
        client,
        payment_intent["id"].as_s,
        description: "Updated description",
        metadata: {"order_id" => "12345"}
      )
      
      # Verify the updates
      updated["id"].as_s.should eq(payment_intent["id"].as_s)
      updated["description"].as_s.should eq("Updated description")
      updated["metadata"]["order_id"].as_s.should eq("12345")
      
      # Clean up
      Stripe::Resources::PaymentIntent.cancel(client, payment_intent["id"].as_s)
    end
  end
  
  describe ".confirm" do
    it "confirms a payment intent" do
      client = StripeTest.client
      
      # Create a payment method
      payment_method = Stripe::Resources::PaymentMethod.create(
        client,
        type: "card",
        # Use payment method token instead of raw card data
        card: {
          token: "tok_visa"
        }
      )
      
      # Create a payment intent first without confirming
      payment_intent = Stripe::Resources::PaymentIntent.create(
        client,
        amount: 2000,
        currency: "usd",
        payment_method_types: ["card"],
        payment_method: payment_method["id"].as_s
      )
      
      # Confirm the payment intent
      confirmed = Stripe::Resources::PaymentIntent.confirm(
        client, 
        payment_intent["id"].as_s
      )
      
      # Verify the confirmation
      confirmed["id"].as_s.should eq(payment_intent["id"].as_s)
      confirmed["status"].as_s.should eq("succeeded") # Test mode with valid card should succeed
    end
  end
  
  describe ".capture" do
    it "captures an uncaptured payment intent" do
      client = StripeTest.client
      
      # Create a payment method
      payment_method = Stripe::Resources::PaymentMethod.create(
        client,
        type: "card",
        # Use payment method token instead of raw card data
        card: {
          token: "tok_visa"
        }
      )
      
      # Create a payment intent with manual capture
      payment_intent = Stripe::Resources::PaymentIntent.create(
        client,
        amount: 2000,
        currency: "usd",
        payment_method_types: ["card"],
        payment_method: payment_method["id"].as_s,
        confirm: true,
        capture_method: "manual"
      )
      
      # Verify it needs capture
      payment_intent["status"].as_s.should eq("requires_capture")
      
      # Capture the payment intent
      captured = Stripe::Resources::PaymentIntent.capture(
        client, 
        payment_intent["id"].as_s
      )
      
      # Verify the capture
      captured["id"].as_s.should eq(payment_intent["id"].as_s)
      captured["status"].as_s.should eq("succeeded")
    end
    
    it "captures a partial amount" do
      client = StripeTest.client
      
      # Create a payment method
      payment_method = Stripe::Resources::PaymentMethod.create(
        client,
        type: "card",
        # Use payment method token instead of raw card data
        card: {
          token: "tok_visa"
        }
      )
      
      # Create a payment intent with manual capture
      payment_intent = Stripe::Resources::PaymentIntent.create(
        client,
        amount: 2000,
        currency: "usd",
        payment_method_types: ["card"],
        payment_method: payment_method["id"].as_s,
        confirm: true,
        capture_method: "manual"
      )
      
      # Capture a partial amount
      captured = Stripe::Resources::PaymentIntent.capture(
        client, 
        payment_intent["id"].as_s,
        amount_to_capture: 1500
      )
      
      # Verify the partial capture
      captured["id"].as_s.should eq(payment_intent["id"].as_s)
      captured["status"].as_s.should eq("succeeded")
      captured["amount_received"].as_i.should eq(1500)
    end
  end
  
  describe ".cancel" do
    it "cancels a payment intent" do
      client = StripeTest.client
      
      # Create a payment intent
      payment_intent = Stripe::Resources::PaymentIntent.create(
        client,
        amount: 2000,
        currency: "usd",
        payment_method_types: ["card"]
      )
      
      # Cancel the payment intent
      canceled = Stripe::Resources::PaymentIntent.cancel(
        client, 
        payment_intent["id"].as_s,
        cancellation_reason: "requested_by_customer"
      )
      
      # Verify the cancellation
      canceled["id"].as_s.should eq(payment_intent["id"].as_s)
      canceled["status"].as_s.should eq("canceled")
      canceled["cancellation_reason"].as_s.should eq("requested_by_customer")
    end
  end
  
  describe ".list" do
    it "lists payment intents with correct structure" do
      client = StripeTest.client
      
      # Create a payment intent to ensure we have at least one
      payment_intent = Stripe::Resources::PaymentIntent.create(
        client,
        amount: 2000,
        currency: "usd",
        payment_method_types: ["card"]
      )
      
      # List payment intents
      payment_intents = Stripe::Resources::PaymentIntent.list(
        client,
        limit: 3
      )
      
      # Verify the response structure
      payment_intents["object"].as_s.should eq("list")
      payment_intents["data"].as_a.size.should be >= 1
      payment_intents["has_more"].as_bool.should be_a(Bool)
      
      # Verify individual payment intent objects
      item = payment_intents["data"].as_a.first
      item["object"].as_s.should eq("payment_intent")
      item["id"].as_s.should start_with("pi_")
      
      # Clean up
      Stripe::Resources::PaymentIntent.cancel(client, payment_intent["id"].as_s)
    end
  end
end
