require 'rails_helper'

RSpec.describe Questao, type: :model do
  describe 'associações' do
    it { should belong_to(:template).with_foreign_key(:templates_id).optional(true) }
    
    it "deveria ter muitas alternativas" do
      should have_many(:alternativas).with_foreign_key(:questao_id)
    end
    
    it "deveria ter muitas respostas" do
      should have_many(:respostas).class_name('Resposta').with_foreign_key(:questao_id)
    end
    
    it "deveria ter muitos formulários através de respostas" do
      should have_many(:formularios).through(:respostas)
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

    it 'pode ser associada a um formulário através de respostas' do
      # Criamos os objetos sem usar factory para evitar problemas
      template = Template.create(content: "Template de teste")
      questao = Questao.create(enunciado: 'Questão sem formulário', templates_id: template.id)
      
      formulario = Formulario.create(name: "Formulário de teste", date: Date.today)
      
      # Criar uma resposta que associa questão e formulário
      Resposta.create(formulario: formulario, questao: questao, content: "Resposta de teste")
      
      # Verificar se a associação foi feita através da resposta
      expect(questao.reload.formularios).to include(formulario)
      expect(formulario.reload.questoes).to include(questao)
    end
  end
end
