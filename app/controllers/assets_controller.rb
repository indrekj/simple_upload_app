class AssetsController < ApplicationController
  def index
    @drop = Dropio::Drop.find("it_inf")
    @assets = @drop.assets(1, "latest")
  end
end
