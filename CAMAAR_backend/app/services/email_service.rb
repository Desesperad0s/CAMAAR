class EmailService
  class << self
    def send_first_access_emails(users)
      results = []
      
      # Verificar se email está configurado
      unless email_delivery_available?
        Rails.logger.warn("Email não configurado. Simulando envio de emails...")
        return simulate_email_sending(users)
      end
      
      users.each do |user|
        begin
          # Apenas enviar email se o usuário precisa redefinir senha (senha padrão)
          next unless user.needs_password_reset?
          
          # Gerar token de redefinição
          reset_token = user.generate_first_access_token!
          
          # Tentar enviar email
          email = UserMailer.first_access_email(user, reset_token)
          
          if Rails.application.config.action_mailer.delivery_method == :file
            # Modo desenvolvimento - salvar em arquivo
            email.deliver_now
            Rails.logger.info("Email salvo em arquivo para: #{user.email}")
            status = 'saved_to_file'
          else
            # Modo produção - enviar via SMTP
            email.deliver_now
            Rails.logger.info("Email enviado via SMTP para: #{user.email}")
            status = 'sent'
          end
          
          results << {
            user_id: user.id,
            email: user.email,
            name: user.name,
            status: status,
            sent_at: Time.current,
            token: reset_token
          }
          
        rescue => e
          results << {
            user_id: user.id,
            email: user.email,
            name: user.name,
            status: 'error',
            error: e.message,
            sent_at: Time.current
          }
          
          Rails.logger.error("Erro ao enviar email para #{user.email}: #{e.message}")
        end
      end
      
      results
    end
    
    def send_password_reset_email(user)
      begin
        unless email_delivery_available?
          return simulate_password_reset_email(user)
        end
        
        reset_token = user.generate_reset_password_token!
        email = UserMailer.password_reset_email(user, reset_token)
        
        if Rails.application.config.action_mailer.delivery_method == :file
          email.deliver_now
          Rails.logger.info("Email de redefinição salvo em arquivo para: #{user.email}")
          status_message = "Email salvo em arquivo"
        else
          email.deliver_now
          Rails.logger.info("Email de redefinição enviado via SMTP para: #{user.email}")
          status_message = "Email enviado com sucesso"
        end
        
        { success: true, message: status_message, token: reset_token }
      rescue => e
        Rails.logger.error("Erro ao enviar email de redefinição para #{user.email}: #{e.message}")
        { success: false, message: "Erro ao enviar email: #{e.message}" }
      end
    end
    
    private
    
    def email_delivery_available?
      config = Rails.application.config.action_mailer
      
      # Se for modo arquivo, sempre disponível
      return true if config.delivery_method == :file
      
      # Para SMTP, verificar se as credenciais estão configuradas
      if config.delivery_method == :smtp
        smtp_settings = config.smtp_settings
        return false unless smtp_settings[:user_name].present? && smtp_settings[:password].present?
      end
      
      true
    rescue
      false
    end
    
    def simulate_email_sending(users)
      Rails.logger.info("=== SIMULAÇÃO DE ENVIO DE EMAILS ===")
      
      users.map do |user|
        next unless user.needs_password_reset?
        
        reset_token = user.generate_first_access_token!
        
        Rails.logger.info("📧 SIMULADO: Email para #{user.name} (#{user.email})")
        Rails.logger.info("   Token: #{reset_token}")
        Rails.logger.info("   Link: http://localhost:3000/nova-senha?token=#{reset_token}&email=#{user.email}")
        
        {
          user_id: user.id,
          email: user.email,
          name: user.name,
          status: 'simulated',
          sent_at: Time.current,
          token: reset_token,
          reset_link: "http://localhost:3000/nova-senha?token=#{reset_token}&email=#{user.email}"
        }
      end.compact
    end
    
    def simulate_password_reset_email(user)
      reset_token = user.generate_reset_password_token!
      
      Rails.logger.info("📧 SIMULADO: Email de redefinição para #{user.name} (#{user.email})")
      Rails.logger.info("   Token: #{reset_token}")
      Rails.logger.info("   Link: http://localhost:3000/redefinir-senha?token=#{reset_token}&email=#{user.email}")
      
      {
        success: true,
        message: "Email simulado com sucesso",
        token: reset_token,
        reset_link: "http://localhost:3000/redefinir-senha?token=#{reset_token}&email=#{user.email}"
      }
    end
  end
end
