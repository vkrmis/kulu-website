class InvoicesController < ApplicationController
  before_filter :require_login, :set_organization
  skip_before_filter :require_login, :only => [:index, :dashboard, :search]
  helper_method :sort_column, :sort_direction

  def search
    if logged_in? and @organization_name.present?
      begin
        @params = search_params.reject { |_, v| v.blank? }
        @invoices = Invoice.search(api_params(@params))
      rescue HTTPService::ClientError
        flash.now[:error] = 'Could not populate any search results'
      end
    end

    if !logged_in? and @organization_name.blank?
      render 'static_pages/landing_page'
    end
  end

  def dashboard
    now = Date.current
    @from = params[:from] || (now - 30).iso8601
    @to = params[:to] || now.iso8601

    if logged_in? and @organization_name.present?
      begin
        @reports = Report.new(api_params(report_params.merge(from: @from, to: @to)))
        render 'home/dashboard'
      rescue HTTPService::ClientError
        logout # FIXME
      end
    end

    if !logged_in? and @organization_name.blank?
      render 'static_pages/landing_page'
    end
  end

  def index
    @pre_signed_post = KuluAWS.new.presigned_post
    if logged_in? and @organization_name.present?
      @invoice = Invoice.new(url_prefix: @pre_signed_post.key)

      begin
        @invoices = Invoice.list(api_params(request_params))
      rescue HTTPService::ClientError
        logout
      end
    end

    if !logged_in? and @organization_name.blank?
      render 'static_pages/landing_page'
    end
  end

  def create
    invoice = Invoice.create(api_params(create_params))
    if invoice.valid?
      redirect_to invoice_path(invoice.id)
    else
      render json: {error_messages: invoice.errors.full_messages}
    end
  end

  def show
    @invoice = Invoice.find(api_params(show_params)).decorate
    @page_params = params.slice(:direction, :order, :page, :per_page)
    @currencies = Currency.all
    @categories = select_categories(KuluService::API.new.categories(organization_name: @organization_name,
                                                                    token: current_user_token))
    @invoice_states =
        KuluService::API.new.list_of_states(organization_name: @organization_name, token: current_user_token)
    @invoices =
        Invoices.next_and_prev_invoices(api_params(params))
  end

  def update
    @invoice = Invoice.update(api_params(update_params))
    flash.notice = 'Expense successfully updated'
    render :nothing => true
  end

  def destroy
    Invoice.destroy(api_params(delete_params))
    redirect_to root_path, notice: 'Expense successfully deleted'
  end

  private

  def sort_column
    %w(name amount currency remarks date created_at expense_type status conflict user_name).include?((params[:order] || '').downcase) ? params[:order] : 'created_at'
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'desc'
  end

  def select_categories(categories)
    categories.inject({}) do |acc, v|
      map = {v['name'] => v['id']}
      acc.merge!(map)
      acc
    end
  end

  def set_organization
    @organization_name = request.subdomain if Subdomain.matches?(request)
  end

  def require_login
    redirect_to root_url unless logged_in? # halts request cycle
  end

  def api_params(base_params)
    base_params.merge(organization_name: @organization_name, token: current_user_token)
  end

  def create_params
    params.permit(invoice: [:url_prefix, :filename])
  end

  def update_params
    params.permit(:id, invoice: [:id, :name, :currency, :expense_type, :amount, :date, :status, :conflict, :remarks, :category_id])
  end

  def show_params
    params.permit(:id, :direction, :order)
  end

  def delete_params
    params.permit(:id)
  end

  def request_params
    params.permit(:order, :direction, :per_page, :page)
  end

  def search_params
    params.permit(:q, :order, :direction, :per_page, :page, :name, :amount, :currency, :from_date, :to_date,
                  :amount, :min_amount, :max_amount, :expense_type, :status, :conflict, :user_name, :category_name,
                  :from_submission_date, :to_submission_date)
  end

  def report_params
    params.permit(:from, :to)
  end
end
