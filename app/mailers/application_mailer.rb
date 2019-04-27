class ApplicationMailer < ActionMailer::Base
  default from: 'noreply@also.fm'
  layout 'mailer'

  self.default_url_options = {host: 'also.fm', https: true}
end
