class DisciplinasController < ApplicationController
  before_action :set_disciplina, only: %i[ show edit update destroy ]

   # GET /disciplinas or /disciplinas.json
  def index
    @disciplinas = Disciplina.all

    render json: @disciplinas
  end

  # GET /disciplinas/1 or /disciplinas/1.json
  def show

    set_disciplina

    render json: @disciplina
  end

  # GET /disciplinas/new
  def new
    @disciplina = Disciplina.new
    render json: @disciplina
  end

  # GET /disciplinas/1/edit
  def edit
    set_turma
    render json: @turma
  end

  # POST /disciplinas or /disciplinas.json
  def create
    @disciplina = Disciplina.new(disciplina_params)

    if @disciplina.save
      render json: @disciplina, status: :created, location: @disciplina
    else
      render json: @disciplina.errors, status: :unprocessable_entity

    end
  end

  # PATCH/PUT /disciplinas/1 or /disciplinas/1.json
  def update

    set_disciplina

    if @disciplina.update(disciplina_params)
        render json: @disciplina, status: :ok, location: @disciplina
    else
        render json: @disciplina.errors, status: :unprocessable_entity 

    end
  end

  # DELETE /disciplinas/1 or /disciplinas/1.json
  def destroy
    @disciplina.destroy!
  
    head :no_content
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_disciplina
      @disciplina = Disciplina.find(params.require(:id))
    end

    # Only allow a list of trusted parameters through.
    def disciplina_params
      params.require(:disciplina).permit(:name, :code, :departamento_id)
    end
end
