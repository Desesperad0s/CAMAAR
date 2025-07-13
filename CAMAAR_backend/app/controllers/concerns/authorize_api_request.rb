module AuthorizeApiRequest
  def authenticate_request
    if auth_header.present?
      @current_user = user_from_token
      render json: { error: 'Não autorizado' }, status: :unauthorized unless @current_user
    else
      render json: { error: 'Não autorizado' }, status: :unauthorized
    end
  end

  def current_user
    @current_user
  end

  private

  def user_from_token
    payload = JwtService.decode(auth_token)
    User.find_by(id: payload[:user_id]) if payload
  rescue ActiveRecord::RecordNotFound
    nil
  end

  def auth_token
    auth_header.split(' ').last
  end

  def auth_header
    request.headers['Authorization']
  end
end
