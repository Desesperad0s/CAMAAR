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

  # GET /formularios/report/excel
  def excel_report
    begin
      require 'caxlsx'
      
      formularios = Formulario.includes(respostas: { questao: :alternativas }).all
      
      begin
        if formularios.first && formularios.first.respostas.first && formularios.first.respostas.first.questao
          sample_questao = formularios.first.respostas.first.questao
          Rails.logger.info "Questao attributes available: #{sample_questao.attributes.keys.join(', ')}"
        end
        
        package = Axlsx::Package.new
        workbook = package.workbook
        
        workbook.add_worksheet(name: "Relatório de Formulários") do |sheet|
          all_questions = []
          formularios.each do |formulario|
            formulario.respostas.each do |resposta|
              if resposta.questao
                question_title = resposta.questao.enunciado || "Questão #{resposta.questao.id}"
                all_questions << question_title unless all_questions.include?(question_title)
              end
            end
          end
          
          headers = ["ID", "Formulário", "Data de Criação"] + all_questions
          
          header_row = sheet.add_row(headers)
          sheet.add_style "A1:#{Axlsx.cell_r(headers.length - 1, 0)}", b: true
          
          formularios.each do |formulario|
            row_data = [
              formulario.id,
              formulario.name || "Formulário #{formulario.id}",
              formulario.created_at&.strftime("%d/%m/%Y %H:%M")
            ]
            
            all_questions.each { |_| row_data << "" }
            
            formulario.respostas.each do |resposta|
              if resposta.questao
                question_title = resposta.questao.enunciado || "Questão #{resposta.questao.id}"
                col_index = headers.index(question_title)
                if col_index && resposta.content.present?
                  row_data[col_index] = resposta.content
                end
              end
            end
            
            sheet.add_row(row_data)
          end
          
          sheet.auto_filter = "A1:#{Axlsx.cell_r(headers.length - 1, 0)}"
        end
        
        send_data package.to_stream.read, 
          type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", 
          filename: "relatorio_formularios_#{Time.now.strftime("%Y%m%d%H%M%S")}.xlsx",
          disposition: "attachment"
      rescue NameError => e
        Rails.logger.error "Module name error: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        render json: { error: "Não foi possível gerar o relatório Excel. Erro de configuração." }, status: :internal_server_error
      end
    rescue => e
      Rails.logger.error "Failed to generate Excel report: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      render json: { error: "Não foi possível gerar o relatório Excel. Erro interno." }, status: :internal_server_error
    end
  end

  # POST /formularios
  def create
    ActiveRecord::Base.transaction do
      formulario_attrs = formulario_params.to_h
      
      process_resposta_attributes_for_create(formulario_attrs)
      
      @formulario = Formulario.new(formulario_attrs)
      
      Rails.logger.debug "Creating formulario with attributes: #{formulario_attrs.inspect}"
      
      if @formulario.save
        process_additional_respostas
        
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
