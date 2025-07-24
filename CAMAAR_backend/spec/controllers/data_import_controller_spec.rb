require 'rails_helper'

RSpec.describe DataImportController, type: :controller do
  let(:user) { FactoryBot.create(:user, :admin) }
  let(:token) { JwtService.encode(user_id: user.id) }

  before do
    request.headers['Authorization'] = "Bearer #{token}"
    allow(controller).to receive(:current_user).and_return(user)
    allow(controller).to receive(:authenticate_request).and_return(true)
    controller.instance_variable_set(:@current_user, user)
  end

  describe 'POST #import' do
    let(:classes_json) { { turmas: [{ code: 'TEST001', nome: 'Turma Teste' }] }.to_json }
    let(:members_json) { { discentes: [{ nome: 'João Silva', email: 'joao@test.com' }] }.to_json }

    context 'when files do not exist' do
      before do
        allow(File).to receive(:exist?).and_return(false)
      end

      it 'returns not found error' do
        post :import
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['success']).to be false
        expect(JSON.parse(response.body)['message']).to eq('Arquivos não encontrados')
      end

      it 'does not call JsonProcessorService' do
        expect(JsonProcessorService).not_to receive(:process_discentes)
        post :import
      end
    end

    context 'when files exist but have invalid JSON' do
      before do
        allow(File).to receive(:exist?).and_return(true)
        allow(File).to receive(:read).and_return('invalid json')
      end

      it 'returns unprocessable entity error' do
        post :import
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['success']).to be false
        expect(JSON.parse(response.body)['message']).to eq('Arquivo JSON inválido')
      end

      it 'does not raise an exception' do
        expect { post :import }.not_to raise_error
      end
    end

    context 'when files exist and have valid JSON' do
      before do
        allow(File).to receive(:exist?).and_return(true)
        allow(File).to receive(:read).with(Rails.root.join('classes.json').to_s).and_return(classes_json)
        allow(File).to receive(:read).with(Rails.root.join('class_members.json').to_s).and_return(members_json)

        allow(JsonProcessorService).to receive(:process_discentes).and_return({
          success: true,
          total_processed: 1,
          errors: []
        })

        allow(controller).to receive(:ensure_database_structure)
      end

      it 'processes data successfully' do
        post :import
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['success']).to be true
        expect(JSON.parse(response.body)['message']).to eq('Dados importados com sucesso')
      end

      it 'calls JsonProcessorService with correct parsed data (string JSON)' do
        expect(JsonProcessorService).to receive(:process_discentes).with(members_json)
        post :import
      end

      it 'calls ensure_database_structure' do
        expect(controller).to receive(:ensure_database_structure)
        post :import
      end
    end

    context 'when processing fails' do
      before do
        allow(File).to receive(:exist?).and_return(true)
        allow(File).to receive(:read).with(Rails.root.join('classes.json').to_s).and_return(classes_json)
        allow(File).to receive(:read).with(Rails.root.join('class_members.json').to_s).and_return(members_json)

        allow(JsonProcessorService).to receive(:process_discentes).and_return({
          success: false,
          total_processed: 0,
          errors: ['Erro de processamento']
        })

        allow(controller).to receive(:ensure_database_structure)
      end

      it 'returns error with details' do
        post :import
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['success']).to be false
        expect(JSON.parse(response.body)['message']).to eq('Dados importados com erros')
        expect(JSON.parse(response.body)['errors']).to include('Erro de processamento')
      end
    end

    context 'when an exception occurs' do
      before do
        allow(File).to receive(:exist?).and_raise(StandardError.new('Erro inesperado'))
      end

      it 'returns internal server error' do
        post :import
        expect(response).to have_http_status(:internal_server_error)
        expect(JSON.parse(response.body)['success']).to be false
        expect(JSON.parse(response.body)['message']).to eq('Erro ao processar importação')
      end

      it 'handles unexpected exceptions gracefully' do
        expect { post :import }.not_to raise_error
      end
    end

    context 'when classes.json exists but class_members.json does not' do
      before do
        allow(File).to receive(:exist?).with(Rails.root.join('classes.json').to_s).and_return(true)
        allow(File).to receive(:exist?).with(Rails.root.join('class_members.json').to_s).and_return(false)
      end

      it 'returns file not found error' do
        post :import
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['success']).to be false
        expect(JSON.parse(response.body)['message']).to eq('Arquivos não encontrados')
      end
    end

    context 'when only one file has invalid JSON' do
      before do
        allow(File).to receive(:exist?).and_return(true)
        allow(File).to receive(:read).with(Rails.root.join('classes.json').to_s).and_return('invalid json')
        allow(File).to receive(:read).with(Rails.root.join('class_members.json').to_s).and_return(members_json)
      end

      it 'returns invalid JSON error' do
        post :import
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['success']).to be false
        expect(JSON.parse(response.body)['message']).to eq('Arquivo JSON inválido')
      end
    end

    context 'when files are empty' do
      let(:empty_json) { '{}' }

      before do
        allow(File).to receive(:exist?).and_return(true)
        allow(File).to receive(:read).with(Rails.root.join('classes.json').to_s).and_return(empty_json)
        allow(File).to receive(:read).with(Rails.root.join('class_members.json').to_s).and_return(empty_json)
        allow(controller).to receive(:ensure_database_structure)

        allow(JsonProcessorService).to receive(:process_discentes).and_return({
          success: false,
          total_processed: 0,
          errors: ['Nenhum dado para importar']
        })
      end

      it 'processes but imports no data with error message' do
        post :import
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['success']).to be false
        expect(JSON.parse(response.body)['message']).to eq('Dados importados com erros')
      end

      it 'calls process_discentes with string JSON "{}"' do
        expect(JsonProcessorService).to receive(:process_discentes).with(empty_json)
        post :import
      end
    end
  end

  describe 'authorization' do
    context 'when user is not admin' do
      let(:regular_user) { FactoryBot.create(:user, :student) }
      let(:regular_token) { JwtService.encode(user_id: regular_user.id) }

      before do
        request.headers['Authorization'] = "Bearer #{regular_token}"
        allow(controller).to receive(:current_user).and_return(regular_user)
        controller.instance_variable_set(:@current_user, regular_user)
      end

      it 'returns forbidden error' do
        post :import
        expect(response).to have_http_status(:forbidden)
        expect(JSON.parse(response.body)['error']).to include('Acesso negado')
      end
    end
  end
end


