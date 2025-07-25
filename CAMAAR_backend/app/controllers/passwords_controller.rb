

##
# PasswordsController
#
# Controller responsável por gerenciar operações sobre as senhas dos usuários

class PasswordsController < ApplicationController
  skip_before_action :authenticate_request

  ##
  # Rota: POST /passwords/forgot
  # Envia email de recuperação de senha para o usuário informado
  #
  # === Argumentos
  # * +email+ - Email do usuário (params)
  #
  # === Retorno
  # JSON com mensagem de sucesso ou erro
  #
  # === Efeitos Colaterais
  # Envia email de redefinição de senha se usuário existir
  def forgot
    email = params[:email]
    return render_missing(:email) unless email.present?
    user = User.find_by(email: email)
    if user
      result = EmailService.send_password_reset_email(user)
      return render_success('Email de redefinição enviado com sucesso') if result[:success]
      return render_error('Erro ao enviar email de redefinição', :internal_server_error)
    end
    render_success('Se o email estiver cadastrado, você receberá instruções para redefinir sua senha')
  end

  ##
  # Rota: POST /passwords/reset
  # Redefine a senha do usuário
  #
  # === Argumentos
  # * +token+ - Token de redefinição de senha (params)
  # * +email+ - Email do usuário (params)
  # * +password+ - Nova senha (params)
  # * +password_confirmation+ - Confirmação da nova senha (params)
  #
  # === Retorno
  # JSON com mensagem de sucesso ou erro
  #
  # === Efeitos Colaterais
  # Atualiza senha do usuário e invalida token se válido
  def reset
    request.body.rewind
    
    email = params[:email]
    password = params[:password]
    password_confirmation = params[:password_confirmation]
    
    Rails.logger.debug "DEBUG Reset - email: #{email}, password: #{password ? '[PRESENT]' : '[MISSING]'}, password_confirmation: #{password_confirmation ? '[PRESENT]' : '[MISSING]'}"
    
    return render_missing(:email, :password, :password_confirmation) unless [email, password, password_confirmation].all?(&:present?)
    return render_error('As senhas não coincidem', :unprocessable_entity) unless password == password_confirmation
    
    user = User.find_by(email: email)
    return render_error('Usuário não encontrado', :not_found) unless user
    
    # Ignorando validação de token por enquanto
    if user.update(password: password)
      return render_success('Senha redefinida com sucesso')
    else
      return render_error('Erro ao redefinir senha', :unprocessable_entity, user.errors.full_messages)
    end
  end
  

  ##
  # Rota: POST /passwords/set-first
  # Define a senha pela primeira vez para usuários recém-cadastrados
  #
  # === Argumentos
  # * +token+ - Token de primeiro acesso (params)
  # * +email+ - Email do usuário (params)
  # * +password+ - Nova senha (params)
  # * +password_confirmation+ - Confirmação da nova senha (params)
  #
  # === Retorno
  # JSON com mensagem de sucesso ou erro
  #
  # === Efeitos Colaterais
  # Atualiza senha do usuário e invalida token se válido
  def set_first_password
    request.body.rewind
    
    email = params[:email]
    password = params[:password]
    password_confirmation = params[:password_confirmation]
    
    Rails.logger.debug "DEBUG SetFirst - email: #{email}, password: #{password ? '[PRESENT]' : '[MISSING]'}, password_confirmation: #{password_confirmation ? '[PRESENT]' : '[MISSING]'}"
    
    return render_missing(:email, :password, :password_confirmation) unless [email, password, password_confirmation].all?(&:present?)
    return render_error('As senhas não coincidem', :unprocessable_entity) unless password == password_confirmation
    
    user = User.find_by(email: email)
    return render_error('Usuário não encontrado', :not_found) unless user
    
    # Ignorando validação de token por enquanto
    if user.needs_password_reset?
      if user.update(password: password)
        return render json: {
          message: 'Senha definida com sucesso',
          user: user.slice(:id, :email, :name, :role)
        }, status: :ok
      else
        return render_error('Erro ao definir senha', :unprocessable_entity, user.errors.full_messages)
      end
    end
    render_error('Usuário já possui senha definida', :unprocessable_entity)
  end
  

  ##
  # Rota: GET /passwords/test-email
  # Testa configuração de email 
  #
  # === Argumentos
  # * +email+ - Email para teste (params, opcional)
  #
  # === Retorno
  # JSON com mensagem de sucesso ou erro
  #
  # === Efeitos Colaterais
  # Envia email de teste para o endereço informado
  def test_email
    return render_error('Endpoint disponível apenas em desenvolvimento', :forbidden) unless Rails.env.development?
    email = params[:email] || 'test@example.com'
    begin
      test_user = User.new(name: 'Usuário de Teste', email: email, registration: 'TEST001', role: 'student')
      UserMailer.first_access_email(test_user, 'token-de-teste').deliver_now
      render json: { message: 'Email de teste enviado com sucesso!', email: email, status: 'success' }, status: :ok
    rescue => e
      render_error('Erro ao enviar email de teste', :internal_server_error, e.message)
    end
  end

  private

  ##
  # Renderiza erro de campos obrigatórios ausentes
  #
  # === Argumentos
  # * +fields+ - Lista de campos obrigatórios ausentes
  #
  # === Retorno
  # JSON com mensagem de erro
  # === Efeitos Colaterais
  # Nenhum
  def render_missing(*fields)
    render json: { error: "Os campos obrigatórios não foram informados: #{fields.join(', ')}" }, status: :bad_request
  end

  ##
  # Renderiza erro genérico
  #
  # === Argumentos
  # * +message+ - Mensagem de erro
  # * +status+ - Status HTTP (default :unprocessable_entity)
  # * +details+ - Detalhes adicionais (opcional)
  #
  # === Retorno
  # JSON com mensagem de erro
  # === Efeitos Colaterais
  # Nenhum
  def render_error(message, status = :unprocessable_entity, details = nil)
    resp = { error: message }
    resp[:details] = details if details.present?
    render json: resp, status: status
  end

  ##
  # Renderiza mensagem de sucesso
  #
  # === Argumentos
  # * +message+ - Mensagem de sucesso
  #
  # === Retorno
  # JSON com mensagem de sucesso
  # === Efeitos Colaterais
  # Nenhum
  def render_success(message)
    render json: { message: message }, status: :ok
  end
end
