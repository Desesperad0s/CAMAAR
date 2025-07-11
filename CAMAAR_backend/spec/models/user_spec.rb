require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it 'é válido com atributos válidos' do
      user = User.new(
        registration: '12345678',
        name: 'Teste Usuario',
        email: 'teste@example.com',
        password: 'senha123',
        major: 'Ciência da Computação',
        role: 'student'
      )
      expect(user).to be_valid
    end

    it 'é inválido sem uma registration' do
      user = User.new(registration: nil)
      user.valid?
      expect(user.errors[:registration]).to include("can't be blank")
    end

    it 'é inválido sem um nome' do
      user = User.new(name: nil)
      user.valid?
      expect(user.errors[:name]).to include("can't be blank")
    end

    it 'é inválido sem um email' do
      user = User.new(email: nil)
      user.valid?
      expect(user.errors[:email]).to include("can't be blank")
    end

    it 'é inválido com um email em formato incorreto' do
      user = User.new(email: 'email-invalido')
      user.valid?
      expect(user.errors[:email]).to include("is invalid")
    end

    it 'é inválido com email duplicado' do
      User.create!(
        registration: '12345678',
        name: 'Usuário Original', 
        email: 'teste@example.com',
        password: 'senha123',
        major: 'Ciência da Computação',
        role: 'student'
      )
      
      user = User.new(
        registration: '87654321',
        name: 'Novo Usuário',
        email: 'teste@example.com',
        password: 'senha123',
        major: 'Ciência da Computação',
        role: 'student'
      )
      
      user.valid?
      expect(user.errors[:email]).to include("has already been taken")
    end
  end

  # Testes de métodos do modelo
  describe 'métodos' do
    describe '#estudante?' do
      it 'retorna true quando o role é estudante' do
        user = User.new(role: 'student')
        expect(user.estudante?).to eq(true)
      end

      it 'retorna false quando o role não é estudante' do
        user = User.new(role: 'professor')
        expect(user.estudante?).to eq(false)
      end
    end

    describe '#professor?' do
      it 'retorna true quando o role é professor' do
        user = User.new(role: 'professor')
        expect(user.professor?).to eq(true)
      end

      it 'retorna false quando o role não é professor' do
        user = User.new(role: 'student')
        expect(user.professor?).to eq(false)
      end
    end
  end
end
