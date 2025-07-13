class JsonProcessor
  def self.process_classes(data)
    parsed_data = JSON.parse(data)

    parsed_data.each do |disciplina_data|
      disciplina = Disciplina.find_or_create_by!(
        code: disciplina_data['code'],
        name: disciplina_data['name']
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

  def self.process_classes(data)
    parsed_data = JSON.parse(data)

    parsed_data.each do |turma_data|

        turma = Turma.find_by_code(code: turma_data["classCode"])

        alunos = turma_data["dicente"]

        alunos.each do |aluno_data|

            aluno = User.create!(
              name: aluno_data["nome"],
              major: aluno_data["curso"],
              registration: aluno_data["matricula"],
              email: aluno_data["email"],
              role: aluno_data["ocupacao"]
            )

            # TODO: enviar email pros carinhas criarem a senha

            TurmaAluno.create!(
                turma_id: turma.id,
                aluno_id: aluno.id
            )
        end
    end
  end
end