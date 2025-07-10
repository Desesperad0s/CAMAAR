class TurmasController < ApplicationController
  before_action :set_turma, only: %i[ show edit update destroy ]

  # GET /turmas or /turmas.json
  def index
    @turmas = Turma.all
  end

  # GET /turmas/1 or /turmas/1.json
  def show

    set_turma

    respond_to do |format|
      format.json { render json: @turma}
    end
  end

  # GET /turmas/new
  def new
    @turma = Turma.new
    respond_to do |format|
      format.json { render json: @turma }
    end
  end

  # GET /turmas/1/edit
  def edit
    set_turma
    respond_to do |format|
      format.json { render json: @turma}
    end
  end

  # POST /turmas or /turmas.json
  def create
    @turma = Turma.new(turma_params)
    respond_to do |format|
      if @turma.save
      
        format.json { render :show, status: :created, location: @turma }
      else
      
        format.json { render json: @turma.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /turmas/1 or /turmas/1.json
  def update

    set_turma
    
    respond_to do |format|
      if @turma.update(turma_params)
        
        format.json { render json: @turma, status: :ok, location: @turma }
      else
        
        format.json { render json: @turma.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /turmas/1 or /turmas/1.json
  def destroy
    
    @turma.destroy!

    respond_to do |format|
     
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_turma
      @turma = Turma.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def turma_params
      params.expect(turma: [ :code, :number, :semester, :time ])
    end
end
