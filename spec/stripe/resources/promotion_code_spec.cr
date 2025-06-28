require "../../spec_helper"

# Helper module for promotion code specs
module PromotionCodeSpecHelpers
  def self.create_test_coupon(client)
    coupon = Stripe::Resources::Coupon.create(
      client,
      duration: "forever",
      percent_off: 25.0
    )
    coupon["id"].as_s
  end
end

describe Stripe::Resources::PromotionCode do
  describe ".create" do
    it "creates a promotion code" do
      client = StripeTest.client
      coupon_id = PromotionCodeSpecHelpers.create_test_coupon(client)
      
      promotion_code = Stripe::Resources::PromotionCode.create(
        client,
        coupon: coupon_id
      )

      promotion_code["id"].as_s.should start_with("promo_")
      promotion_code["object"].as_s.should eq("promotion_code")
      promotion_code["coupon"]["id"].as_s.should eq(coupon_id)
      promotion_code["active"].as_bool.should be_true
    end

    it "creates a promotion code with custom code" do
      client = StripeTest.client
      coupon_id = PromotionCodeSpecHelpers.create_test_coupon(client)
      unique_code = "TEST#{Time.utc.to_unix}"
      
      promotion_code = Stripe::Resources::PromotionCode.create(
        client,
        coupon: coupon_id,
        code: unique_code
      )

      promotion_code["code"].as_s.should eq(unique_code)
    end

    it "creates a promotion code with restrictions" do
      client = StripeTest.client
      coupon_id = PromotionCodeSpecHelpers.create_test_coupon(client)
      
      promotion_code = Stripe::Resources::PromotionCode.create(
        client,
        coupon: coupon_id,
        restrictions: {
          first_time_transaction: true,
          minimum_amount: 1000,
          minimum_amount_currency: "usd"
        }
      )

      promotion_code["restrictions"]["first_time_transaction"].as_bool.should be_true
      promotion_code["restrictions"]["minimum_amount"].as_i.should eq(1000)
      promotion_code["restrictions"]["minimum_amount_currency"].as_s.should eq("usd")
    end

    it "creates a promotion code with metadata" do
      client = StripeTest.client
      coupon_id = PromotionCodeSpecHelpers.create_test_coupon(client)
      
      promotion_code = Stripe::Resources::PromotionCode.create(
        client,
        coupon: coupon_id,
        metadata: {"campaign" => "summer_launch"}
      )

      promotion_code["metadata"]["campaign"].as_s.should eq("summer_launch")
    end
  end

  describe ".retrieve" do
    it "retrieves an existing promotion code" do
      client = StripeTest.client
      # First create a coupon and promotion code
      coupon_id = PromotionCodeSpecHelpers.create_test_coupon(client)
      created_promotion_code = Stripe::Resources::PromotionCode.create(
        client,
        coupon: coupon_id
      )
      promotion_code_id = created_promotion_code["id"].as_s

      # Then retrieve it
      promotion_code = Stripe::Resources::PromotionCode.retrieve(client, promotion_code_id)

      promotion_code["id"].as_s.should eq(promotion_code_id)
      promotion_code["coupon"]["id"].as_s.should eq(coupon_id)
    end

    it "raises an error for non-existent promotion code" do
      client = StripeTest.client
      expect_raises(Stripe::StripeError) do
        Stripe::Resources::PromotionCode.retrieve(client, "promo_nonexistent")
      end
    end
  end

  describe ".update" do
    it "updates a promotion code" do
      client = StripeTest.client
      # First create a coupon and promotion code
      coupon_id = PromotionCodeSpecHelpers.create_test_coupon(client)
      created_promotion_code = Stripe::Resources::PromotionCode.create(
        client,
        coupon: coupon_id,
        active: true
      )
      promotion_code_id = created_promotion_code["id"].as_s

      # Then update it
      updated_promotion_code = Stripe::Resources::PromotionCode.update(
        client,
        promotion_code_id,
        active: false,
        metadata: {"updated" => "true"}
      )

      updated_promotion_code["id"].as_s.should eq(promotion_code_id)
      updated_promotion_code["active"].as_bool.should be_false
      updated_promotion_code["metadata"]["updated"].as_s.should eq("true")
    end
  end

  describe ".list" do
    it "lists promotion codes" do
      client = StripeTest.client
      # Create a coupon and a couple of promotion codes
      coupon_id = PromotionCodeSpecHelpers.create_test_coupon(client)
      timestamp = Time.utc.to_unix
      
      Stripe::Resources::PromotionCode.create(
        client,
        coupon: coupon_id,
        code: "LIST1#{timestamp}"
      )

      Stripe::Resources::PromotionCode.create(
        client,
        coupon: coupon_id,
        code: "LIST2#{timestamp}"
      )

      # List promotion codes with a limit of 5
      promotion_codes = Stripe::Resources::PromotionCode.list(client, limit: 5)

      promotion_codes["object"].as_s.should eq("list")
      promotion_codes["data"].as_a.size.should be <= 5
      promotion_codes["data"].as_a.size.should be > 0
    end

    it "filters promotion codes by coupon" do
      client = StripeTest.client
      # Create a coupon and promotion code
      coupon_id = PromotionCodeSpecHelpers.create_test_coupon(client)
      unique_code = "FILTER#{Time.utc.to_unix}"
      
      Stripe::Resources::PromotionCode.create(
        client,
        coupon: coupon_id,
        code: unique_code
      )

      # List promotion codes for this specific coupon
      promotion_codes = Stripe::Resources::PromotionCode.list(client, coupon: coupon_id)

      promotion_codes["object"].as_s.should eq("list")
      if !promotion_codes["data"].as_a.empty?
        promotion_codes["data"].as_a.each do |promo_code|
          promo_code["coupon"]["id"].as_s.should eq(coupon_id)
        end
      end
    end
  end
end
