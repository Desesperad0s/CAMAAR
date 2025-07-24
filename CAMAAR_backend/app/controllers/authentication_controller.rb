##
# AuthenticationController
#
# Controller responsável por autenticação de usuários no sistema.
class AuthenticationController < ApplicationController
  skip_before_action :authenticate_request, only: [:login]

  ##
  # Realiza autenticação do usuário no sistema
  #
  # === Argumentos
  # * +email+ - Email do usuário para autenticação
  # * +password+ - Senha do usuário para autenticação
  #
  # === Retorno
  # Em caso de sucesso: JSON com dados do usuário e token JWT com status 200 (ok)
  # Em caso de erro: JSON com mensagem de erro e status 401 (unauthorized)
  #
  # === Efeitos Colaterais
  # * Gera um novo token JWT para o usuário
  # * Define o auth_token do usuário
  # * Consulta o banco de dados para validar credenciais
  #
  # Rota: POST /auth/login
  def login
    @user = User.authenticate(params[:email], params[:password])
    
    if @user
      token = JwtService.encode(user_id: @user.id)
      
      @user.auth_token = token
      
      render json: { 
        user: user_data(@user),
        token: token
      }, status: :ok
    else
      render json: { error: 'E-mail ou senha inválidos' }, status: :unauthorized
    end
  end

  ##
  # Retorna informações do usuário autenticado atual
  #
  # === Argumentos
  # Nenhum argumento - utiliza o current_user definido pelo filtro de autenticação
  #
  # === Retorno
  # JSON com os dados do usuário atual e status 200 (ok)
  #
  # === Efeitos Colaterais
  # Nenhum efeito colateral - apenas retorna dados do usuário já autenticado
  #
  # Rota: GET /auth/me
  def me
    render json: { user: user_data(current_user) }, status: :ok
  end

  ##
  # Realiza logout do usuário
  #
  # === Argumentos
  # Nenhum argumento
  #
  # === Retorno
  # JSON com mensagem de sucesso e status 200 (ok)
  #
  # === Efeitos Colaterais
  # * Pode invalidar tokens no lado servidor (implementação futura)
  # * Por enquanto apenas retorna mensagem de sucesso
  #
  # Rota: DELETE /auth/logout
  def logout
    
    render json: { message: 'Logout realizado com sucesso' }, status: :ok
  end

  private

  ##
  # Formata os dados do usuário para retorno em JSON
  #
  # === Argumentos
  # * +user+ - Objeto User a ser formatado
  #
  # === Retorno
  # Hash contendo os dados essenciais do usuário:
  # * id, name, email, registration, role, token
  #
  # === Efeitos Colaterais
  # Nenhum efeito colateral - apenas formata dados
  #
  def user_data(user)
    {
      id: user.id,
      name: user.name,
      email: user.email,
      registration: user.registration,
      role: user.role,
      token: user.auth_token
    }
  end
end
