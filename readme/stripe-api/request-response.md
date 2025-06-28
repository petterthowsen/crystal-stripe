# Stripe API Request and Response Handling

This document explains how requests and responses work in the Stripe API and how they will be implemented in the Crystal Stripe library.

## API Base URL

All Stripe API requests are made to:

```
https://api.stripe.com
```

## Request Methods

Stripe API uses standard HTTP methods:

| Method | Description |
|--------|-------------|
| GET | Retrieve resources |
| POST | Create resources or perform actions |
| DELETE | Delete resources |
| PATCH | Update resources (partial updates) |

## Request Structure

### Headers

Common headers for Stripe API requests:

| Header | Description |
|--------|-------------|
| `Authorization` | API key for authentication |
| `Stripe-Version` | API version to use |
| `Stripe-Account` | Account ID for Connect requests |
| `Idempotency-Key` | Key for preventing duplicate requests |
| `Content-Type` | Usually `application/x-www-form-urlencoded` |

### Parameters

Parameters can be sent in different ways depending on the request method:

- **GET**: Parameters are included in the query string
- **POST/PATCH/DELETE**: Parameters are included in the request body as form-encoded data

### Nested Parameters

Stripe supports nested parameters using square bracket notation:

```
customer[email]=customer@example.com&customer[metadata][order_id]=6735
```

In Crystal, this would be represented as:

```crystal
params = {
  "customer" => {
    "email" => "customer@example.com",
    "metadata" => {
      "order_id" => "6735"
    }
  }
}
```

## Response Structure

### Success Responses

Successful responses have:
- HTTP status code in the 2xx range
- JSON body containing the requested data

### Error Responses

Error responses have:
- HTTP status code in the 4xx or 5xx range
- JSON body containing error details

Example error response:

```json
{
  "error": {
    "code": "resource_missing",
    "doc_url": "https://docs.stripe.com/error-codes/resource-missing",
    "message": "No such customer: cus_123456789",
    "param": "id",
    "type": "invalid_request_error"
  }
}
```

### Pagination

List responses are paginated with:

- `has_more`: Boolean indicating if there are more items
- `data`: Array of objects
- `object`: Always "list"
- `url`: URL of the list endpoint

Example:

```json
{
  "object": "list",
  "data": [
    { /* object 1 */ },
    { /* object 2 */ }
  ],
  "has_more": true,
  "url": "/v1/customers"
}
```

## Implementation in Crystal

### Making Requests

The Crystal Stripe library will handle requests as follows:

```crystal
module Stripe
  class Client
    def initialize(api_key : String, api_version : String? = nil, stripe_account : String? = nil)
      @api_key = api_key
      @api_version = api_version || DEFAULT_API_VERSION
      @stripe_account = stripe_account
      @http_client = HTTP::Client.new(URI.parse("https://api.stripe.com"))
      @http_client.connect_timeout = 30.seconds
      @http_client.read_timeout = 80.seconds
    end
    
    def request(method : Symbol, path : String, params : Hash? = nil, headers : HTTP::Headers? = nil) : JSON::Any
      # Prepare headers
      request_headers = default_headers
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
    
    private def default_headers
      headers = HTTP::Headers{
        "Authorization" => "Bearer #{@api_key}",
        "Stripe-Version" => @api_version,
        "User-Agent" => "Stripe/v1 CrystalBindings/1.0.0"
      }
      
      if @stripe_account
        headers["Stripe-Account"] = @stripe_account
      end
      
      headers
    end
    
    private def flatten_params(params : Hash, parent_key : String? = nil) : Hash(String, String)
      result = {} of String => String
      
      params.each do |key, value|
        key_str = key.to_s
        composed_key = parent_key ? "#{parent_key}[#{key_str}]" : key_str
        
        case value
        when Hash
          result.merge!(flatten_params(value, composed_key))
        when Array
          value.each_with_index do |item, index|
            if item.is_a?(Hash)
              result.merge!(flatten_params(item, "#{composed_key}[#{index}]"))
            else
              result["#{composed_key}[#{index}]"] = item.to_s
            end
          end
        else
          result[composed_key] = value.to_s
        end
      end
      
      result
    end
    
    private def handle_response(response : HTTP::Client::Response) : JSON::Any
      case response.status_code
      when 200..299
        # Success response
        JSON.parse(response.body)
      else
        # Error response
        error_data = JSON.parse(response.body)
        error_obj = error_data["error"]
        
        error_type = error_obj["type"].as_s
        error_message = error_obj["message"].as_s
        
        error_class = case error_type
                      when "card_error"
                        CardError
                      when "invalid_request_error"
                        InvalidRequestError
                      when "api_error"
                        APIError
                      when "idempotency_error"
                        IdempotencyError
                      else
                        StripeError
                      end
        
        raise error_class.new(response.status_code, ErrorObject.from_json(error_obj.to_json))
      end
    end
  end
end
```

### Handling Pagination

The library will provide methods to handle pagination:

```crystal
module Stripe
  class ListObject(T)
    include Enumerable(T)
    
    property data : Array(T)
    property has_more : Bool
    property url : String
    
    def initialize(@data, @has_more, @url)
    end
    
    def each
      @data.each do |item|
        yield item
      end
    end
    
    def next_page(client : Client, params : Hash? = nil) : ListObject(T)?
      return nil unless @has_more
      
      # Extract the last ID for pagination
      last_id = @data.last.id
      
      # Prepare pagination parameters
      page_params = params ? params.dup : {} of String => String
      page_params["starting_after"] = last_id
      
      # Make the request for the next page
      client.request(:get, @url, page_params).as_list(T)
    end
    
    def auto_paging_each(client : Client, params : Hash? = nil)
      current_page = self
      
      loop do
        current_page.each do |item|
          yield item
        end
        
        current_page = current_page.next_page(client, params)
        break unless current_page
      end
    end
  end
end
```

## Idempotency

To prevent duplicate processing of requests, use idempotency keys for non-idempotent requests (like creating charges):

```crystal
client.charges.create(
  amount: 2000,
  currency: "usd",
  source: "tok_visa",
  idempotency_key: "a-unique-idempotency-key"
)
```

The library will automatically include the `Idempotency-Key` header when provided.

## Request Timeouts

The Crystal Stripe library will set reasonable timeouts:

- Connect timeout: 30 seconds
- Read timeout: 80 seconds

These can be configured when initializing the client:

```crystal
client = Stripe::Client.new(
  api_key: "sk_test_your_test_key",
  connect_timeout: 20.seconds,
  read_timeout: 60.seconds
)
```

## Best Practices

1. **Use HTTPS**: Always use HTTPS for API requests.

2. **Handle Rate Limiting**: Implement exponential backoff for rate limit errors.

3. **Use Idempotency Keys**: For non-idempotent requests to prevent duplicate processing.

4. **Set Timeouts**: Configure appropriate timeouts to prevent hanging requests.

5. **Validate Parameters**: Validate parameters before sending them to the API.

6. **Handle Pagination**: Use pagination methods for listing large collections of resources.
