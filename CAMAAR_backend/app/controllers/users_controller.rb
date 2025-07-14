class UsersController < ApplicationController
  skip_before_action :authenticate_request, only: [:register]
  before_action :set_user, only: [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, with: :user_not_found

  # GET /users
  def index
    @users = User.all
    render json: @users
  end

  # GET /users/1
  def show
    render json: @user
  end

  # POST /users
  def create
    @user = User.new(user_params)

    if @user.save
      token = JwtService.encode(user_id: @user.id)
      @user.auth_token = token
      render json: { 
        user: @user.as_json(except: [:password_digest]), 
        token: token 
      }, status: :created
    else
      render json: { errors: @user.errors }, status: :unprocessable_entity
    end
  end

  # POST /register
  # Endpoint público para registro de novos usuários
  def register
    @user = User.new(user_params)
    @user.role = 'student' # Por padrão, novos registros são estudantes

    if @user.save
      token = JwtService.encode(user_id: @user.id)
      @user.auth_token = token
      render json: { 
        user: @user.as_json(except: [:password_digest]), 
        token: token 
      }, status: :created
    else
      render json: { errors: @user.errors }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /users/1
  def update
    if @user.update(user_params)
      render json: @user
    else
      render json: { errors: @user.errors }, status: :unprocessable_entity
    end
  end

  # DELETE /users/1
  def destroy
    @user.destroy!
    head :no_content
  end

  # GET /user/turmas
  # Retorna todas as turmas do usuário logado
  def turmas
    @user = User.find(@current_user.id)
    @turmas = @user.turma_alunos.map(&:turma)
    
    render json: @turmas
  end

  private
    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:registration, :name, :email, :password, :forms_answered, :major, :role)
    end

    def user_not_found
      render json: { error: "Usuário não encontrado" }, status: :not_found
    end
end