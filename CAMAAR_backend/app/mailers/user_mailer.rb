class UserMailer < ApplicationMailer
  helper :application # Inclui helpers padrão

  def send_set_password_email(user)
    @user = user
    @set_password_url = "https://camaar.com/reset_password?token=#{user.reset_password_token}"
    mail(
      to: @user.email,
      subject: 'Configure sua senha para acessar o sistema CAMAAR'
    )
  end
end
