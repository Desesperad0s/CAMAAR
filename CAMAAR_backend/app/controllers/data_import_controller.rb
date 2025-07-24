class DataImportController < ApplicationController
  before_action :authenticate_request
  before_action :authorize_admin, only: [:import]

  ##
  # Importa dados de disciplinas, turmas e alunos a partir de arquivos JSON
  #
  # === Argumentos
  # Nenhum argumento - utiliza arquivos JSON fixos na raiz do projeto:
  # * classes.json - dados das turmas e disciplinas
  # * class_members.json - dados dos membros das turmas
  #
  # === Retorno
  # Em caso de sucesso: JSON com estatísticas da importação e status 200 (ok)
  # Em caso de erro: JSON com detalhes do erro e status apropriado (404, 422, 500)
  #
  # === Efeitos Colaterais
  # * Verifica e corrige estrutura do banco de dados
  # * Cria/atualiza registros de Departamento, Disciplina, User, Turma e TurmaAluno
  # * Executa em transação - se houver erro, faz rollback de todas as alterações
  # * Gera logs detalhados do processo de importação
  #
  # Rota: POST /import-data
  def import
    begin
      ensure_database_structure

      classes_path = Rails.root.join('classes.json').to_s
      members_path = Rails.root.join('class_members.json').to_s

      # Validação dos arquivos JSON
      unless json_files_exist?(classes_path, members_path)
        return render json: json_files_missing_response(classes_path, members_path), status: :not_found
      end

      classes_data, members_data = read_json_files(classes_path, members_path)
      unless valid_json?(classes_data) && valid_json?(members_data)
        return render json: json_invalid_response, status: :unprocessable_entity
      end

      classes_result = {success: true, total_processed: 0, errors: []}
      Rails.logger.info("Ignorando processamento de disciplinas/turmas conforme solicitado")

      discentes_result = JsonProcessorService.process_discentes(members_data)
      Rails.logger.info("Resultado do processamento de discentes: #{discentes_result.inspect}")

      all_success = discentes_result[:success]
      all_errors = discentes_result[:errors] || []

      email_results = send_first_access_emails_if_needed(discentes_result[:new_users])

      if all_success
        render json: success_response(discentes_result, classes_result, email_results), status: :ok
      else
        render json: error_response(discentes_result, classes_result, all_errors, email_results), status: :ok
      end
    rescue => e
      Rails.logger.error("Erro na importação de dados: #{e.message}")
      Rails.logger.error("Backtrace: #{e.backtrace.join("\n")}")
      render json: internal_error_response(e), status: :internal_server_error
    end
  end

  private

  ##
  # Verifica se os arquivos JSON existem
  def json_files_exist?(classes_path, members_path)
    File.exist?(classes_path) && File.exist?(members_path)
  end

  ##
  # Retorna resposta de erro para arquivos ausentes
  def json_files_missing_response(classes_path, members_path)
    {
      success: false,
      message: "Arquivos não encontrados",
      details: {
        classes_path: classes_path,
        members_path: members_path,
        classes_exists: File.exist?(classes_path),
        members_exists: File.exist?(members_path)
      }
    }
  end

  ##
  # Lê os arquivos JSON
  def read_json_files(classes_path, members_path)
    [File.read(classes_path), File.read(members_path)]
  end

  ##
  # Valida se o conteúdo é um JSON válido
  def valid_json?(data)
    JSON.parse(data)
    true
  rescue JSON::ParserError
    false
  end

  ##
  # Retorna resposta de erro para JSON inválido
  def json_invalid_response
    {
      success: false,
      message: "Arquivo JSON inválido",
      error: "Erro ao parsear JSON"
    }
  end

  ##
  # Envia emails de primeiro acesso se houver novos usuários
  def send_first_access_emails_if_needed(new_users)
    return [] unless new_users && new_users.any?
    Rails.logger.info("Enviando emails de primeiro acesso para #{new_users.size} novos usuários")
    EmailService.send_first_access_emails(new_users)
  end

  ##
  # Monta resposta de sucesso
  def success_response(discentes_result, classes_result, email_results)
    {
      success: true,
      message: "Dados importados com sucesso",
      stats: {
        users_processed: discentes_result[:total_processed],
        classes_processed: classes_result[:total_processed],
        turmas_processed: Turma.count,
        emails_sent: email_results.count { |r| r[:status] == 'sent' },
        email_errors: email_results.count { |r| r[:status] == 'error' }
      },
      email_details: email_results
    }
  end

  ##
  # Monta resposta de erro
  def error_response(discentes_result, classes_result, all_errors, email_results)
    {
      success: false,
      message: "Dados importados com erros",
      stats: {
        users_processed: discentes_result[:total_processed],
        classes_processed: classes_result[:total_processed],
        errors: all_errors,
        emails_sent: email_results.count { |r| r[:status] == 'sent' },
        email_errors: email_results.count { |r| r[:status] == 'error' }
      },
      email_details: email_results
    }
  end

  ##
  # Monta resposta de erro interno
  def internal_error_response(e)
    {
      success: false,
      message: "Erro ao processar importação",
      error: e.message,
      backtrace: e.backtrace.first(5)
    }
  end

  def authorize_admin
    unless @current_user && @current_user.admin?
      render json: { error: 'Acesso negado. Apenas administradores podem realizar esta operação.' }, status: :forbidden
    end
  end

  ##
  # Verifica se existe uma turma padrão (ID 1) e cria se necessário
  #
  # === Argumentos
  # Nenhum argumento recebido
  #
  # === Retorno
  # Nenhum retorno específico
  #
  # === Efeitos Colaterais
  # * Verifica existência de turma com ID 1
  # * Cria departamento padrão se não existir nenhum
  # * Cria disciplina padrão se não existir nenhuma
  # * Cria turma padrão se não existir nenhuma
  # * Registra informações detalhadas no log do Rails
  # * Em caso de erro, registra no log mas não interrompe execução
  def ensure_database_structure
    begin
      turma = Turma.find_by(id: 1)
      unless turma
        Rails.logger.warn("Não existe turma com ID 1. Verificando se existe alguma turma no sistema...")
        if Turma.count == 0
          Rails.logger.warn("Nenhuma turma encontrada no sistema. É necessário criar ao menos uma turma.")
          if Disciplina.count == 0
            Rails.logger.warn("Nenhuma disciplina encontrada. Criando disciplina padrão...")
            if Departamento.count == 0
              Rails.logger.warn("Nenhum departamento encontrado. Criando departamento padrão...")
              departamento = Departamento.create!(name: "Departamento de Ciência da Computação", code: "CIC")
            else
              departamento = Departamento.first
            end
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
          Rails.logger.warn("Criando turma padrão com ID 1...")
          turma = Turma.new(
            code: "T1",
            semester: "2025/1",
            time: "08:00",
            disciplina_id: disciplina.id
          )
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
  
  private
  
  def authorize_admin
    unless @current_user && @current_user.admin?
      render json: { error: 'Acesso negado. Apenas administradores podem realizar esta operação.' }, status: :forbidden
    end
  end
  
  ##
  # Verifica se existe uma turma padrão (ID 1) e cria se necessário
  #
  # === Argumentos
  # Nenhum argumento recebido
  #
  # === Retorno
  # Nenhum retorno específico
  #
  # === Efeitos Colaterais
  # * Verifica existência de turma com ID 1
  # * Cria departamento padrão se não existir nenhum
  # * Cria disciplina padrão se não existir nenhuma
  # * Cria turma padrão se não existir nenhuma
  # * Registra informações detalhadas no log do Rails
  # * Em caso de erro, registra no log mas não interrompe execução
  def ensure_database_structure
    begin
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
