require "http/client"
require "json"
require "uri"
require "socket"
require "openssl"
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
      @connect_timeout : Time::Span = DEFAULT_CONNECT_TIMEOUT,
      @read_timeout : Time::Span = DEFAULT_READ_TIMEOUT
    )
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
          body = flatten_params(params)
        end
      end
      
      # Make the request using manual TCP connection
      response = make_tcp_request(method, full_path, request_headers, body)
      
      # Handle response
      handle_response(response)
    end
    
    # Make a manual TCP request to avoid HTTP::Client issues with form data
    private def make_tcp_request(method : Symbol, path : String, headers : HTTP::Headers, body : Hash(String, String)?) : HTTP::Client::Response
      uri = URI.parse(API_BASE)
      host = uri.host.not_nil!
      port = uri.port || (uri.scheme == "https" ? 443 : 80)
      
      # Prepare the request body
      request_body = ""
      if body && !body.empty?
        request_body = URI::Params.encode(body)
        headers["Content-Type"] = "application/x-www-form-urlencoded"
        headers["Content-Length"] = request_body.bytesize.to_s
      else
        headers["Content-Length"] = "0"
      end
      
      # Build the HTTP request
      http_request = String.build do |str|
        str << "#{method.to_s.upcase} #{path} HTTP/1.1\r\n"
        str << "Host: #{host}\r\n"
        str << "Connection: close\r\n"
        
        headers.each do |key, values|
          values.each do |value|
            str << "#{key}: #{value}\r\n"
          end
        end
        
        str << "\r\n"
        str << request_body if !request_body.empty?
      end
      
      # Make the connection
      socket = if uri.scheme == "https"
        tcp_socket = TCPSocket.new(host, port)
        context = OpenSSL::SSL::Context::Client.new
        context.verify_mode = OpenSSL::SSL::VerifyMode::PEER
        OpenSSL::SSL::Socket::Client.new(tcp_socket, context: context, sync_close: true, hostname: host)
      else
        TCPSocket.new(host, port)
      end
      
      begin
        # Send the request
        socket.write(http_request.to_slice)
        socket.flush
        
        # Read the response
        response_data = socket.gets_to_end
        
        # Parse the HTTP response
        parse_http_response(response_data)
      ensure
        socket.close
      end
    end
    
    # Parse HTTP response from raw string
    private def parse_http_response(response_data : String) : HTTP::Client::Response
      # Split on \r\n\r\n to separate headers from body
      header_body_split = response_data.split("\r\n\r\n", 2)
      
      if header_body_split.size < 2
        # Fallback to \n\n split for servers that don't use \r\n
        header_body_split = response_data.split("\n\n", 2)
      end
      
      header_section = header_body_split[0]
      body = header_body_split.size > 1 ? header_body_split[1] : ""
      
      lines = header_section.split(/\r?\n/)
      
      # Parse status line
      status_line = lines[0]
      status_parts = status_line.split(" ", 3)
      
      unless status_parts.size >= 2
        raise Stripe::APIError.new(
          status_code: 0,
          message: "Invalid HTTP response: #{response_data[0...200]}"
        )
      end
      
      status_code = status_parts[1].to_i
      
      # Parse headers
      headers = HTTP::Headers.new
      
      lines[1..].each do |line|
        next if line.strip.empty?
        
        if line.includes?(":")
          key, value = line.split(":", 2)
          headers[key.strip] = value.strip
        end
      end
      
      # Handle chunked transfer encoding
      if headers["Transfer-Encoding"]? == "chunked"
        body = decode_chunked_body(body)
      end
      
      HTTP::Client::Response.new(status_code, body, headers)
    end
    
    # Decode chunked transfer encoding
    private def decode_chunked_body(chunked_body : String) : String
      result = String.build do |str|
        remaining = chunked_body
        
        while !remaining.empty?
          # Find the first \r\n which indicates end of chunk size
          newline_pos = remaining.index("\r\n")
          break unless newline_pos
          
          # Get chunk size (in hex)
          chunk_size_hex = remaining[0...newline_pos]
          chunk_size = chunk_size_hex.to_i(16)
          
          # If chunk size is 0, we're done
          break if chunk_size == 0
          
          # Skip past the \r\n after chunk size
          chunk_start = newline_pos + 2
          chunk_end = chunk_start + chunk_size
          
          # Extract the chunk data
          if chunk_end <= remaining.size
            str << remaining[chunk_start...chunk_end]
          end
          
          # Move past this chunk and its trailing \r\n
          remaining = remaining[(chunk_end + 2)..]
        end
      end
      
      result
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
            message: "Invalid JSON response: #{e.message}. Response body: #{response.body[0...200]}"
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
            message: "Invalid error response: #{e.message}. Response body: #{response.body[0...200]}"
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
