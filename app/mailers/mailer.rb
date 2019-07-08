require 'mail'
require './app/models/organisation_manager/user'

class Mailer
  def send_confirmation_mail(user, context)
    mail = Mail.deliver do
      from     'support@sandbox699fcebe40314a1c83be87824e008ebc.mailgun.org'
      to       user.email
      subject  'Please confirm your account'

      html_part do
        content_type 'text/html; charset=UTF-8'
        body    ERB.new(File.read('app/views/mailer/confirmation_instructions.html.erb')).result(context)
      end
    end
  end

  def send_reset_password_mail(user, context)
    mail = Mail.deliver do
      from     'support@sandbox699fcebe40314a1c83be87824e008ebc.mailgun.org'
      to       user.email
      subject  'Reset password instructions'

      html_part do
        content_type 'text/html; charset=UTF-8'
        body     ERB.new(File.read('app/views/mailer/reset_password_instructions.html.erb')).result(context)
      end
    end
  end

  def send_invitation_mail(user, context)
    mail = Mail.deliver do
      from    'support@sandbox699fcebe40314a1c83be87824e008ebc.mailgun.org'
      to      user.email
      subject 'Invitation'

      html_part do
        content_type 'text/html; charset=UTF-8'
        body     ERB.new(File.read('app/views/mailer/confirmation_instructions.html.erb')).result(context)
      end
    end
  end

  def send_transfer_ownership_mail(user, context)
    mail = Mail.deliver do
      from    'support@sandbox699fcebe40314a1c83be87824e008ebc.mailgun.org'
      to      user.email
      subject 'Transfer Ownership'

      html_part do
        content_type 'text/html; charset=UTF-8'
        body     ERB.new(File.read('app/views/mailer/transfer_ownership_instructions.html.erb')).result(context)
      end
    end
  end
end
