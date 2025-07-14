Dado('estou matriculado na turma {string}') do |codigo|
  @turma = Turma.find_by(codigo: codigo)
  @turma.alunos << @current_user
end

Dado('existe um formulário disponível para minha turma') do
  @formulario = FactoryBot.create(:formulario, turma: @turma)
  @questoes = FactoryBot.create_list(:questao, 3, formulario: @formulario)
end

Quando('preencho todas as questões com respostas válidas') do
  @questoes.each do |questao|
    within("#questao_#{questao.id}") do
      fill_in 'Resposta', with: 'Resposta para a questão'
    end
  end
end

Dado('que já respondi um formulário anteriormente') do
  steps %Q{
    Dado existe um formulário disponível para minha turma
    Quando eu acesso a página do formulário
    E preencho todas as questões com respostas válidas
    E clico no botão "Enviar Respostas"
  }
end

Quando('deixo algumas questões obrigatórias em branco') do
  @questoes.first(2).each do |questao|
    within("#questao_#{questao.id}") do
      fill_in 'Resposta', with: ''
    end
  end
end