require 'digest/sha2'
class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :check_admin

  protected

  helper_method :admin?
  def admin?
    session[:logged_in]
  end

  private

  def check_admin
    return if params[:pw].blank? || admin?

    if Digest::SHA512.hexdigest(params[:pw]) == YAML.load_file(Rails.root.to_s + '/config/password.yml')[:password]
      session[:logged_in] = true
    else
      session[:logged_in] = false
    end
  end
end
