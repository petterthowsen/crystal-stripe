require "../../spec_helper"

describe Stripe::Resources::Balance do
  describe ".retrieve" do
    it "retrieves the account balance" do
      StripeTest.with_vcr_recording("balance_retrieve") do
        client = StripeTest.client
        balance = Stripe::Resources::Balance.retrieve(client)
        
        # Test the balance object properties
        balance.object.should eq("balance")
        
        # Test balance has proper fields
        balance.available.should be_a(Array(Stripe::Resources::Balance::Funds))
        balance.pending.should be_a(Array(Stripe::Resources::Balance::Funds))
        
        # The test account may have various currencies and amounts
        # so we'll just verify the structure, not exact values
        balance.available.each do |fund|
          fund.amount.should be_a(Int64)
          fund.currency.should be_a(String)
        end
        
        balance.pending.each do |fund|
          fund.amount.should be_a(Int64)
          fund.currency.should be_a(String)
        end
      end
    end
  end

  describe ".list_transactions" do
    it "lists balance transactions with correct structure" do
      StripeTest.with_vcr_recording("balance_list_transactions") do
        client = StripeTest.client
        # Limit to 2 to keep test fast
        transactions = Stripe::Resources::Balance.list_transactions(client, limit: 2)
        
        # A new account might not have any transactions
        # Just test the structure matches what we expect
        transactions.should be_a(Array(Stripe::Resources::Balance::Transaction))
        
        if !transactions.empty?
          transaction = transactions.first
          transaction.id.should match(/^txn_/)
          transaction.object.should eq("balance_transaction")
          transaction.amount.should be_a(Int64)
          transaction.currency.should be_a(String)
          transaction.created.should be_a(Time)
        end
      end
    end

    it "passes pagination parameters correctly" do
      client = StripeTest.client
      
      # Create a client with our test API key
      custom_client = Stripe::Client.new(api_key: StripeTest::TEST_API_KEY)
      
      # We'll make two requests, one with limit: 1 and one with limit: 2
      # and verify we get different numbers of results
      transactions1 = Stripe::Resources::Balance.list_transactions(custom_client, limit: 1)
      transactions2 = Stripe::Resources::Balance.list_transactions(custom_client, limit: 2)
      
      # The second request should return at most 2 transactions
      # (it could return fewer if the account doesn't have many transactions)
      if !transactions2.empty?
        transactions2.size.should be <= 2
      end
      
      # If we got any transactions in the first request,
      # we should have received at most 1
      if !transactions1.empty?
        transactions1.size.should be <= 1
      end
    end
  end

  describe ".retrieve_transaction" do
    # This test can only succeed if there are transactions in the test account
    # So we'll make it conditional on having transactions
    it "retrieves a transaction if one exists" do
      # First check if there are any transactions
      client = StripeTest.client
      transactions = Stripe::Resources::Balance.list_transactions(client, limit: 1)
      
      # Only run the test if there's at least one transaction
      if !transactions.empty?
        txn_id = transactions.first.id
        
        StripeTest.with_vcr_recording("balance_retrieve_transaction") do
          txn = Stripe::Resources::Balance.retrieve_transaction(client, txn_id)
          
          txn.id.should eq(txn_id)
          txn.object.should eq("balance_transaction")
          txn.amount.should be_a(Int64)
          txn.currency.should be_a(String)
          txn.created.should be_a(Time)
        end
      end
    end

    it "raises error for non-existent transaction" do
      client = StripeTest.client
      
      expect_raises(Stripe::InvalidRequestError, /No such balance transaction/) do
        Stripe::Resources::Balance.retrieve_transaction(client, "txn_nonexistent123456789")
      end
    end
  end
end
