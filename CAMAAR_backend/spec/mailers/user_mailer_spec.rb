require 'rails_helper'

RSpec.describe UserMailer, type: :mailer do
  let(:user) { create(:user, name: 'João Silva', email: 'joao@example.com') }
  let(:reset_token) { 'abc123token' }

  describe '.first_access_email' do
    let(:mail) { UserMailer.first_access_email(user, reset_token) }

    it 'sets the correct headers' do
      expect(mail.subject).to eq('Bem-vindo ao CAMAAR - Defina sua senha de acesso')
      expect(mail.to).to eq(['231003406@aluno.unb.br']) 
      expect(mail.from).to eq(['lucaslgol05@gmail.com'])
    end

    it 'assigns user and token variables' do
      # Test both HTML and text parts
      expect(mail.html_part.body.to_s).to include(user.name)
      expect(mail.html_part.body.to_s).to include(reset_token)
      expect(mail.text_part.body.to_s).to include(user.name)
      expect(mail.text_part.body.to_s).to include(reset_token)
    end


    it 'renders the body with user information' do
      expect(mail.html_part.body.to_s).to include('João Silva')
      expect(mail.text_part.body.to_s).to include('João Silva')
    end

    it 'includes a clickable reset link' do
      expect(mail.html_part.body.to_s).to include('href=')
      expect(mail.html_part.body.to_s).to include('nova-senha')
    end

    it 'contains important email elements' do
      html_body = mail.html_part.body.to_s
      expect(html_body).to include('CAMAAR')
      expect(html_body).to include('senha')
      expect(html_body).to include(user.email)
      expect(html_body).to include(user.registration)
    end
  end

  describe '.password_reset_email' do
    let(:mail) { UserMailer.password_reset_email(user, reset_token) }

    it 'sets the correct headers' do
      expect(mail.subject).to eq('CAMAAR - Redefinição de senha solicitada')
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(['lucaslgol05@gmail.com'])
    end

    it 'assigns user and token variables' do
      expect(mail.html_part.body.to_s).to include(user.name)
      expect(mail.html_part.body.to_s).to include(reset_token)
      expect(mail.text_part.body.to_s).to include(user.name)
      expect(mail.text_part.body.to_s).to include(reset_token)
    end


    it 'renders the body with user information' do
      expect(mail.html_part.body.to_s).to include('João Silva')
      expect(mail.text_part.body.to_s).to include('João Silva')
    end

    it 'includes a clickable reset link' do
      expect(mail.html_part.body.to_s).to include('href=')
      expect(mail.html_part.body.to_s).to include('redefinir-senha')
    end

    it 'contains important email elements' do
      html_body = mail.html_part.body.to_s
      text_body = mail.text_part.body.to_s
      expect(html_body).to include('CAMAAR')
      expect(text_body).to include('CAMAAR')
      expect(html_body).to include('senha')
    end
  end

  describe '#frontend_url (private method)' do
    let(:mailer) { UserMailer.new }

    it 'returns a valid URL' do
      url = mailer.send(:frontend_url)
      expect(url).to be_a(String)
      expect(url).to match(/^https?:\/\//)
    end

    it 'returns the default localhost URL when no config is set' do
      url = mailer.send(:frontend_url)
      expect(url).to eq('http://localhost:3000')
    end
  end
end
