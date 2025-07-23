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
    # Vamos usar um campo virtual para simplificar (sem mudança no banco)
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
    # Como não vamos alterar o banco, apenas retornamos o token
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
  # Nenhum - apenas consulta o valor da senha
  def needs_password_reset?
    # Lógica simples: se a senha é padrão, precisa redefinir
    password == 'padrao123'
  end
end
