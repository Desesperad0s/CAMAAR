
require 'rails_helper'

RSpec.describe 'Gerenciamento de Templates', type: :feature do
  let(:admin) { create(:user, :admin) }

  before do
    login_as(admin)
  end

  describe 'Criar template' do
    scenario 'admin cria um novo template com sucesso' do
      visit new_template_path

      fill_in 'Nome', with: 'Template de Avaliação'
      fill_in 'Descrição', with: 'Template para avaliação de disciplinas'

      click_button 'Adicionar Questão'
      within('.questao-fields:first') do
        fill_in 'Enunciado', with: 'Como você avalia a disciplina?'
        select 'Múltipla escolha', from: 'Tipo'
      end

      click_button 'Salvar Template'

      expect(page).to have_content('Template criado com sucesso')
      expect(Template.last.name).to eq('Template de Avaliação')
    end
  end
end