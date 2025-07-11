require 'rails_helper'

RSpec.describe Alternativa, type: :model do
  describe 'associações' do
    it { should belong_to(:questao) }
  end

  describe 'validações' do
    it { should validate_presence_of(:content) }
  end

  describe 'factory' do
    it 'tem uma factory válida' do
      questao = create(:questao, template: create(:template))
      alternativa = build(:alternativa, questao: questao)
      expect(alternativa).to be_valid
    end
  end
end
