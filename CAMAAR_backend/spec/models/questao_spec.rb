require 'rails_helper'

RSpec.describe Questao, type: :model do
  describe 'associações' do
    it { should belong_to(:template).with_foreign_key(:templates_id) }
    it { should belong_to(:formulario).with_foreign_key(:formularios_id).optional(true) }
    
    # Pendente até que as tabelas sejam atualizadas com as chaves estrangeiras corretas
    it "deveria ter muitas alternativas" do
      pending "Alternativas não tem a chave estrangeira questao_id"
      should have_many(:alternativas).with_foreign_key(:questao_id)
    end
    
    it "deveria ter muitas respostas" do
      pending "Resposta não tem a chave estrangeira questao_id"
      should have_many(:respostas).class_name('Resposta').with_foreign_key(:questao_id)
    end
  end

  describe 'factory' do
    it 'tem uma factory válida' do
      expect(build(:questao, template: create(:template))).to be_valid
    end
  end

  describe 'validações' do
    it 'permite ser criada sem um formulário' do
      template = create(:template)
      questao = Questao.new(enunciado: 'Questão sem formulário', templates_id: template.id)
      expect(questao).to be_valid
    end

    it 'pode ser associada posteriormente a um formulário' do
      # Criamos os objetos sem usar factory para evitar problemas
      template = Template.create(content: "Template de teste")
      questao = Questao.create(enunciado: 'Questão sem formulário', templates_id: template.id)
      
      # Criar um formulário diretamente
      formulario = Formulario.create(name: "Formulário de teste")
      
      # Associar o formulário à questão
      questao.update(formularios_id: formulario.id)
      
      # Verificar se a associação foi feita
      expect(questao.reload.formulario).to eq(formulario)
    end
  end
end
