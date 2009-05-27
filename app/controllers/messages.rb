class Messages < Application
  only_provides :json

  # GET /messages
  def index
    @messages = Message.find(:all, :limit => 10, :order => 'created_at DESC')
    display @messages
  end

  # GET /messages/:id
  def show
    @message = Message.find_by_id(params[:id])
    raise NotFound unless @message
    display @message
  end

  # POST /messages
  def create
    @message = Message.new(params[:message])
    if @message.save
      display @message
    else
      display @message.errors.full_messages
    end
  end

  # DELETE /messages/:id
  #def destroy
  #  @message = Message.find_by_id(params[:id])
  #  raise NotFound unless @message
  #  if @message.destroy
  #    redirect url(:messages)
  #  else
  #    raise BadRequest
  #  end
  #end
end
