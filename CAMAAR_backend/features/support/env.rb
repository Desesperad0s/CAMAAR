# encoding: utf-8

require 'capybara/cucumber'
require 'cucumber/rails'
require 'database_cleaner'

DatabaseCleaner.strategy = :truncation

Around do |scenario, block|
  DatabaseCleaner.cleaning(&block)
end

ENV['RAILS_ENV'] = 'test'

# Configuração para testes que usam Capybara
Capybara.default_driver = :rack_test  # Use rack_test em vez de selenium para testes mais rápidos
Capybara.app_host = 'http://localhost:3000'
Capybara.run_server = false

# Configuração para testes que necessitam JavaScript
Capybara.javascript_driver = :selenium_chrome_headless

# Configurar driver headless para ambientes sem interface gráfica
Capybara.register_driver :selenium_chrome_headless do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--headless')
  options.add_argument('--no-sandbox')
  options.add_argument('--disable-dev-shm-usage')
  options.add_argument('--disable-gpu')
  
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

class ApplicationController
  skip_before_action :authenticate_request, if: -> { Rails.env.test? }
end