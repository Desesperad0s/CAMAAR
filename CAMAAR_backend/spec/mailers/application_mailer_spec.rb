require 'rails_helper'

RSpec.describe ApplicationMailer, type: :mailer do
  describe 'default configuration' do
    it 'sets the correct default from address' do
      expect(ApplicationMailer.default[:from]).to eq('lucaslgol05@gmail.com')
    end

    it 'uses the mailer layout' do
      expect(ApplicationMailer._layout).to eq('mailer')
    end
  end

  describe 'inheritance' do
    it 'inherits from ActionMailer::Base' do
      expect(ApplicationMailer.superclass).to eq(ActionMailer::Base)
    end
  end
end
