##
# TurmasController
#
# Controller responsável por gerenciar as turmas do sistema

class TurmasController < ApplicationController
  before_action :set_turma, only: %i[ show edit update destroy ]
  

  ##
  # Rota: GET /turmas
  # Lista todas as turmas do sistema
  #
  # === Argumentos
  # Nenhum argumento recebido
  #
  # === Retorno
  # Array JSON contendo todos os registros de turmas
  #
  # === Efeitos Colaterais
  # Nenhum
  def index
    if @current_user&.admin?
      @turmas = Turma.joins(:disciplina).where(disciplinas: { departamento_id: @current_user.departamento_id })
    else
      @turmas = Turma.none
    end
    render json: @turmas
  end

  ##
  # Rota: GET /turmas/:id
  # Exibe os detalhes de uma turma específica
  #
  # === Argumentos
  # * +id+ - ID da turma (através dos params)
  #
  # === Retorno
  # JSON com os dados da turma encontrada
  #
  # === Efeitos Colaterais
  # Nenhum
  def show

    
    set_turma

    render json: @turma
  end

  ##
  # Rota: GET /turmas/find_by_code
  # Busca uma turma pelo código
  #
  # === Argumentos
  # * +code+ - Código da turma (params)
  #
  # === Retorno
  # * JSON com os dados da turma encontrada e status 200 (success)
  # * JSON com mensagem de erro e status 404 (not found)
  #
  # === Efeitos Colaterais
  # Nenhum 
  def find_by_code
  @turma = Turma.find_by(code: params[:code])
  if @turma
    render json: @turma, status: :ok
  else
    render json: { error: 'Turma não encontrada' }, status: :not_found
  end
end

  ##
  # Rota: GET /turmas/new
  # Prepara uma nova instância de turma para criação
  #
  # === Argumentos
  # Nenhum argumento recebido
  #
  # === Retorno
  # JSON com nova instância de Turma
  #
  # === Efeitos Colaterais
  # Define @turma como nova instância
  def new
    
    @turma = Turma.new
    render json: @turma
  end

  ##
  # Rota: GET /turmas/:id/edit
  # Prepara uma turma existente para edição
  #
  # === Argumentos
  # * +id+ - ID da turma (através dos params e callback set_turma)
  #
  # === Retorno
  # JSON com os dados da turma para edição
  #
  # === Efeitos Colaterais
  # Nenhum
  def edit
    
    set_turma
    render json: @turma


  end

  ##
  # Rota: POST /turmas
  # Cria uma nova turma no sistema
  #
  # === Argumentos
  # * +turma+ - Hash com os dados da nova turma
  #
  # === Retorno
  # * JSON com os dados da turma criada e status 201 (success)
  # * JSON com erros de validação e status 422 (failure)
  #
  # === Efeitos Colaterais
  # * Cria um novo registro na tabela de turmas
  def create
    
    @turma = Turma.new(turma_params)
    if @turma.save
      render json: @turma, status: :created
    else
      render json: @turma.errors, status: :unprocessable_entity

    end
  end

  ##
  # Rota: PATCH/PUT /turmas/:id
  # Atualiza os dados de uma turma existente
  #
  # === Argumentos
  # * +id+ - ID da turma (através dos params)
  # * +turma+ - Hash com os novos dados da turma
  #
  # === Retorno
  # * JSON com os dados atualizados da turma (success)
  # * JSON com erros de validação e status 422 (failure)
  #
  # === Efeitos Colaterais
  # * Atualiza o registro da turma no banco de dados
  def update
    

    set_turma


      if @turma.update(turma_params)

        render json: @turma, status: :ok, location: @turma
      else

        render json: @turma.errors, status: :unprocessable_entity

    end
  end

  ##
  # Rota: DELETE /turmas/:id
  # Remove uma turma do sistema
  #
  # === Argumentos
  # * +id+ - ID da turma a ser removida (através dos params)
  #
  # === Retorno
  # Status 204 (no content) indicando remoção bem-sucedida
  #
  # === Efeitos Colaterais
  # * Remove o registro da turma do banco de dados
  def destroy
   

    @turma.destroy!

     head :no_content

  end
  
  ##
  # Rota: GET /turmas/:id/formularios
  # Retorna todos os formulários associados a uma turma específica
  #
  # === Argumentos
  # * +id+ - ID da turma (através dos params)
  #
  # === Retorno
  # Array JSON contendo todos os formulários da turma
  #
  # === Efeitos Colaterais
  # Nenhum
  def formularios
    @turma = Turma.find(params[:id])
    if current_user.professor?
      @formularios = @turma.formularios.where(publico_alvo: 'docente')
    elsif current_user.estudante?
      @formularios = @turma.formularios.where(publico_alvo: 'discente')
    else
      @formularios = @turma.formularios
    end
    render json: @formularios
  end

  private
    ##
    # Localiza e define a turma baseada no ID fornecido nos parâmetros
    #
    # === Argumentos
    # Nenhum argumento direto - utiliza params[:id]
    #
    # === Retorno
    # Define a variável de instância @turma
    #
    # === Efeitos Colaterais
    # * Define @turma como a turma encontrada
    # * Levanta exceção ActiveRecord::RecordNotFound se não encontrada
    def set_turma
      @turma = Turma.find(params[:id])
    end

    ##
    # Filtra e permite apenas parâmetros confiáveis para criação/atualização de turmas
    #
    # === Argumentos
    # Nenhum argumento direto, utiliza params
    #
    # === Retorno
    # Hash com parâmetros filtrados e permitidos
    #
    # === Efeitos Colaterais
    # Nenhum 
    def turma_params
      params.require(:turma).permit(:code, :number, :semester, :time, :disciplina_id)
    end
end