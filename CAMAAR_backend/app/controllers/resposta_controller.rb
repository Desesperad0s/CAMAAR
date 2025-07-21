class RespostaController < ApplicationController
  before_action :set_resposta, only: %i[show update destroy]

  ##
  # Lista todas as respostas do sistema
  #
  # === Argumentos
  # Nenhum argumento é necessário
  #
  # === Retorno
  # JSON contendo array de todas as respostas
  #
  # === Efeitos Colaterais
  # Nenhum efeito colateral - apenas consulta o banco de dados
  #
  # GET /resposta
  def index
    @respostas = Resposta.all
    render json: @respostas
  end

  ##
  # Exibe uma resposta específica identificada pelo ID
  #
  # === Argumentos
  # * +id+ - ID da resposta a ser exibida (passado via params[:id])
  #
  # === Retorno
  # JSON contendo os dados da resposta
  # Se a resposta não for encontrada, retorna erro 404
  #
  # === Efeitos Colaterais
  # Nenhum efeito colateral - apenas consulta o banco de dados
  #
  # GET /resposta/1
  def show
    render json: @resposta
  end

  ##
  # Cria uma nova resposta no sistema
  #
  # === Argumentos
  # * +resposta+ - Hash contendo dados da resposta (content, questao_id, user_id, formulario_id)
  #
  # === Retorno
  # Em caso de sucesso: JSON com dados da resposta criada e status 201 (created)
  # Em caso de erro: JSON com erros de validação e status 422 (unprocessable_entity)
  #
  # === Efeitos Colaterais
  # * Cria novo registro de Resposta no banco de dados
  #
  # POST /resposta
  def create
    @resposta = Resposta.new(resposta_params)

    if @resposta.save
      render json: @resposta, status: :created
    else
      render json: { errors: @resposta.errors }, status: :unprocessable_entity
    end
  end

  ##
  # Atualiza uma resposta existente
  #
  # === Argumentos
  # * +id+ - ID da resposta a ser atualizada (passado via params[:id])
  # * +resposta+ - Hash contendo os novos dados da resposta (via resposta_params)
  #
  # === Retorno
  # Em caso de sucesso: JSON com dados atualizados da resposta
  # Em caso de erro: JSON com erros de validação e status 422 (unprocessable_entity)
  #
  # === Efeitos Colaterais
  # * Atualiza o registro da Resposta no banco de dados
  #
  # PATCH/PUT /resposta/1
  def update
    if @resposta.update(resposta_params)
      render json: @resposta
    else
      render json: { errors: @resposta.errors }, status: :unprocessable_entity
    end
  end

  ##
  # Remove uma resposta do sistema
  #
  # === Argumentos
  # * +id+ - ID da resposta a ser removida (passado via params[:id])
  #
  # === Retorno
  # Status 204 (no_content) indicando sucesso sem conteúdo de resposta
  # Se a resposta não for encontrada, retorna erro 404
  #
  # === Efeitos Colaterais
  # * Remove permanentemente a resposta do banco de dados
  #
  # DELETE /resposta/1
  def destroy
    @resposta.destroy!
    head :no_content
  end
  
  ##
  # Cria múltiplas respostas em uma única transação
  #
  # === Argumentos
  # * +respostas+ - Array de hashes contendo dados das respostas a serem criadas
  #
  # === Retorno
  # Em caso de sucesso: JSON com array das respostas criadas e status 201 (created)
  # Em caso de erro: JSON com erros e status 422 (unprocessable_entity)
  #
  # === Efeitos Colaterais
  # * Cria múltiplos registros de Resposta no banco de dados em uma transação
  # * Se alguma resposta falhar, todas são revertidas (rollback)
  #
  # POST /resposta/batch_create
  def batch_create
    ActiveRecord::Base.transaction do
      @respostas = []
      
      if params[:respostas].present?
        params[:respostas].each do |resposta_params|
          resposta = Resposta.new(
            content: resposta_params[:content],
            questao_id: resposta_params[:questao_id],
            formulario_id: resposta_params[:formulario_id]
          )
          
          if resposta.save
            @respostas << resposta
          else
            render json: { errors: resposta.errors }, status: :unprocessable_entity
            raise ActiveRecord::Rollback
          end
        end
        
        render json: @respostas, status: :created
      else
        render json: { error: "Respostas not provided" }, status: :unprocessable_entity
      end
    end
  end
    
  ##
  # Busca todas as respostas de um formulário específico, agrupadas por questão
  #
  # === Argumentos
  # * +formulario_id+ - ID do formulário (passado via params[:formulario_id])
  #
  # === Retorno
  # Em caso de sucesso: JSON com respostas agrupadas por questão, incluindo detalhes da questão
  # Em caso de formulário não encontrado: JSON com erro e status 404 (not_found)
  # Em caso de não autorização: JSON com erro e status 401 (unauthorized)
  #
  # === Efeitos Colaterais
  # * Verifica autorização do usuário para acessar o formulário
  # * Consulta banco de dados para buscar respostas e questões relacionadas
  #
  # GET /resposta/formulario/:formulario_id
  def by_formulario
    formulario_id = params[:formulario_id]
    
    # Verificar se o formulário existe
    formulario = Formulario.find_by(id: formulario_id)
    
    if formulario.nil?
      render json: { error: "Formulário não encontrado" }, status: :not_found
      return
    end
    
    # Se o usuário não for admin, verificar se o formulário está associado a alguma turma do usuário
    unless @current_user.admin?
      turma_ids = @current_user.turmas.pluck(:id)
      unless turma_ids.include?(formulario.turma_id)
        render json: { error: "Unauthorized" }, status: :unauthorized
        return
      end
    end
    
    @respostas = Resposta.where(formulario_id: formulario_id)
                         .includes(:questao)
    
    # Agrupar respostas por questão
    result = @respostas.group_by(&:questao_id).map do |questao_id, questao_respostas|
      questao = questao_respostas.first.questao
      {
        questao_id: questao_id,
        questao_texto: questao&.content || "Questão desconhecida",
        tipo: questao&.kind || "text",
        respostas: questao_respostas.map do |resposta|
          {
            id: resposta.id,
            resposta: resposta.content,
            created_at: resposta.created_at
          }
        end
      }
    end
    
    render json: result
  end

  private
    ##
    # Localiza e define a resposta baseada no ID fornecido nos parâmetros
    #
    # === Argumentos
    # Nenhum argumento direto - utiliza params[:id]
    #
    # === Retorno
    # Define a variável de instância @resposta
    #
    # === Efeitos Colaterais
    # * Define @resposta como a resposta encontrada
    # * Levanta exceção ActiveRecord::RecordNotFound se não encontrada
    def set_resposta
      @resposta = Resposta.find(params[:id])
    end

    ##
    # Filtra e permite apenas parâmetros confiáveis para criação/atualização de respostas
    #
    # === Argumentos
    # Nenhum argumento direto - utiliza params
    #
    # === Retorno
    # Hash com parâmetros filtrados e permitidos (content, questao_id, formulario_id)
    #
    # === Efeitos Colaterais
    # Nenhum - apenas filtragem de parâmetros
    def resposta_params
      params.require(:resposta).permit(:content, :questao_id, :formulario_id)
    end
end
