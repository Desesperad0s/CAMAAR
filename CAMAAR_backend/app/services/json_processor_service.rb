##
# Service responsável pelo processamento e importação de dados JSON
# 
# Este service processa arquivos JSON contendo informações de turmas e alunos,
# criando usuários no sistema e associando-os a turmas existentes.
#
class JsonProcessorService
  ##
  # Importa todos os dados dos arquivos JSON (classes.json e class_members.json)
  #
  # === Argumentos
  # Nenhum argumento recebido
  #
  # === Retorno
  # Hash contendo:
  # * +:success+ - Boolean indicando sucesso geral da operação
  # * +:class_members+ - Hash com resultados do processamento de membros
  # * +:classes+ - Hash com resultados do processamento de turmas
  # * +:error+ - Mensagem de erro geral (se houver)
  #
  # === Efeitos Colaterais
  # * Lê arquivos JSON do diretório raiz do projeto
  # * Cria usuários no banco de dados
  # * Associa usuários à turma padrão (ID 1)
  # * Registra logs detalhados do processo
  #
  # === Exemplo
  #   result = JsonProcessorService.import_all_data
  #   # => { success: true, class_members: {...}, classes: {...} }
  def self.import_all_data
    begin
      # Carregar os arquivos JSON
      classes_path = Rails.root.join('classes.json')
      members_path = Rails.root.join('class_members.json')
      
      # Verificar existência dos arquivos
      unless File.exist?(classes_path) && File.exist?(members_path)
        Rails.logger.error("Arquivos JSON não encontrados: #{classes_path}, #{members_path}")
        return {
          success: false,
          error: "Arquivos JSON não encontrados",
          class_members: { error: "Arquivo não encontrado", errors: [] },
          classes: { error: "Arquivo não encontrado", errors: [] }
        }
      end
      
      # Ler os conteúdos dos arquivos
      classes_data = File.read(classes_path)
      members_data = File.read(members_path)
      
      # Processar os dados
      classes_result = process_classes(classes_data)
      members_result = process_discentes(members_data)
      
      # Verificar se houve erros em algum dos processos
      all_success = classes_result[:success] && members_result[:success]
      all_errors = classes_result[:errors] + members_result[:errors]
      
      return {
        success: all_success,
        class_members: { 
          total_processed: members_result[:total_processed],
          errors: members_result[:errors]
        },
        classes: {
          total_processed: classes_result[:total_processed],
          errors: classes_result[:errors]
        }
      }
    rescue StandardError => e
      Rails.logger.error("Erro na importação: #{e.message}\n#{e.backtrace.join("\n")}")
      return {
        success: false,
        error: e.message,
        class_members: { error: e.message, errors: [] },
        classes: { error: e.message, errors: [] }
      }
    end
  end

  ##
  # Processa dados de turmas/classes do arquivo JSON
  # 
  # NOTA: Este método está atualmente desativado conforme solicitação do projeto.
  # O sistema usa uma turma padrão (ID 1) ao invés de criar novas turmas.
  #
  # === Argumentos
  # * +data+ - String contendo dados JSON das turmas
  #
  # === Retorno
  # Hash contendo:
  # * +:success+ - Boolean (sempre true, pois método está desativado)
  # * +:total_processed+ - Integer (sempre 0)
  # * +:errors+ - Array vazio
  #
  # === Efeitos Colaterais
  # * Registra mensagem informativa no log
  # * Não cria turmas ou disciplinas
  def self.process_classes(data)
    Rails.logger.info("Método process_classes chamado mas está desativado conforme solicitado")
    Rails.logger.info("Não estamos criando disciplinas/turmas, apenas usuários serão associados à turma ID 1")
    
    return {success: true, total_processed: 0, errors: []}
  rescue JSON::ParserError => e
    Rails.logger.error("JSON inválido de classes: #{e.message}")
    raise "JSON inválido de classes: #{e.message}"
  end

  ##
  # Processa dados de discentes/alunos do arquivo JSON
  #
  # === Argumentos
  # * +data+ - String contendo dados JSON dos alunos organizados por turma
  #
  # === Retorno
  # Hash contendo:
  # * +:success+ - Boolean indicando se o processamento foi bem-sucedido
  # * +:total_processed+ - Integer com número de usuários processados
  # * +:errors+ - Array com mensagens de erro encontradas
  #
  # === Efeitos Colaterais
  # * Verifica existência da turma padrão (ID 1)
  # * Cria novos usuários no banco de dados com role 'student'
  # * Associa usuários existentes e novos à turma padrão
  # * Define senha padrão ("padrao123") para novos usuários
  # * Registra logs detalhados de cada operação
  # * Trata erros individualmente por aluno sem interromper o processo
  #
  # === Validações
  # * Email e matrícula são obrigatórios
  # * Verifica duplicatas por email ou matrícula
  # * Determina role baseado no campo 'ocupacao'
  ##
  # Refatoração: extrai métodos auxiliares para reduzir complexidade
  # Cria ou atualiza usuário a partir dos dados do aluno
  def self.create_or_update_user(aluno_data, role)
    existing_user = User.find_by(email: aluno_data['email']) || User.find_by(registration: aluno_data['matricula'])
    if existing_user
      Rails.logger.info("Aluno já existe, atualizando: #{existing_user.name} - #{existing_user.email}")
      existing_user.update!(
        name: aluno_data['nome'] || existing_user.name,
        major: aluno_data['curso'] || existing_user.major,
        registration: aluno_data['matricula'] || existing_user.registration,
        email: aluno_data['email'] || existing_user.email,
        role: role
      )
      Rails.logger.info("Dados do aluno atualizados: #{existing_user.name}")
      existing_user
    else
      Rails.logger.info("Criando novo aluno: #{aluno_data['nome']} - #{aluno_data['email']}")
      aluno = User.create!(
        name: aluno_data['nome'] || "Usuário #{aluno_data['matricula']}",
        major: aluno_data['curso'] || 'Não informado',
        registration: aluno_data['matricula'],
        email: aluno_data['email'],
        role: role,
        password: "padrao123"
      )
      Rails.logger.info("Novo aluno criado: #{aluno.name}")
      aluno
    end
  end

  ##
  # Refatoração: associa usuário à turma padrão
  def self.associate_user_to_turma(aluno, turma)
    if aluno.persisted?
      unless TurmaAluno.exists?(turma_id: turma.id, aluno_id: aluno.id)
        TurmaAluno.create!(turma_id: turma.id, aluno_id: aluno.id)
        Rails.logger.info("Aluno associado à turma ID 1")
      else
        Rails.logger.info("Aluno já associado à turma ID 1")
      end
      true
    else
      false
    end
  end

  def self.process_discentes(data)
    parsed_data = JSON.parse(data)
    errors = []
    processed_users = 0
    new_users = []

    begin
      turma = Turma.find(1)
      Rails.logger.info("Usando turma fixa com ID 1: #{turma.inspect}")
    rescue => e
      Rails.logger.error("Não foi possível encontrar a turma com ID 1: #{e.message}")
      return {success: false, total_processed: 0, new_users: [], errors: ["Turma com ID 1 não encontrada. Certifique-se de que existe ao menos uma turma no sistema."]}
    end

    parsed_data.each do |turma_data|
      disciplina_code = turma_data['code']
      Rails.logger.info("Processando dados para disciplina com código: #{disciplina_code} - (apenas para registro, não criando disciplinas)")
      alunos = turma_data['dicente']

      if alunos.nil? || !alunos.is_a?(Array)
        errors << "Formato inválido para alunos na turma com código: #{disciplina_code}"
        Rails.logger.error("Formato inválido para alunos na turma com código: #{disciplina_code}")
        next
      end

      Rails.logger.info("Processando #{alunos.length} alunos")
      alunos.each do |aluno_data|
        begin
          Rails.logger.info("Processando aluno: #{aluno_data.inspect}")
          unless aluno_data['email'].present? && aluno_data['matricula'].present?
            errors << "Dados incompletos para aluno: #{aluno_data.inspect}"
            Rails.logger.error("Dados incompletos para aluno: #{aluno_data.inspect}")
            next
          end

          # Determinar o papel do usuário
          role = 'student'
          if aluno_data['ocupacao'].present?
            ocupacao = aluno_data['ocupacao'].to_s.downcase
            role = (ocupacao == 'dicente' || ocupacao == 'aluno' || ocupacao == 'estudante') ? 'student' : 
                   (ocupacao == 'professor' || ocupacao == 'docente') ? 'professor' : 'student'
          end

          aluno = create_or_update_user(aluno_data, role)
          if associate_user_to_turma(aluno, turma)
            processed_users += 1
            new_users << aluno
          else
            errors << "Erro ao criar o usuário: #{aluno_data['email']} - #{aluno.errors.full_messages.join(', ')}"
            Rails.logger.error("Erro ao criar o usuário: #{aluno_data['email']} - #{aluno.errors.full_messages.join(', ')}")
          end
        rescue => e
          errors << "Erro ao processar aluno #{aluno_data['email'] || 'sem email'}: #{e.message}"
          Rails.logger.error("Erro ao processar aluno #{aluno_data['email'] || 'sem email'}: #{e.message}")
          Rails.logger.error(e.backtrace.join("\n"))
        end
      end
    end

    Rails.logger.info("Processamento de alunos concluído: #{processed_users} alunos processados, #{new_users.length} novos usuários, #{errors.length} erros")
    {success: errors.empty?, total_processed: processed_users, new_users: new_users, errors: errors}
  rescue JSON::ParserError => e
    Rails.logger.error("JSON inválido de discentes: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
    {success: false, total_processed: 0, new_users: [], errors: ["JSON inválido de discentes: #{e.message}"]}
  end
end