namespace :formularios do
  desc "Migrate questoes from direct formulario association to use respostas as a join table"
  task migrate_to_respostas: :environment do
    puts "Starting migration of questoes to use respostas as join table..."
    
    # Find all questoes that are associated directly with formularios
    questoes_to_migrate = Questao.where.not(formularios_id: nil)
    
    count = 0
    
    ActiveRecord::Base.transaction do
      questoes_to_migrate.find_each do |questao|
        # Create a new resposta to associate the form with the question
        if questao.formularios_id.present?
          Resposta.create!(
            questao_id: questao.id,
            formulario_id: questao.formularios_id
          )
          count += 1
          print "." if count % 10 == 0  # Progress indicator
        end
      end
    end
    
    puts "\nMigrated #{count} questoes to use respostas as join table"
    puts "Migration complete!"
  end
end
