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
    @message = params[:message]

    respond_to do |format|
      format.html # page.html.erb
    end
  end

  def encode
    @code = Code.new(params[:code])
    @code.message_coded = encode_message(@code.master, @code.key_a, @code.key_b, @code.message)
    @code.ip = request.remote_ip
    @message = @code

    @code.save if @code.message_coded

    respond_to do |format|
      if @message.message_coded
        format.html { render :action => "page", :current_page => @message }
        format.json { render :json => { :status => "success", :coded => @message } }
      else
        format.html { redirect_to page_url + "/code" }
        format.json { render :json => { :status => "error" } }
      end
    end
  end

  def decoded
    @code = Code.new
    @decoded = decode_message(params[:decode_master], params[:decode_key_a], params[:decode_key_b], params[:decode_message])

    respond_to do |format|
      if @decoded
        format.html { render :action => "page", :current_page => "decoded" }
        format.json { render :json => { :status => "success", :message => @decoded } }
      else
        format.html { redirect_to page_url + "/decode" }
        format.json { render :json => { :status => "error" } }
      end
    end
  end

  def retrieve
    @dir = params[:directory]
    @files = files_from_dir("app/assets/images/" + @dir + "/*[.png|.jpg]")

    respond_to do |format|
      format.json { render :json => @files }
    end
  end

  def contact
    @contact = Contact.new(params[:contact])

    if @contact.captcha.gsub(/[^0-9A-Za-z]/, '').capitalize == "Ovaltine"
      @contact.save

      ContactMailer.user_email(@contact.email).deliver if @contact.email != ""
      ContactMailer.admin_email(@contact).deliver

      respond_to do |format|
        format.html { redirect_to(page_url + "#contact") }
        format.json { render :json => { :status => "success" } }
      end
    else
      respond_to do |format|
        format.html { redirect_to(page_url + "#contact") }
        format.json { render :json => { :status => "error" } }
      end
    end
    #ContactMailer.send_user().deliver
    #ContactMailer.send_admin("iam@brad.io").deliver
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
