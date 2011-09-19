class CodesController < ApplicationController
  # GET /codes
  # GET /codes.json
  def index
    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def page
    respond_to do |format|
      format.html # page.html.erb
    end
  end

  def retrieve
    @dir = params[:directory]
    @files = Dir.glob(File.join(Rails.root, "app/assets/images/" + @dir + "/*"))
#   if @directory == "maps"
#     return ["images/maps/map-2.jpg", "images/maps/map-3.jpg", "images/maps/map-3.jpg", "images/maps/map-4.jpg", "images/maps/map-5.jpg", "images/maps/map-6.jpg", "images/maps/map-7.jpg"]
#   else
#     return ["images/assoc/people-2.png", "images/assoc/people-3.png", "images/assoc/people-4.png", "images/assoc/people-5.png", "images/assoc/people-6.png", "images/assoc/people-7.png"]
    respond_to do |format|
      format.json
    end
  end

=begin
  # GET /codes/1
  # GET /codes/1.json
  def show
    @code = Code.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @code }
    end
  end

  # GET /codes/new
  # GET /codes/new.json
  def new
    @code = Code.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @code }
    end
  end

  # GET /codes/1/edit
  def edit
    @code = Code.find(params[:id])
  end

  # POST /codes
  # POST /codes.json
  def create
    @code = Code.new(params[:code])

    respond_to do |format|
      if @code.save
        format.html { redirect_to @code, :notice => 'Code was successfully created.' }
        format.json { render :json => @code, :status => :created, :location => @code }
      else
        format.html { render :action => "new" }
        format.json { render :json => @code.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /codes/1
  # PUT /codes/1.json
  def update
    @code = Code.find(params[:id])

    respond_to do |format|
      if @code.update_attributes(params[:code])
        format.html { redirect_to @code, :notice => 'Code was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @code.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /codes/1
  # DELETE /codes/1.json
  def destroy
    @code = Code.find(params[:id])
    @code.destroy

    respond_to do |format|
      format.html { redirect_to codes_url }
      format.json { head :ok }
    end
  end
=end
end
