class PasswordsController < ApplicationController
  skip_before_action :authenticate_request
  
  # POST /passwords/forgot
  def forgot
    
  end
  
  # POST /passwords/reset
  def reset
  end
end
