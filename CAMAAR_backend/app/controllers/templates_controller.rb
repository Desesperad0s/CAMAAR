class TemplatesController < ApplicationController
  before_action :set_template, only: [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, with: :template_not_found

  ##
  # Lista todos os templates disponíveis no sistema
  #
  # === Argumentos
  # Nenhum argumento é necessário
  #
  # === Retorno
  # Retorna um JSON contendo um array de templates com suas questões e alternativas aninhadas
  #
  # === Efeitos Colaterais
  # Nenhum efeito colateral - apenas consulta o banco de dados
  #
  # GET /templates
  def index
    @templates = Template.all
    render json: @templates.as_json(include: { questoes: { include: :alternativas } })
  end

  ##
  # Exibe um template específico identificado pelo ID
  #
  # === Argumentos
  # * +id+ - ID do template a ser exibido (passado via params[:id])
  #
  # === Retorno
  # Retorna um JSON contendo o template com suas questões e alternativas aninhadas
  # Se o template não for encontrado, retorna erro 404 via template_not_found
  #
  # === Efeitos Colaterais
  # Nenhum efeito colateral - apenas consulta o banco de dados
  #
  # GET /templates/1
  def show
    render json: @template.as_json(include: { questoes: { include: :alternativas } })
  end

  ##
  # Cria um novo template com questões e alternativas associadas
  #
  # === Argumentos
  # * +template+ - Hash contendo os dados do template (content, admin_id ou user_id)
  # * +questoes_attributes+ - Array ou Hash de questões com seus enunciados e alternativas (opcional)
  # * +questoes+ - Array de questões para compatibilidade com versões anteriores (opcional)
  #
  # === Retorno
  # Em caso de sucesso: JSON do template criado com status 201 (created)
  # Em caso de erro: JSON com os erros de validação e status 422 (unprocessable_entity)
  #
  # === Efeitos Colaterais
  # * Cria um novo registro de Template no banco de dados
  # * Cria registros de Questao associados ao template
  # * Cria registros de Alternativa associados às questões
  # * Se não houver user_id válido, busca e atribui o primeiro admin encontrado
  #
  # POST /templates
  def create
    # Create a new template based on basic attributes
    # Obter o user_id do parâmetro admin_id ou user_id
    user_id = params[:template][:admin_id] || params[:template][:user_id]
    
    # Se não houver um user_id válido, tenta encontrar um admin
    unless user_id.present? && User.exists?(user_id)
      admin = User.where(role: 'admin').first
      user_id = admin&.id
    end
    
    @template = Template.new(
      content: params[:template][:content],
      user_id: user_id
    )
    
    if @template.save
      if params[:template][:questoes_attributes].present?
        if params[:template][:questoes_attributes].is_a?(Array)
          params[:template][:questoes_attributes].each do |questao_attrs|
            questao = @template.questoes.create!(
              enunciado: questao_attrs[:enunciado]
            )
            
            # Process alternativas if present
            if questao_attrs[:alternativas_attributes].present?
              if questao_attrs[:alternativas_attributes].is_a?(Array)
                questao_attrs[:alternativas_attributes].each do |alt_attrs|
                  questao.alternativas.create!(content: alt_attrs[:content])
                end
              else
                questao_attrs[:alternativas_attributes].each do |_, alt_attrs|
                  questao.alternativas.create!(content: alt_attrs[:content])
                end
              end
            end
          end
        else
          params[:template][:questoes_attributes].each do |_, questao_attrs|
            questao = @template.questoes.create!(
              enunciado: questao_attrs[:enunciado]
            )
            
            if questao_attrs[:alternativas_attributes].present?
              questao_attrs[:alternativas_attributes].each do |_, alt_attrs|
                questao.alternativas.create!(content: alt_attrs[:content])
              end
            end
          end
        end
      end
      
      # Handle questões provided as a separate array (for backward compatibility)
      if params[:questoes].present? && params[:questoes].is_a?(Array)
        params[:questoes].each do |questao_params|
          questao = @template.questoes.create!(
            enunciado: questao_params[:enunciado]
          )
          
          if questao_params[:alternativas].present? && questao_params[:alternativas].is_a?(Array)
            questao_params[:alternativas].each do |alternativa_content|
              questao.alternativas.create!(content: alternativa_content)
            end
          end
        end
      end
      
      @template.reload
      render json: @template.as_json(include: { questoes: { include: :alternativas } }), status: :created, location: @template
    else
      render json: { errors: @template.errors }, status: :unprocessable_entity
    end
  end

  ##
  # Atualiza um template existente
  #
  # === Argumentos
  # * +id+ - ID do template a ser atualizado (passado via params[:id])
  # * +template+ - Hash contendo os novos dados do template (via template_params)
  #
  # === Retorno
  # Em caso de sucesso: JSON do template atualizado com suas questões e alternativas
  # Em caso de erro: JSON com os erros de validação e status 422 (unprocessable_entity)
  #
  # === Efeitos Colaterais
  # * Atualiza o registro do Template no banco de dados
  # * Pode atualizar, criar ou deletar questões e alternativas associadas (via nested attributes)
  #
  # PATCH/PUT /templates/1
  def update
    if @template.update(template_params)
      render json: @template.as_json(include: { questoes: { include: :alternativas } })
    else
      render json: { errors: @template.errors }, status: :unprocessable_entity
    end
  end

  ##
  # Remove um template do sistema
  #
  # === Argumentos
  # * +id+ - ID do template a ser removido (passado via params[:id])
  #
  # === Retorno
  # Retorna status 204 (no_content) indicando sucesso sem conteúdo de resposta
  # Se o template não for encontrado, retorna erro 404 via template_not_found
  #
  # === Efeitos Colaterais
  # * Remove permanentemente o template do banco de dados
  # * Remove todas as questões e alternativas associadas (via dependent: :destroy nas associações)
  #
  # DELETE /templates/1
  def destroy
    @template.destroy!
    head :no_content
  end

  private
    ##
    # Busca e define o template baseado no ID fornecido
    #
    # === Argumentos
    # * +id+ - ID do template (obtido via params[:id])
    #
    # === Retorno
    # Define a variável de instância @template com o objeto Template encontrado
    # Se não encontrar, dispara ActiveRecord::RecordNotFound que é capturado pelo rescue_from
    #
    # === Efeitos Colaterais
    # * Define @template como variável de instância
    # * Consulta o banco de dados
    #
    def set_template
      @template = Template.find(params[:id])
    end

    ##
    # Define os parâmetros permitidos para criação e atualização de templates
    #
    # === Argumentos
    # Nenhum argumento direto - utiliza params do request
    #
    # === Retorno
    # Retorna um ActionController::Parameters com apenas os campos permitidos:
    # * content: conteúdo do template
    # * user_id: ID do usuário proprietário
    # * questoes_attributes: array de questões com seus atributos aninhados
    #   * id, enunciado, _destroy
    #   * alternativas_attributes: array de alternativas (id, content, _destroy)
    #
    # === Efeitos Colaterais
    # Nenhum efeito colateral - apenas filtra parâmetros de entrada
    #
    def template_params
      params.require(:template).permit(
        :content, 
        :user_id,
        questoes_attributes: [
          :id, 
          :enunciado, 
          :_destroy,
          alternativas_attributes: [:id, :content, :_destroy]
        ]
      )
    end

    ##
    # Método de tratamento de erro para quando um template não é encontrado
    #
    # === Argumentos
    # Nenhum argumento
    #
    # === Retorno
    # Retorna JSON com mensagem de erro e status 404 (not_found)
    #
    # === Efeitos Colaterais
    # * Renderiza resposta JSON de erro
    # * Define status HTTP como 404
    #
    def template_not_found
      render json: { error: "Template não encontrado" }, status: :not_found
    end
end
