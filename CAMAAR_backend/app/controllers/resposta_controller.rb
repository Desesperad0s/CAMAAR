class RespostaController < ApplicationController
  before_action :set_resposta, only: %i[show update destroy]

  # GET /resposta
  def index
    @respostas = Resposta.all
    render json: @respostas
  end

  # GET /resposta/1
  def show
    render json: @resposta
  end

  # POST /resposta
  def create
    @resposta = Resposta.new(resposta_params)

    if @resposta.save
      render json: @resposta, status: :created
    else
      render json: { errors: @resposta.errors }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /resposta/1
  def update
    if @resposta.update(resposta_params)
      render json: @resposta
    else
      render json: { errors: @resposta.errors }, status: :unprocessable_entity
    end
  end

  # DELETE /resposta/1
  def destroy
    @resposta.destroy!
    head :no_content
  end
  
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
        questao_texto: questao&.enunciado || "Questão desconhecida",
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
    # Use callbacks to share common setup or constraints between actions.
    def set_resposta
      @resposta = Resposta.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def resposta_params
      params.require(:resposta).permit(:content, :questao_id, :formulario_id)
    end
end
