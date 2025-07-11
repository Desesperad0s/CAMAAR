FactoryBot.define do
  factory :resposta do
    sequence(:content) { |n| "Resposta #{n}" }
    association :questao
    association :formulario
  end
end
