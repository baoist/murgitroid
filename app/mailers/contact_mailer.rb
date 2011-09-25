class ContactMailer < ActionMailer::Base
  default :from => "keen@its-supermurgitroid.com"

  def user_email(information)
    mail(:to => information, :subject => "Official Message to Headquarters!")
  end
end
