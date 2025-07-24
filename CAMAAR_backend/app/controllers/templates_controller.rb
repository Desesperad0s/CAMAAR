##
# TemplatesController
#
# Controller responsável por gerenciar templates de formulários

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
  # Nenhum 
  #
  # Rota: GET /templates
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
  # Nenhum 
  #
  # Rota: GET /templates/:id
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
  # Rota: POST /templates
  def create
    user_id = params[:template][:admin_id] || params[:template][:user_id]
    unless user_id.present? && User.exists?(user_id)
      admin = User.where(role: 'admin').first
      user_id = admin&.id
    end

    @template = Template.new(
      content: params[:template][:content],
      user_id: user_id
    )

    if @template.save
      process_questoes_attributes(@template, params[:template][:questoes_attributes]) if params[:template][:questoes_attributes].present?
      process_legacy_questoes(@template, params[:questoes]) if params[:questoes].present? && params[:questoes].is_a?(Array)
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
  # * Pode atualizar, criar ou deletar questões e alternativas associadas
  #
  # Rota: PATCH/PUT /templates/1
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
  # * Remove todas as questões e alternativas associadas 
  #
  # DELETE /templates/1
  def destroy
    template_data = {
      id: @template.id,
      content: @template.content,
      questoes_count: @template.questoes.count,
      formularios_count: @template.formularios.count
    }
    
    @template.destroy!
    
    render json: { 
      message: "Template deletado com sucesso",
      template: template_data
    }, status: :ok
  end

    ##
    # Busca e define o template baseado no ID fornecido
    #
    # === Argumentos
    # * +id+ - ID do template (obtido via params[:id])
    #
    # === Retorno
    # Define a variável de instância @template com o objeto Template encontrado
    # Se não encontrar, dispara ActiveRecord::RecordNotFound 
    #
    # === Efeitos Colaterais
    # * Define @template como variável de instância
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
    # Nenhum
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
    def template_not_found
      render json: { error: "Template não encontrado" }, status: :not_found
    end

    ##
    # Processa os atributos de questões e alternativas recebidos via params
    #
    # === Argumentos
    # * +template+ - Template ao qual as questões serão associadas
    # * +questoes_attrs+ - Array ou Hash de questões e alternativas
    #
    # === Retorno
    # Cria questões e alternativas associadas ao template
    # === Efeitos Colaterais
    # Cria registros no banco de dados
    def process_questoes_attributes(template, questoes_attrs)
      return unless questoes_attrs.present?
      if questoes_attrs.is_a?(Array)
        questoes_attrs.each { |q| create_questao_with_alternativas(template, q) }
      else
        questoes_attrs.each { |_, q| create_questao_with_alternativas(template, q) }
      end
    end

    ##
    # Processa questões recebidas via params para compatibilidade antiga
    #
    # === Argumentos
    # * +template+ - Template ao qual as questões serão associadas
    # * +questoes+ - Array de questões (legacy)
    #
    # === Retorno
    # Cria questões e alternativas associadas ao template
    # === Efeitos Colaterais
    # Cria registros no banco de dados
    def process_legacy_questoes(template, questoes)
      questoes.each do |questao_params|
        questao = template.questoes.create!(enunciado: questao_params[:enunciado])
        if questao_params[:alternativas].present? && questao_params[:alternativas].is_a?(Array)
          questao_params[:alternativas].each do |alternativa_content|
            questao.alternativas.create!(content: alternativa_content)
          end
        end
      end
    end

    ##
    # Cria uma questão e suas alternativas associadas
    #
    # === Argumentos
    # * +template+ - Template ao qual a questão será associada
    # * +questao_attrs+ - Hash de atributos da questão e alternativas
    #
    # === Retorno
    # Cria questão e alternativas associadas
    # === Efeitos Colaterais
    # Cria registros no banco de dados
    def create_questao_with_alternativas(template, questao_attrs)
      questao = template.questoes.create!(enunciado: questao_attrs[:enunciado])
      if questao_attrs[:alternativas_attributes].present?
        alts = questao_attrs[:alternativas_attributes]
        if alts.is_a?(Array)
          alts.each { |alt| questao.alternativas.create!(content: alt[:content]) }
        else
          alts.each { |_, alt| questao.alternativas.create!(content: alt[:content]) }
        end
      end
    end
end
