class DepartamentosController < ApplicationController
  before_action :set_departamento, only: %i[ show edit update destroy ]

  # GET /departamentos or /departamentos.json
  def index
    @departamentos = Departamento.all
  end

  # GET /departamentos/1 or /departamentos/1.json
  def show

    set_departamento

    respond_to do |format|
      format.json { render json: @departamento }
    end
  end

  # GET /departamentos/new
  def new
    @departamento = Departamento.new
    respond_to do |format|
      format.json { render json: @departamento }
    end
  end

  # GET /departamentos/1/edit
  def edit
    set_departamento

    respond_to do |format|
      format.json { render json: @departamento }
    end
  end

  # POST /departamentos or /departamentos.json
  def create
    @departamento = Departamento.new(departamento_params)

    respond_to do |format|
      if @departamento.save
        
        format.json { render json: @departamento, status: :created, location: @departamento }
      else
  
        format.json { render json: @departamento.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /departamentos/1 or /departamentos/1.json
  def update

    set_departamento

    respond_to do |format|
      if @departamento.update(departamento_params)

        format.json { render json: @departamento, status: :ok, location: @departamento }
      else
        
        format.json { render json: @departamento.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /departamentos/1 or /departamentos/1.json
  def destroy
    @departamento.destroy!

    respond_to do |format|
      
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_departamento
      @departamento = Departamento.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def departamento_params
      params.expect(departamento: [ :code, :name, :abreviation ])
    end
end
