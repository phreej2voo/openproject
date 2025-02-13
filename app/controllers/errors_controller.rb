class ErrorsController < ApplicationController
  include ErrorsHelper
  include OpenProjectErrorHelper
  include Accounts::CurrentUser

  no_authorization_required! :not_found, :unacceptable, :internal_error
  skip_before_action :check_if_login_required

  def not_found
    render_404
  end

  def unacceptable
    render file: "#{Rails.public_path.join('422.html')}",
           status: :unacceptable,
           layout: false
  end

  def internal_error
    render_500 error_options
  end

  private

  def error_options
    {
      exception: request.env["action_dispatch.exception"]
    }.compact
  end

  def use_layout
    "only_logo"
  end
end
