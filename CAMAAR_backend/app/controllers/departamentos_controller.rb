##
# DepartamentosController
#
# Controller responsável por gerenciar operações de departamentos acadêmicos

class DepartamentosController < ApplicationController
  before_action :set_departamento, only: %i[ show edit update destroy ]

  ##
  # Lista todos os departamentos do sistema
  #
  # === Argumentos
  # Nenhum argumento recebido
  #
  # === Retorno
  # Variável de instância @departamentos com todos os registros
  #
  # === Efeitos Colaterais
  # Nenhum 
  def index
    @departamentos = Departamento.all
  end

  ##
  # Exibe os detalhes de um departamento específico
  #
  # === Argumentos
  # Rota: GET /departamentos/:id
  #
  # === Retorno
  # JSON com os dados do departamento encontrado
  #
  # === Efeitos Colaterais
  # Nenhum 
  def show

    set_departamento

    render json: @departamento
  end

  ##
  # Prepara uma nova instância de departamento para criação
  #
  # === Argumentos
  # Nenhum argumento recebido
  #
  # === Retorno
  # JSON com nova instância de Departamento
  #
  # === Efeitos Colaterais
  # Define @departamento como nova instância
  def new
    @departamento = Departamento.new
    render json: @departamento 
  end

  ##
  # Prepara um departamento existente para edição
  #
  # === Argumentos
  # Rota: GET /departamentos/:id/edit
  #
  # === Retorno
  # JSON com os dados do departamento para edição
  #
  # === Efeitos Colaterais
  # Nenhum - apenas preparação para edição
  def edit
    set_departamento
    render json: @departamento 
  end

  ##
  # Cria um novo departamento no sistema
  #
  # === Argumentos
  # Rota: POST /departamentos
  #
  # === Retorno
  # * JSON com os dados do departamento criado e status 201 (success)
  # * JSON com erros de validação e status 422 (failure)
  #
  # === Efeitos Colaterais
  # * Cria um novo registro na tabela de departamentos
  def create
    @departamento = Departamento.new(departamento_params)

  
    if @departamento.save
        
      render json: @departamento, status: :created, location: @departamento 
    else
      render json: @departamento.errors, status: :unprocessable_entity 
    
    end
  end

  ##
  # Atualiza os dados de um departamento existente
  #
  # === Argumentos
  # Rota: PATCH/PUT /departamentos/:id
  # * +departamento+ - Hash com os novos dados do departamento
  #
  # === Retorno
  # * JSON com os dados atualizados do departamento (success)
  # * JSON com erros de validação e status 422 (failure)
  #
  # === Efeitos Colaterais
  # * Atualiza o registro do departamento no banco de dados
  def update

    set_departamento

    
    if @departamento.update(departamento_params)

      render json: @departamento, status: :ok, location: @departamento 
    else
      
      render json: @departamento.errors, status: :unprocessable_entity 
      
    end
  end

  ##
  # Remove um departamento do sistema
  #
  # === Argumentos
  # Rota: DELETE /departamentos/:id
  #
  # === Retorno
  # Status 204 (no content) indicando remoção bem-sucedida
  #
  # === Efeitos Colaterais
  # * Remove o registro do departamento do banco de dados
  def destroy
    @departamento.destroy!
    
    head :no_content 
  end

  private
    ##
    # Localiza e define o departamento baseado no ID fornecido nos parâmetros
    #
    # === Argumentos
    # Nenhum argumento direto - utiliza params[:id]
    #
    # === Retorno
    # Define a variável de instância @departamento
    #
    # === Efeitos Colaterais
    # * Define @departamento como o departamento encontrado
    # * Levanta exceção ActiveRecord::RecordNotFound se não encontrado
    def set_departamento
      @departamento = Departamento.find(params.expect(:id))
    end

    ##
    # Filtra e permite apenas parâmetros confiáveis para criação/atualização de departamentos
    #
    # === Argumentos
    # Nenhum argumento direto - utiliza params
    #
    # === Retorno
    # Hash com parâmetros filtrados e permitidos
    #
    # === Efeitos Colaterais
    # Nenhum - apenas filtragem de parâmetros
    def departamento_params
      params.expect(departamento: [ :code, :name, :abreviation ])
    end
end
