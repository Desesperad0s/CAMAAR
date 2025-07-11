FactoryBot.define do
  factory :questao do
    sequence(:enunciado) { |n| "Questão de teste número #{n}" }
    

    trait :with_formulario do
      association :formulario, foreign_key: :formularios_id
    end
    
    factory :questao_with_template do
      after(:build) do |questao|
        questao.template = create(:template) unless questao.template
      end
    end
  end
end
