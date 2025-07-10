json.extract! user, :id, :registration, :name, :email, :password, :forms_answered, :major, :role, :created_at, :updated_at
json.url user_url(user, format: :json)
