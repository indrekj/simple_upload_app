require 'digest/sha2'
class Application < Merb::Controller
  before :check_admin

  protected

  def admin?
    session[:logged_in]
  end

  private

  def check_admin
    return if params[:pw].blank? || admin?

    pw = "f96679019bbe38d09fea7b103e4fea741a7c9d97f03264ae05317b0efee727d4446f969652ead86b75becc95c739e5ef881aab492a262c5043d084a20ac4e775"
    if Digest::SHA512.new.update(params[:pw]).to_s == pw
      session[:logged_in] = true
    else
      session[:logged_in] = false
    end
  end
end
