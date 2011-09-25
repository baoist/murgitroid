ActionMailer::Base.smtp_settings = {
  :user_name => "baoist",
  :password => "02062591",
  :domain => "murgitroid.heroku.com",
  :address => "smtp.sendgrid.net",
  :port => 587,
  :authentication => :plain,
  :enable_starttls_auto => true
}

#ActionMailer::Base.default_url_options[:host] = "brad.com:2323"
