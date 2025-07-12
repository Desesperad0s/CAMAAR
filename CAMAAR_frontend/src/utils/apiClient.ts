import { HttpClient } from "./httpClient.ts";
const BACK_URL = "http://caamar_rails:3000";

export class Api {
    api;
    constructor() {
        this.api = new HttpClient(
            BACK_URL, 
            { credentials: 'include' }
        );
    }

    async login(email, password) {
        const response = await this.api.post(`/login`, { email, password });
        return response.data;
    }
}
