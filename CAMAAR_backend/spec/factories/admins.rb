FactoryBot.define do
  factory :admin do
    registration { 12345 }
    name { "Admin Teste" }
    email { "admin@example.com" }
    password { "senha123" }
  end
end
