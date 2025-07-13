# spec/support/auth_helpers.rb

module AuthHelpers
  def auth_headers(user = nil)
    user ||= create(:user, :admin)
    token = JwtService.encode(user_id: user.id)
    { 'Authorization' => "Bearer #{token}" }
  end
  
  def mock_admin_user
    build_stubbed(:user, :admin)
  end
end

RSpec.configure do |config|
  config.include AuthHelpers, type: :request
  config.include AuthHelpers, type: :controller
end
