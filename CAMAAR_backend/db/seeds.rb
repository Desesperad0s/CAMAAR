# Script de seed para o sistema CAMAAR
# Este script insere dados iniciais no banco de dados para testes
# Pode ser executado com o comando: rails db:seed
# Para recriar o banco: rails db:reset (drop + create + migrate + seed)

# Limpar tabelas existentes para evitar duplicação
puts "Limpando o banco de dados..."
# Ordem de limpeza importante por causa das chaves estrangeiras
TurmaAluno.destroy_all rescue puts "Tabela TurmaAluno já vazia"
Turma.destroy_all rescue puts "Tabela Turma já vazia"
Disciplina.destroy_all rescue puts "Tabela Disciplina já vazia"
User.destroy_all rescue puts "Tabela User já vazia"
Departamento.destroy_all rescue puts "Tabela Departamento já vazia"
puts "Banco de dados limpo!"

# Criar Departamentos
puts "Criando departamentos..."
departamentos = [
  { code: 'CIC', name: 'Departamento de Ciência da Computação', abreviation: 'CIC' },
  { code: 'EST', name: 'Departamento de Estatística', abreviation: 'EST' },
  { code: 'MAT', name: 'Departamento de Matemática', abreviation: 'MAT' },
  { code: 'FIS', name: 'Departamento de Física', abreviation: 'FIS' },
  { code: 'ECO', name: 'Departamento de Economia', abreviation: 'ECO' }
]

departamentos_criados = {}
departamentos.each do |dept|
  departamento = Departamento.create!(dept)
  departamentos_criados[dept[:code]] = departamento
end
puts "#{departamentos.size} departamentos criados!"

# Criar Disciplinas
puts "Criando disciplinas..."
disciplinas = [
  { name: 'Algoritmos e Programação de Computadores', departamento: departamentos_criados['CIC'] },
  { name: 'Estruturas de Dados', departamento: departamentos_criados['CIC'] },
  { name: 'Engenharia de Software', departamento: departamentos_criados['CIC'] },
  { name: 'Cálculo 1', departamento: departamentos_criados['MAT'] },
  { name: 'Álgebra Linear', departamento: departamentos_criados['MAT'] },
  { name: 'Estatística Aplicada', departamento: departamentos_criados['EST'] },
  { name: 'Física 1', departamento: departamentos_criados['FIS'] },
  { name: 'Macroeconomia', departamento: departamentos_criados['ECO'] }
]

# disciplinas.each do |disc|
#   Disciplina.create!(disc)
# end
puts "#{disciplinas.size} disciplinas criadas!"

# Criar Usuários - Admins, Professores e Estudantes
puts "Criando usuários..."

# Admins
admin_users = [
  { registration: 'ADM001', name: 'Admin Principal', email: 'admin@camaar.com', password: 'admin123', role: 'admin' },
  { registration: 'ADM002', name: 'Suporte Admin', email: 'suporte@camaar.com', password: 'suporte123', role: 'admin' }
]

# Professores
professor_users = [
  { registration: 'PROF001', name: 'João Silva', email: 'joao.silva@unb.br', password: 'senha123', role: 'professor', major: 'Ciência da Computação' },
  { registration: 'PROF002', name: 'Maria Santos', email: 'maria.santos@unb.br', password: 'senha123', role: 'professor', major: 'Matemática' },
  { registration: 'PROF003', name: 'Carlos Ferreira', email: 'carlos.ferreira@unb.br', password: 'senha123', role: 'professor', major: 'Estatística' }
]

# Estudantes
student_users = [
  { registration: '180019999', name: 'Ana Oliveira', email: 'ana.oliveira@aluno.unb.br', password: 'senha123', role: 'student', major: 'Ciência da Computação' },
  { registration: '190029999', name: 'Pedro Costa', email: 'pedro.costa@aluno.unb.br', password: 'senha123', role: 'student', major: 'Engenharia de Software' },
  { registration: '200039999', name: 'Júlia Pereira', email: 'julia.pereira@aluno.unb.br', password: 'senha123', role: 'student', major: 'Ciência da Computação' },
  { registration: '210049999', name: 'Lucas Souza', email: 'lucas.souza@aluno.unb.br', password: 'senha123', role: 'student', major: 'Matemática' },
  { registration: '220059999', name: 'Isabela Lima', email: 'isabela.lima@aluno.unb.br', password: 'senha123', role: 'student', major: 'Estatística' }
]

# Criar todos os usuários
all_users = admin_users + professor_users + student_users
all_users.each do |user_data|
  user = User.create!(user_data)
  puts "Usuário criado: #{user.name} (#{user.role})"
end

puts "#{all_users.size} usuários criados com sucesso!"

# Criar Turmas
puts "Criando turmas..."
# Pegar as disciplinas criadas
disciplinas_criadas = Disciplina.all.to_a
professores_criados = User.where(role: 'professor').to_a

# Criar algumas turmas
# Nota: A associação com disciplinas será tratada depois se necessário através de uma migração
turmas = [
  { name: 'Turma A1', code: 'APC-01', semester: '2025/1', time: 'SEG-QUA 14:00-16:00' }, 
  { name: 'Turma B1', code: 'EDA-01', semester: '2025/1', time: 'TER-QUI 10:00-12:00' },
  { name: 'Turma C1', code: 'ESW-01', semester: '2025/1', time: 'SEG-SEX 16:00-18:00' },
  { name: 'Turma D1', code: 'CAL-01', semester: '2025/1', time: 'TER-QUI 08:00-10:00' },
  { name: 'Turma E1', code: 'ALG-01', semester: '2025/1', time: 'SEG-QUA 10:00-12:00' }
]

turmas_criadas = []
turmas.each do |turma_data|
  turma = Turma.create!(turma_data)
  turmas_criadas << turma
  puts "Turma criada: #{turma.name} (#{turma.code})"
end

puts "#{turmas_criadas.size} turmas criadas!"

# Associar alunos às turmas
puts "Associando alunos às turmas..."
alunos = User.where(role: 'student').to_a

# Cada aluno se matricula em 2-3 turmas aleatoriamente
alunos.each do |aluno|
  # Seleciona 2 ou 3 turmas aleatoriamente para cada aluno
  num_turmas = rand(2..3)
  turmas_do_aluno = turmas_criadas.sample(num_turmas)
  
  turmas_do_aluno.each do |turma|
    # Inserção direta para evitar problemas de associação
    TurmaAluno.create!(turma_id: turma.id, aluno_id: aluno.id)
    puts "Aluno #{aluno.name} matriculado na turma #{turma.name}"
  end
end

puts "Matrículas de alunos concluídas!"

# Criar Templates
puts "Criando templates de formulários..."
if defined?(Template)
  # Encontrar usuários admin
  admins = User.where(role: 'admin').to_a
  
  if admins.any?
    # Criar alguns templates de exemplo
    templates = [
      { content: 'Template de Avaliação de Disciplina', user_id: admins.first.id },
      { content: 'Template de Avaliação de Professor', user_id: admins.last.id },
      { content: 'Template de Pesquisa de Satisfação', user_id: admins.first.id }
    ]
    
    templates.each do |template_data|
      template = Template.create!(template_data)
      
      # Criar algumas questões para cada template
      questoes_exemplos = [
        { enunciado: 'Como você avalia o conteúdo da disciplina?' },
        { enunciado: 'O professor explica bem o conteúdo?' },
        { enunciado: 'As avaliações foram justas?' },
        { enunciado: 'O que poderia ser melhorado?' }
      ]
      
      questoes_exemplos.each do |questao_data|
        questao = template.questoes.create!(questao_data)
        
        # Criar alternativas para cada questão
        alternativas = [
          { content: 'Excelente' },
          { content: 'Bom' },
          { content: 'Regular' },
          { content: 'Ruim' },
          { content: 'Péssimo' }
        ]
        
        alternativas.each do |alt_data|
          questao.alternativas.create!(alt_data)
        end
      end
      
      puts "Template criado: #{template.content} com #{template.questoes.count} questões"
    end
    
    puts "#{templates.size} templates criados com sucesso!"
  else
    puts "Nenhum admin encontrado para criar templates. Pulando criação de templates."
  end
else
  puts "Modelo Template não encontrado, pulando criação de templates."
end

puts "Seed finalizado com sucesso!"
