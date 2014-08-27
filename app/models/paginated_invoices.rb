class PaginatedInvoices < Kaminari::PaginatableArray
  PAGINATION_KEYS = %w{page per_page total_pages total_count}

  def initialize(raw_data)
    invoices = raw_data['items'].map {|i| Invoice.new(i).decorate }
    @page, @limit, @total_pages, total_count = raw_data['meta'].values_at(*PAGINATION_KEYS)

    super(invoices, total_count: total_count)
  end

  def current_page
    @page
  end

  def total_pages
    @total_pages
  end

  def limit_value
    @limit
  end

  def offset_value
    (current_page - 1) * limit_value
  end

  def last_page?
    current_page == total_pages
  end
end