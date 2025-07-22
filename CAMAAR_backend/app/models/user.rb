##
# Modelo representando usuários do sistema CAMAAR
#
# Os usuários podem ter diferentes roles: student, professor ou admin.
# Estudantes são associados a turmas através da model TurmaAluno.
# Professores e admins podem criar templates de formulários.
#
class User < ApplicationRecord
  has_many :turma_alunos, foreign_key: :aluno_id
  has_many :turmas, through: :turma_alunos
  has_many :templates, foreign_key: :user_id
  
  attr_accessor :auth_token

  validates :registration, presence: true
  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }, uniqueness: true
  validates :role, presence: true, inclusion: { in: ['student', 'professor', 'admin'] }
  validates :password, presence: true, length: { minimum: 6 }, on: :create
  
  ##
  # Verifica se o usuário é um estudante
  #
  # === Argumentos
  # Nenhum argumento
  #
  # === Retorno
  # Boolean - true se o role for 'student', false caso contrário
  #
  # === Efeitos Colaterais
  # Nenhum - método apenas de consulta
  def estudante?
    role == 'student'
  end
  
  ##
  # Verifica se o usuário é um professor
  #
  # === Argumentos
  # Nenhum argumento
  #
  # === Retorno
  # Boolean - true se o role for 'professor', false caso contrário
  #
  # === Efeitos Colaterais
  # Nenhum - método apenas de consulta
  def professor?
    role == 'professor'
  end
  
  ##
  # Verifica se o usuário é um administrador
  #
  # === Argumentos
  # Nenhum argumento
  #
  # === Retorno
  # Boolean - true se o role for 'admin', false caso contrário
  #
  # === Efeitos Colaterais
  # Nenhum - método apenas de consulta
  def admin?
    role == 'admin'
  end

  ##
  # Autentica um usuário através de email e senha
  #
  # === Argumentos
  # * +email+ - Email do usuário
  # * +password+ - Senha do usuário
  #
  # === Retorno
  # * User object se autenticação for bem-sucedida
  # * nil se email não for encontrado ou senha estiver incorreta
  #
  # === Efeitos Colaterais
  # * Consulta o banco de dados para encontrar usuário por email
  # * Compara senha fornecida com senha armazenada
  #
  # === Nota
  # ATENÇÃO: Este método compara senhas em texto plano, 
  # o que não é uma prática segura para produção.
  # Recomenda-se usar has_secure_password do Rails.
  def self.authenticate(email, password)
    user = find_by(email: email)
    return user if user && user.password == password
    nil
  end
end
