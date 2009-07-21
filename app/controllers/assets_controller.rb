class AssetsController < ApplicationController
  before_filter :admin?, :only => [:update, :destroy]

  # GET /assets
  def index
    @asset ||= Asset.new
    @assets = Asset.find(:all, :select => 'id, title, category, author, year', :order => 'LOWER(category) ASC, year DESC, LOWER(title) ASC')
    @categories = @assets.map(&:category).map(&:downcase)
  end

  # GET /assets/:id
  def show
    @asset = Asset.find(params[:id])
    body = @asset.body.to_s
    unless body.match(/html/)
      body = body.gsub("\n", '<br/>')
    end
    render :text => body, :layout => false
  end

  # POST /assets
  def create
    @asset = Asset.new(params[:asset])
    @asset.year = Time.now.strftime("%Y").to_i if params[:asset][:year].blank?
    @asset.creator_ip = request.remote_ip

    if @asset.save
      flash[:notice] = "Edukalt fail lisatud"
      @asset = nil
      redirect_to home_path
    else
      flash[:error] = "Shit happened"
      index
      render :action => 'index'
    end
  end

  # PUT /assets/:id
  def update
    @asset = Asset.find_by_id(params[:id])

    if @asset.update_attributes(params[:asset])
      render :json => @asset
    else
      render :json => @asset, :status => 409
    end
  end

  # DELETE /assets/:id
  def destroy
    @asset = Asset.find(params[:id])
    
    if @asset.destroy
      render :json => {:success => true}
    else
      render :json => {:success => false}
    end
  end
end
