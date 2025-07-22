
# == Módulo AuthorizeApiRequest
# Responsável por autenticar requisições usando JWT e definir o usuário atual.
module AuthorizeApiRequest

  ##
  # Autentica a requisição usando o token JWT presente no header.
  #
  # === Argumentos
  # Nenhum argumento direto (usa o header Authorization da requisição)
  #
  # === Retorno
  # * Se autorizado: define @current_user e permite execução do controller
  # * Se não autorizado: retorna JSON com erro e status 401 (unauthorized)
  #
  # === Efeitos Colaterais
  # * Define @current_user se o token for válido
  # * Interrompe o fluxo do controller se não autorizado
  def authenticate_request
    if auth_header.present?
      @current_user = user_from_token
      render json: { error: 'Não autorizado' }, status: :unauthorized unless @current_user
    else
      render json: { error: 'Não autorizado' }, status: :unauthorized
    end
  end

  ##
  # Retorna o usuário autenticado na requisição atual.
  #
  # === Argumentos
  # Nenhum argumento
  #
  # === Retorno
  # * Usuário autenticado (User) ou nil se não autenticado
  #
  # === Efeitos Colaterais
  # Nenhum
  def current_user
    @current_user
  end

  private

  ##
  # Decodifica o token JWT e retorna o usuário correspondente.
  #
  # === Argumentos
  # Nenhum argumento direto (usa o token extraído do header Authorization)
  #
  # === Retorno
  # * Usuário autenticado (User) se o token for válido e usuário existir
  # * nil se não encontrado ou erro
  #
  # === Efeitos Colaterais
  # Nenhum
  def user_from_token
    payload = JwtService.decode(auth_token)
    User.find_by(id: payload[:user_id]) if payload
  rescue ActiveRecord::RecordNotFound
    nil
  end

  ##
  # Extrai o token JWT do header Authorization.
  #
  # === Argumentos
  # Nenhum argumento
  #
  # === Retorno
  # * String com o token JWT extraído do header Authorization
  #
  # === Efeitos Colaterais
  # Nenhum
  def auth_token
    auth_header.split(' ').last
  end

  ##
  # Retorna o valor do header Authorization da requisição.
  #
  # === Argumentos
  # Nenhum argumento
  #
  # === Retorno
  # * String com o header Authorization ou nil
  #
  # === Efeitos Colaterais
  # Nenhum
  def auth_header
    request.headers['Authorization']
  end
end
