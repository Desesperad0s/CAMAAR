require 'rails_helper'

RSpec.describe Template, type: :model do
  describe 'associações' do
    it { should belong_to(:admin).with_foreign_key(:admin_id).optional(true) }
    it { should have_many(:questoes).with_foreign_key(:templates_id).dependent(:destroy) }
    
    it "deveria ter muitos formulários" do
      pending "Formulario não tem a chave estrangeira template_id"
      should have_many(:formularios).with_foreign_key(:template_id)
    end
    
    it { should accept_nested_attributes_for(:questoes).allow_destroy(true) }
  end

  describe 'factory' do
    it 'tem uma factory válida' do
      expect(build(:template)).to be_valid
    end

    it 'pode criar um template com questões' do
      template = create(:template_with_questions, questions_count: 2)
      expect(template.questoes.count).to eq(2)
    end
  end

  describe 'criação com questões aninhadas' do
    it 'permite criar um template com questões via atributos aninhados' do
      template_attrs = {
        content: 'Template com questões aninhadas',
        questoes_attributes: [
          { enunciado: 'Primeira questão' },
          { enunciado: 'Segunda questão' }
        ]
      }

      template = Template.create(template_attrs)
      expect(template).to be_valid
      expect(template.questoes.count).to eq(2)
      expect(template.questoes.map(&:enunciado)).to include('Primeira questão', 'Segunda questão')
    end
  end
end
