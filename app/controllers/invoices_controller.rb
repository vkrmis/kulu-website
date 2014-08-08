class InvoicesController < ApplicationController
  def create
    url_prefix, filename = params[:invoice].values_at(:url_prefix, :filename)
    invoice = Invoice.create(url_prefix, filename)

    if invoice.valid?
      redirect_to :root,
                  notice: "#{filename} has been uploaded and will be processed. Upload ID: #{invoice.invoice_id}"
    else
      render json: { error_messages: invoice.errors.full_messages }
    end
  end

  def index
    @invoices = Invoice.list
  end
end
