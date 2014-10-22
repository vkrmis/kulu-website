require 'net/http'

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
      pathmime = MimeMagic.by_path(URI.parse(u.html_safe).path)
      if !pathmime.nil?
        pathmime.type
      end
    else
      ''
    end
  end

  def name
    object.name || '-'
  end

  def display_date
    formatted_date('%d %b %Y')
  end

  def input_date
    formatted_date('%d-%m-%Y')
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

  private

  def formatted_date(format)
    d = object.date

    if d.blank?
      '-'
    else
      Date.parse(d).strftime(format)
    end
  end
end
