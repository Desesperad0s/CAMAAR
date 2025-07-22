require 'rails_helper'

RSpec.describe EmailService, type: :service do
  let(:user) { create(:user, email: 'test@example.com', password: 'padrao123') }
  let(:user_with_custom_password) { create(:user, email: 'custom@example.com', password: 'custom123') }
  let(:users_needing_reset) { [user] }
  let(:mixed_users) { [user, user_with_custom_password] }

  describe '.send_first_access_emails' do
    context 'when email delivery is available' do
      before do
        allow(EmailService).to receive(:email_delivery_available?).and_return(true)
        allow(Rails.application.config.action_mailer).to receive(:delivery_method).and_return(:smtp)
      end

      context 'with users needing password reset' do
        it 'sends emails to users with default password' do
          expect(UserMailer).to receive(:first_access_email).with(user, anything).and_call_original
          expect_any_instance_of(ActionMailer::MessageDelivery).to receive(:deliver_now)
          
          results = EmailService.send_first_access_emails(users_needing_reset)
          
          expect(results.length).to eq(1)
          expect(results.first[:user_id]).to eq(user.id)
          expect(results.first[:email]).to eq(user.email)
          expect(results.first[:status]).to eq('sent')
          expect(results.first[:token]).to be_present
        end

        it 'skips users who do not need password reset' do
          results = EmailService.send_first_access_emails([user_with_custom_password])
          
          expect(results).to be_empty
        end

        it 'processes mixed users correctly' do
          expect(UserMailer).to receive(:first_access_email).once.and_call_original
          expect_any_instance_of(ActionMailer::MessageDelivery).to receive(:deliver_now)
          
          results = EmailService.send_first_access_emails(mixed_users)
          
          expect(results.length).to eq(1)
          expect(results.first[:user_id]).to eq(user.id)
        end

        it 'generates first access token for each user' do
          expect(user).to receive(:generate_first_access_token!).and_return('token123')
          expect(UserMailer).to receive(:first_access_email).with(user, 'token123').and_call_original
          expect_any_instance_of(ActionMailer::MessageDelivery).to receive(:deliver_now)
          
          results = EmailService.send_first_access_emails(users_needing_reset)
          
          expect(results.first[:token]).to eq('token123')
        end
      end

      context 'when using file delivery method' do
        before do
          allow(Rails.application.config.action_mailer).to receive(:delivery_method).and_return(:file)
        end

        it 'saves email to file and marks as saved_to_file' do
          expect(UserMailer).to receive(:first_access_email).with(user, anything).and_call_original
          expect_any_instance_of(ActionMailer::MessageDelivery).to receive(:deliver_now)
          
          results = EmailService.send_first_access_emails(users_needing_reset)
          
          expect(results.first[:status]).to eq('saved_to_file')
        end
      end

      context 'when email sending fails' do
        it 'handles exceptions and marks as error' do
          expect(UserMailer).to receive(:first_access_email).and_raise(StandardError.new('SMTP Error'))
          
          results = EmailService.send_first_access_emails(users_needing_reset)
          
          expect(results.length).to eq(1)
          expect(results.first[:status]).to eq('error')
          expect(results.first[:error]).to eq('SMTP Error')
        end
      end
    end

    context 'when email delivery is not available' do
      before do
        allow(EmailService).to receive(:email_delivery_available?).and_return(false)
      end

      it 'simulates email sending' do
        expect(EmailService).to receive(:simulate_email_sending).with(users_needing_reset).and_call_original
        
        results = EmailService.send_first_access_emails(users_needing_reset)
        
        expect(results.length).to eq(1)
        expect(results.first[:status]).to eq('simulated')
        expect(results.first[:reset_link]).to include('nova-senha')
      end
    end
  end

  describe '.send_password_reset_email' do
    context 'when email delivery is available' do
      before do
        allow(EmailService).to receive(:email_delivery_available?).and_return(true)
        allow(Rails.application.config.action_mailer).to receive(:delivery_method).and_return(:smtp)
      end

      it 'sends password reset email successfully' do
        expect(user).to receive(:generate_reset_password_token!).and_return('reset_token123')
        expect(UserMailer).to receive(:password_reset_email).with(user, 'reset_token123').and_call_original
        expect_any_instance_of(ActionMailer::MessageDelivery).to receive(:deliver_now)
        
        result = EmailService.send_password_reset_email(user)
        
        expect(result[:success]).to be true
        expect(result[:message]).to eq('Email enviado com sucesso')
        expect(result[:token]).to eq('reset_token123')
      end

      context 'when using file delivery method' do
        before do
          allow(Rails.application.config.action_mailer).to receive(:delivery_method).and_return(:file)
        end

        it 'saves email to file' do
          expect(UserMailer).to receive(:password_reset_email).and_call_original
          expect_any_instance_of(ActionMailer::MessageDelivery).to receive(:deliver_now)
          
          result = EmailService.send_password_reset_email(user)
          
          expect(result[:success]).to be true
          expect(result[:message]).to eq('Email salvo em arquivo')
        end
      end

      context 'when email sending fails' do
        it 'handles exceptions and returns error' do
          expect(UserMailer).to receive(:password_reset_email).and_raise(StandardError.new('SMTP Error'))
          
          result = EmailService.send_password_reset_email(user)
          
          expect(result[:success]).to be false
          expect(result[:message]).to eq('Erro ao enviar email: SMTP Error')
        end
      end
    end

    context 'when email delivery is not available' do
      before do
        allow(EmailService).to receive(:email_delivery_available?).and_return(false)
      end

      it 'simulates password reset email' do
        expect(EmailService).to receive(:simulate_password_reset_email).with(user).and_call_original
        
        result = EmailService.send_password_reset_email(user)
        
        expect(result[:success]).to be true
        expect(result[:message]).to eq('Email simulado com sucesso')
        expect(result[:reset_link]).to include('redefinir-senha')
      end
    end
  end

  describe '.email_delivery_available?' do
    context 'when using file delivery method' do
      before do
        allow(Rails.application.config.action_mailer).to receive(:delivery_method).and_return(:file)
      end

      it 'returns true' do
        expect(EmailService.send(:email_delivery_available?)).to be true
      end
    end

    context 'when using SMTP delivery method' do
      before do
        allow(Rails.application.config.action_mailer).to receive(:delivery_method).and_return(:smtp)
      end

      context 'with valid SMTP settings' do
        before do
          allow(Rails.application.config.action_mailer).to receive(:smtp_settings).and_return({
            user_name: 'user@example.com',
            password: 'password123'
          })
        end

        it 'returns true' do
          expect(EmailService.send(:email_delivery_available?)).to be true
        end
      end

      context 'with missing SMTP credentials' do
        before do
          allow(Rails.application.config.action_mailer).to receive(:smtp_settings).and_return({
            user_name: '',
            password: ''
          })
        end

        it 'returns false' do
          expect(EmailService.send(:email_delivery_available?)).to be false
        end
      end

      context 'when SMTP settings raise an exception' do
        before do
          allow(Rails.application.config.action_mailer).to receive(:smtp_settings).and_raise(StandardError)
        end

        it 'returns false' do
          expect(EmailService.send(:email_delivery_available?)).to be false
        end
      end
    end
  end

  describe '.simulate_email_sending' do
    it 'creates simulation results for users needing password reset' do
      expect(user).to receive(:generate_first_access_token!).and_return('sim_token123')
      
      results = EmailService.send(:simulate_email_sending, users_needing_reset)
      
      expect(results.length).to eq(1)
      result = results.first
      expect(result[:user_id]).to eq(user.id)
      expect(result[:email]).to eq(user.email)
      expect(result[:status]).to eq('simulated')
      expect(result[:token]).to eq('sim_token123')
      expect(result[:reset_link]).to include('nova-senha')
      expect(result[:reset_link]).to include('sim_token123')
      expect(result[:reset_link]).to include(user.email)
    end

    it 'skips users who do not need password reset' do
      results = EmailService.send(:simulate_email_sending, [user_with_custom_password])
      
      expect(results).to be_empty
    end
  end

  describe '.simulate_password_reset_email' do
    it 'creates simulation result for password reset' do
      expect(user).to receive(:generate_reset_password_token!).and_return('sim_reset_token123')
      
      result = EmailService.send(:simulate_password_reset_email, user)
      
      expect(result[:success]).to be true
      expect(result[:message]).to eq('Email simulado com sucesso')
      expect(result[:token]).to eq('sim_reset_token123')
      expect(result[:reset_link]).to include('redefinir-senha')
      expect(result[:reset_link]).to include('sim_reset_token123')
      expect(result[:reset_link]).to include(user.email)
    end
  end
end
