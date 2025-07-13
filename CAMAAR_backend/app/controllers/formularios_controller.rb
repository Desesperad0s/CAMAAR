class FormulariosController < ApplicationController
  before_action :set_formulario, only: %i[show update destroy]

  # GET /formularios
  def index
    @formularios = Formulario.all
    render json: @formularios.as_json(
      include: { 
        respostas: { 
          include: { 
            questao: { include: :alternativas }
          }
        },
        template: { only: [:id, :name, :user_id] }
      },
      methods: [:template_id]
    )
  end

  # GET /formularios/1
  def show
    render json: @formulario.as_json(
      include: { 
        respostas: { 
          include: { 
            questao: { include: :alternativas }
          }
        },
        template: { only: [:id, :name, :user_id] }
      },
      methods: [:template_id]
    )
  end

  # POST /formularios
  def create
    ActiveRecord::Base.transaction do
      @formulario = Formulario.new(formulario_params)

      if @formulario.save
        if params[:formulario] && params[:formulario][:respostas].present?
          params[:formulario][:respostas].each do |resposta_params|
            if resposta_params[:questao_id].present?
              questao_id = resposta_params[:questao_id]
              
              @formulario.respostas.create!(
                questao_id: questao_id,
                content: resposta_params[:content]
              )
            end
          end
        end
        
        render json: @formulario.as_json(
          include: { 
            respostas: { 
              include: { 
                questao: { include: :alternativas }
              }
            },
            template: { only: [:id, :name, :user_id] }
          },
          methods: [:template_id]
        ), status: :created
      else
        render json: { errors: @formulario.errors }, status: :unprocessable_entity
        raise ActiveRecord::Rollback
      end
    end
  end

  # PATCH/PUT /formularios/1
  def update
    @formulario.assign_attributes(formulario_params)
    
    # Para debugging
    Rails.logger.debug "FORMULARIO PARAMS: #{formulario_params.inspect}"
    Rails.logger.debug "FORMULARIO ATTRIBUTES: #{@formulario.attributes.inspect}"
    Rails.logger.debug "FULL PARAMS: #{params.inspect}"
    
    if @formulario.save
      render json: @formulario.as_json(
        include: { 
          respostas: { 
            include: { 
              questao: { include: :alternativas }
            }
          },
          template: { only: [:id, :name, :user_id] }
        },
        methods: [:template_id]
      )
    else
      Rails.logger.error "FORMULARIO UPDATE ERRORS: #{@formulario.errors.full_messages.join(', ')}"
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
      # Create the formulario with the template_id explicitly
      @formulario = Formulario.new(name: params[:name], date: params[:date])
      @formulario.template_id = params[:template_id] if params[:template_id].present?
      @formulario.turma_id = params[:turma_id] if params[:turma_id].present?
      
      if @formulario.save
        # Only create responses for existing questions
        if params[:respostas].present?
          params[:respostas].each do |resposta_params|
            # We require a questao_id to create a response
            if resposta_params[:questao_id].present?
              # Create the resposta using an existing question
              @formulario.respostas.create!(
                questao_id: resposta_params[:questao_id],
                content: resposta_params[:content]
              )
            end
          end
        elsif params[:formulario] && params[:formulario][:respostas_attributes].present?
          # Support for nested attributes format
          params[:formulario][:respostas_attributes].each do |resposta_params|
            if resposta_params[:questao_id].present?
              @formulario.respostas.create!(
                questao_id: resposta_params[:questao_id],
                content: resposta_params[:content]
              )
            end
          end
        end
        
        # Return a comprehensive response with all related data
        render json: @formulario.as_json(
          include: { 
            respostas: { 
              include: { 
                questao: { include: :alternativas }
              }
            },
            template: { only: [:id, :name, :user_id] }
          },
          methods: [:template_id]
        ), status: :created
      else
        render json: { errors: @formulario.errors }, status: :unprocessable_entity
        raise ActiveRecord::Rollback
      end
    end
  end

  # GET /formularios/1/questoes
  def questoes
    @formulario = Formulario.find(params[:id])
    
    if @formulario.template
      @questoes = @formulario.template.questoes
    else
      # Tenta buscar questões associadas através das respostas
      questoes_ids = @formulario.respostas.pluck(:questao_id).uniq
      @questoes = Questao.where(id: questoes_ids)
    end
    
    render json: @questoes
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_formulario
      @formulario = Formulario.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def formulario_params
      params.require(:formulario).permit(
        :name, 
        :date, 
        :template_id, 
        :turma_id,
        :remove_missing_respostas,
        respostas_attributes: [
          :id, 
          :questao_id, 
          :content, 
          :_destroy
        ],
        respostas: [
          :id,
          :questao_id,
          :content
        ]
      )
    end
end
