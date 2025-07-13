class AuthenticationController < ApplicationController
  skip_before_action :authenticate_request, only: [:login]

  # POST /auth/login
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

  # GET /auth/me
  def me
    render json: { user: user_data(current_user) }, status: :ok
  end

  # DELETE /auth/logout
  def logout
    
    render json: { message: 'Logout realizado com sucesso' }, status: :ok
  end

  private

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
