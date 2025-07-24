##
# FormulariosController
# Controller responsável por gerenciar formulários
class FormulariosController < ApplicationController
  before_action :set_formulario, only: %i[show update destroy]

  ##
  # Método auxiliar para opções de serialização JSON de formulários
  #
  # === Argumentos
  # Nenhum argumento recebido
  #
  # === Retorno
  # Hash de opções para o método as_json
  #
  # === Efeitos Colaterais
  # Nenhum
  #
  def formulario_json_options
    {
      include: {
        respostas: {
          include: {
            questao: { include: :alternativas }
          }
        },
        template: { only: [:id, :name, :user_id] }
      },
      methods: [:template_id]
    }
  end


  ##
  # Gera lista de cabeçalhos para o relatório Excel
  #
  # === Argumentos
  # * +formularios+ - Array de formulários
  #
  # === Retorno
  # Array de strings com os cabeçalhos
  #
  # === Efeitos Colaterais
  # Nenhum
  def all_questions_headers(formularios)
    ["ID", "Formulário", "Data de Criação"] + unique_question_headers(formularios)
  end

  ##
  # Extrai e retorna cabeçalhos únicos das questões
  #
  # === Argumentos
  # * +formularios+ - Array de formulários
  #
  # === Retorno
  # Array de strings com os títulos das questões
  #
  # === Efeitos Colaterais
  # Nenhum
  def unique_question_headers(formularios)
    formularios.flat_map do |formulario|
      formulario.respostas.map do |resposta|
        resposta.questao&.enunciado || (resposta.questao ? "Questão #{resposta.questao.id}" : nil)
      end
    end.compact.uniq
  end


  ##
  # Monta uma linha para o relatório Excel
  #
  # === Argumentos
  # * +formulario+ - Formulário
  # * +headers+ - Array de cabeçalhos
  #
  # === Retorno
  # Array com dados da linha
  #
  # === Efeitos Colaterais
  # Nenhum
  def build_excel_row(formulario, headers)
    base_row = [
      formulario.id,
      formulario.name || "Formulário #{formulario.id}",
      formulario.created_at&.strftime("%d/%m/%Y %H:%M")
    ]
    respostas_hash = respostas_hash_for_excel(formulario)
    row = base_row + Array.new(headers.length - 3, "")
    respostas_hash.each do |question_title, content|
      col_index = headers.index(question_title)
      row[col_index] = content if col_index
    end
    row
  end

  ##
  # Cria hash de respostas para facilitar montagem da linha Excel
  #
  # === Argumentos
  # * +formulario+ - Formulário
  #
  # === Retorno
  # Hash com títulos das questões e conteúdos das respostas
  #
  # === Efeitos Colaterais
  # Nenhum
  def respostas_hash_for_excel(formulario)
    formulario.respostas.each_with_object({}) do |resposta, hash|
      if resposta.questao
        question_title = resposta.questao.enunciado || "Questão #{resposta.questao.id}"
        hash[question_title] = resposta.content if resposta.content.present?
      end
    end
  end


  ##
  # Renderiza o formulário como JSON
  #
  # === Argumentos
  # * +formulario+ - Formulário
  # * +status+ - Status HTTP (default :ok)
  #
  # === Retorno
  # Renderiza JSON do formulário
  #
  # === Efeitos Colaterais
  # Nenhum
  def render_formulario_json(formulario, status = :ok)
    render  json: @formulario.as_json(
          include: { 
            respostas: { 
              include: { 
                questao: { include: :alternativas }
              }
            },
            template: { only: [:id, :name, :user_id] }
          },
          methods: [:template_id]
        ), status: status
  end

  ##
  # Lista todos os formulários do sistema
  #
  # === Argumentos
  # Nenhum argumento é necessário
  #
  # === Retorno
  # JSON contendo array de formulários com suas respostas, questões, alternativas e templates aninhados
  #
  # === Efeitos Colaterais
  # Nenhum
  #
  # Rota: GET /formularios
  def index
    @formularios = Formulario.all
    render json: @formularios.as_json(formulario_json_options)
  end

  ##
  # Exibe um formulário específico identificado pelo ID
  #
  # === Argumentos
  # * +id+ - ID do formulário a ser exibido (passado via params[:id])
  #
  # === Retorno
  # JSON contendo o formulário com suas respostas, questões, alternativas e template aninhados
  # Se o formulário não for encontrado, retorna erro 404
  #
  # === Efeitos Colaterais
  # Nenhum
  #
  # Rota: GET /formularios/1
  def show
    render_formulario_json(@formulario)
  end

  ##
  # Gera relatório em Excel com todos os formulários e suas respostas
  #
  # === Argumentos
  # Nenhum argumento é necessário
  #
  # === Retorno
  # Arquivo Excel (.xlsx) contendo relatório formatado dos formulários
  # Em caso de erro: JSON com mensagem de erro e status 500
  #
  # === Efeitos Colaterais
  # * Consulta o banco de dados para obter todos os formulários
  # * Gera arquivo Excel temporário
  # * Força download do arquivo no navegador
  #
  # Rota: GET /formularios/report/excel
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
        headers = all_questions_headers(formularios)
        workbook.add_worksheet(name: "Relatório de Formulários") do |sheet|
          header_row = sheet.add_row(headers)
          sheet.add_style "A1:#{Axlsx.cell_r(headers.length - 1, 0)}", b: true
          formularios.each do |formulario|
            sheet.add_row(build_excel_row(formulario, headers))
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


  ##
  # Cria um novo formulário no sistema
  #
  # === Argumentos
  # * +formulario+ - Hash com os dados do novo formulário (name, date, template_id, turma_id, respostas/respostas_attributes)
  #
  # === Retorno
  # * JSON com os dados do formulário criado e status 201 (success)
  # * JSON com erros de validação e status 422 (failure)
  #
  # === Efeitos Colaterais
  # * Cria um novo registro na tabela de formulários
  # * Cria respostas associadas ao formulário
  #
  # Rota: POST /formularios
def create
  # Convert respostas array to respostas_attributes array if present
  if params[:formulario] && params[:formulario][:respostas].present? && params[:formulario][:respostas].is_a?(Array)
    params[:formulario][:respostas_attributes] = params[:formulario][:respostas].map do |resposta|
      ActionController::Parameters.new(resposta).permit(:id, :questao_id, :content, :_destroy)
    end
  end
  ActiveRecord::Base.transaction do
    @formulario = Formulario.new(formulario_params)
    Rails.logger.debug "Creating formulario with attributes: #{formulario_params.inspect}"
    if @formulario.save
      @formulario.reload
      render_formulario_json(@formulario, :created)
    else
      render json: { errors: @formulario.errors }, status: :unprocessable_entity
      raise ActiveRecord::Rollback
    end
  end
end



  ##
  # Atualiza um formulário existente no sistema
  #
  # === Argumentos
  # * +id+ - ID do formulário a ser atualizado (passado via params[:id])
  # * +formulario+ - Hash com os novos dados do formulário (name, date, template_id, turma_id, respostas/respostas_attributes)
  #
  # === Retorno
  # * JSON com os dados do formulário atualizado (success)
  # * JSON com erros de validação e status 422 (failure)
  #
  # === Efeitos Colaterais
  # * Atualiza o registro do formulário no banco de dados
  # * Cria, atualiza ou remove respostas associadas ao formulário
  #
  # Rota: PATCH/PUT /formularios/1

  def update
    ActiveRecord::Base.transaction do
      respostas_to_destroy_ids, respostas_to_add = respostas_update_arrays
      @formulario.assign_attributes(formulario_params.except(:respostas_attributes))
      if @formulario.save
        destroy_and_add_respostas(respostas_to_destroy_ids, respostas_to_add)
        update_respostas_from_params
        render_formulario_json(@formulario)
      else
        Rails.logger.error "FORMULARIO UPDATE ERRORS: #{@formulario.errors.full_messages.join(', ')}"
        render json: { errors: @formulario.errors }, status: :unprocessable_entity
        raise ActiveRecord::Rollback
      end
    end
  end

  ##
  # Inicializa arrays para respostas a serem removidas/adicionadas no update
  #
  # === Argumentos
  # Nenhum argumento direto - utiliza params[:formulario]
  #
  # === Retorno
  # Arrays de IDs para remoção e dados para adição
  #
  # === Efeitos Colaterais
  # Nenhum
  def respostas_update_arrays
    respostas_to_destroy_ids = []
    respostas_to_add = []
    if params[:formulario] && params[:formulario][:respostas_attributes].present?
      attributes = params[:formulario][:respostas_attributes]
      if attributes.is_a?(Array)
        attributes.each { |resposta_attr| process_resposta_attributes(resposta_attr, respostas_to_destroy_ids, respostas_to_add) }
      elsif attributes.is_a?(Hash)
        attributes.each { |_, resposta_attr| process_resposta_attributes(resposta_attr, respostas_to_destroy_ids, respostas_to_add) }
      end
    end
    [respostas_to_destroy_ids, respostas_to_add]
  end

  ##
  # Remove e adiciona respostas após update
  #
  # === Argumentos
  # * +respostas_to_destroy_ids+ - Array de IDs de respostas a serem removidas
  # * +respostas_to_add+ - Array de dados de respostas a serem adicionadas
  #
  # === Retorno
  # Nenhum retorno direto
  #
  # === Efeitos Colaterais
  # Modifica registros de respostas no banco de dados
  def destroy_and_add_respostas(respostas_to_destroy_ids, respostas_to_add)
    if respostas_to_destroy_ids.any?
      @formulario.respostas.where(id: respostas_to_destroy_ids).destroy_all
    end
    respostas_to_add.each { |resposta_data| @formulario.respostas.create!(resposta_data) }
  end

  ##
  # Atualiza respostas existentes a partir dos parâmetros
  #
  # === Argumentos
  # Nenhum argumento direto - utiliza params[:formulario]
  #
  # === Retorno
  # Nenhum retorno direto
  #
  # === Efeitos Colaterais
  # Modifica registros de respostas no banco de dados
  def update_respostas_from_params
    if params[:formulario] && params[:formulario][:respostas_attributes].present?
      attributes = params[:formulario][:respostas_attributes]
      if attributes.is_a?(Hash)
        attributes.each { |_, resposta_attr| update_existing_resposta(resposta_attr) }
      elsif attributes.is_a?(Array)
        attributes.each { |resposta_attr| update_existing_resposta(resposta_attr) }
      end
    end
  end
  
  ##
  # Remove um formulário do sistema
  #
  # === Argumentos
  # * +id+ - ID do formulário a ser removido (através dos params)
  #
  # === Retorno
  # Status 204 (no content) indicando remoção bem-sucedida
  #
  # === Efeitos Colaterais
  # * Remove o registro do formulário do banco de dados
  # * Remove respostas associadas (dependendo das configurações do modelo)
  # Rota: DELETE /formularios/1
  def destroy
    @formulario.destroy!
    head :no_content
  end
  
  ##
  # Cria um formulário com questões e respostas em uma única operação
  #
  # === Argumentos
  # * +name+ - Nome do formulário
  # * +date+ - Data do formulário
  # * +template_id+ - (Opcional) ID do template associado
  # * +turma_id+ - (Opcional) ID da turma associada
  # * +respostas+ - Array de respostas a serem criadas (questao_id, content)
  # * +formulario[respostas_attributes]+ - Alternativa usando nested attributes
  #
  # === Retorno
  # * JSON com formulário criado incluindo respostas e questões (success)
  # * JSON com erros de validação (failure)
  #
  # === Efeitos Colaterais
  # * Cria novo formulário no banco de dados
  # * Cria respostas associadas ao formulário
  # * Valida existência das questões antes da criação
  # Rota: POST /formularios/create_with_questions
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
        if params[:respostas].present?
          params[:respostas].each do |resposta_params|
            if resposta_params[:questao_id].present?
              @formulario.respostas.create!(
                questao_id: resposta_params[:questao_id],
                content: resposta_params[:content]
              )
            end
          end
        elsif params[:formulario] && params[:formulario][:respostas_attributes].present?
          params[:formulario][:respostas_attributes].each do |resposta_params|
            if resposta_params[:questao_id].present?
              @formulario.respostas.create!(
                questao_id: resposta_params[:questao_id],
                content: resposta_params[:content]
              )
            end
          end
        end
        render_formulario_json(@formulario, :created)
      else
        render json: { errors: @formulario.errors }, status: :unprocessable_entity
        raise ActiveRecord::Rollback
      end
    end
  end

  ##
  # Retorna todas as questões associadas a um formulário
  #
  # === Argumentos
  # * +id+ - ID do formulário (através dos params)
  #
  # === Retorno
  # Array JSON contendo questões do template ou questões das respostas do formulário
  #
  # === Efeitos Colaterais
  # Nenhum - operação somente de leitura
  # Rota: GET /formularios/1/questoes
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
    ##
    # Processa atributos de resposta durante operações de update
    #
    # === Argumentos
    # * +resposta_attr+ - Hash com dados da resposta
    # * +respostas_to_destroy_ids+ - Array para IDs de respostas a serem removidas
    # * +respostas_to_add+ - Array para dados de novas respostas
    #
    # === Retorno
    # Nenhum retorno direto - modifica os arrays passados por referência
    #
    # === Efeitos Colaterais
    # * Adiciona IDs ao array de exclusão se _destroy estiver marcado
    # * Adiciona dados ao array de criação para novas respostas
    
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
    
    ##
    # Converte parâmetros de respostas para o formato respostas_attributes durante criação
    #
    # === Argumentos
    # * +formulario_attrs+ - Hash com atributos do formulário que será modificado
    #
    # === Retorno
    # Nenhum retorno direto - modifica o hash passado por referência
    #
    # === Efeitos Colaterais
    # * Converte array de respostas em hash respostas_attributes
    # * Mescla com respostas_attributes existentes se houver
    def process_resposta_attributes_for_create(formulario_attrs)
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
    
    ##
    # Processa respostas adicionais após salvar o formulário
    #
    # === Argumentos
    # Nenhum argumento direto - utiliza @formulario e params
    #
    # === Retorno
    # Nenhum retorno específico
    #
    # === Efeitos Colaterais
    # * Cria respostas adicionais que não estão no formato respostas_attributes
    # * Associa as respostas ao formulário recém-criado
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
    
    ##
    # Atualiza uma resposta existente com novos dados
    #
    # === Argumentos
    # * +resposta_attr+ - Hash com dados da resposta a ser atualizada
    #
    # === Retorno
    # Nenhum retorno específico
    #
    # === Efeitos Colaterais
    # * Atualiza o conteúdo da resposta no banco de dados
    # * Registra erros no log em caso de falha
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

    ##
    # Localiza e define o formulário baseado no ID fornecido nos parâmetros
    #
    # === Argumentos
    # Nenhum argumento direto - utiliza params[:id]
    #
    # === Retorno
    # Define a variável de instância @formulario
    #
    # === Efeitos Colaterais
    # * Define @formulario como o formulário encontrado
    # * Levanta exceção ActiveRecord::RecordNotFound se não encontrado
    def set_formulario
      @formulario = Formulario.find(params[:id])
    end


    ##
    # Filtra e permite apenas parâmetros confiáveis para criação/atualização de formulários
    #
    # === Argumentos
    # Nenhum argumento direto - utiliza params
    #
    # === Retorno
    # Hash com parâmetros filtrados e permitidos, incluindo normalização de respostas_attributes
    #
    # === Efeitos Colaterais
    # * Converte diferentes formatos de respostas para respostas_attributes padronizado
    # * Registra parâmetros processados no log para debugging
    def formulario_params
    permitted = params.require(:formulario).permit(
      :name, :date, :template_id, :turma_id,
      :publico_alvo, :remove_missing_respostas,
      respostas_attributes: [:id, :questao_id, :content, :_destroy]
    )
    # Normalize respostas_attributes to array if present as hash
    if permitted[:respostas_attributes].is_a?(Hash)
      permitted[:respostas_attributes] = permitted[:respostas_attributes].values
    end
    permitted
  end

  ##
  # Normaliza respostas_attributes para o formato hash
  #
  # === Argumentos
  # * +permitted+ - Parâmetros permitidos do formulário
  #
  # === Retorno
  # Hash de respostas_attributes normalizado
  #
  # === Efeitos Colaterais
  # Nenhum
  def normalize_respostas_attributes(permitted)
    attrs = params[:formulario][:respostas_attributes]
    if attrs.present?
      if attrs.is_a?(Hash)
        attrs
      elsif attrs.is_a?(Array)
        attrs.each_with_index.map { |a, i| [i.to_s, a.permit(:id, :questao_id, :content, :_destroy)] }.to_h
      end
    elsif params[:formulario][:respostas].present? && params[:formulario][:respostas].is_a?(Array)
      respostas_hash = {}
      params[:formulario][:respostas].each_with_index do |r, i|
        attrs = {}
        attrs[:id] = r[:id] if r[:id].present?
        attrs[:questao_id] = r[:questao_id] if r[:questao_id].present?
        attrs[:content] = r[:content] if r[:content].present?
        attrs[:_destroy] = r[:_destroy] if r[:_destroy].present?
        respostas_hash[i.to_s] = attrs
      end
      respostas_hash
    else
      permitted[:respostas_attributes]
    end
  end
end
