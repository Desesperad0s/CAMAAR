require 'cucumber/rails'
require 'capybara/cucumber'
require 'factory_bot_rails'

World(FactoryBot::Syntax::Methods)

# Limpa o banco de dados entre os testes
DatabaseCleaner.strategy = :truncation

Around do |scenario, block|
  DatabaseCleaner.cleaning(&block)
end

# Configuração do Capybara
Capybara.default_driver = :rack_test
Capybara.javascript_driver = :selenium_chrome_headless

# Incluir módulos de autenticação (assumindo que está usando Devise)
World(Warden::Test::Helpers)
After { Warden.test_reset! }