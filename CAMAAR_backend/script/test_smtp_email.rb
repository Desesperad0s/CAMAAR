#!/usr/bin/env ruby
# Script para testar envio REAL de emails

puts "🚀 TESTE DE ENVIO REAL DE EMAIL"
puts "=" * 50

# Verificar configurações
puts "\n📧 Configurações de Email:"
puts "Delivery Method: #{Rails.application.config.action_mailer.delivery_method}"
puts "SMTP Address: #{ENV['SMTP_ADDRESS']}"
puts "SMTP User: #{ENV['SMTP_USER_NAME']}"
puts "SMTP Password: #{'*' * (ENV['SMTP_PASSWORD']&.length || 0)}"

puts "\n🧪 Criando usuário de teste com senha padrão..."
test_user = User.new(
  email: "231003406@aluno.unb.br",
  name: "Usuário de Teste",
  registration: "TEST001",
  role: "student",
  password: "padrao123" 
)

puts "🔍 Verificando se usuário precisa de reset: #{test_user.needs_password_reset?}"

puts "\n📤 Enviando email de primeiro acesso..."
begin
  result = EmailService.send_first_access_emails([test_user])
  puts "✅ Resultado: #{result.inspect}"
  
  if result.any? { |r| r[:status] == 'sent' }
    puts "\n🎉 EMAIL ENVIADO COM SUCESSO!"
    puts "📧 Verifique sua caixa de entrada em: #{ENV['SMTP_USER_NAME']}"
  else
    puts "\n❌ FALHA NO ENVIO"
    puts "🔍 Detalhes: #{result.inspect}"
  end
  
rescue => e
  puts "\n💥 ERRO: #{e.message}"
  puts "🔍 Backtrace:"
  puts e.backtrace.first(5).join("\n")
end

puts "\n📂 Verificando diretório de emails..."
mails_dir = Rails.root.join('tmp', 'mails')
if Dir.exist?(mails_dir)
  files = Dir.entries(mails_dir).reject { |f| f.start_with?('.') }
  puts "📁 Arquivos encontrados: #{files.count}"
  files.each { |f| puts "  - #{f}" }
else
  puts "❌ Diretório tmp/mails não encontrado"
end
