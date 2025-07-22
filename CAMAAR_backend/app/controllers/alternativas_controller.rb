class AlternativasController < ApplicationController
  before_action :set_alternativa, only: %i[ show edit update destroy ]

  ##
  # Lista todas as alternativas ou alternativas de uma questão específica
  #
  # === Argumentos
  # * +questao_id+ - (Opcional) ID da questão para filtrar alternativas
  #
  # === Retorno
  # Array JSON contendo as alternativas (todas ou filtradas por questão)
  #
  # === Efeitos Colaterais
  # Nenhum - operação somente de leitura
  def index
    if params[:questao_id].present?
      @alternativas = Alternativa.where(questao_id: params[:questao_id])
    else
      @alternativas = Alternativa.all
    end
    
    render json: @alternativas
  end

  ##
  # Exibe os detalhes de uma alternativa específica
  #
  # === Argumentos
  # * +id+ - ID da alternativa (através dos params)
  #
  # === Retorno
  # JSON com os dados da alternativa encontrada
  #
  # === Efeitos Colaterais
  # Nenhum - operação somente de leitura
  def show
    render json: @alternativa
  end

  ##
  # Prepara uma nova instância de alternativa para criação
  #
  # === Argumentos
  # Nenhum argumento recebido
  #
  # === Retorno
  # Nova instância de Alternativa
  #
  # === Efeitos Colaterais
  # Define @alternativa como nova instância
  def new
    @alternativa = Alternativa.new
  end

  ##
  # Prepara uma alternativa existente para edição
  #
  # === Argumentos
  # * +id+ - ID da alternativa (através dos params e callback set_alternativa)
  #
  # === Retorno
  # Implicitamente retorna a view de edição
  #
  # === Efeitos Colaterais
  # Nenhum - apenas preparação para edição
  def edit
  end

  ##
  # Cria uma nova alternativa no sistema
  #
  # === Argumentos
  # * +alternativa+ - Hash com os dados da nova alternativa (content, questao_id)
  #
  # === Retorno
  # * HTML: Redirecionamento com notice (success) ou renderização do form com erros
  # * JSON: Dados da alternativa criada com status 201 ou erros com status 422
  #
  # === Efeitos Colaterais
  # * Cria um novo registro na tabela de alternativas
  def create
    @alternativa = Alternativa.new(alternativa_params)

    respond_to do |format|
      if @alternativa.save
        format.html { redirect_to @alternativa, notice: "Alternativa was successfully created." }
        format.json { render :show, status: :created, location: @alternativa }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @alternativa.errors, status: :unprocessable_entity }
      end
    end
  end

  ##
  # Atualiza os dados de uma alternativa existente
  #
  # === Argumentos
  # * +id+ - ID da alternativa a ser atualizada (através dos params)
  # * +alternativa+ - Hash com os novos dados da alternativa
  #
  # === Retorno
  # * HTML: Redirecionamento com notice (success) ou renderização do form com erros
  # * JSON: Dados atualizados ou erros de validação
  #
  # === Efeitos Colaterais
  # * Atualiza o registro da alternativa no banco de dados
  def update
    respond_to do |format|
      if @alternativa.update(alternativa_params)
        format.html { redirect_to @alternativa, notice: "Alternativa was successfully updated." }
        format.json { render :show, status: :ok, location: @alternativa }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @alternativa.errors, status: :unprocessable_entity }
      end
    end
  end

  ##
  # Remove uma alternativa do sistema
  #
  # === Argumentos
  # * +id+ - ID da alternativa a ser removida (através dos params)
  #
  # === Retorno
  # * HTML: Redirecionamento para índice com notice de sucesso
  # * JSON: Status 204 (no content)
  #
  # === Efeitos Colaterais
  # * Remove o registro da alternativa do banco de dados
  def destroy
    @alternativa.destroy!

    respond_to do |format|
      format.html { redirect_to alternativas_path, status: :see_other, notice: "Alternativa was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    ##
    # Localiza e define a alternativa baseada no ID fornecido nos parâmetros
    #
    # === Argumentos
    # Nenhum argumento direto - utiliza params[:id]
    #
    # === Retorno
    # Define a variável de instância @alternativa
    #
    # === Efeitos Colaterais
    # * Define @alternativa como a alternativa encontrada
    # * Levanta exceção ActiveRecord::RecordNotFound se não encontrada
    def set_alternativa
      @alternativa = Alternativa.find(params[:id])
    end

    ##
    # Filtra e permite apenas parâmetros confiáveis para criação/atualização de alternativas
    #
    # === Argumentos
    # Nenhum argumento direto - utiliza params
    #
    # === Retorno
    # Hash com parâmetros filtrados e permitidos
    #
    # === Efeitos Colaterais
    # Nenhum - apenas filtragem de parâmetros
    def alternativa_params
      params.require(:alternativa).permit(:content, :questao_id)
    end
end
