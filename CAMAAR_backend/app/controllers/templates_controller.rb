class TemplatesController < ApplicationController
  before_action :set_template, only: [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, with: :template_not_found

  # GET /templates
  def index
    @templates = Template.all
    render json: @templates.as_json(include: { questoes: { include: :alternativas } })
  end

  # GET /templates/1
  def show
    render json: @template.as_json(include: { questoes: { include: :alternativas } })
  end

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
              enunciado: questao_attrs[:enunciado],
              formularios_id: questao_attrs[:formularios_id]
            )
            
            # Process alternativas if present
            if questao_attrs[:alternativas_attributes].present?
              # If alternativas_attributes is an array
              if questao_attrs[:alternativas_attributes].is_a?(Array)
                questao_attrs[:alternativas_attributes].each do |alt_attrs|
                  questao.alternativas.create!(content: alt_attrs[:content])
                end
              # If alternativas_attributes is a hash
              else
                questao_attrs[:alternativas_attributes].each do |_, alt_attrs|
                  questao.alternativas.create!(content: alt_attrs[:content])
                end
              end
            end
          end
        # If questoes_attributes is a hash (from strong params)
        else
          params[:template][:questoes_attributes].each do |_, questao_attrs|
            questao = @template.questoes.create!(
              enunciado: questao_attrs[:enunciado],
              formularios_id: questao_attrs[:formularios_id]
            )
            
            # Process alternativas if present
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
            enunciado: questao_params[:enunciado],
            formularios_id: questao_params[:formularios_id]
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

  # PATCH/PUT /templates/1
  def update
    if @template.update(template_params)
      render json: @template.as_json(include: { questoes: { include: :alternativas } })
    else
      render json: { errors: @template.errors }, status: :unprocessable_entity
    end
  end

  # DELETE /templates/1
  def destroy
    @template.destroy!
    head :no_content
  end



  private
    def set_template
      @template = Template.find(params[:id])
    end

    def template_params
      params.require(:template).permit(
        :content, 
        :user_id,
        questoes_attributes: [
          :id, 
          :enunciado, 
          :formularios_id, 
          :_destroy,
          alternativas_attributes: [:id, :content, :_destroy]
        ]
      )
    end

    def template_not_found
      render json: { error: "Template não encontrado" }, status: :not_found
    end
end
