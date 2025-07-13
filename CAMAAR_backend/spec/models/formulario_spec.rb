require 'rails_helper'

RSpec.describe Formulario, type: :model do
  describe "associações" do
    it { should belong_to(:template).optional }
    it { should have_many(:respostas) }
    it { should have_many(:questoes).through(:respostas) }
  end
  
  describe "validações" do
    it "é válido com atributos válidos" do
      formulario = build(:formulario)
      expect(formulario).to be_valid
    end
    
    it "é inválido sem um nome" do
      formulario = build(:formulario, name: nil)
      expect(formulario).to_not be_valid
    end
    
    it "é inválido sem uma data" do
      formulario = build(:formulario, date: nil)
      expect(formulario).to_not be_valid
    end
  end
  
  describe "comportamentos" do
    it "pode ser associado a questões através de respostas" do
      template = create(:template)
      formulario = create(:formulario, template: template)
      questao = create(:questao, templates_id: template.id)
      resposta = create(:resposta, formulario: formulario, questao: questao)
      
      expect(formulario.questoes).to include(questao)
    end
    
    it "pode ter respostas associadas" do
      formulario = create(:formulario)
      questao = create(:questao, templates_id: create(:template).id)
      resposta = create(:resposta, formulario: formulario, questao: questao)
      
      expect(formulario.respostas).to include(resposta)
      expect(formulario.questoes).to include(questao)
    end
  end
end
