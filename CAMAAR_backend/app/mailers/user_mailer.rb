class UserMailer < ApplicationMailer
  default from: 'lucaslgol05@gmail.com'  

  def first_access_email(user, reset_token)
    @user = user
    @reset_token = reset_token
    @reset_url = "#{frontend_url}/nova-senha?token=#{@reset_token}&email=#{@user.email}"
    
    # TODO: to: @user.email
    mail(
      to: "231003406@aluno.unb.br",
      subject: 'Bem-vindo ao CAMAAR - Defina sua senha de acesso'
    )
  end

  def password_reset_email(user, reset_token)
    @user = user
    @reset_token = reset_token
    @reset_url = "#{frontend_url}/redefinir-senha?token=#{@reset_token}&email=#{@user.email}"
    
    mail(
      to: @user.email,
      subject: 'CAMAAR - Redefinição de senha solicitada'
    )
  end
  
  private
  
  def frontend_url
    if Rails.application.config.respond_to?(:frontend_url) && Rails.application.config.frontend_url.present?
      Rails.application.config.frontend_url
    else
      'http://localhost:3000'
    end
  end
end
