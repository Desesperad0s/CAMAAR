##
# Mailer responsável pelo envio de emails de acesso e redefinição de senha para usuários do sistema CAMAAR
#
# Métodos principais:
# - first_access_email: Envia email de primeiro acesso para o usuário
# - password_reset_email: Envia email de redefinição de senha
#
class UserMailer < ApplicationMailer
  default from: 'lucaslgol05@gmail.com'  

  ##
  # Envia email de primeiro acesso para o usuário
  #
  # === Argumentos
  # * +user+ - Objeto User que receberá o email
  # * +reset_token+ - Token de redefinição/primeiro acesso
  #
  # === Retorno
  # Email enviado para o usuário
  #
  # === Efeitos Colaterais
  # * Gera link de primeiro acesso com token
  # * Envia email para o usuário
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
    
    ##
    # Envia email de redefinição de senha para o usuário
    #
    # === Argumentos
    # * +user+ - Objeto User que receberá o email
    # * +reset_token+ - Token de redefinição de senha
    #
    # === Retorno
    # Email enviado para o usuário
    #
    # === Efeitos Colaterais
    # * Gera link de redefinição de senha com token
    # * Envia email para o usuário
    def password_reset_email(user, reset_token)
      @user = user
      @reset_token = reset_token
      @reset_url = "#{frontend_url}/redefinir-senha?token=#{@reset_token}&email=#{@user.email}"
      
    # TODO: to: @user.email
    mail(
      to: "231003406@aluno.unb.br",
      subject: 'CAMAAR - Redefinição de senha solicitada'
    )
  end
  
  private
  
  ##
  # Retorna a URL do frontend para geração de links nos emails
  #
  # === Argumentos
  # Nenhum argumento
  #
  # === Retorno
  # String - URL base do frontend
  #
  # === Efeitos Colaterais
  # Nenhum
  def frontend_url
    if Rails.application.config.respond_to?(:frontend_url) && Rails.application.config.frontend_url.present?
      Rails.application.config.frontend_url
    else
      'http://localhost:3000'
    end
  end
end
