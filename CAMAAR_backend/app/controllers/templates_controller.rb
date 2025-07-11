class TemplatesController < ApplicationController
  before_action :set_template, only: [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, with: :template_not_found

  # GET /templates
  def index
    @templates = Template.all
    render json: @templates.as_json(include: :questoes)
  end

  # GET /templates/1
  def show
    render json: @template.as_json(include: :questoes)
  end

  # POST /templates
  def create
    @template = Template.new(template_params)
    
    if @template.save
      if params[:questoes].present? && params[:questoes].is_a?(Array)
        params[:questoes].each do |questao_params|
          questao = Questao.new(
            enunciado: questao_params[:enunciado],
            templates_id: @template.id
          )
          
          if questao_params[:formularios_id].present?
            questao.formularios_id = questao_params[:formularios_id]
          end
          
          questao.save!
        end
        
        @template.reload
      end
      
      render json: @template.as_json(include: :questoes), status: :created, location: @template
    else
      render json: { errors: @template.errors }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /templates/1
  def update
    if params[:template] && params[:template][:questoes_attributes].present?
      template_basic_params = params[:template].except(:questoes_attributes)
      template_basic_params = template_basic_params.empty? ? {} : template_basic_params.permit(:content, :admin_id)
      
      if @template.update(template_basic_params)
        params[:template][:questoes_attributes].each do |questao_attr|
          next if questao_attr[:id].present? 
          
          @template.questoes.create!(enunciado: questao_attr[:enunciado])
        end
        
        @template.reload
        render json: @template.as_json(include: :questoes)
      else
        render json: { errors: @template.errors }, status: :unprocessable_entity
      end
    else
      # Normal update without questoes_attributes
      if @template.update(template_params)
        render json: @template.as_json(include: :questoes)
      else
        render json: { errors: @template.errors }, status: :unprocessable_entity
      end
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
        :admin_id,
        questoes_attributes: [:id, :enunciado, :formularios_id, :_destroy]
      )
    end

    def template_not_found
      render json: { error: "Template não encontrado" }, status: :not_found
    end
end
