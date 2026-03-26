class QuickbooksService
  BASE_URL = {
    'sandbox' => 'https://sandbox-quickbooks.api.intuit.com',
    'production' => 'https://quickbooks.api.intuit.com'
  }.freeze

  def initialize(user)
    @user = user
    @token = user.quick_books_token
    raise "QuickBooks not connected" unless @token

    refresh_token_if_needed!
  end

  # Create or update customer in QuickBooks
  def sync_customer(customer_user)
    qb_customer_id = customer_user.quickbooks_customer_id

    if qb_customer_id
      update_customer(qb_customer_id, customer_user)
    else
      create_customer(customer_user)
    end
  end

  # Create invoice for completed appointment
  def create_invoice(appointment)
    customer_qb_id = appointment.customer.quickbooks_customer_id

    # Ensure customer exists in QB first
    unless customer_qb_id
      customer_qb_id = sync_customer(appointment.customer)
    end

    invoice_data = build_invoice_data(appointment, customer_qb_id)
    response = make_request(:post, '/v3/company/:realmId/invoice', invoice_data)

    if response['Invoice']
      invoice = response['Invoice']
      appointment.update(quickbooks_invoice_id: invoice['Id'])
      invoice['Id']
    else
      Rails.logger.error "Failed to create invoice: #{response}"
      nil
    end
  end

  # Record payment for invoice
  def record_payment(appointment, payment_amount, payment_method = 'Square')
    return unless appointment.quickbooks_invoice_id

    payment_data = {
      TotalAmt: payment_amount / 100.0,
      CustomerRef: { value: appointment.customer.quickbooks_customer_id },
      Line: [{
        Amount: payment_amount / 100.0,
        LinkedTxn: [{
          TxnId: appointment.quickbooks_invoice_id,
          TxnType: "Invoice"
        }]
      }],
      PaymentMethodRef: { name: payment_method }
    }

    response = make_request(:post, '/v3/company/:realmId/payment', payment_data)

    if response['Payment']
      payment = response['Payment']
      appointment.update(quickbooks_payment_id: payment['Id'])
      payment['Id']
    else
      Rails.logger.error "Failed to record payment: #{response}"
      nil
    end
  end

  private

  def create_customer(customer_user)
    customer_data = {
      DisplayName: customer_user.name || customer_user.email,
      PrimaryEmailAddr: { Address: customer_user.email }
    }

    response = make_request(:post, '/v3/company/:realmId/customer', customer_data)

    if response['Customer']
      customer = response['Customer']
      customer_user.update(quickbooks_customer_id: customer['Id'])
      customer['Id']
    else
      Rails.logger.error "Failed to create customer: #{response}"
      nil
    end
  end

  def update_customer(qb_customer_id, customer_user)
    existing = make_request(:get, "/v3/company/:realmId/customer/#{qb_customer_id}")
    return nil unless existing['Customer']

    customer_data = {
      Id: qb_customer_id,
      SyncToken: existing['Customer']['SyncToken'],
      DisplayName: customer_user.name || customer_user.email,
      PrimaryEmailAddr: { Address: customer_user.email }
    }

    response = make_request(:post, '/v3/company/:realmId/customer', customer_data)
    response['Customer'] ? qb_customer_id : nil
  end

  def build_invoice_data(appointment, customer_qb_id)
    line_items = []

    # Main service line item with tax
    line_items << {
      DetailType: "SalesItemLineDetail",
      Amount: appointment.base_service_price,
      Description: appointment.selected_service,
      SalesItemLineDetail: {
        Qty: 1,
        UnitPrice: appointment.base_service_price,
        ItemRef: { name: appointment.selected_service },
        TaxCodeRef: { value: "TAX" }
      }
    }

    # Add-ons with tax
    appointment.appointment_add_ons.includes(:service).each do |appointment_add_on|
      line_items << {
        DetailType: "SalesItemLineDetail",
        Amount: appointment_add_on.final_price / 100.0,
        Description: appointment_add_on.final_name,
        SalesItemLineDetail: {
          Qty: 1,
          UnitPrice: appointment_add_on.final_price / 100.0,
          ItemRef: { name: appointment_add_on.final_name },
          TaxCodeRef: { value: "TAX" }
        }
      }
    end

    {
      CustomerRef: { value: customer_qb_id },
      Line: line_items,
      TxnDate: appointment.time.strftime('%Y-%m-%d'),
      DueDate: appointment.time.strftime('%Y-%m-%d'),
      TxnTaxDetail: {
        TxnTaxCodeRef: { value: "2" }
      }
    }
  end

  def make_request(method, path, body = nil)
    url = "#{base_url}#{path.gsub(':realmId', @token.realm_id)}"

    headers = {
      'Authorization' => "Bearer #{@token.access_token}",
      'Accept' => 'application/json',
      'Content-Type' => 'application/json'
    }

    response = case method
    when :get
      HTTParty.get(url, headers: headers)
    when :post
      HTTParty.post(url, headers: headers, body: body.to_json)
    end

    JSON.parse(response.body)
  rescue => e
    Rails.logger.error "QuickBooks API error: #{e.message}"
    {}
  end

  def base_url
    environment = QUICKBOOKS_CONFIG[:environment]
    BASE_URL[environment] || BASE_URL['sandbox']
  end

  def refresh_token_if_needed!
    return unless @token.expired?

    oauth_client = OAuth2::Client.new(
      QUICKBOOKS_CONFIG[:client_id],
      QUICKBOOKS_CONFIG[:client_secret],
      site: QUICKBOOKS_CONFIG[:auth_url],
      token_url: QUICKBOOKS_CONFIG[:token_url]
    )

    access_token = OAuth2::AccessToken.new(
      oauth_client,
      @token.access_token,
      refresh_token: @token.refresh_token
    )

    new_token = access_token.refresh!

    @token.update!(
      access_token: new_token.token,
      refresh_token: new_token.refresh_token,
      expires_at: Time.current + new_token.expires_in.seconds
    )
  rescue => e
    Rails.logger.error "Token refresh failed: #{e.message}"
    raise "QuickBooks token expired. Please reconnect."
  end
end
