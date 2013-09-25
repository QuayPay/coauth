class UserMailer < ActionMailer::Base
  default from: "no-reply@quaypay.com"

def welcome_email(user)
    @user = user
    
    mail(to: (user.email || 'cam@quaypay.com'), subject: 'Welcome to QuayPay')
  end
end
