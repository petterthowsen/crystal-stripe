module Stripe
  module Resources
    # Represents a Stripe Balance resource
    #
    # The Balance object represents your Stripe balance,
    # providing detailed breakdown of available and pending funds.
    #
    # See the [Balance API docs](https://docs.stripe.com/api/balance)
    class Balance
      # Represents a Balance fund availability
      class Funds
        include JSON::Serializable
        
        # Amount available, in smallest currency unit (e.g., cents for USD)
        getter amount : Int64
        
        # Three-letter ISO currency code
        getter currency : String
        
        # Detailed breakdown of available funds
        getter source_types : Hash(String, Int64)?
      end
      
      # Represents a Balance object returned by the Stripe API
      class BalanceObject
        include JSON::Serializable
        
        # String representing the object's type
        getter object : String
        
        # Available funds that can be used for payouts
        getter available : Array(Funds)
        
        # Funds held due to pending transactions
        getter pending : Array(Funds)
        
        # Funds connected account can use for payouts (Connect only)
        getter connect_reserved : Array(Funds)?
        
        # Balance for each type of payout attempt failure
        getter instant_available : Array(Funds)?
      end
      
      # Retrieves the Stripe account balance
      #
      # @param client [Stripe::Client] Client used to connect to Stripe API
      # @return [BalanceObject] The account balance
      def self.retrieve(client : Stripe::Client) : BalanceObject
        response = client.request(:get, "/v1/balance")
        BalanceObject.from_json(response.to_json)
      end
      
      # Represents a balance transaction returned by the Stripe API
      class Transaction
        include JSON::Serializable
        
        # Unique identifier for the transaction
        getter id : String
        
        # String representing the object's type
        getter object : String
        
        # Amount of the transaction, in smallest currency unit
        getter amount : Int64
        
        # Time at which the transaction was created
        @[JSON::Field(converter: Time::EpochConverter)]
        getter created : Time
        
        # Three-letter ISO currency code
        getter currency : String
        
        # Human-readable description of the transaction
        getter description : String?
        
        # Fee (in cents) associated with this transaction
        getter fee : Int64
        
        # Breakdown of the fees associated with this transaction
        getter fee_details : Array(FeeDetail)?
        
        # Net amount of the transaction, in smallest currency unit
        getter net : Int64
        
        # Type of the balance transaction (charge, payment, adjustment, etc.)
        getter type : String
        
        # Additional data related to the type of transaction
        getter source : JSON::Any?
        
        # Status of transaction (available or pending)
        getter status : String
        
        # Represents a fee detail in a balance transaction
        class FeeDetail
          include JSON::Serializable
          
          # Amount of the fee, in smallest currency unit
          getter amount : Int64
          
          # Three-letter ISO currency code
          getter currency : String
          
          # Type of the fee (e.g., stripe_fee, tax)
          getter type : String
          
          # ID of the application fee that caused this fee (if applicable)
          getter application : String?
          
          # Description of the fee
          getter description : String?
        end
      end
      
      # List all balance transactions
      #
      # @param client [Stripe::Client] Client used to connect to Stripe API
      # @param limit [Int32?] Maximum number of transactions to return
      # @param starting_after [String?] Starting point cursor for pagination
      # @param ending_before [String?] End point cursor for pagination
      # @return [Stripe::List(Transaction)] Paginated list of balance transactions
      def self.list_transactions(
        client : Stripe::Client,
        limit : Int32? = nil,
        starting_after : String? = nil,
        ending_before : String? = nil,
        type : String? = nil
      )
        params = {} of String => String | Int32
        
        params["limit"] = limit if limit
        params["starting_after"] = starting_after if starting_after
        params["ending_before"] = ending_before if ending_before
        params["type"] = type if type
        
        response = client.request(:get, "/v1/balance/history", params)
        
        # Convert the response to a List object (to be implemented later)
        transactions = Array(Transaction).new
        
        response["data"].as_a.each do |transaction_data|
          transactions << Transaction.from_json(transaction_data.to_json)
        end
        
        transactions
      end
      
      # Retrieve a specific balance transaction
      #
      # @param client [Stripe::Client] Client used to connect to Stripe API
      # @param id [String] Unique identifier of the transaction to retrieve
      # @return [Transaction] The balance transaction
      def self.retrieve_transaction(client : Stripe::Client, id : String) : Transaction
        response = client.request(:get, "/v1/balance/history/#{id}")
        Transaction.from_json(response.to_json)
      end
    end
  end
end
