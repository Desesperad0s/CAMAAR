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
      # Simplificando o processo de criação para usar os nested attributes
      formulario_attrs = formulario_params.to_h
      
      # Processar respostas se estiverem presentes diretamente nos parâmetros
      process_resposta_attributes_for_create(formulario_attrs)
      
      @formulario = Formulario.new(formulario_attrs)
      
      # Log para debugging
      Rails.logger.debug "Creating formulario with attributes: #{formulario_attrs.inspect}"
      
      if @formulario.save
        # Processar respostas após salvar se necessário (para params que não são attributes aninhados)
        process_additional_respostas
        
        # Recarregar o formulário para incluir as respostas criadas
        @formulario.reload
        
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
    ActiveRecord::Base.transaction do
      respostas_to_destroy_ids = []
      respostas_to_add = []
      
      # Processar respostas_attributes se presente
      if params[:formulario] && params[:formulario][:respostas_attributes].present?
        # Pode ser um array ou um hash
        attributes = params[:formulario][:respostas_attributes]
        
        if attributes.is_a?(Array)
          attributes.each do |resposta_attr|
            process_resposta_attributes(resposta_attr, respostas_to_destroy_ids, respostas_to_add)
          end
        elsif attributes.is_a?(Hash)
          attributes.each do |_, resposta_attr|
            process_resposta_attributes(resposta_attr, respostas_to_destroy_ids, respostas_to_add)
          end
        end
      end
      
      # Atribuir os atributos ao formulário
      @formulario.assign_attributes(formulario_params.except(:respostas_attributes))
      
      if @formulario.save
        # Processar exclusões manualmente
        if respostas_to_destroy_ids.any?
          @formulario.respostas.where(id: respostas_to_destroy_ids).destroy_all
        end
        
        # Adicionar novas respostas manualmente
        respostas_to_add.each do |resposta_data|
          @formulario.respostas.create!(resposta_data)
        end
        
        # Atualizar respostas existentes
        if params[:formulario] && params[:formulario][:respostas_attributes].present?
          attributes = params[:formulario][:respostas_attributes]
          
          if attributes.is_a?(Hash)
            attributes.each do |_, resposta_attr|
              update_existing_resposta(resposta_attr)
            end
          elsif attributes.is_a?(Array)
            attributes.each do |resposta_attr|
              update_existing_resposta(resposta_attr)
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
        )
      else
        Rails.logger.error "FORMULARIO UPDATE ERRORS: #{@formulario.errors.full_messages.join(', ')}"
        render json: { errors: @formulario.errors }, status: :unprocessable_entity
        raise ActiveRecord::Rollback
      end
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
      if params[:respostas].present?
        questao_ids = params[:respostas].map { |r| r[:questao_id] }.compact
        existing_questoes = Questao.where(id: questao_ids)
        
        if existing_questoes.count != questao_ids.uniq.count
          render json: { errors: "Uma ou mais questões não existem" }, status: :unprocessable_entity
          return
        end
      end
      
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
    # Método auxiliar para processar os atributos de resposta
    def process_resposta_attributes(resposta_attr, respostas_to_destroy_ids, respostas_to_add)
      return unless resposta_attr.is_a?(Hash)
      
      if resposta_attr[:_destroy] == '1' && resposta_attr[:id].present?
        respostas_to_destroy_ids << resposta_attr[:id]
      elsif resposta_attr[:id].blank? && resposta_attr[:questao_id].present?
        respostas_to_add << {
          questao_id: resposta_attr[:questao_id],
          content: resposta_attr[:content]
        }
      end
    end
    
    # Processa parâmetros de respostas para create
    def process_resposta_attributes_for_create(formulario_attrs)
      # Verifica e converte respostas em respostas_attributes se necessário
      if params[:formulario] && params[:formulario][:respostas].present? && params[:formulario][:respostas].is_a?(Array)
        respostas_attributes = {}
        
        params[:formulario][:respostas].each_with_index do |resposta, index|
          if resposta[:questao_id].present?
            respostas_attributes[index.to_s] = {
              questao_id: resposta[:questao_id],
              content: resposta[:content]
            }
          end
        end
        
        formulario_attrs[:respostas_attributes] ||= {}
        formulario_attrs[:respostas_attributes].merge!(respostas_attributes)
      end
    end
    
    # Processa respostas adicionais após salvar o formulário
    def process_additional_respostas
      # Processa respostas que não estão no formato respostas_attributes
      if params[:formulario] && params[:formulario][:respostas].present? && !formulario_params[:respostas_attributes].present?
        params[:formulario][:respostas].each do |resposta_params|
          if resposta_params[:questao_id].present?
            @formulario.respostas.create!(
              questao_id: resposta_params[:questao_id],
              content: resposta_params[:content]
            )
          end
        end
      end
    end
    
    # Método auxiliar para atualizar uma resposta existente
    def update_existing_resposta(resposta_attr)
      return unless resposta_attr.is_a?(Hash)
      
      if resposta_attr[:id].present? && resposta_attr[:_destroy] != '1'
        begin
          resposta = @formulario.respostas.find_by(id: resposta_attr[:id])
          if resposta && resposta_attr[:content].present?
            resposta.update(content: resposta_attr[:content])
          end
        rescue => e
          Rails.logger.error "Error updating resposta: #{e.message}"
        end
      end
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_formulario
      @formulario = Formulario.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def formulario_params
      # Primeiro, obtemos os parâmetros básicos permitidos
      permitted = params.require(:formulario).permit(
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
        ]
      )
      
      # Se houver respostas_attributes como um hash, precisamos normalizá-lo
      if params[:formulario][:respostas_attributes].present?
        if params[:formulario][:respostas_attributes].is_a?(Hash)
          # Já está no formato correto como hash
          # permitted[:respostas_attributes] já está definido pelo permit
        elsif params[:formulario][:respostas_attributes].is_a?(Array)
          # Converter de array para hash com índices como chaves
          permitted[:respostas_attributes] = params[:formulario][:respostas_attributes].each_with_index.map do |attrs, i|
            [i.to_s, attrs.permit(:id, :questao_id, :content, :_destroy)]
          end.to_h
        end
      end
      
      # Se houver respostas como um array separado, vamos convertê-las para o formato respostas_attributes
      if params[:formulario][:respostas].present? && params[:formulario][:respostas].is_a?(Array)
        respostas_hash = {}
        params[:formulario][:respostas].each_with_index do |r, i|
          attrs = {}
          attrs[:id] = r[:id] if r[:id].present?
          attrs[:questao_id] = r[:questao_id] if r[:questao_id].present?
          attrs[:content] = r[:content] if r[:content].present?
          attrs[:_destroy] = r[:_destroy] if r[:_destroy].present?
          
          respostas_hash[i.to_s] = attrs
        end
        
        permitted[:respostas_attributes] ||= {}
        permitted[:respostas_attributes].merge!(respostas_hash)
      end
      
      # Adicionar debugging
      Rails.logger.debug "PERMITTED PARAMS: #{permitted.inspect}"
      permitted
    end
end
