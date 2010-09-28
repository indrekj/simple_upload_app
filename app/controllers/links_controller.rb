class LinksController < ApplicationController
  # GET /links
  def index
    @link ||= Link.new
    @links = Link.order('url ASC').all
  end
    
  # POST /links
  def create
    @link = Link.new(params[:link])
    @link.creator_ip = request.remote_ip

    if @link.save
      @link = nil
      redirect_to links_path, :notice => "Edukalt link lisatud"
    else
      index
      flash.now[:alert] = "Shit happened"
      render :action => "index"
    end
  end
    
  # GET /links/:id/delete
  def delete
    redirect_to links_path
  end
end
