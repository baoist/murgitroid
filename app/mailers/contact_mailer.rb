class ContactMailer < ActionMailer::Base
  default :from => "keen@its-supermurgitroid.com"

  def user_email(email)
    mail(:to => email, :subject => "Official Message to Headquarters!")
  end

  def admin_email(information)
    @info = information
    mail(:to => "keen@its-supermurgitroid.com", :subject => "Someone has contact you from your site!")
  end
end
