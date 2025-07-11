FactoryBot.define do
  factory :formulario do
    sequence(:name) { |n| "Formulário #{n}" }
    date { Date.today }
  end
end
