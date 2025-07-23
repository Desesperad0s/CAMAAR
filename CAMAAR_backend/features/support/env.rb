# encoding: utf-8

require 'capybara/cucumber'
require 'cucumber/rails'
require 'database_cleaner'

DatabaseCleaner.strategy = :truncation

Around do |scenario, block|
  DatabaseCleaner.cleaning(&block)
end


ENV['RAILS_ENV'] = 'test'

class ApplicationController
  skip_before_action :authenticate_request, if: -> { Rails.env.test? }
end


Capybara.app_host = 'http://localhost:3000' 
Capybara.run_server = false 
Capybara.default_driver = :selenium_chrome