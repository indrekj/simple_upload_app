class AssessmentsController < ApplicationController
  protect_from_forgery :except => [:create, :update]
  before_filter :admin?, :only => [:destroy]

  # GET /assessments
  def index
    respond_to do |format|
      format.html do
        @categories = Category.all
      end

      format.json do
        @category = Category.find(params[:category_id])
        @assessments = @category.assessments.confirmed.
          select("id, title, author, year").
          order("LOWER(title) ASC, year DESC").all
        @assessments.each {|a| a[:assessment_path] = assessment_url(a)}
        render :json => {:category => @category.name, :assessments => @assessments}.to_json
      end
    end
  end

  # GET /assessments/exists
  def exists
    source = params[:source]
    id = params[:attempt_id]
    assessment = Assessment.select("id").where(:source => source, :attempt_id => id)

    if assessment.exists?
      render :json => {:exists => true}
    else
      render :json => {:exists => false}
    end
  end

  # GET /assessments/new
  def new
    @assessment = Assessment.new
    render :layout => false
  end

  # GET /assessments/:id
  def show
    @assessment = Assessment.find(params[:id])
    body = @assessment.body.to_s
    unless body.match(/html/)
      body = body.gsub("\n", "<br/>")
    end
    render :text => body, :layout => false
  end

  # POST /assessments
  def create
    @assessment = Assessment.new(params[:assessment])
    @assessment.creator_ip = request.remote_ip
    @assessment.test = params[:file]
    success = !!@assessment.save

    render :json => {
      :success => success, 
      :assessment => {
        :id => @assessment.id,
        :title => @assessment.title,
        :category_name => @assessment.category_name
      }
    }.to_json, :status => (success ? 200 : 409 ) 
  end

  # PUT /assessments/:id
  def update
    @assessment = Assessment.unconfirmed.find_by_id(params[:id])
    @assessment.confirmed = true
    @assessment.attributes = params[:assessment]
    success = !!@assessment.save

    cookies[:author] = @assessment.author

    render :json => {:success => success}.to_json, 
      :status => (success ? 200 : 409 ) 
  end

  # DELETE /assessments/:id
  def destroy
    @assessment = Assessment.find(params[:id])
    
    if @assessment.destroy
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
