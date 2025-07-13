class DepartamentosController < ApplicationController
  before_action :set_departamento, only: %i[ show edit update destroy ]

  # GET /departamentos or /departamentos.json
  def index
    @departamentos = Departamento.all
  end

  # GET /departamentos/1 or /departamentos/1.json
  def show

    set_departamento

    render json: @departamento
  end

  # GET /departamentos/new
  def new
    @departamento = Departamento.new
    render json: @departamento 
  end

  # GET /departamentos/1/edit
  def edit
    set_departamento
    render json: @departamento 
  end

  # POST /departamentos or /departamentos.json
  def create
    @departamento = Departamento.new(departamento_params)

  
    if @departamento.save
        
      render json: @departamento, status: :created, location: @departamento 
    else
      render json: @departamento.errors, status: :unprocessable_entity 
    
    end
  end

  # PATCH/PUT /departamentos/1 or /departamentos/1.json
  def update

    set_departamento

    
    if @departamento.update(departamento_params)

      render json: @departamento, status: :ok, location: @departamento 
    else
      
      render json: @departamento.errors, status: :unprocessable_entity 
      
    end
  end

  # DELETE /departamentos/1 or /departamentos/1.json
  def destroy
    @departamento.destroy!
    
    head :no_content 
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
