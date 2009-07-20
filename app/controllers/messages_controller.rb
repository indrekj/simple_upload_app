class MessagesController < ApplicationController
  # GET /messages
  def index
    @messages = Message.find(:all, :limit => 10, :order => 'created_at DESC')
    render :json => @messages
  end
  
  # GET /messages/:id
  def show
    @message = Message.find(params[:id])
    render :json => @message
  end 

  # POST /messages
  def create
    @message = Message.new(params[:message])
    if @message.save
      render :json => @message.to_json
    else
      render :json => @message.errors.full_messages.to_json
    end
  end
end
