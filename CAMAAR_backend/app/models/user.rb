class User < ApplicationRecord
  has_many :turma_alunos, foreign_key: :aluno_id
  has_many :turmas, through: :turma_alunos
  has_many :templates, foreign_key: :user_id
  
  attr_accessor :auth_token
  
  attr_accessor :reset_password_token, :first_access_token
  
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

  def self.authenticate(email, password)
    user = find_by(email: email)
    return user if user && user.password == password
    nil
  end
  
  # Gerar token para primeiro acesso/redefinição de senha
  def generate_reset_password_token!
    self.reset_password_token = SecureRandom.urlsafe_base64
    # Vamos usar um campo virtual para simplificar (sem mudança no banco)
    save!
    reset_password_token
  end
  
  # Gerar token para primeiro acesso
  def generate_first_access_token!
    self.first_access_token = SecureRandom.urlsafe_base64
    # Como não vamos alterar o banco, apenas retornamos o token
    first_access_token
  end
  
  # Verificar se precisar definir senha (novo usuário)
  def needs_password_reset?
    # Lógica simples: se a senha é padrão, precisa redefinir
    password == 'padrao123'
  end
end
