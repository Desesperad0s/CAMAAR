class ApplicationController < ActionController::API
  include AuthorizeApiRequest
  
  before_action :authenticate_request, except: [:health_check]
  
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActionController::ParameterMissing, with: :parameter_missing
  rescue_from JWT::DecodeError, with: :unauthorized_request
  
  def health_check
    render json: { status: 'online' }, status: :ok
  end
  
  private
  
  def record_not_found(exception)
    render json: { error: exception.message }, status: :not_found
  end
  
  def parameter_missing(exception)
    render json: { error: exception.message }, status: :unprocessable_entity
  end
  
  def unauthorized_request
    render json: { error: 'Token inválido ou expirado' }, status: :unauthorized
  end
end
