#!/usr/bin/env ruby

# Script para testar o envio de emails
# Execute: rails runner script/test_email.rb

puts "=== Teste de Envio de Email CAMAAR ==="
puts

# Verificar se o ambiente está configurado
puts "Ambiente: #{Rails.env}"
puts "Configuração de email:"
puts "  Delivery method: #{Rails.application.config.action_mailer.delivery_method}"
puts "  Perform deliveries: #{Rails.application.config.action_mailer.perform_deliveries}"
puts "  Raise delivery errors: #{Rails.application.config.action_mailer.raise_delivery_errors}"
puts

# Verificar se as configurações SMTP estão presentes
smtp_config = Rails.application.config.action_mailer.smtp_settings
if smtp_config
  puts "Configurações SMTP:"
  puts "  Address: #{smtp_config[:address]}"
  puts "  Port: #{smtp_config[:port]}"
  puts "  Domain: #{smtp_config[:domain]}"
  puts "  Username: #{smtp_config[:user_name] ? '[CONFIGURADO]' : '[NÃO CONFIGURADO]'}"
  puts "  Password: #{smtp_config[:password] ? '[CONFIGURADO]' : '[NÃO CONFIGURADO]'}"
else
  puts "AVISO: Configurações SMTP não encontradas!"
end
puts

# Criar usuário de teste
test_user = User.new(
  name: 'Usuário de Teste',
  email: '231003406@aluno.unb.br',
  registration: 'TEST001',
  role: 'student',
  password: 'padrao123'
)

puts "Testando EmailService..."
begin
  result = EmailService.send_first_access_emails([test_user])
  puts "Resultado do EmailService:"
  puts result.inspect
  puts
rescue => e
  puts "ERRO no EmailService: #{e.message}"
  puts e.backtrace.first(3)
  puts
end

puts "Testando UserMailer diretamente..."
begin
  token = 'token-de-teste-12345'
  email = UserMailer.first_access_email(test_user, token)
  puts "Email criado com sucesso!"
  puts "  Para: #{email.to}"
  puts "  Assunto: #{email.subject}"
  puts "  De: #{email.from}"
  
  delivery_method = Rails.application.config.action_mailer.delivery_method
  puts "  Método de entrega: #{delivery_method}"
  
  if Rails.env.development?
    puts
    
    if delivery_method == :file
      puts "📁 Modo arquivo ativado - emails serão salvos em tmp/mails/"
      email.deliver_now
      puts "✅ Email salvo em arquivo com sucesso!"
      
      # Verificar se o arquivo foi criado
      mail_dir = Rails.root.join('tmp', 'mails')
      if Dir.exist?(mail_dir)
        files = Dir.glob(File.join(mail_dir, '*')).sort_by { |f| File.mtime(f) }
        if files.any?
          latest_file = files.last
          puts "📄 Último arquivo de email: #{File.basename(latest_file)}"
        end
      end
    else
      print "📧 Deseja tentar enviar o email via SMTP? (y/N): "
      response = STDIN.gets.chomp.downcase
      
      if response == 'y' || response == 'yes'
        puts "🚀 Tentando enviar email..."
        email.deliver_now
        puts "✅ Email enviado com sucesso!"
      else
        puts "Email não enviado (apenas criado)."
      end
    end
  end
rescue => e
  puts "❌ ERRO ao criar/enviar email: #{e.message}"
  puts "💡 Dica: Verifique as configurações SMTP ou use delivery_method: :file para desenvolvimento"
  puts e.backtrace.first(5)
end

puts
puts "=== Fim do Teste ==="
