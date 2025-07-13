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
}