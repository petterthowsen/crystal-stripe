# Include required files first so they're available to the main module
require "./stripe/errors"
require "./stripe/client"
require "./stripe/resources/balance"
require "./stripe/resources/customer"
require "./stripe/resources/payment_method"
require "./stripe/resources/payment_intent"
require "./stripe/resources/invoice"
require "./stripe/resources/invoice_item"
require "./stripe/resources/product"
require "./stripe/resources/price"
require "./stripe/resources/subscription"
require "./stripe/resources/promotion_code"
require "./stripe/resources/coupon"

# The `Stripe` module provides a Crystal interface to the Stripe API.
#
# This library allows you to interact with the Stripe API in an idiomatic Crystal way.
# It provides classes for resources like charges, customers, and subscriptions,
# along with a `Client` class to make authenticated API requests.
#
# ## Example
#
# ```
# # Set your API key
# Stripe.api_key = ENV["STRIPE_API_KEY"]
#
# # Retrieve balance
# balance = Stripe::Balance.retrieve
# puts "Available USD: #{balance.available.find(&.currency.===("usd")).try(&.amount) || 0}"
#
# # List balance transactions
# txns = Stripe::Balance.list_transactions(limit: 5)
# txns.each do |txn|
#   puts "#{txn.type}: #{txn.amount / 100.0} #{txn.currency.upcase}"
# end
# ```
module Stripe
  VERSION = "0.1.1"
  
  # Default client for simple access without creating client instances
  class_getter client : Client? = nil
  
  # Set the API key for the default client
  def self.api_key=(api_key : String)
    @@client = Client.new(api_key: api_key)
  end
  
  # Get the API key from the default client
  def self.api_key : String?
    @@client.try(&.api_key)
  end
  
  # Set the API version for the default client
  def self.api_version=(api_version : String)
    if client = @@client
      @@client = Client.new(api_key: client.api_key, api_version: api_version)
    else
      raise "Set api_key before setting api_version"
    end
  end
  
  # Get the API version from the default client
  def self.api_version : String?
    @@client.try(&.api_version)
  end
  
  # Get or create the default client
  private def self.default_client : Client
    @@client || raise "No API key set. Set your API key using Stripe.api_key = <API_KEY>"
  end
  
  # Balance resource accessible via module methods
  module Balance
    # Retrieves the current account balance
    def self.retrieve : Resources::Balance::BalanceObject
      Resources::Balance.retrieve(Stripe.default_client)
    end
    
    # List balance transactions
    def self.list_transactions(
      limit : Int32? = nil,
      starting_after : String? = nil,
      ending_before : String? = nil,
      type : String? = nil
    )
      Resources::Balance.list_transactions(
        Stripe.default_client,
        limit: limit,
        starting_after: starting_after,
        ending_before: ending_before,
        type: type
      )
    end
    
    # Retrieve a specific balance transaction
    def self.retrieve_transaction(id : String) : Resources::Balance::Transaction
      Resources::Balance.retrieve_transaction(Stripe.default_client, id)
    end
  end
end
