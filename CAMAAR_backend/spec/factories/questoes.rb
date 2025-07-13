FactoryBot.define do
  factory :questao do
    sequence(:enunciado) { |n| "Questão de teste número #{n}" }
    


    factory :questao_with_template do
      after(:build) do |questao|
        questao.template = create(:template) unless questao.template
      end
    end
  end
end
