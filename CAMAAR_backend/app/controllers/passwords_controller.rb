class PasswordsController < ApplicationController
  skip_before_action :authenticate_request
  
  ##
  # Inicia o processo de recuperação de senha
  #
  # === Argumentos
  # * +email+ - Email do usuário que esqueceu a senha (implícito nos params)
  #
  # === Retorno
  # Atualmente não implementado - método vazio
  #
  # === Efeitos Colaterais
  # Nenhum - método ainda não implementado
  # Quando implementado, deve:
  # * Enviar email de recuperação de senha
  # * Gerar token de redefinição
  def forgot
    
  end
  
  ##
  # Processa a redefinição de senha com token válido
  #
  # === Argumentos
  # * +token+ - Token de redefinição de senha (implícito nos params)
  # * +password+ - Nova senha do usuário (implícito nos params)
  # * +password_confirmation+ - Confirmação da nova senha (implícito nos params)
  #
  # === Retorno
  # Atualmente não implementado - método vazio
  #
  # === Efeitos Colaterais
  # Nenhum - método ainda não implementado
  # Quando implementado, deve:
  # * Validar token de redefinição
  # * Atualizar senha do usuário
  # * Invalidar token usado
  def reset
  end
end
