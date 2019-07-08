require 'mail'

case ENV['RACK_ENV']
when "test"
when "development"
	Mail.defaults do
  	delivery_method :smtp, address: "localhost", port: 1025
	end
else
	Mail.defaults do
    delivery_method :smtp, {
    	:port      => 587,
      :address   => "smtp.mailgun.org",
      :user_name => Figaro.env.mail_username,
      :password  => Figaro.env.mail_password
    }
  end
end
