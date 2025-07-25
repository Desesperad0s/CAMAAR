##
# ApplicationController
#
# Controller base do sistema, responsável por fornecer funcionalidades comuns a todos os controllers

class ApplicationController < ActionController::API
  include AuthorizeApiRequest
  
  before_action :authenticate_request, except: [:health_check]
  
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActionController::ParameterMissing, with: :parameter_missing
  rescue_from JWT::DecodeError, with: :unauthorized_request
  
  ##
  # Rota: GET /health_check
  # Retorna o status da aplicação
  #
  # === Argumentos
  # Nenhum argumento é necessário
  #
  # === Retorno
  # JSON com status 'online' e código HTTP 200 (ok)
  #
  # === Efeitos Colaterais
  # Nenhum efeito colateral - apenas retorna status da aplicação
  def health_check
    render json: { status: 'online' }, status: :ok
  end
  
  private
  
  ##
  # Tratamento de erro para registros não encontrados no banco de dados
  #
  # === Argumentos
  # * +exception+ - Exceção ActiveRecord::RecordNotFound capturada
  #
  # === Retorno
  # JSON com mensagem de erro e status 404 (not_found)
  #
  # === Efeitos Colaterais
  # * Renderiza resposta JSON de erro
  # * Define status HTTP como 404
  #
  def record_not_found(exception)
    render json: { error: exception.message }, status: :not_found
  end
  
  ##
  # Tratamento de erro para parâmetros obrigatórios ausentes
  #
  # === Argumentos
  # * +exception+ - Exceção ActionController::ParameterMissing capturada
  #
  # === Retorno
  # JSON com mensagem de erro e status 422 (unprocessable_entity)
  #
  # === Efeitos Colaterais
  # * Renderiza resposta JSON de erro
  # * Define status HTTP como 422
  #
  def parameter_missing(exception)
    render json: { error: exception.message }, status: :unprocessable_entity
  end
  
  ##
  # Tratamento de erro para tokens JWT inválidos ou expirados
  #
  # === Argumentos
  # Nenhum argumento - captura JWT::DecodeError automaticamente
  #
  # === Retorno
  # JSON com mensagem de erro de autorização e status 401 (unauthorized)
  #
  # === Efeitos Colaterais
  # * Renderiza resposta JSON de erro
  # * Define status HTTP como 401
  #
  def unauthorized_request
    render json: { error: 'Token inválido ou expirado' }, status: :unauthorized
  end
end
