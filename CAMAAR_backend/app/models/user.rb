class User < ApplicationRecord
  has_many :turmas_alunos

  validates :registration, presence: true
  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }, uniqueness: true
  validates :role, presence: true, inclusion: { in: ['student', 'professor', 'admin'] }
  
  def estudante?
    role == 'student'
  end
  
  def professor?
    role == 'professor'
  end
end
