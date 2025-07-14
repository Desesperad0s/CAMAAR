# encoding: utf-8

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

