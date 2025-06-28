require "http/client"
require "json"
require "uri"
require "./errors"

module Stripe
  # The `Client` class handles communication with the Stripe API.
  #
  # It provides methods for making requests to the API, handling authentication,
  # and processing responses.
  #
  # ## Examples
  #
  # ```
  # # Create a client with your API key
  # client = Stripe::Client.new(api_key: ENV["STRIPE_API_KEY"])
  #
  # # Make a request
  # response = client.request(:get, "/v1/balance")
  #
  # # With API version specified
  # client = Stripe::Client.new(
  #   api_key: ENV["STRIPE_API_KEY"],
  #   api_version: "2025-05-28.basil"
  # )
  #
  # # For Connect accounts
  # client = Stripe::Client.new(
  #   api_key: ENV["STRIPE_API_KEY"],
  #   stripe_account: "acct_1032D82eZvKYlo2C"
  # )
  # ```
  class Client
    # Default API version to use for all requests
    API_VERSION = "2025-05-28.basil"

    # Default connection timeout in seconds
    DEFAULT_CONNECT_TIMEOUT = 30.seconds

    # Default read timeout in seconds
    DEFAULT_READ_TIMEOUT = 80.seconds

    # Base URL for the Stripe API
    API_BASE = "https://api.stripe.com"

    # @return [String] The API key used for requests
    getter api_key : String

    # @return [String] The API version used for requests
    getter api_version : String

    # @return [String?] The Stripe account ID used for Connect requests
    getter stripe_account : String?

    # Initialize a new Stripe client
    #
    # @param api_key [String] The Stripe API key
    # @param api_version [String?] The Stripe API version
    # @param stripe_account [String?] The Stripe account ID for Connect requests
    # @param connect_timeout [Time::Span] Connection timeout for HTTP requests
    # @param read_timeout [Time::Span] Read timeout for HTTP requests
    def initialize(
      @api_key : String,
      @api_version : String = API_VERSION,
      @stripe_account : String? = nil,
      connect_timeout : Time::Span = DEFAULT_CONNECT_TIMEOUT,
      read_timeout : Time::Span = DEFAULT_READ_TIMEOUT
    )
      @http_client = HTTP::Client.new(URI.parse(API_BASE))
      @http_client.connect_timeout = connect_timeout
      @http_client.read_timeout = read_timeout
    end

    # Performs a request to the Stripe API.
    #
    # @param method [Symbol] The HTTP method to use (:get, :post, :delete, or :patch)
    # @param path [String] The path to request
    # @param params [Hash(String | Symbol, String | Int32 | Float64 | Bool | Hash | Array | Nil) | NamedTuple | Nil] The parameters to send
    # @param headers [HTTP::Headers?] Additional headers to send
    # @param idempotency_key [String?] Optional idempotency key to prevent duplicate requests
    # @return [JSON::Any] The parsed JSON response
    def request(
      method : Symbol,
      path : String,
      params : Hash(String | Symbol, String | Int32 | Float64 | Bool | Hash | Array | Nil) | NamedTuple | Nil = nil,
      headers : HTTP::Headers? = nil,
      idempotency_key : String? = nil
    ) : JSON::Any
      # Prepare headers
      request_headers = default_headers
      
      # Add idempotency key if provided
      if idempotency_key && (method == :post)
        request_headers["Idempotency-Key"] = idempotency_key
      end
      
      # Add custom headers if provided
      if headers
        headers.each { |k, v| request_headers[k] = v }
      end
      
      # Prepare path and body
      full_path = path
      body = nil
      
      case method
      when :get
        if params && !params.empty?
          query_string = URI::Params.encode(flatten_params(params))
          full_path = "#{path}?#{query_string}"
        end
      when :post, :delete, :patch
        if params && !params.empty?
          body = URI::Params.encode(flatten_params(params))
          request_headers["Content-Type"] = "application/x-www-form-urlencoded"
        end
      end
      
      # Make the request
      response = case method
                when :get
                  @http_client.get(full_path, headers: request_headers)
                when :post
                  @http_client.post(full_path, headers: request_headers, body: body)
                when :delete
                  @http_client.delete(full_path, headers: request_headers, body: body)
                when :patch
                  @http_client.patch(full_path, headers: request_headers, body: body)
                else
                  raise ArgumentError.new("Unsupported HTTP method: #{method}")
                end
      
      # Handle response
      handle_response(response)
    end
    
    # Generate default headers for all Stripe API requests
    private def default_headers
      headers = HTTP::Headers{
        "Authorization" => "Bearer #{@api_key}",
        "Stripe-Version" => @api_version,
        "User-Agent" => "Stripe/v1 CrystalBindings/0.1.0"
      }
      
      # Only add Stripe-Account header if it's not nil
      if account = @stripe_account
        headers["Stripe-Account"] = account
      end
      
      headers
    end
    
    # Flatten nested parameters for URL encoding
    #
    # Converts nested hashes and arrays into the format Stripe expects for form-encoded params
    private def flatten_params(params : Hash | NamedTuple, parent_key : String? = nil) : Hash(String, String)
      result = {} of String => String
      
      params_hash = params.is_a?(NamedTuple) ? params.to_h : params
      
      params_hash.each do |key, value|
        key_str = key.to_s
        composed_key = parent_key ? "#{parent_key}[#{key_str}]" : key_str
        
        case value
        when Hash, NamedTuple
          result.merge!(flatten_params(value, composed_key))
        when Array
          value.each_with_index do |item, index|
            if item.is_a?(Hash) || item.is_a?(NamedTuple)
              result.merge!(flatten_params(item, "#{composed_key}[#{index}]"))
            else
              result["#{composed_key}[#{index}]"] = item.to_s
            end
          end
        when Nil
          # Skip nil values
        else
          result[composed_key] = value.to_s
        end
      end
      
      result
    end
    
    # Special method for testing - allows test access to the private method
    def __flatten_params(params : Hash | NamedTuple, parent_key : String? = nil) : Hash(String, String)
      flatten_params(params, parent_key)
    end
    
    # Handle API responses and raise appropriate errors for non-2xx responses
    private def handle_response(response : HTTP::Client::Response) : JSON::Any
      case response.status_code
      when 200..299
        # Success response
        begin
          JSON.parse(response.body)
        rescue e : JSON::ParseException
          raise Stripe::APIError.new(
            status_code: response.status_code,
            message: "Invalid JSON response: #{e.message}"
          )
        end
      else
        # Error response
        begin
          error_data = JSON.parse(response.body)
          error_obj = error_data["error"]
          
          error_type = error_obj["type"].as_s
          error_message = error_obj["message"].as_s
          
          case error_type
          when "card_error"
            raise Stripe::CardError.new(
              status_code: response.status_code,
              message: error_message,
              code: error_obj["code"]?.try(&.as_s?),
              param: error_obj["param"]?.try(&.as_s?),
              decline_code: error_obj["decline_code"]?.try(&.as_s?)
            )
          when "invalid_request_error"
            raise Stripe::InvalidRequestError.new(
              status_code: response.status_code,
              message: error_message,
              param: error_obj["param"]?.try(&.as_s?)
            )
          when "authentication_error"
            raise Stripe::AuthenticationError.new(
              status_code: response.status_code,
              message: error_message
            )
          when "rate_limit_error"
            raise Stripe::RateLimitError.new(
              status_code: response.status_code,
              message: error_message
            )
          when "idempotency_error"
            raise Stripe::IdempotencyError.new(
              status_code: response.status_code,
              message: error_message
            )
          when "api_error"
            raise Stripe::APIError.new(
              status_code: response.status_code,
              message: error_message
            )
          else
            raise Stripe::StripeError.new(
              status_code: response.status_code,
              message: error_message
            )
          end
        rescue e : JSON::ParseException
          # Handle case where response is not valid JSON
          raise Stripe::APIError.new(
            status_code: response.status_code,
            message: "Invalid error response: #{e.message}"
          )
        rescue e : KeyError | TypeCastError
          # Handle case where error object does not have expected fields
          raise Stripe::APIError.new(
            status_code: response.status_code,
            message: "Malformed error response: #{e.message}"
          )
        end
      end
    end
  end
end
