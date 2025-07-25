##
# AdminsController
#
# Controller responsável por gerenciar operações de administradores do sistema
class AdminsController < ApplicationController
  before_action :set_admin, only: %i[show update destroy]

  ##
  # Rota: GET /admins
  # Lista todos os administradores do sistema
  #
  # === Argumentos
  # Nenhum argumento recebido
  #
  # === Retorno
  # Array JSON contendo todos os registros de administradores
  #
  # === Efeitos Colaterais
  # Nenhum 
  def index
    @admins = Admin.all
    render json: @admins
  end

  ##
  # Rota: GET /admins/:id
  # Exibe os detalhes de um administrador específico
  #
  # === Argumentos
  # Nenhum argumento recebido
  #
  # === Retorno
  # JSON com os dados do administrador encontrado
  #
  # === Efeitos Colaterais
  # Nenhum 
  def show
    render json: @admin
  end

  ##
  # Rota: POST /admins
  # Cria um novo administrador no sistema
  #
  # === Argumentos
  # * +admin+ - Hash com os dados do novo administrador
  #
  # === Retorno
  # * JSON com os dados do administrador criado e status 201 (success)
  # * JSON com erros de validação e status 422 (failure)
  #
  # === Efeitos Colaterais
  # * Cria um novo registro na tabela de administradores
  def create
    @admin = Admin.new(admin_params)

    if @admin.save
      render json: @admin, status: :created
    else
      render json: { errors: @admin.errors }, status: :unprocessable_entity
    end
  end

  ##
  # Rota: PUT/PATCH /admins/:id
  # Atualiza os dados de um administrador existente
  #
  # === Argumentos
  # * +admin+ - Hash com os novos dados do administrador
  #
  # === Retorno
  # * JSON com os dados atualizados do administrador (success)
  # * JSON com erros de validação e status 422 (failure)
  #
  # === Efeitos Colaterais
  # * Atualiza o registro do administrador no banco de dados
  def update
    if @admin.update(admin_params)
      render json: @admin
    else
      render json: { errors: @admin.errors }, status: :unprocessable_entity
    end
  end

  ##
  # Rota: DELETE /admins/:id
  # Remove um administrador do sistema
  #
  # === Argumentos
  # * +id+ - ID do administrador a ser removido
  #
  # === Retorno
  # Status 204 (no content) indicando remoção bem-sucedida
  #
  # === Efeitos Colaterais
  # * Remove o registro do administrador do banco de dados
  def destroy
    @admin.destroy!
    head :no_content
  end

  private
    ##
    # Localiza e define o administrador baseado no ID fornecido nos parâmetros
    #
    # === Argumentos
    # Nenhum argumento direto - utiliza params[:id]
    #
    # === Retorno
    # Define a variável de instância @admin
    #
    # === Efeitos Colaterais
    # * Define @admin como o administrador encontrado
    # * Levanta exceção ActiveRecord::RecordNotFound se não encontrado
    def set_admin
      @admin = Admin.find(params[:id])
    end

    ##
    # Filtra e permite apenas parâmetros confiáveis para criação/atualização de administradores
    #
    # === Argumentos
    # Nenhum argumento direto - utiliza params
    #
    # === Retorno
    # Hash com parâmetros filtrados e permitidos
    #
    # === Efeitos Colaterais
    # Nenhum 
    def admin_params
      params.require(:admin).permit(:registration, :name, :email, :password)
    end
end
