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
  end
end
