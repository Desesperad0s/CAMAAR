class JsonProcessor
  def self.process_classes(data)
    parsed_data = JSON.parse(data)

    parsed_data.each do |disciplina_data|
      disciplina = Disciplina.create!(
        code: disciplina_data['code'],
        name: disciplina_data['name'],
        departamento_id: 1
      )

      turma_data = disciplina_data['class']
      Turma.create!(
        code: turma_data['classCode'],
        semester: turma_data['semester'],
        time: turma_data['time'],
        disciplina_id: disciplina.id
      )
    end
  rescue JSON::ParserError => e
    raise "JSON inválido: #{e.message}"
  end

  def self.process_discentes(data)
    parsed_data = JSON.parse(data)

    parsed_data.each do |turma_data|
      turma = Turma.joins(:disciplina).find_by(disciplinas: { code: turma_data['code'] })

      alunos = turma_data['dicente']

      alunos.each do |aluno_data|
        aluno = User.create!(
          name: aluno_data['nome'],
          major: aluno_data['curso'],
          registration: aluno_data['matricula'],
          email: aluno_data['email'],
          role: (aluno_data['ocupacao'] == 'dicente' ? 'student' : 'professor'),
          password: "padrao"
        )

        #TODO: add the email to send
        if aluno.persisted?
            TurmaAluno.create!(
                turma_id: turma.id,
                aluno_id: aluno.id
            )
        else
                raise "Erro ao criar o usuário: #{aluno.errors.full_messages.join(', ')}"
        end
      end
    end

    rescue JSON::ParserError => e
        raise "JSON inválido: #{e.message}"
  end
end