class TurmasController < ApplicationController
  before_action :set_turma, only: %i[ show edit update destroy ]
  

 # GET /turmas or /turmas.json
  def index
    
    @turmas = Turma.all
    render json: @turmas
  end

  # GET /turmas/1 or /turmas/1.json
  def show

    
    set_turma

    render json: @turma
  end

  # GET /turmas/new
  def new
    
    @turma = Turma.new
    render json: @turma
  end

  # GET /turmas/1/edit
  def edit
    
    set_turma
    render json: @turma


  end

  # POST /turmas or /turmas.json
  def create
    
    @turma = Turma.new(turma_params)
    if @turma.save
      render json: @turma, status: :created
    else
      render json: @turma.errors, status: :unprocessable_entity

    end
  end

  # PATCH/PUT /turmas/1 or /turmas/1.json
  def update
    

    set_turma


      if @turma.update(turma_params)

        render json: @turma, status: :ok, location: @turma
      else

        render json: @turma.errors, status: :unprocessable_entity

    end
  end

  def destroy
   

    @turma.destroy!

     head :no_content

  end
  
  # GET /turmas/1/formularios
  # Retorna todos os formulários associados a uma turma específica
  def formularios
    @turma = Turma.find(params[:id])
    @formularios = @turma.formularios
    
    render json: @formularios
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_turma
      @turma = Turma.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def turma_params
      params.require(:turma).permit(:code, :number, :semester, :time, :disciplina_id)
    end
end