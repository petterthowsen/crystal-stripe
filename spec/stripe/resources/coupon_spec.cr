require "../../spec_helper"

describe Stripe::Resources::Coupon do
  describe ".create" do
    it "creates a percent-off coupon" do
      client = StripeTest.client
      percent_off = 25.5
      
      coupon = Stripe::Resources::Coupon.create(
        client,
        duration: "forever",
        percent_off: percent_off
      )

      coupon["id"].as_s.should_not be_empty
      coupon["object"].as_s.should eq("coupon")
      coupon["percent_off"].as_f.should eq(percent_off)
      coupon["duration"].as_s.should eq("forever")
    end

    it "creates an amount-off coupon" do
      client = StripeTest.client
      amount_off = 1000
      currency = "usd"
      
      coupon = Stripe::Resources::Coupon.create(
        client,
        duration: "once",
        amount_off: amount_off,
        currency: currency
      )

      coupon["id"].as_s.should_not be_empty
      coupon["object"].as_s.should eq("coupon")
      coupon["amount_off"].as_i.should eq(amount_off)
      coupon["currency"].as_s.should eq(currency)
      coupon["duration"].as_s.should eq("once")
    end

    it "creates a coupon with metadata" do
      client = StripeTest.client
      
      coupon = Stripe::Resources::Coupon.create(
        client,
        duration: "forever",
        percent_off: 15.0,
        metadata: {"test" => "integration"}
      )

      coupon["metadata"]["test"].as_s.should eq("integration")
    end

    it "creates a repeating coupon" do
      client = StripeTest.client
      
      coupon = Stripe::Resources::Coupon.create(
        client,
        duration: "repeating",
        duration_in_months: 3,
        percent_off: 10.0
      )

      coupon["duration"].as_s.should eq("repeating")
      coupon["duration_in_months"].as_i.should eq(3)
    end
  end

  describe ".retrieve" do
    it "retrieves an existing coupon" do
      client = StripeTest.client
      # First create a coupon
      created_coupon = Stripe::Resources::Coupon.create(
        client,
        duration: "forever",
        percent_off: 30.0,
        name: "Test Coupon"
      )
      coupon_id = created_coupon["id"].as_s

      # Then retrieve it
      coupon = Stripe::Resources::Coupon.retrieve(client, coupon_id)

      coupon["id"].as_s.should eq(coupon_id)
      coupon["percent_off"].as_f.should eq(30.0)
      coupon["name"].as_s.should eq("Test Coupon")
    end

    it "raises an error for non-existent coupon" do
      client = StripeTest.client
      expect_raises(Stripe::StripeError) do
        Stripe::Resources::Coupon.retrieve(client, "non_existent_coupon")
      end
    end
  end

  describe ".update" do
    it "updates a coupon" do
      client = StripeTest.client
      # First create a coupon
      created_coupon = Stripe::Resources::Coupon.create(
        client,
        duration: "forever",
        percent_off: 25.0
      )
      coupon_id = created_coupon["id"].as_s

      # Then update it
      updated_coupon = Stripe::Resources::Coupon.update(
        client,
        coupon_id,
        name: "Updated Name",
        metadata: {"updated" => "true"}
      )

      updated_coupon["id"].as_s.should eq(coupon_id)
      updated_coupon["name"].as_s.should eq("Updated Name")
      updated_coupon["metadata"]["updated"].as_s.should eq("true")
    end
  end

  describe ".delete" do
    it "deletes a coupon" do
      client = StripeTest.client
      # First create a coupon
      created_coupon = Stripe::Resources::Coupon.create(
        client,
        duration: "forever",
        percent_off: 15.0
      )
      coupon_id = created_coupon["id"].as_s

      # Then delete it
      deleted_coupon = Stripe::Resources::Coupon.delete(client, coupon_id)

      deleted_coupon["id"].as_s.should eq(coupon_id)
      deleted_coupon["deleted"].as_bool.should be_true
    end
  end

  describe ".list" do
    it "lists coupons" do
      client = StripeTest.client
      # Create a few coupons
      timestamp = Time.utc.to_unix
      
      Stripe::Resources::Coupon.create(
        client,
        duration: "forever",
        percent_off: 10.0,
        name: "List Test Coupon 1 #{timestamp}"
      )

      Stripe::Resources::Coupon.create(
        client,
        duration: "once",
        amount_off: 500,
        currency: "usd",
        name: "List Test Coupon 2 #{timestamp}"
      )

      # List coupons with a limit of 5
      coupons = Stripe::Resources::Coupon.list(client, limit: 5)

      coupons["object"].as_s.should eq("list")
      coupons["data"].as_a.size.should be <= 5
      coupons["data"].as_a.size.should be > 0
    end
  end
end
