class FormulariosController < ApplicationController
  before_action :set_formulario, only: %i[show update destroy]

  # GET /formularios
  def index
    @formularios = Formulario.all
    render json: @formularios.as_json(include: { questoes: { include: :alternativas } })
  end

  # GET /formularios/1
  def show
    render json: @formulario.as_json(include: { questoes: { include: :alternativas } })
  end

  # POST /formularios
  def create
    @formulario = Formulario.new(formulario_params)

    if @formulario.save
      render json: @formulario, status: :created
    else
      render json: { errors: @formulario.errors }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /formularios/1
  def update
    if @formulario.update(formulario_params)
      render json: @formulario
    else
      render json: { errors: @formulario.errors }, status: :unprocessable_entity
    end
  end

  # DELETE /formularios/1
  def destroy
    @formulario.destroy!
    head :no_content
  end
  
  # POST /formularios/create_with_questions
  def create_with_questions
    ActiveRecord::Base.transaction do
      @formulario = Formulario.new(name: params[:name], date: params[:date])
      @formulario.template_id = params[:template_id] if params[:template_id].present?
      @formulario.turma_id = params[:turma_id] if params[:turma_id].present?
      
      if @formulario.save
        if params[:questoes].present?
          params[:questoes].each do |questao_params|
            questao = @formulario.questoes.create!(
              enunciado: questao_params[:enunciado],
              templates_id: questao_params[:template_id] || @formulario.template_id
            )
            
            if questao_params[:alternativas].present?
              questao_params[:alternativas].each do |alt_params|
                questao.alternativas.create!(content: alt_params[:content])
              end
            end
          end
        end
        
        render json: @formulario.as_json(include: { questoes: { include: :alternativas } }), status: :created
      else
        render json: { errors: @formulario.errors }, status: :unprocessable_entity
        raise ActiveRecord::Rollback
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_formulario
      @formulario = Formulario.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def formulario_params
      params.require(:formulario).permit(:name, :date, :template_id, :turma_id)
    end
end
