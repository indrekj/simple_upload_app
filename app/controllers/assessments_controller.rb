class AssessmentsController < ApplicationController
  before_filter :admin?, :only => [:update, :destroy]

  # GET /assessments
  def index
    respond_to do |format|
      format.html do
        @assessment ||= Assessment.new
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

  # GET /assessments/:id
  def show
    @assessment = Assessment.find(params[:id])
    body = @assessment.body.to_s
    unless body.match(/html/)
      body = body.gsub("\n", '<br/>')
    end
    render :text => body, :layout => false
  end

  # POST /assessments
  def create
    @assessment = Assessment.new(params[:assessment])
    @assessment.year = Time.now.strftime("%Y").to_i if params[:assessment][:year].blank?
    @assessment.creator_ip = request.remote_ip
    cookies[:author] = @assessment.author

    success = @assessment.save

    respond_to do |format|
      format.html { render :text => "No JS support?" }
      format.js   { render :json => {:success => success, :data => @assessment}.to_json }
      format.json { render :json => @assessment.to_json, :status => (success ? 200 : 409 ) }
    end
  end

  # PUT /assessments/:id
  def update
    @assessment = Assessment.find_by_id(params[:id])
    @assessment.confirmed = true
    @assessment.attributes = params[:assessment]
    success = @assessment.save
    @assessment[:assessment_path] = assessment_path(@assessment)

    respond_to do |format|
      format.html { render :text => "No JS support?" }
      format.js   { render :json => {:success => success, :data => @assessment}.to_json }
      format.json { render :json => @assessment.to_json, :status => (success ? 200 : 409 ) }
    end
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
