import { HttpClient } from "./httpClient.ts";
const BACK_URL = "http://backend:3333";

export class Api {
    api;
    constructor() {
        this.api = new HttpClient(
            BACK_URL,
            { credentials: 'include' }
        );
    }

    async login(email, password) {
        return await this.api.post(`/login`, { email, password });
    }

    async getFormulario(id) {
        return await this.api.get(`/formularios/${id}`);
    }

    async createFormularioWithTemplate(templateId, turmaId, name, date) {
        return await this.api.post('/formularios/create_with_questions', {
            template_id: templateId,
            turma_id: turmaId,
            name: name,
            date: date
        });
    }


    async getTemplate(id) {
        return await this.api.get(`/templates/${id}`);
    }

    async getTurmas() {
        return await this.api.get('/turmas');
    }

    async getTurma(id) {
        return await this.api.get(`/turmas/${id}`);
    }

    async getDisciplinas() {
        return await this.api.get('/disciplinas');
    }

    async getDisciplina(id) {
        return await this.api.get(`/disciplinas/${id}`);
    }

    async getQuestoes(formularioId) {
        return await this.api.get(`/questaos?formulario_id=${formularioId}`);
    }

    async getAlternativas(questaoId) {
        return await this.api.get(`/alternativas?questao_id=${questaoId}`);
    }

    async getAdmins() {
        return await this.api.get('/admins');
    }
}
