class QuestaosController < ApplicationController
  before_action :set_questao, only: %i[ show edit update destroy ]

  ##
  # Lista todas as questões ou questões de um formulário específico
  #
  # === Argumentos
  # Rota: GET /questaos or /formularios/:formulario_id/questaos
  #
  # === Retorno
  # Array JSON contendo as questões (todas ou filtradas por formulário/template)
  #
  # === Efeitos Colaterais
  # Nenhum - operação somente de leitura
  def index
    if params[:formulario_id].present?
      formulario = Formulario.find_by(id: params[:formulario_id])
      if formulario
        # Buscando questões através da relação com template
        if formulario.template_id
          @questaos = Questao.where(templates_id: formulario.template_id)
        else
          @questaos = []
        end
      else
        @questaos = []
      end
    else
      @questaos = Questao.all
    end
    
    render json: @questaos
  end

  ##
  # Exibe os detalhes de uma questão específica
  #
  # === Argumentos
  # Rota: GET /questaos/:id
  #
  # === Retorno
  # JSON com os dados da questão encontrada
  #
  # === Efeitos Colaterais
  # Nenhum - operação somente de leitura
  def show
    render json: @questao
  end

  ##
  # Prepara uma nova instância de questão para criação
  #
  # === Argumentos
  # Nenhum argumento recebido
  #
  # === Retorno
  # Nova instância de Questao
  #
  # === Efeitos Colaterais
  # Define @questao como nova instância
  def new
    @questao = Questao.new
  end

  ##
  # Prepara uma questão existente para edição
  #
  # === Argumentos
  # Rota: GET /questaos/:id/edit
  #
  # === Retorno
  # Implicitamente retorna a view de edição
  #
  # === Efeitos Colaterais
  # Nenhum - apenas preparação para edição
  def edit
  end

  ##
  # Cria uma nova questão no sistema
  #
  # === Argumentos
  # Rota: POST /questaos
  #
  # === Retorno
  # * HTML: Redirecionamento com notice (success) ou renderização do form com erros
  # * JSON: Dados da questão criada com status 201 ou erros com status 422
  #
  # === Efeitos Colaterais
  # * Cria um novo registro na tabela de questões
  # * Pode criar alternativas associadas
  def create
    @questao = Questao.new(questao_params)

    if @questao.save
      render json: @questao, status: :created
    else
      # Log dos erros para debug
      Rails.logger.error "Questao validation errors: #{@questao.errors.full_messages}"
      if @questao.alternativas.any?
        @questao.alternativas.each_with_index do |alt, index|
          Rails.logger.error "Alternativa #{index} errors: #{alt.errors.full_messages}" if alt.errors.any?
        end
      end
      render json: @questao.errors, status: :unprocessable_entity
    end
  end

  ##
  # Atualiza os dados de uma questão existente
  #
  # === Argumentos
  # Rota: PATCH/PUT /questaos/:id
  # * +questao+ - Hash com os novos dados da questão
  #
  # === Retorno
  # * HTML: Redirecionamento com notice (success) ou renderização do form com erros
  # * JSON: Dados atualizados ou erros de validação
  #
  # === Efeitos Colaterais
  # * Atualiza o registro da questão no banco de dados
  # * Pode atualizar/criar/remover alternativas associadas
  def update
    if @questao.update(questao_params)
      render json: @questao, status: :ok
    else
      render json: @questao.errors, status: :unprocessable_entity
    end
  end

  ##
  # Remove uma questão do sistema
  #
  # === Argumentos
  # * +id+ - ID da questão a ser removida (através dos params)
  #
  # === Retorno
  # * HTML: Redirecionamento para índice com notice de sucesso
  # * JSON: Status 204 (no content)
  #
  # === Efeitos Colaterais
  # * Remove o registro da questão do banco de dados
  # * Remove alternativas associadas (dependendo das configurações do modelo)
  def destroy
    @questao.destroy!
    head :no_content
  end

  private
    ##
    # Localiza e define a questão baseada no ID fornecido nos parâmetros
    #
    # === Argumentos
    # Nenhum argumento direto - utiliza params[:id]
    #
    # === Retorno
    # Define a variável de instância @questao
    #
    # === Efeitos Colaterais
    # * Define @questao como a questão encontrada
    # * Levanta exceção ActiveRecord::RecordNotFound se não encontrada
    def set_questao
      @questao = Questao.find(params[:id])
    end

    ##
    # Filtra e permite apenas parâmetros confiáveis para criação/atualização de questões
    #
    # === Argumentos
    # Nenhum argumento direto - utiliza params
    #
    # === Retorno
    # Hash com parâmetros filtrados e permitidos
    #
    # === Efeitos Colaterais
    # Nenhum - apenas filtragem de parâmetros
    def questao_params
      params.require(:questao).permit(
        :enunciado, 
        :templates_id, 
        :formularios_id, 
        alternativas_attributes: [:id, :content, :_destroy]
      )
    end
end
