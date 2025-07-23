class DisciplinasController < ApplicationController
  before_action :set_disciplina, only: %i[ show edit update destroy ]

  ##
  # Lista todas as disciplinas do sistema
  #
  # === Argumentos
  # Nenhum argumento recebido
  #
  # === Retorno
  # Array JSON contendo todos os registros de disciplinas
  #
  # === Efeitos Colaterais
  # Nenhum - operação somente de leitura
  def index
    @disciplinas = Disciplina.all

    render json: @disciplinas
  end

  ##
  # Exibe os detalhes de uma disciplina específica
  #
  # === Argumentos
  # Rota: GET /disciplinas/:id
  #
  # === Retorno
  # JSON com os dados da disciplina encontrada
  #
  # === Efeitos Colaterais
  # Nenhum - operação somente de leitura
  def show

    set_disciplina

    render json: @disciplina
  end

  ##
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
  # Prepara uma disciplina existente para edição
  # 
  # === Nota
  # Há um erro no código original - chama set_turma mas deveria ser set_disciplina
  #
  # === Argumentos
  # * +id+ - ID da disciplina (através dos params)
  #
  # === Retorno
  # JSON com os dados para edição (atualmente retorna @turma por erro)
  #
  # === Efeitos Colaterais
  # Nenhum - apenas preparação para edição
  def edit
    set_turma
    render json: @turma
  end

  ##
  # Cria uma nova disciplina no sistema
  #
  # === Argumentos
  # Rota: POST /disciplinas
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
  # Atualiza os dados de uma disciplina existente
  #
  # === Argumentos
  # Rota: PATCH/PUT /disciplinas/:id
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
    # Nenhum argumento direto - utiliza params[:id]
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
    # Nenhum argumento direto - utiliza params
    #
    # === Retorno
    # Hash com parâmetros filtrados e permitidos
    #
    # === Efeitos Colaterais
    # Nenhum - apenas filtragem de parâmetros
    def disciplina_params
      params.require(:disciplina).permit(:name, :code, :departamento_id)
    end
end
