##
# DisciplinasController
#
# Controller responsável por gerenciar operações em disciplinas
class DisciplinasController < ApplicationController
  before_action :set_disciplina, only: %i[ show edit update destroy ]

  ##
  # Rota: GET /disciplinas
  # Lista todas as disciplinas do sistema
  #
  # === Argumentos
  # Nenhum argumento recebido
  #
  # === Retorno
  # Array JSON contendo todos os registros de disciplinas
  #
  # === Efeitos Colaterais
  # Nenhum 
  def index
    @disciplinas = Disciplina.all

    render json: @disciplinas
  end

  ##
  # Rota: GET /disciplinas/:id
  # Exibe os detalhes de uma disciplina específica
  #
  # === Argumentos
  # * +id+ - ID da disciplina (através dos params)
  #
  # === Retorno
  # JSON com os dados da disciplina encontrada
  #
  # === Efeitos Colaterais
  # Nenhum 
  def show

    set_disciplina

    render json: @disciplina
  end

  ##
  # Rota: GET /disciplinas/new
  # Prepara uma nova instância de disciplina para criação
  #
  # === Argumentos
  # Nenhum argumento recebido
  #
  # === Retorno
  # JSON com nova instância de Disciplina
  #
  # === Efeitos Colaterais
  # Define @disciplina como nova instância
  def new
    @disciplina = Disciplina.new
    render json: @disciplina
  end

  ##
  # Rota: GET /disciplinas/:id/edit
  # Prepara uma disciplina existente para edição
  #
  # === Argumentos
  # * +id+ - ID da disciplina (através dos params)
  #
  # === Retorno
  # JSON com os dados da disciplina para edição
  #
  # === Efeitos Colaterais
  # Nenhum, apenas prepara para edição
  def edit
    set_turma
    render json: @turma
  end

  ##
  # Rota: POST /disciplinas
  # Cria uma nova disciplina no sistema
  #
  # === Argumentos
  # * +disciplina+ - Hash com os dados da nova disciplina
  #
  # === Retorno
  # * JSON com os dados da disciplina criada e status 201 (success)
  # * JSON com erros de validação e status 422 (failure)
  #
  # === Efeitos Colaterais
  # * Cria um novo registro na tabela de disciplinas
  def create
    @disciplina = Disciplina.new(disciplina_params)

    if @disciplina.save
      render json: @disciplina, status: :created, location: @disciplina
    else
      render json: @disciplina.errors, status: :unprocessable_entity

    end
  end

  ##
  # Rota: PATCH/PUT /disciplinas/:id
  # Atualiza os dados de uma disciplina existente
  #
  # === Argumentos
  # * +id+ - ID da disciplina (através dos params)
  # * +disciplina+ - Hash com os novos dados da disciplina
  #
  # === Retorno
  # * JSON com os dados atualizados da disciplina (success)
  # * JSON com erros de validação e status 422 (failure)
  #
  # === Efeitos Colaterais
  # * Atualiza o registro da disciplina no banco de dados
  def update

    set_disciplina

    if @disciplina.update(disciplina_params)
        render json: @disciplina, status: :ok, location: @disciplina
    else
        render json: @disciplina.errors, status: :unprocessable_entity 

    end
  end

  ##
  # Rota: DELETE /disciplinas/:id
  # Remove uma disciplina do sistema
  #
  # === Argumentos
  # * +id+ - ID da disciplina a ser removida (através dos params)
  #
  # === Retorno
  # Status 204 (no content) indicando remoção bem-sucedida
  #
  # === Efeitos Colaterais
  # * Remove o registro da disciplina do banco de dados
  def destroy
    @disciplina.destroy!
  
    head :no_content
  end

  private
    ##
    # Localiza e define a disciplina baseada no ID fornecido nos parâmetros
    #
    # === Argumentos
    # Nenhum argumento direto, utiliza params[:id]
    #
    # === Retorno
    # Define a variável de instância @disciplina
    #
    # === Efeitos Colaterais
    # * Define @disciplina como a disciplina encontrada
    # * Levanta exceção ActiveRecord::RecordNotFound se não encontrada
    def set_disciplina
      @disciplina = Disciplina.find(params.require(:id))
    end

    ##
    # Filtra e permite apenas parâmetros confiáveis para criação/atualização de disciplinas
    #
    # === Argumentos
    # Nenhum argumento direto, utiliza params
    #
    # === Retorno
    # Hash com parâmetros filtrados e permitidos
    #
    # === Efeitos Colaterais
    # Nenhum
    def disciplina_params
      params.require(:disciplina).permit(:name, :code, :departamento_id)
    end
end
