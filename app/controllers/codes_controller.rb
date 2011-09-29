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
    @page = params[:current_page]
    @message = params[:message]
    user_agent = request.env['HTTP_USER_AGENT'].downcase
    puts user_agent
    puts 'foo'
    puts 'foo'
    puts 'foo'
    puts 'foo'
    puts 'foo'
    puts 'foo'
    puts 'foo'
    puts 'foo'
    puts 'foo'
    puts 'foo'
    puts 'foo'
    puts 'foo'
    puts user_agent.index('ipod')
    puts user_agent.index('iphone')
    puts user_agent.index('ipad')
    puts 'foo'
    puts 'foo'
    @agent = (user_agent == user_agent.index('ipod') or user_agent == user_agent.index('ipad') or user_agent == user_agent.index('iphone'))? 'iproduct' : nil
    puts @agent

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
  end
end
