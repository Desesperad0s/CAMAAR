class JwtService
  SECRET_KEY = Rails.application.credentials.secret_key_base || 'development_secret_key'
  
  ##
  # Codifica um payload em um token JWT
  #
  # === Argumentos
  # * +payload+ - Hash contendo os dados a serem codificados no token (ex: user_id)
  # * +exp+ - (Opcional) Tempo de expiração do token (padrão: 24 horas a partir de agora)
  #
  # === Retorno
  # String contendo o token JWT codificado
  #
  # === Efeitos Colaterais
  # * Adiciona timestamp de expiração ao payload
  # * Utiliza SECRET_KEY para assinar o token
  #
  # === Exemplo
  #   token = JwtService.encode(user_id: 1, role: 'admin')
  #   # => "eyJhbGciOiJIUzI1NiJ9..."
  def self.encode(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET_KEY)
  end
  
  ##
  # Decodifica um token JWT e retorna o payload
  #
  # === Argumentos
  # * +token+ - String contendo o token JWT a ser decodificado
  #
  # === Retorno
  # * HashWithIndifferentAccess contendo o payload decodificado (success)
  # * nil se o token for inválido ou expirado (failure)
  #
  # === Efeitos Colaterais
  # * Verifica assinatura do token usando SECRET_KEY
  # * Valida expiração do token
  # * Captura exceções de token inválido ou expirado
  #
  # === Exemplo
  #   payload = JwtService.decode(token)
  #   # => { "user_id" => 1, "role" => "admin", "exp" => 1642781234 }
  def self.decode(token)
    decoded = JWT.decode(token, SECRET_KEY)[0]
    HashWithIndifferentAccess.new(decoded)
  rescue JWT::DecodeError, JWT::ExpiredSignature
    nil
  end
end
