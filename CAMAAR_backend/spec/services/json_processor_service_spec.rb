require 'rails_helper'

RSpec.describe JsonProcessorService, type: :service do
  describe '.import_all_data' do
    context 'quando os arquivos JSON existem' do
      before do
        allow(File).to receive(:exist?).and_return(true)
        allow(File).to receive(:read).and_return('[]')
        
        allow(JsonProcessorService).to receive(:process_classes).and_return(true)
        allow(JsonProcessorService).to receive(:process_discentes).and_return(true)
        
        allow(User).to receive(:count).and_return(10)
        allow(Disciplina).to receive(:count).and_return(5)
      end
      
      it 'retorna um hash de sucesso' do
        result = JsonProcessorService.import_all_data
        
        expect(result).to be_a(Hash)
        expect(result[:success]).to be true
        expect(result[:class_members]).to be_a(Hash)
        expect(result[:classes]).to be_a(Hash)
        expect(result[:class_members][:total_processed]).to eq(10)
        expect(result[:classes][:total_processed]).to eq(5)
      end
    end
    
    context 'quando os arquivos JSON não existem' do
      before do
        allow(File).to receive(:exist?).and_return(false)
      end
      
      it 'retorna um hash de erro' do
        result = JsonProcessorService.import_all_data
        
        expect(result).to be_a(Hash)
        expect(result[:success]).to be false
        expect(result[:error]).to eq('Arquivos JSON não encontrados')
      end
    end
    
    context 'quando ocorre um erro durante o processamento' do
      before do
        allow(File).to receive(:exist?).and_return(true)
        allow(File).to receive(:read).and_return('[]')
        allow(JsonProcessorService).to receive(:process_classes).and_raise(StandardError.new('Erro de teste'))
      end
      
      it 'retorna um hash com o erro' do
        result = JsonProcessorService.import_all_data
        
        expect(result).to be_a(Hash)
        expect(result[:success]).to be false
        expect(result[:error]).to eq('Erro de teste')
      end
    end
  end
end
