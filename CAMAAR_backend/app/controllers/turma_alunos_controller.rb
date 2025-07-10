class TurmaAlunosController < ApplicationController
  before_action :set_turma_aluno, only: %i[ show edit update destroy ]

  # GET /turma_alunos or /turma_alunos.json
  def index
    @turma_alunos = TurmaAluno.all
  end

  # GET /turma_alunos/1 or /turma_alunos/1.json
  def show
  end

  # GET /turma_alunos/new
  def new
    @turma_aluno = TurmaAluno.new
  end

  # GET /turma_alunos/1/edit
  def edit
  end

  # POST /turma_alunos or /turma_alunos.json
  def create
    @turma_aluno = TurmaAluno.new(turma_aluno_params)

    respond_to do |format|
      if @turma_aluno.save
        format.html { redirect_to @turma_aluno, notice: "Turma aluno was successfully created." }
        format.json { render :show, status: :created, location: @turma_aluno }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @turma_aluno.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /turma_alunos/1 or /turma_alunos/1.json
  def update
    respond_to do |format|
      if @turma_aluno.update(turma_aluno_params)
        format.html { redirect_to @turma_aluno, notice: "Turma aluno was successfully updated." }
        format.json { render :show, status: :ok, location: @turma_aluno }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @turma_aluno.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /turma_alunos/1 or /turma_alunos/1.json
  def destroy
    @turma_aluno.destroy!

    respond_to do |format|
      format.html { redirect_to turma_alunos_path, status: :see_other, notice: "Turma aluno was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_turma_aluno
      @turma_aluno = TurmaAluno.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def turma_aluno_params
      params.fetch(:turma_aluno, {})
    end
end
