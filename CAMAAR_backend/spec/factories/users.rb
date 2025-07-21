FactoryBot.define do
  factory :user do
    sequence(:registration) { |n| "REG#{n}" }
    sequence(:name) { |n| "User #{n}" }
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password123" }
    role { "student" } 

    trait :admin do
      role { "admin" }
    end

    trait :professor do
      role { "professor" }
    end
    
    trait :student do
      role { "student" }
    end

    trait :needs_password_reset do
      password { "padrao123" }
    end

    trait :with_custom_password do
      password { "custom123" }
    end
  end
end
