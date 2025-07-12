class User < ApplicationRecord
  has_many :turmas_alunos
  
  attr_accessor :auth_token

  validates :registration, presence: true
  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }, uniqueness: true
  validates :role, presence: true, inclusion: { in: ['student', 'professor', 'admin'] }
  validates :password, presence: true, length: { minimum: 6 }, on: :create
  
  def estudante?
    role == 'student'
  end
  
  def professor?
    role == 'professor'
  end
  
  def admin?
    role == 'admin'
  end

  # Método simples para autenticar usuários
  def self.authenticate(email, password)
    user = find_by(email: email)
    return user if user && user.password == password
    nil
  end
end
