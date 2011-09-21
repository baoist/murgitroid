class CodesController < ApplicationController
  def imageset
    @images = page_images(params[:current_page])
  end

  before_filter :imageset
  # GET /codes
  # GET /codes.json
  def index
    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def page
    @code = Code.new

    puts encode_message(1, "Q", "S", "This is a test")
    puts decode_message(1, "Q", "S", "B6RQR QCBDQ B")
    respond_to do |format|
      format.html # page.html.erb
    end
  end

  def encode
    @code = Code.new(params[:code])
    @code.save

    respond_to do |format|
      format.html { redirect_to(page_url + "#code", :coded => "foo") }
      format.json { render :json => { :coded => "foo"} }
    end
  end

  def retrieve
    @dir = params[:directory]
    @files = files_from_dir("app/assets/images/" + @dir + "/*[.png|.jpg]")

    respond_to do |format|
      format.json { render :json => @files }
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
