class UserMailer < ApplicationMailer
  def send_password_email
    @user = params[:user]
    mail(
      to: @user.email,
      subject: 'Bem-vindo ao sistema CAMAAR!'
    )
  end
end
