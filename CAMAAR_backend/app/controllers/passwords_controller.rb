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
    email = params[:email]
    
    unless email.present?
      return render json: { 
        error: 'Email é obrigatório' 
      }, status: :bad_request
    end
    
    user = User.find_by(email: email)
    
    if user
      result = EmailService.send_password_reset_email(user)
      
      if result[:success]
        render json: { 
          message: 'Email de redefinição enviado com sucesso' 
        }, status: :ok
      else
        render json: { 
          error: 'Erro ao enviar email de redefinição' 
        }, status: :internal_server_error
      end
    else
      # Por segurança, sempre retornar sucesso mesmo se o usuário não existir
      render json: { 
        message: 'Se o email estiver cadastrado, você receberá instruções para redefinir sua senha' 
      }, status: :ok
    end
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
    token = params[:token]
    email = params[:email]
    password = params[:password]
    password_confirmation = params[:password_confirmation]
    
    unless token.present? && email.present? && password.present? && password_confirmation.present?
      return render json: { 
        error: 'Token, email, senha e confirmação de senha são obrigatórios' 
      }, status: :bad_request
    end
    
    unless password == password_confirmation
      return render json: { 
        error: 'As senhas não coincidem' 
      }, status: :unprocessable_entity
    end
    
    user = User.find_by(email: email)
    
    unless user
      return render json: { 
        error: 'Usuário não encontrado' 
      }, status: :not_found
    end
    
    # Verificar se o token é válido
    if user.reset_password_token == token
      if user.update(password: password)
        # Limpar o token após uso
        user.update_column(:reset_password_token, nil)
        
        render json: { 
          message: 'Senha redefinida com sucesso' 
        }, status: :ok
      else
        render json: { 
          error: 'Erro ao redefinir senha',
          details: user.errors.full_messages
        }, status: :unprocessable_entity
      end
    else
      render json: { 
        error: 'Token inválido ou expirado' 
      }, status: :unprocessable_entity
    end
  end
  
  # POST /passwords/set-first - Para usuários que estão definindo senha pela primeira vez
  def set_first_password
    token = params[:token]
    email = params[:email]
    password = params[:password]
    password_confirmation = params[:password_confirmation]
    
    unless token.present? && email.present? && password.present? && password_confirmation.present?
      return render json: { 
        error: 'Token, email, senha e confirmação de senha são obrigatórios' 
      }, status: :bad_request
    end
    
    unless password == password_confirmation
      return render json: { 
        error: 'As senhas não coincidem' 
      }, status: :unprocessable_entity
    end
    
    user = User.find_by(email: email)
    
    unless user
      return render json: { 
        error: 'Usuário não encontrado' 
      }, status: :not_found
    end
    
    # Verificar se o token é válido e se o usuário precisa definir senha
    if user.first_access_token == token && user.needs_password_reset?
      if user.update(password: password)
        # Limpar o token após uso
        user.update_column(:first_access_token, nil)
        
        render json: { 
          message: 'Senha definida com sucesso',
          user: {
            id: user.id,
            email: user.email,
            name: user.name,
            role: user.role
          }
        }, status: :ok
      else
        render json: { 
          error: 'Erro ao definir senha',
          details: user.errors.full_messages
        }, status: :unprocessable_entity
      end
    else
      render json: { 
        error: 'Token inválido, expirado ou usuário já possui senha definida' 
      }, status: :unprocessable_entity
    end
  end
  
  # GET /passwords/test-email - Para testar configuração de email (apenas em desenvolvimento)
  def test_email
    if Rails.env.development?
      email = params[:email] || 'test@example.com'
      
      begin
        # Criar um usuário temporário para teste
        test_user = User.new(
          name: 'Usuário de Teste',
          email: email,
          registration: 'TEST001',
          role: 'student'
        )
        
        # Tentar enviar email
        UserMailer.first_access_email(test_user, 'token-de-teste').deliver_now
        
        render json: { 
          message: 'Email de teste enviado com sucesso!',
          email: email,
          status: 'success'
        }, status: :ok
      rescue => e
        render json: { 
          error: 'Erro ao enviar email de teste',
          details: e.message,
          status: 'error'
        }, status: :internal_server_error
      end
    else
      render json: { 
        error: 'Endpoint disponível apenas em desenvolvimento' 
      }, status: :forbidden
    end
  end
end
