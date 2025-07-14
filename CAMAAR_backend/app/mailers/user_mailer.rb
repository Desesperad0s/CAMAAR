class UserMailer < Devise::Mailer
  helper :application # Inclui helpers padrão
  include Devise::Controllers::UrlHelpers # Inclui helpers do Devise
  default template_path: 'devise/mailer' # Usa os templates padrão do Devise

  def send_set_password_email(user)
    @user = user
    @set_password_url = edit_user_password_url(@user, reset_password_token: @user.send(:set_reset_password_token))
    mail(
      to: @user.email,
      subject: 'Configure sua senha para acessar o sistema CAMAAR'
    )
  end
end
