class InvoicesController < ApplicationController
  def create
    url_prefix, filename = params[:invoice].values_at(:url_prefix, :filename)
    invoice = Invoice.new(url_prefix: url_prefix, filename: filename)
    KuluService.new.create_invoice(invoice.storage_key)

    redirect_to :root, notice: "#{filename} has been uploaded and will be processed."
  end
end
