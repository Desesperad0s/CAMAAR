FactoryBot.define do
  factory :template do
    content { 'Template de avaliação de disciplina' }
    association :user, factory: [:user, :admin]
    

    factory :template_with_questions do
      transient do
        questions_count { 3 }
        alternativas_per_question { 0 }
      end

      after(:create) do |template, evaluator|
        create_list(:questao, evaluator.questions_count, template: template).each do |questao|
          if evaluator.alternativas_per_question > 0
            create_list(:alternativa, evaluator.alternativas_per_question, questao: questao)
          end
        end
      end
    end
  end
end
