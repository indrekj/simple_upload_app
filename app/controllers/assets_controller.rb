class AssetsController < ApplicationController
  before_filter :admin?, :only => [:update, :destroy]

  # GET /assets
  def index
    respond_to do |format|
      format.html do
        @asset ||= Asset.new
        @categories = Category.all
      end

      format.json do
        @category = Category.find(params[:category_id])
        @assets = @category.assets.find(:all, :select => "id, title, author, year", 
                                        :order => "LOWER(title) ASC, year DESC")
        @assets.each {|a| a[:url] = asset_path(a)}
        render :json => {:category => @category.name, :assets => @assets}.to_json
      end
    end
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
      flash[:notice] = "Fail edukalt lisatud"
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

  def category
    index
    render :action => 'index'
    # TODO
    #@categories = @categories.select {|c| c == params[:name].downcase}
    #render :action => 'index'
  end
end
