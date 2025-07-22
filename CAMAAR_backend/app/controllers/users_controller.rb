class UsersController < ApplicationController
  skip_before_action :authenticate_request, only: [:register]
  before_action :set_user, only: [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, with: :user_not_found

  ##
  # Lista todos os usuários do sistema
  #
  # === Argumentos
  # Nenhum argumento é necessário
  #
  # === Retorno
  # JSON contendo array de todos os usuários
  #
  # === Efeitos Colaterais
  # Nenhum efeito colateral - apenas consulta o banco de dados
  #
  # GET /users
  def index
    @users = User.all
    render json: @users
  end

  ##
  # Exibe um usuário específico identificado pelo ID
  #
  # === Argumentos
  # * +id+ - ID do usuário a ser exibido (passado via params[:id])
  #
  # === Retorno
  # JSON contendo os dados do usuário
  # Se o usuário não for encontrado, retorna erro 404 via user_not_found
  #
  # === Efeitos Colaterais
  # Nenhum efeito colateral - apenas consulta o banco de dados
  #
  # GET /users/1
  def show
    render json: @user
  end

  ##
  # Cria um novo usuário no sistema (endpoint administrativo)
  #
  # === Argumentos
  # * +user+ - Hash contendo dados do usuário (name, email, password, registration, role)
  #
  # === Retorno
  # Em caso de sucesso: JSON com dados do usuário criado e token JWT, status 201 (created)
  # Em caso de erro: JSON com erros de validação e status 422 (unprocessable_entity)
  #
  # === Efeitos Colaterais
  # * Cria novo registro de User no banco de dados
  # * Gera token JWT para o usuário
  # * Define auth_token do usuário
  #
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

  ##
  # Registro público de novos usuários (estudantes)
  #
  # === Argumentos
  # * +user+ - Hash contendo dados do usuário (name, email, password, registration)
  #
  # === Retorno
  # Em caso de sucesso: JSON com dados do usuário criado e token JWT, status 201 (created)
  # Em caso de erro: JSON com erros de validação e status 422 (unprocessable_entity)
  #
  # === Efeitos Colaterais
  # * Cria novo registro de User no banco com role 'student'
  # * Gera token JWT para o usuário
  # * Define auth_token do usuário
  #
  # POST /register
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

  ##
  # Atualiza os dados de um usuário existente
  #
  # === Argumentos
  # * +id+ - ID do usuário a ser atualizado (passado via params[:id])
  # * +user+ - Hash contendo os novos dados do usuário (via user_params)
  #
  # === Retorno
  # Em caso de sucesso: JSON com dados atualizados do usuário
  # Em caso de erro: JSON com erros de validação e status 422 (unprocessable_entity)
  #
  # === Efeitos Colaterais
  # * Atualiza o registro do User no banco de dados
  #
  # PATCH/PUT /users/1
  def update
    if @user.update(user_params)
      render json: @user
    else
      render json: { errors: @user.errors }, status: :unprocessable_entity
    end
  end

  ##
  # Remove um usuário do sistema
  #
  # === Argumentos
  # * +id+ - ID do usuário a ser removido (passado via params[:id])
  #
  # === Retorno
  # Status 204 (no_content) indicando sucesso sem conteúdo de resposta
  # Se o usuário não for encontrado, retorna erro 404 via user_not_found
  #
  # === Efeitos Colaterais
  # * Remove permanentemente o usuário do banco de dados
  # * Remove todas as associações relacionadas (turma_alunos, respostas, etc.)
  #
  # DELETE /users/1
  def destroy
    @user.destroy!
    head :no_content
  end

  ##
  # Retorna todas as turmas do usuário logado
  #
  # === Argumentos
  # Nenhum argumento - utiliza o current_user autenticado
  #
  # === Retorno
  # JSON contendo array das turmas nas quais o usuário está matriculado
  #
  # === Efeitos Colaterais
  # Nenhum efeito colateral - apenas consulta o banco de dados
  #
  # GET /user/turmas
  def turmas
    @user = User.find(@current_user.id)
    @turmas = @user.turma_alunos.map(&:turma)
    
    render json: @turmas
  end

  private
    ##
    # Busca e define o usuário baseado no ID fornecido
    #
    # === Argumentos
    # * +id+ - ID do usuário (obtido via params[:id])
    #
    # === Retorno
    # Define a variável de instância @user com o objeto User encontrado
    # Se não encontrar, dispara ActiveRecord::RecordNotFound que é capturado pelo rescue_from
    #
    # === Efeitos Colaterais
    # * Define @user como variável de instância
    # * Consulta o banco de dados
    #
    def set_user
      @user = User.find(params[:id])
    end

    ##
    # Define os parâmetros permitidos para criação e atualização de usuários
    #
    # === Argumentos
    # Nenhum argumento direto - utiliza params do request
    #
    # === Retorno
    # ActionController::Parameters com apenas os campos permitidos:
    # * registration, name, email, password, forms_answered, major, role
    #
    # === Efeitos Colaterais
    # Nenhum efeito colateral - apenas filtra parâmetros de entrada
    #
    def user_params
      params.require(:user).permit(:registration, :name, :email, :password, :forms_answered, :major, :role)
    end

    ##
    # Método de tratamento de erro para quando um usuário não é encontrado
    #
    # === Argumentos
    # Nenhum argumento
    #
    # === Retorno
    # JSON com mensagem de erro e status 404 (not_found)
    #
    # === Efeitos Colaterais
    # * Renderiza resposta JSON de erro
    # * Define status HTTP como 404
    #
    def user_not_found
      render json: { error: "Usuário não encontrado" }, status: :not_found
    end
end
