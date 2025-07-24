class EmailService
  class << self
    ##
    # Envia emails de primeiro acesso para uma lista de usuários
    #
    # === Argumentos
    # * +users+ - Array de usuários para os quais o email será enviado
    #
    # === Retorno
    # Array de hashes com informações sobre o envio para cada usuário
    #
    # === Efeitos Colaterais
    # * Envia emails reais ou simula envio, dependendo da configuração
    # * Gera tokens de acesso para usuários que precisam redefinir senha
    def send_first_access_emails(users)
      results = []
      unless email_delivery_available?
        Rails.logger.warn("Email não configurado. Simulando envio de emails...")
        return simulate_email_sending(users)
      end
      users.each do |user|
        next unless user.needs_password_reset?
        results << process_first_access_email(user)
      end
      results.compact
    end

    ##
    # Processa o envio de email de primeiro acesso para um usuário
    #
    # === Argumentos
    # * +user+ - Usuário para o qual o email será enviado
    # === Retorno
    # Hash com informações do envio ou erro
    def process_first_access_email(user)
      begin
        reset_token = user.generate_first_access_token!
        email = UserMailer.first_access_email(user, reset_token)
        status = deliver_email(email, user, :first_access)
        {
          user_id: user.id,
          email: user.email,
          name: user.name,
          status: status,
          sent_at: Time.current,
          token: reset_token
        }
      rescue => e
        Rails.logger.error("Erro ao enviar email para #{user.email}: #{e.message}")
        {
          user_id: user.id,
          email: user.email,
          name: user.name,
          status: 'error',
          error: e.message,
          sent_at: Time.current
        }
      end
    end
    
    ##
    # Envia email de redefinição de senha para um usuário
    #
    # === Argumentos
    # * +user+ - Usuário para o qual o email será enviado
    #
    # === Retorno
    # Hash com status do envio, mensagem e token gerado
    #
    # === Efeitos Colaterais
    # * Envia email real ou simula envio, dependendo da configuração
    # * Gera token de redefinição de senha
    def send_password_reset_email(user)
      begin
        unless email_delivery_available?
          return simulate_password_reset_email(user)
        end
        reset_token = user.generate_reset_password_token!
        email = UserMailer.password_reset_email(user, reset_token)
        status_message = deliver_email(email, user, :password_reset)
        { success: true, message: status_message, token: reset_token }
      rescue => e
        Rails.logger.error("Erro ao enviar email de redefinição para #{user.email}: #{e.message}")
        { success: false, message: "Erro ao enviar email: #{e.message}" }
      end
    end

    ##
    # Realiza a entrega do email e retorna mensagem de status
    #
    # === Argumentos
    # * +email+ - Objeto de email a ser enviado
    # * +user+ - Usuário destinatário
    # * +type+ - Tipo de email (:first_access ou :password_reset)
    # === Retorno
    # String com mensagem de status
    def deliver_email(email, user, type)
      if Rails.application.config.action_mailer.delivery_method == :file
        email.deliver_now
        msg = type == :first_access ? "Email salvo em arquivo para: #{user.email}" : "Email de redefinição salvo em arquivo para: #{user.email}"
        Rails.logger.info(msg)
        type == :first_access ? 'saved_to_file' : 'Email salvo em arquivo'
      else
        email.deliver_now
        msg = type == :first_access ? "Email enviado via SMTP para: #{user.email}" : "Email de redefinição enviado via SMTP para: #{user.email}"
        Rails.logger.info(msg)
        type == :first_access ? 'sent' : 'Email enviado com sucesso'
      end
    end
    
    private
    
    ##
    # Verifica se o envio de email está disponível/configurado
    #
    # === Argumentos
    # Nenhum
    #
    # === Retorno
    # Boolean - true se o envio está disponível, false caso contrário
    #
    # === Efeitos Colaterais
    # Nenhum
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
    
    ##
    # Simula o envio de emails de primeiro acesso para uma lista de usuários
    #
    # === Argumentos
    # * +users+ - Array de usuários
    #
    # === Retorno
    # Array de hashes simulando o envio para cada usuário
    #
    # === Efeitos Colaterais
    # * Gera tokens simulados e logs de simulação
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
    
    ##
    # Simula o envio de email de redefinição de senha para um usuário
    #
    # === Argumentos
    # * +user+ - Usuário
    #
    # === Retorno
    # Hash simulando o envio do email
    #
    # === Efeitos Colaterais
    # * Gera token simulado e logs de simulação
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
