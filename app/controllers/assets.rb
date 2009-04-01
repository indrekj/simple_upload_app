class Assets < Application
  # GET /assets
  def index
    @asset ||= Asset.new
    @assets = Asset.find(:all, :order => 'LOWER(category) ASC, year DESC, LOWER(title) ASC')
    render :template => 'assets/index'
  end

  # GET /assets/:id
  def show
    @asset = Asset.find(params[:id])
    body = @asset.body.to_s
    unless body.match(/html/)
      body = body.gsub("\n", '<br/>')
    end
    render body, :layout => false
  end

  # POST /assets
  def create
    @asset = Asset.new(params[:asset])
    @asset.year = Time.now.strftime("%Y").to_i if params[:asset][:year].blank?
    if file = params[:file]
      @asset.tempfile = file[:tempfile]
      @asset.filesize = file[:size]
      @asset.filename = file[:filename]
      @asset.content_type = file[:content_type]
    end
    @asset.creator_ip = request.remote_ip
    if @asset.save
      @_message = "Edukalt fail lisatud"
      @asset = nil
      redirect '/', :message => @_message
    else
      @_message = "Shit happened"
      index
    end
  end

  # GET /assets/:id/delete
  def delete
    render
  end
end
