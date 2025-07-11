require 'rails_helper'

RSpec.describe TurmasController, type: :controller do
    let!(:departamento) { Departamento.create!(name: "Exatas", code: "EXA", abreviation: "EXA") }
    let!(:disciplina) { Disciplina.create!(name: "OAC", departamento_id: departamento.id) }
    let!(:turma) { Turma.create!(code: "CIC-69", number: 1, semester: "25.1", time: "35T23", disciplina_id: disciplina.id) }
    let!(:turma1) { Turma.create!(code: "CIC-70", number: 2, semester: "25.2", time: "24N23", disciplina_id: disciplina.id) }

  describe "GET /turmas" do
    it "pega todas as turmas" do
      get :index, format: :json
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /turmas" do
    it "cria uma turma" do
      expect {
        post :create, params: { turma: { code: turma.code, number: turma.number, semester: turma.semester, time: turma.time, disciplina_id: disciplina.id } }, format: :json

        puts response.body
      }.to change(Turma, :count).by(1)
      expect(response).to have_http_status(:created)
    end
  end

  describe "GET /turmas/:id" do
    it "shows turma" do
      get :show, params: { id: turma.id }, format: :json
      expect(response).to have_http_status(:ok)
      turma_resposta = JSON.parse(response.body)
      expect(turma_resposta["code"]).to eq(turma.code)
      expect(turma_resposta["number"]).to eq(turma.number)
      expect(turma_resposta["semester"]).to eq(turma.semester)
      expect(turma_resposta["time"]).to eq(turma.time)
    end
  end

  describe "PATCH /turmas/:id" do
    it "atualiza os dados da turma" do
      patch :update, params: { id: turma.id, turma: { code: turma1.code, number: turma1.number, semester: turma1.semester, time: turma1.time, disciplina_id: disciplina.id } }, format: :json
      expect(response).to have_http_status(:ok)
      turma_resposta = JSON.parse(response.body)
      expect(turma_resposta["id"]).to eq(turma.id)
      expect(turma_resposta["code"]).to eq(turma1.code)
    end
  end

  describe "DELETE /turmas/:id" do
    it "deleta uma turma" do
      expect {
        delete :destroy, params: { id: turma.id }, format: :json
      }.to change(Turma, :count).by(-1)
      expect(response).to have_http_status(:no_content)
    end
  end
end