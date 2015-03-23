class HomeController < ApplicationController
  helper_method :sort_column, :sort_direction

  def dashboard
    @pre_signed_post = KuluAWS.new.presigned_post

    if logged_in?
      @invoice = Invoice.new(url_prefix: @pre_signed_post.key)
      params[:token] = current_user_token
      @invoices = Invoice.list(request_params.merge(organization_name: request.subdomain))
    else
      render 'home/landing'
    end
  end

  def login
    set_current_user_token(KuluService::API.new.login(login_params)['token']) unless current_user_token
    redirect_to root_url
  end

  def signup
    KuluService::API.new.signup(signup_params)
    redirect_to root_url
  end

  private

  def sort_column
    %w(name amount currency remarks date expense_type status conflict).include?((params[:sort] || '').downcase) ? params[:sort] : 'created_at'
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ?  params[:direction] : 'desc'
  end

  def login_params
    params.permit(:team_name, :user_email, :user_name, :password)
  end

  def signup_params
    params.permit(:name, :user_email, :user_name, :password, :confirm)
  end

  def request_params
    params.permit(:order, :direction, :per_page, :page, :token)
  end
end
