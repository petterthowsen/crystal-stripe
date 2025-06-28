require "../client"

module Stripe::Resources::Invoice
  # Creates a new invoice for a customer.
  # 
  # See Stripe API docs: https://docs.stripe.com/api/invoices/create
  #
  # ```
  # client = Stripe::Client.new(api_key: ENV["STRIPE_API_KEY"])
  # 
  # # Create a simple invoice for a customer
  # invoice = Stripe::Resources::Invoice.create(
  #   client,
  #   customer: "cus_12345"
  # )
  # 
  # # Create an invoice with send_invoice collection method
  # invoice = Stripe::Resources::Invoice.create(
  #   client,
  #   customer: "cus_12345",
  #   collection_method: "send_invoice"
  # )
  # ```
  def self.create(client : Stripe::Client, **params) : JSON::Any
    client.request(:post, "/v1/invoices", params)
  end

  # Retrieves the invoice with the given ID.
  #
  # See Stripe API docs: https://docs.stripe.com/api/invoices/retrieve
  #
  # ```
  # client = Stripe::Client.new(api_key: ENV["STRIPE_API_KEY"])
  # invoice = Stripe::Resources::Invoice.retrieve(client, "in_12345")
  # ```
  def self.retrieve(client : Stripe::Client, id : String, **params) : JSON::Any
    client.request(:get, "/v1/invoices/#{id}", params)
  end

  # Updates an existing invoice.
  #
  # See Stripe API docs: https://docs.stripe.com/api/invoices/update
  #
  # ```
  # client = Stripe::Client.new(api_key: ENV["STRIPE_API_KEY"])
  # 
  # # Update invoice metadata
  # invoice = Stripe::Resources::Invoice.update(
  #   client,
  #   "in_12345",
  #   metadata: {"order_id" => "6735"}
  # )
  # 
  # # Update invoice description
  # invoice = Stripe::Resources::Invoice.update(
  #   client,
  #   "in_12345",
  #   description: "Updated invoice description"
  # )
  # ```
  def self.update(client : Stripe::Client, id : String, **params) : JSON::Any
    client.request(:post, "/v1/invoices/#{id}", params)
  end

  # Deletes a draft invoice.
  #
  # See Stripe API docs: https://docs.stripe.com/api/invoices/delete
  #
  # ```
  # client = Stripe::Client.new(api_key: ENV["STRIPE_API_KEY"])
  # deleted_invoice = Stripe::Resources::Invoice.delete(client, "in_12345")
  # ```
  def self.delete(client : Stripe::Client, id : String, **params) : JSON::Any
    client.request(:delete, "/v1/invoices/#{id}", params)
  end

  # Returns a list of invoices.
  #
  # See Stripe API docs: https://docs.stripe.com/api/invoices/list
  #
  # ```
  # client = Stripe::Client.new(api_key: ENV["STRIPE_API_KEY"])
  # 
  # # List all invoices
  # invoices = Stripe::Resources::Invoice.list(client)
  #
  # # List invoices for a specific customer
  # invoices = Stripe::Resources::Invoice.list(
  #   client,
  #   customer: "cus_12345",
  #   limit: 5
  # )
  #
  # # List invoices with a specific status
  # invoices = Stripe::Resources::Invoice.list(
  #   client,
  #   status: "draft"
  # )
  # ```
  def self.list(client : Stripe::Client, **params) : JSON::Any
    client.request(:get, "/v1/invoices", params)
  end

  # Finalizes a draft invoice.
  #
  # See Stripe API docs: https://docs.stripe.com/api/invoices/finalize
  #
  # ```
  # client = Stripe::Client.new(api_key: ENV["STRIPE_API_KEY"])
  # finalized_invoice = Stripe::Resources::Invoice.finalize(
  #   client, 
  #   "in_12345"
  # )
  # ```
  def self.finalize(client : Stripe::Client, id : String, **params) : JSON::Any
    client.request(:post, "/v1/invoices/#{id}/finalize", params)
  end

  # Pays an invoice.
  #
  # See Stripe API docs: https://docs.stripe.com/api/invoices/pay
  #
  # ```
  # client = Stripe::Client.new(api_key: ENV["STRIPE_API_KEY"])
  # paid_invoice = Stripe::Resources::Invoice.pay(client, "in_12345")
  # ```
  def self.pay(client : Stripe::Client, id : String, **params) : JSON::Any
    client.request(:post, "/v1/invoices/#{id}/pay", params)
  end

  # Sends an invoice to the customer.
  # 
  # See Stripe API docs: https://docs.stripe.com/api/invoices/send
  #
  # ```
  # client = Stripe::Client.new(api_key: ENV["STRIPE_API_KEY"])
  # 
  # # Send invoice to the customer
  # sent_invoice = Stripe::Resources::Invoice.send(client, "in_12345")
  # 
  # # Send invoice with custom parameters
  # sent_invoice = Stripe::Resources::Invoice.send(
  #   client, 
  #   "in_12345",
  #   statement_descriptor: "Custom descriptor")
  # ```
  def self.send(client : Stripe::Client, id : String, **params) : JSON::Any
    client.request(:post, "/v1/invoices/#{id}/send", params)
  end

  # Voids an invoice.
  #
  # See Stripe API docs: https://docs.stripe.com/api/invoices/void
  #
  # ```
  # client = Stripe::Client.new(api_key: ENV["STRIPE_API_KEY"])
  # voided_invoice = Stripe::Resources::Invoice.void(client, "in_12345")
  # ```
  def self.void(client : Stripe::Client, id : String, **params) : JSON::Any
    client.request(:post, "/v1/invoices/#{id}/void", params)
  end

  # Marks an invoice as uncollectible.
  #
  # See Stripe API docs: https://docs.stripe.com/api/invoices/mark_uncollectible
  #
  # ```
  # client = Stripe::Client.new(api_key: ENV["STRIPE_API_KEY"])
  # uncollectible_invoice = Stripe::Resources::Invoice.mark_uncollectible(client, "in_12345")
  # ```
  def self.mark_uncollectible(client : Stripe::Client, id : String, **params) : JSON::Any
    client.request(:post, "/v1/invoices/#{id}/mark_uncollectible", params)
  end

  # Searches for invoices.
  #
  # See Stripe API docs: https://docs.stripe.com/api/invoices/search
  #
  # ```
  # client = Stripe::Client.new(api_key: ENV["STRIPE_API_KEY"])
  # 
  # # Search for paid invoices
  # result = Stripe::Resources::Invoice.search(
  #   client,
  #   query: "status:'paid'"
  # )
  # ```
  def self.search(client : Stripe::Client, **params) : JSON::Any
    client.request(:get, "/v1/invoices/search", params)
  end
  
  # Retrieves the PDF invoice URL for a finalized invoice.
  # This URL can be used to display a PDF invoice to the customer or generate a download link.
  # Note: The invoice must be finalized before a PDF URL is available.
  #
  # See Stripe API docs: https://docs.stripe.com/api/invoices/object#invoice_object-hosted_invoice_url
  #
  # ```
  # client = Stripe::Client.new(api_key: ENV["STRIPE_API_KEY"])
  # 
  # # Get the PDF URL for a finalized invoice
  # pdf_url = Stripe::Resources::Invoice.pdf_url(client, "in_12345")
  # ```
  def self.pdf_url(client : Stripe::Client, id : String) : String?
    invoice = retrieve(client, id)
    
    # Fully defensive approach with nested try blocks
    begin
      if url = invoice["hosted_invoice_url"]?
        url.as_s?
      else
        nil
      end
    rescue
      # If any error occurs during retrieval or type casting, return nil
      nil
    end
  end

  # Downloads the invoice PDF content. Returns the binary PDF data that can be written to a file.
  # Note: The invoice must be finalized before a PDF is available.
  #
  # ```
  # client = Stripe::Client.new(api_key: ENV["STRIPE_API_KEY"])
  # 
  # # Download PDF content for a finalized invoice
  # pdf_content = Stripe::Resources::Invoice.pdf(client, "in_12345")
  # 
  # # Save the PDF to a file
  # File.write("invoice.pdf", pdf_content) if pdf_content
  # ```
  def self.pdf(client : Stripe::Client, id : String) : Bytes?
    url = pdf_url(client, id)
    return nil unless url
    
    # Create a standard HTTP client to download the PDF
    uri = URI.parse(url)
    http = HTTP::Client.new(uri)
    http.get(uri.request_target).body.to_slice
  end

  # Sends the invoice to the customer via email.
  #
  # See Stripe API docs: https://docs.stripe.com/api/invoices/send
  #
  # ```
  # client = Stripe::Client.new(api_key: ENV["STRIPE_API_KEY"])
  # 
  # # Send invoice to customer via email
  # sent_invoice = Stripe::Resources::Invoice.send_email(client, "in_12345")
  # ```
  # 
  # Note: Custom statement descriptors and email messages are not directly supported
  # by the Stripe API. To customize these, configure your email templates in the Stripe Dashboard.
  def self.send_email(client : Stripe::Client, id : String) : JSON::Any
    # Simply call the send method with no additional parameters
    send(client, id)
  end
end
