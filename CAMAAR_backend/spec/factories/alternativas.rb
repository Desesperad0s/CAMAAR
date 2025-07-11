FactoryBot.define do
  factory :alternativa do
    sequence(:content) { |n| "Alternativa #{n}" }
    association :questao
  end
end
