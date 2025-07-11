require 'rails_helper'

RSpec.describe Formulario, type: :model do
  describe "associações" do
    it { should belong_to(:template).optional }
    it { should have_many(:questoes).with_foreign_key('formularios_id') }
    it { should have_many(:respostas) }
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
    it "pode ser criado com questões" do
      template = create(:template)
      formulario = create(:formulario, template: template)
      questao = create(:questao, template: template, formulario: formulario)
      
      expect(formulario.questoes).to include(questao)
    end
    
    it "pode ter respostas associadas" do
      formulario = create(:formulario)
      questao = create(:questao, formulario: formulario, template: create(:template))
      resposta = create(:resposta, formulario: formulario, questao: questao)
      
      expect(formulario.respostas).to include(resposta)
    end
  end
end
