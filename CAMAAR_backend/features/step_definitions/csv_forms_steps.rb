require 'csv'

Dado('que estou logado como administrador') do
  visit('/login')
  fill_in 'Email', with: 'admin@admin.unb.br'
  fill_in 'Senha', with: 'senha_admin'
  click_button 'Entrar'
  expect(page).to have_current_path('/gerenciamento')
end

Dado('estou na página de resultados do formulário') do
  visit('/resultados')
  expect(page).to have_content('Resultados')
end

Dado('existem respostas preenchidas no formulário') do
  expect(page).to have_selector('.avaliacoes-list .card')
  @formulario_com_respostas = true
end

Dado('não existem respostas preenchidas no formulário') do
  expect(page).not_to have_selector('.avaliacoes-list .card')
  @formulario_com_respostas = false
end

Quando('clico no botão {string}') do |botao|
  @downloads_before = Dir[File.join(Downloads::PATH, '*.csv')].length
  
  click_button botao

  sleep 2 if @formulario_com_respostas
end

Então('um arquivo CSV deve ser gerado para download') do
  downloads_after = Dir[File.join(Downloads::PATH, '*.csv')].length
  expect(downloads_after).to eq(@downloads_before + 1)

  @latest_csv = Dir[File.join(Downloads::PATH, '*.csv')].max_by { |f| File.mtime(f) }
  expect(File.exist?(@latest_csv)).to be true
end

Então('o arquivo deve conter os dados dos resultados do formulário') do
  csv_content = CSV.read(@latest_csv, headers: true)
 
  expect(csv_content.headers).to include('Turma', 'Questão', 'Resposta')

  expect(csv_content.size).to be > 0

  File.delete(@latest_csv)
end

Então('uma mensagem de erro deve ser exibida dizendo {string}') do |mensagem|
  expect(page).to have_content(mensagem)
end

Então('nenhum arquivo CSV deve ser gerado') do
  downloads_after = Dir[File.join(Downloads::PATH, '*.csv')].length
  expect(downloads_after).to eq(@downloads_before)
end

module Downloads
  PATH = File.join(Dir.home, "Downloads")
  
  def self.clear
    FileUtils.rm_f(Dir[File.join(PATH, "*.csv")])
  end
end