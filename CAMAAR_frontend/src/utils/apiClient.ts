import { HttpClient } from "./httpClient";

export class Api {
    api;
    constructor() {
        this.api = new HttpClient(
            process.env.REACT_APP_BACKEND_URL, 
            { credentials: 'include' }
        );
    }
}