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

    async login(email, password) {
        try {
            const response = await this.api.post(`/auth/login`, { email, password });
            if (response && response.token) {
                localStorage.setItem('token', response.token);
                localStorage.setItem('user', JSON.stringify(response.user));
                this.token = response.token;
                
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

    async getFormulario(id) {
        return await this.api.get(`/formularios/${id}`);
    }

    async createFormularioWithTemplate(templateId, turmaId, name, date) {
        try {
            if (!templateId) throw new Error("ID do template é obrigatório");
            if (!turmaId) throw new Error("ID da turma é obrigatório");
            
            // Se name não for fornecido, crie um nome padrão
            const formName = name || `Formulário ${new Date().toLocaleDateString()}`;
            // Se date não for fornecido, use a data atual
            const formDate = date || new Date().toISOString().split('T')[0];
            
            console.log("Enviando request para criar formulário:", {
                template_id: templateId,
                turma_id: turmaId,
                name: formName,
                date: formDate
            });
            
            return await this.api.post('/formularios/create_with_questions', {
                template_id: templateId,
                turma_id: turmaId,
                name: formName,
                date: formDate
            });
        } catch (error) {
            console.error("Erro ao criar formulário com template:", error);
            throw error;
        }
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
        return await this.api.get(`/formularios/${formularioId}/questoes`);
    }

    async getAlternativas(questaoId) {
        return await this.api.get(`/alternativas?questao_id=${questaoId}`);
    }

    async getAdmins() {
        return await this.api.get('/admins');
    }
    
    // Métodos para AvailableForms
    async getUserTurmas() {
        try {
            return await this.api.get('/user/turmas');
        } catch (error) {
            console.error("Erro ao buscar turmas do usuário:", error);
            return null;
        }
    }
    
    async getTurmaForms(turmaId) {
        try {
            return await this.api.get(`/turmas/${turmaId}/formularios`);
        } catch (error) {
            console.error(`Erro ao buscar formulários da turma ${turmaId}:`, error);
            return null;
        }
    }
    
    async getFormularioDetails(formularioId) {
        try {
            return await this.api.get(`/formularios/${formularioId}`);
        } catch (error) {
            console.error(`Erro ao buscar detalhes do formulário ${formularioId}:`, error);
            return null;
        }
    }
    
    async submitFormAnswers(formRespostas) {
        try {
            return await this.api.post('/resposta/batch_create', { respostas: formRespostas });
        } catch (error) {
            console.error("Erro ao enviar respostas do formulário:", error);
            throw error;
        }
    }
    
    async getFormularios() {
        try {
            return await this.api.get('/formularios');
        } catch (error) {
            console.error("Erro ao buscar formulários:", error);
            throw error;
        }
    }
    
    async getFormulariosRespondidos() {
        try {
            // Como não temos mais relação com usuários, esta função pode verificar
            // os formulários que têm pelo menos uma resposta
            const response = await this.api.get('/formularios');
            // Aqui poderíamos fazer alguma lógica adicional para filtrar formulários respondidos
            return response;
        } catch (error) {
            console.error("Erro ao buscar formulários respondidos:", error);
            return { data: [] };
        }
    }
    
    async getRespostasByForm(formId) {
        try {
            return await this.api.get(`/resposta/formulario/${formId}`);
        } catch (error) {
            console.error(`Erro ao buscar respostas do formulário ${formId}:`, error);
            return { data: [] };
        }
    }
}
