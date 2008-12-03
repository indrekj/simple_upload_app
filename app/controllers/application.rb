class Application < Merb::Controller
  before :admin?

  def admin?
    false
  end
end
