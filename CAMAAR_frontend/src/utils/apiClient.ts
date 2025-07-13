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

    async getFormularios() {
        return await this.api.get(`/formularios`);
    }
}