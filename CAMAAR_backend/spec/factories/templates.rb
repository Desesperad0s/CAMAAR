FactoryBot.define do
  factory :template do
    content { 'Template de avaliação de disciplina' }
    

    factory :template_with_questions do
      transient do
        questions_count { 3 }
      end

      after(:create) do |template, evaluator|
        create_list(:questao, evaluator.questions_count, template: template)
      end
    end
  end
end
