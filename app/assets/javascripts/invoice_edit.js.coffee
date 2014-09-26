class Kulu.InvoiceEdit
  constructor: (@formContainer) ->
    @updateButton = @formContainer.find(".invoice-edit-submit")
    @invoiceID = @formContainer.find('input[name="invoice-id"]').val()
    @dateGroup = @formContainer.find('.invoice-details-date-group')

    @updateButton.click (e) =>
      e.preventDefault()
      @formSubmit()

  isDateValid: () =>
    dateInput = @dateGroup.find(".invoice-details-date")
    moment($(dateInput).val(), "DD-MM-YYYY").isValid()

  formSubmit: () =>
    unless @isDateValid()
      @dateGroup.addClass('has-error')
      return false

    data = {
      name: @formContainer.find('input[name="invoice[:name]"]').val()
      currency: @formContainer.find('select[name="invoice[:currency]"]').val()
      amount: Number(@formContainer.find('input[name="invoice[:amount]"]').val())
      date: @formContainer.find('input[name="invoice[:date]"]').val()
    }

    $.ajax(
      type: "PUT"
      url: Routes.invoice_path({id: @invoiceID})
      data: JSON.stringify({invoice: data})
      contentType: "application/json"
    )
