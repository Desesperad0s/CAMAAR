class JsonProcessorService
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

  def self.process_classes(data)
    Rails.logger.info("Método process_classes chamado mas está desativado conforme solicitado")
    Rails.logger.info("Não estamos criando disciplinas/turmas, apenas usuários serão associados à turma ID 1")
    
    return {success: true, total_processed: 0, errors: []}
  rescue JSON::ParserError => e
    Rails.logger.error("JSON inválido de classes: #{e.message}")
    raise "JSON inválido de classes: #{e.message}"
  end
  def self.process_discentes(data)
    parsed_data = JSON.parse(data)
    errors = []
    processed_users = 0

    # Simplificar a abordagem - usar turma com ID 1
    begin
      turma = Turma.find(1)
      Rails.logger.info("Usando turma fixa com ID 1: #{turma.inspect}")
    rescue => e
      Rails.logger.error("Não foi possível encontrar a turma com ID 1: #{e.message}")
      # Não vamos criar turmas para simplificar, conforme solicitado
      return {success: false, total_processed: 0, errors: ["Turma com ID 1 não encontrada. Certifique-se de que existe ao menos uma turma no sistema."]}
    end

    parsed_data.each do |turma_data|
      begin
        disciplina_code = turma_data['code']
        Rails.logger.info("Processando dados para disciplina com código: #{disciplina_code} - (apenas para registro, não criando disciplinas)")
        
        # Não vamos mais verificar ou criar disciplinas/turmas
        # Comentado conforme solicitado:
        # Não criamos turmas, apenas usamos a turma ID 1

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
            
            # Validar dados do aluno
            unless aluno_data['email'].present? && aluno_data['matricula'].present?
              errors << "Dados incompletos para aluno: #{aluno_data.inspect}"
              Rails.logger.error("Dados incompletos para aluno: #{aluno_data.inspect}")
              next
            end
            
            # Verificar se o aluno já existe pelo email ou matrícula
            existing_user = User.find_by(email: aluno_data['email']) || 
                            User.find_by(registration: aluno_data['matricula'])
                            
            if existing_user
              Rails.logger.info("Aluno já existe: #{existing_user.name} - #{existing_user.email}")
              # Associar à turma ID 1
              unless TurmaAluno.exists?(turma_id: turma.id, aluno_id: existing_user.id)
                TurmaAluno.create!(turma_id: turma.id, aluno_id: existing_user.id)
                Rails.logger.info("Aluno associado à turma ID 1")
              else
                Rails.logger.info("Aluno já associado à turma ID 1")
              end
              processed_users += 1
              next
            end
            
            # Criar apenas usuário, não criar disciplinas/turmas (conforme solicitado)
            Rails.logger.info("Criando novo aluno: #{aluno_data['nome']} - #{aluno_data['email']}")
            
            # Determinar o papel do usuário
            role = 'student'
            if aluno_data['ocupacao'].present?
              ocupacao = aluno_data['ocupacao'].to_s.downcase
              role = (ocupacao == 'dicente' || ocupacao == 'aluno' || ocupacao == 'estudante') ? 'student' : 
                     (ocupacao == 'professor' || ocupacao == 'docente') ? 'professor' : 'student'
            end
            
            aluno = User.create!(
              name: aluno_data['nome'] || "Usuário #{aluno_data['matricula']}",
              major: aluno_data['curso'] || 'Não informado',
              registration: aluno_data['matricula'],
              email: aluno_data['email'],
              role: role,
              password: "padrao123"
            )

            if aluno.persisted?
              TurmaAluno.create!(
                turma_id: turma.id,
                aluno_id: aluno.id
              )
              Rails.logger.info("Aluno criado e associado à turma ID 1")
              UserMailer.send_set_password_email(aluno).deliver_now
              Rails.logger.info("Email de configuração de senha enviado para #{aluno.email}")
              
              # Enviar email com link para tela específica
              link = "https://camaar.com/tela-especifica"
              UserMailer.custom_email(aluno, "Bem vindo ao CAMAAR, para fazer as avaliações cadastre uma senha", "Olá #{aluno.name}, acesse: #{link}").deliver_now
              Rails.logger.info("Email enviado para #{aluno.email} com link para tela específica")
              
              processed_users += 1
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
      rescue => e
        errors << "Erro ao processar dados de alunos: #{e.message}"
        Rails.logger.error("Erro ao processar dados de alunos: #{e.message}")
        Rails.logger.error(e.backtrace.join("\n"))
      end
    end

    Rails.logger.info("Processamento de alunos concluído: #{processed_users} alunos processados, #{errors.length} erros")
    return {success: errors.empty?, total_processed: processed_users, errors: errors}
  rescue JSON::ParserError => e
    Rails.logger.error("JSON inválido de discentes: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
    raise "JSON inválido de discentes: #{e.message}"
  end
end