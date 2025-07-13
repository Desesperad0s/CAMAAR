class DataImportController < ApplicationController
  before_action :authenticate_request
  before_action :authorize_admin, only: [:import]
  
  # POST /import-data
  def import
    begin
      # Verificar e corrigir estrutura do banco de dados
      ensure_database_structure
      
      classes_path = Rails.root.join('classes.json').to_s
      members_path = Rails.root.join('class_members.json').to_s
      
      unless File.exist?(classes_path) && File.exist?(members_path)
        return render json: {
          success: false,
          message: "Arquivos não encontrados",
          details: {
            classes_path: classes_path,
            members_path: members_path,
            classes_exists: File.exist?(classes_path),
            members_exists: File.exist?(members_path)
          }
        }, status: :not_found
      end
      
      classes_data = File.read(classes_path)
      members_data = File.read(members_path)
      
      begin
        JSON.parse(classes_data)
        JSON.parse(members_data)
      rescue JSON::ParserError => e
        Rails.logger.error("Erro ao parsear JSON: #{e.message}")
        return render json: {
          success: false,
          message: "Arquivo JSON inválido",
          error: e.message
        }, status: :unprocessable_entity
      end
      
      # Abordagem simplificada: ignorar classes_result pois estamos apenas criando usuários
      classes_result = {success: true, total_processed: 0, errors: []}
      Rails.logger.info("Ignorando processamento de disciplinas/turmas conforme solicitado")
      
      # Processar apenas discentes e associá-los à turma ID 1
      discentes_result = JsonProcessorService.process_discentes(members_data)
      Rails.logger.info("Resultado do processamento de discentes: #{discentes_result.inspect}")
      
      # Como ignoramos as classes, o sucesso depende apenas do processamento de discentes
      all_success = discentes_result[:success]
      all_errors = discentes_result[:errors] || []
      
      if all_success
        render json: {
          success: true,
          message: "Dados importados com sucesso",
          stats: {
            users_processed: discentes_result[:total_processed],
            classes_processed: classes_result[:total_processed],
            turmas_processed: Turma.count
          }
        }, status: :ok
      else
        render json: {
          success: false,
          message: "Dados importados com erros",
          stats: {
            users_processed: discentes_result[:total_processed],
            classes_processed: classes_result[:total_processed],
            errors: all_errors
          }
        }, status: :ok
      end
    rescue => e
      # Registrar o erro completo no log para facilitar o diagnóstico
      Rails.logger.error("Erro na importação de dados: #{e.message}")
      Rails.logger.error("Backtrace: #{e.backtrace.join("\n")}")
      
      render json: {
        success: false,
        message: "Erro ao processar importação",
        error: e.message,
        backtrace: e.backtrace.first(5)
      }, status: :internal_server_error
    end
  end
  
  private
  
  def authorize_admin
    unless @current_user && @current_user.admin?
      render json: { error: 'Acesso negado. Apenas administradores podem realizar esta operação.' }, status: :forbidden
    end
  end
  
  def ensure_database_structure
    begin
      # Verificar se existe uma turma com ID 1
      turma = Turma.find_by(id: 1)
      
      unless turma
        Rails.logger.warn("Não existe turma com ID 1. Verificando se existe alguma turma no sistema...")
        
        # Verificar se existe alguma turma
        if Turma.count == 0
          Rails.logger.warn("Nenhuma turma encontrada no sistema. É necessário criar ao menos uma turma.")
          
          # Verificar se existe alguma disciplina
          if Disciplina.count == 0
            Rails.logger.warn("Nenhuma disciplina encontrada. Criando disciplina padrão...")
            
            # Verificar se existe algum departamento
            if Departamento.count == 0
              Rails.logger.warn("Nenhum departamento encontrado. Criando departamento padrão...")
              departamento = Departamento.create!(name: "Departamento de Ciência da Computação", code: "CIC")
            else
              departamento = Departamento.first
            end
            
            # Criar disciplina padrão
            disciplina = Disciplina.create!(
              name: "Disciplina Padrão",
              departamento_id: departamento.id
            )
            
            if ActiveRecord::Base.connection.column_exists?(:disciplinas, :code)
              disciplina.update_column(:code, "DISC-PADRAO")
            end
          else
            disciplina = Disciplina.first
          end
          
          # Criar turma padrão com ID 1
          Rails.logger.warn("Criando turma padrão com ID 1...")
          turma = Turma.new(
            code: "T1",
            semester: "2025/1",
            time: "08:00",
            disciplina_id: disciplina.id
          )
          
          # Forçar ID 1 (em ambiente de desenvolvimento apenas)
          turma.id = 1 if Rails.env.development?
          turma.save!
          
          Rails.logger.info("Turma padrão criada com sucesso: #{turma.inspect}")
        else
          primeira_turma = Turma.first
          Rails.logger.warn("Usando a primeira turma disponível (ID: #{primeira_turma.id}) como padrão.")
        end
      else
        Rails.logger.info("Turma com ID 1 encontrada: #{turma.inspect}")
      end
    rescue => e
      Rails.logger.error("Erro ao verificar/criar turma padrão: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
    end
  end
end
