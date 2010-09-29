class AssetsController < ApplicationController
  def index
    @drop = Dropio::Drop.find("it_inf")
    @assets = @drop.assets(1, "latest")
  end

  def show
    @drop = Dropio::Drop.find("it_inf")
    @asset = Dropio::Asset.find(@drop, params[:id])
    render :layout => false
  end
end
