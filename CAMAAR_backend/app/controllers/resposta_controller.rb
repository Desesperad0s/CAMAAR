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
