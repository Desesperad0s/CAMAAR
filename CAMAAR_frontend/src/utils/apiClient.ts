import { HttpClient } from "./httpClient.ts";
const BACK_URL = "http://localhost:3333";

export class Api {
    api;
    token;

    constructor() {
        this.token = localStorage.getItem('token');
        const headers = { credentials: 'include' };
        if (this.token) {
            headers['Authorization'] = `Bearer ${this.token}`;
        }
        this.api = new HttpClient(BACK_URL, headers);
    }

    
    async createFormularioWithTemplate(templateId, turmaId, name) {
        try {
            const today = new Date().toISOString().slice(0, 10); // yyyy-mm-dd
            return await this.api.post('/formularios', {
                name: name || `Formulário gerado em ${today}`,
                date: today,
                template_id: templateId,
                turma_id: turmaId
            });
        } catch (error) {
            console.error('Erro ao criar formulário com template:', error);
            throw error;
        }
    }

    async login(email, password) {
        try {
            const response = await this.api.post(`/auth/login`, { email, password });
            if (response && response.token) {
                localStorage.setItem('token', response.token);
                localStorage.setItem('user', JSON.stringify(response.user));
                this.token = response.token;
                
                // Atualizar os headers com o novo token
                this.api.updateHeaders({ 
                    'Authorization': `Bearer ${response.token}`
                });
                
                return response;
            }
            return null;
        } catch (error) {
            console.error("Erro de login:", error);
            return null;
        }
    }
    
    async logout() {
        try {
            await this.api.delete('/auth/logout');
            this.clearAuth();
            return true;
        } catch (error) {
            console.error("Erro ao fazer logout:", error);
            return false;
        }
    }
    
    async getUserProfile() {
        try {
            return await this.api.get('/auth/me');
        } catch (error) {
            console.error("Erro ao buscar perfil:", error);
            return null;
        }
    }
    
    clearAuth() {
        localStorage.removeItem('token');
        localStorage.removeItem('user');
        this.token = null;
        this.api.updateHeaders({ 'Authorization': null });
    }
    
    isAuthenticated() {
        return !!this.token;
    }
    
    getCurrentUser() {
        const userStr = localStorage.getItem('user');
        if (userStr) {
            try {
                return JSON.parse(userStr);
            } catch (e) {
                this.clearAuth();
                return null;
            }
        }
        return null;
    }

    // Templates
    async getTemplates() {
        try {
            return await this.api.get('/templates');
        } catch (error) {
            console.error("Erro ao buscar templates:", error);
            return null;
        }
    }

    async getTemplate(id) {
        try {
            return await this.api.get(`/templates/${id}`);
        } catch (error) {
            console.error(`Erro ao buscar template ${id}:`, error);
            return null;
        }
    }

    async createTemplate(templateData) {
        try {
            return await this.api.post('/templates', templateData);
        } catch (error) {
            console.error("Erro ao criar template:", error);
            throw error;
        }
    }

    async deleteTemplate(id) {
        try {
            return await this.api.delete(`/templates/${id}`);
        } catch (error) {
            console.error(`Erro ao deletar template ${id}:`, error);
            throw error;
        }
    }

    async updateTemplate(id, templateData) {
        try {
            return await this.api.put(`/templates/${id}`, templateData);
        } catch (error) {
            console.error(`Erro ao atualizar template ${id}:`, error);
            throw error;
        }
    }

    async getFormularios() {
        return await this.api.get(`/formularios`);
    }
    
    async generateExcelReport() {
        try {
            return await this.api.get(`/formularios/report/excel`, { responseType: 'blob' });
        } catch (error) {
            console.error("Erro ao gerar relatório Excel:", error);
            throw error;
        }
    }
    
    // Métodos para AvailableForms
    async getUserTurmas() {
        try {
            return await this.api.get('/user/turmas');
        } catch (error) {
            console.error("Erro ao buscar turmas do usuário:", error);
            return [];
        }
    }
    
    async getTurmaForms(turmaId) {
        try {
            return await this.api.get(`/turmas/${turmaId}/formularios`);
        } catch (error) {
            console.error(`Erro ao buscar formulários da turma ${turmaId}:`, error);
            return [];
        }
    }
    
    async getFormularioDetails(formId) {
        try {
            return await this.api.get(`/formularios/${formId}`);
        } catch (error) {
            console.error(`Erro ao buscar detalhes do formulário ${formId}:`, error);
            return null;
        }
    }
    
    async getTurma(turmaId) {
        try {
            return await this.api.get(`/turmas/${turmaId}`);
        } catch (error) {
            console.error(`Erro ao buscar turma ${turmaId}:`, error);
            return null;
        }
    }
    
    async getTurmas() {
        try {
            return await this.api.get(`/turmas`);
        } catch (error) {
            console.error(`Erro ao buscar turmas`, error);
            return null;
        }
    }
    
    async getDisciplinas() {
        try {
            return await this.api.get(`/disciplinas`);
        } catch (error) {
            console.error(`Erro ao buscar disciplina`, error);
            return null;
        }
    }
    async getDisciplina(disciplinaId) {
        try {
            return await this.api.get(`/disciplinas/${disciplinaId}`);
        } catch (error) {
            console.error(`Erro ao buscar disciplina ${disciplinaId}:`, error);
            return null;
        }
    }
    
    async getFormulario(formId) {
        try {
            return await this.api.get(`/formularios/${formId}`);
        } catch (error) {
            console.error(`Erro ao buscar formulário ${formId}:`, error);
            return null;
        }
    }
    
    async getQuestoes(formId) {
        try {
            return await this.api.get(`/formularios/${formId}/questoes`);
        } catch (error) {
            console.error(`Erro ao buscar questões do formulário ${formId}:`, error);
            return [];
        }
    }
    
    async getAlternativas(questaoId) {
        try {
            return await this.api.get(`/alternativas?questao_id=${questaoId}`);
        } catch (error) {
            console.error(`Erro ao buscar alternativas para questão ${questaoId}:`, error);
            return [];
        }
    }
    
    async submitFormAnswers(answers) {
        try {
            return await this.api.post('/resposta/batch_create', { respostas: answers });
        } catch (error) {
            console.error("Erro ao enviar respostas:", error);
            throw error;
        }
    }
    
    async importData() {
        try {
            return await this.api.post('/import-data');
        } catch (error) {
            console.error("Erro ao importar dados:", error);
            throw error;
        }
    }
}