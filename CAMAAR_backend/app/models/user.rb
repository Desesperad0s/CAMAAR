##
##
# User
#
# Model responsável por representar usuários do sistema.
# Gerencia autenticação, permissões, associação a turmas e envio de emails de acesso.
#
# Principais responsabilidades:
# - Armazenar dados de login, senha, nome, email, role
# - Relacionar usuários a turmas e respostas
# - Gerenciar tokens de acesso e redefinição de senha
# - Validar dados obrigatórios
#

#
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
  # Nenhum
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
  # Nenhum
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
  # Nenhum
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
  def self.authenticate(email, password)
    user = find_by(email: email)
    return user if user && user.password == password
    nil
  end
  
  # Gerar token para primeiro acesso/redefinição de senha
  ##
  # Gera e salva um token para redefinição de senha
  #
  # === Argumentos
  # Nenhum argumento
  #
  # === Retorno
  # String - token gerado para redefinição de senha
  #
  # === Efeitos Colaterais
  # * Atualiza o campo virtual reset_password_token
  # * Salva o usuário no banco de dados
  def generate_reset_password_token!
    self.reset_password_token = SecureRandom.urlsafe_base64
    save!
    reset_password_token
  end

  ##
  # Gera um token para primeiro acesso do usuário
  #
  # === Argumentos
  # Nenhum argumento
  #
  # === Retorno
  # String - token gerado para primeiro acesso
  #
  # === Efeitos Colaterais
  # * Atualiza o campo virtual first_access_token
  # * Não salva no banco (apenas retorna o token)
  def generate_first_access_token!
    self.first_access_token = SecureRandom.urlsafe_base64
    first_access_token
  end

  ##
  # Verifica se o usuário precisa redefinir a senha (novo usuário)
  #
  # === Argumentos
  # Nenhum argumento
  #
  # === Retorno
  # Boolean - true se a senha for a padrão, false caso contrário
  #
  # === Efeitos Colaterais
  # Nenhum
  def needs_password_reset?
    password == 'padrao123'
  end
end
