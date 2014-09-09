class InvoiceDecorator < Draper::Decorator
  delegate :id, :attachment_url, :name, :date, :amount, :currency

  def attachment_url
    u = object.attachment_url

    if u.present?
      object.attachment_url.html_safe
    else
      helpers.asset_path('placeholder-portrait-450x600.jpg')
    end
  end

  def attachment_mime_type
    u = attachment_url

    if u.present?
      MimeMagic.by_path(URI.parse(u.html_safe).path).type
    else
      ''
    end

  end

  def name
    object.name || '-'
  end

  def date
    d = object.date

    if d.blank?
      '-'
    else
      Time.parse(d).to_formatted_s(:long_ordinal)
    end
  end

  def amount_with_currency
    c = object.currency
    a = object.amount

    if c.blank? or a.blank?
      '-'
    else
      currency = Money::Currency.new(c)
      money = Money.new(a * currency.subunit_to_unit, currency)
      "#{money.symbol}#{money.amount}"
    end
  end
end
