class Links < Application
  # GET /links
  def index
    @link ||= Link.new
    @links = Link.find(:all, :order => 'url ASC')
    render :template => 'links/index'
  end

  # POST /links
  def create
    @link = Link.new(params[:link])
    @link.creator_ip = request.remote_ip
    if @link.save
      @_message = "Edukalt link lisatud"
      @link = nil
      redirect '/links', :message => @_message
    else
      @_message = "Shit happened"
      index
    end
  end

  # GET /links/:id/delete
  def delete
    render
  end
end
