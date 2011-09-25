ActionMailer::Base.smtp_settings = {
  :address          => "box678.bluehost.com",
  :port             => 465,
  :domain           => "its-supermurgitroid.com",
  :user_name        => "keen@its-supermurgitroid.com",
  :password         => "sw33t711!!",
  :authentication   => "plain",
  :enable_starttls_auto => true
}

#ActionMailer::Base.default_url_options[:host] = "brad.com:2323"
