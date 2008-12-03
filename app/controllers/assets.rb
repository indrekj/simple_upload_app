class Assets < Application
  # GET /assets
  def index
    @asset ||= Asset.new
    @assets = Asset.find(:all, :order => 'category, created_at DESC')
    render :template => 'assets/index'
  end

  # GET /assets/:id
  def show
    @asset = Asset.find(params[:id])
    render
  end

  # POST /assets
  def create
    @asset = Asset.new(params[:asset])
    @asset.year = Time.now.strftime("%Y").to_i if params[:asset][:year].blank?
    @asset.file = params[:asset][:file][:path] rescue nil
    if @asset.save
      @_message = "Edukalt fail lisatud"
    else
      @_message = "Shit happened"
    end
    index
  end

  # GET /assets/:id/delete
  def delete
    render
  end
end
