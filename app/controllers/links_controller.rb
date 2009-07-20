class LinksController < ApplicationController
  # GET /links
  def index
    @link ||= Link.new
    @links = Link.find(:all, :order => 'url ASC')
  end
    
  # POST /links
  def create
    @link = Link.new(params[:link])
    @link.creator_ip = request.remote_ip

    if @link.save
      flash[:notice] = "Edukalt link lisatud"
      @link = nil
      redirect '/links'
    else
      flash[:error] = "Shit happened"
      index
      render :action => 'index'
    end
  end
    
  # GET /links/:id/delete
  def delete
    redirect_to links_path
  end
end
