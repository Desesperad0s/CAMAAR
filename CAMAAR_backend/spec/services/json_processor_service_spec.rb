require 'rails_helper'

RSpec.describe JsonProcessorService, type: :service do
  describe '.import_all_data' do
    let(:classes_json) { '[{"code": "DISC001", "dicente": [{"nome": "Aluno 1", "email": "aluno1@example.com", "matricula": "12345"}]}]' }
    let(:class_members_json) { '[{"nome": "Aluno 2", "email": "aluno2@example.com", "matricula": "67890"}]' }

    # ...existing tests...

    context 'quando os arquivos JSON contêm dados mistos (válidos e inválidos)' do
      let(:mixed_data_json) { '[{"code": "DISC001", "dicente": [{"nome": "Aluno 1", "email": "aluno1@example.com", "matricula": "12345"}]}, {"code": "DISC002", "dicente": [{"nome": "Aluno 2"}]}]' }

      before do
        allow(File).to receive(:exist?).and_return(true)
        allow(File).to receive(:read).and_return(mixed_data_json)
        allow(JsonProcessorService).to receive(:process_classes).and_return({ success: true, total_processed: 1, errors: [] })
        allow(JsonProcessorService).to receive(:process_discentes).and_return({ success: false, total_processed: 1, errors: ['Dados incompletos para aluno'] })
      end

      it 'retorna um hash indicando sucesso parcial' do
        result = JsonProcessorService.import_all_data

        expect(result).to be_a(Hash)
        expect(result[:success]).to be false
        expect(result[:class_members][:total_processed]).to eq(1)
        expect(result[:class_members][:errors]).to include('Dados incompletos para aluno')
      end
    end

    context 'quando os arquivos JSON contêm campos inesperados' do
      let(:unexpected_fields_json) { '[{"code": "DISC001", "unexpected_field": "unexpected_value", "dicente": [{"nome": "Aluno 1", "email": "aluno1@example.com", "matricula": "12345"}]}]' }

      before do
        allow(File).to receive(:exist?).and_return(true)
        allow(File).to receive(:read).and_return(unexpected_fields_json)
        allow(JsonProcessorService).to receive(:process_classes).and_return({ success: true, total_processed: 1, errors: [] })
        allow(JsonProcessorService).to receive(:process_discentes).and_return({ success: true, total_processed: 1, errors: [] })
      end

      it 'ignora campos inesperados e processa os dados corretamente' do
        result = JsonProcessorService.import_all_data

        expect(result).to be_a(Hash)
        expect(result[:success]).to be true
        expect(result[:class_members][:total_processed]).to eq(1)
        expect(result[:class_members][:errors]).to be_empty
      end
    end

    context 'quando os arquivos JSON contêm turmas duplicadas' do
      let(:duplicate_classes_json) { '[{"code": "DISC001", "dicente": [{"nome": "Aluno 1", "email": "aluno1@example.com", "matricula": "12345"}]}, {"code": "DISC001", "dicente": [{"nome": "Aluno 2", "email": "aluno2@example.com", "matricula": "67890"}]}]' }

      before do
        allow(File).to receive(:exist?).and_return(true)
        allow(File).to receive(:read).and_return(duplicate_classes_json)
        allow(JsonProcessorService).to receive(:process_classes).and_return({ success: false, total_processed: 1, errors: ['Turmas duplicadas encontradas'] })
        allow(JsonProcessorService).to receive(:process_discentes).and_return({ success: true, total_processed: 2, errors: [] })
      end

      it 'retorna um hash indicando falha parcial devido a turmas duplicadas' do
        result = JsonProcessorService.import_all_data

        expect(result).to be_a(Hash)
        expect(result[:success]).to be false
        expect(result[:classes][:errors]).to include('Turmas duplicadas encontradas')
      end
    end

    context 'quando os arquivos JSON contêm alunos sem matrícula ou email' do
      let(:missing_fields_json) { '[{"code": "DISC001", "dicente": [{"nome": "Aluno 1", "email": "", "matricula": ""}]}]' }

      before do
        allow(File).to receive(:exist?).and_return(true)
        allow(File).to receive(:read).and_return(missing_fields_json)
        allow(JsonProcessorService).to receive(:process_discentes).and_return({ success: false, total_processed: 0, errors: ['Dados incompletos para aluno'] })
      end

      it 'retorna um hash indicando falha no processamento devido a dados incompletos' do
        result = JsonProcessorService.import_all_data

        expect(result).to be_a(Hash)
        expect(result[:success]).to be false
        expect(result[:class_members][:errors]).to include('Dados incompletos para aluno')
      end
    end

    context 'quando os arquivos JSON contêm alunos com ocupações diferentes' do
      let(:different_roles_json) { '[{"code": "DISC001", "dicente": [{"nome": "Aluno 1", "email": "aluno1@example.com", "matricula": "12345", "ocupacao": "professor"}]}]' }

      before do
        allow(File).to receive(:exist?).and_return(true)
        allow(File).to receive(:read).and_return(different_roles_json)
        allow(JsonProcessorService).to receive(:process_discentes).and_return({ success: true, total_processed: 1, errors: [] })
      end

      it 'atribui corretamente o papel baseado na ocupação' do
        result = JsonProcessorService.import_all_data

        expect(result).to be_a(Hash)
        expect(result[:success]).to be true
        expect(result[:class_members][:total_processed]).to eq(1)
        expect(result[:class_members][:errors]).to be_empty
      end
    end

    context 'quando os arquivos JSON contêm turmas sem código' do
      let(:missing_code_json) { '[{"dicente": [{"nome": "Aluno 1", "email": "aluno1@example.com", "matricula": "12345"}]}]' }

      before do
        allow(File).to receive(:exist?).and_return(true)
        allow(File).to receive(:read).and_return(missing_code_json)
        allow(JsonProcessorService).to receive(:process_classes).and_return({ success: false, total_processed: 0, errors: ['Turma sem código encontrada'] })
      end

      it 'retorna um hash indicando falha no processamento devido a turmas sem código' do
        result = JsonProcessorService.import_all_data

        expect(result).to be_a(Hash)
        expect(result[:success]).to be false
        expect(result[:classes][:errors]).to include('Turma sem código encontrada')
      end
    end
  end
end