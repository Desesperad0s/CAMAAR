export class HttpClient {
  baseUrl: string;
  headers: Record<string, string>;

  constructor(baseUrl: string, headers: Record<string, string> = {}) {
    this.baseUrl = baseUrl;
    this.headers = {
      'Content-Type': 'application/json',
      ...headers,
    };
  }
  
  updateHeaders(headers: Record<string, string>) {
    this.headers = {
      ...this.headers,
      ...headers,
    };
    
    // Remover headers nulos ou undefined
    Object.keys(this.headers).forEach(key => {
      if (this.headers[key] === null || this.headers[key] === undefined) {
        delete this.headers[key];
      }
    });
  }
  

  private buildQueryString(params?: Record<string, any>): string {
    if (!params) return '';
    const esc = encodeURIComponent;
    return (
      '?' +
      Object.entries(params)
        .filter(([_, v]) => v !== undefined && v !== null)
        .map(([k, v]) => `${esc(k)}=${esc(v)}`)
        .join('&')
    );
  }

  async get<T>(url: string, options?: { queryParams?: Record<string, any>; responseType?: string }): Promise<T> {
    const { queryParams, responseType } = options || {};
    const normalizedUrl =
      this.normalizeUrl(url) + this.buildQueryString(queryParams);
    
    try {
      const res = await fetch(`${this.baseUrl}${normalizedUrl}`, {
        method: 'GET',
        headers: this.headers,
        credentials: 'include',
      });
      
      if (!res.ok) {
        const errorText = await res.text();
        throw new Error(errorText || `Server returned ${res.status}: ${res.statusText}`);
      }
      
      if (responseType === 'blob') {
        return res.blob() as unknown as T;
      }
      
      return res.json();
    } catch (error) {
      console.error(`Error fetching ${url}:`, error);
      throw error;
    }
  }


  async post<T>(url: string, body: any, queryParams?: Record<string, any>): Promise<T> {
    const normalizedUrl = this.normalizeUrl(url) + this.buildQueryString(queryParams);
    const res = await fetch(`${this.baseUrl}${normalizedUrl}`, {
      method: 'POST',
      headers: this.headers,
      credentials: 'include',
      body: JSON.stringify(body),
    });
    if (!res.ok) throw new Error(await res.text());
    return res.json();
  }


  async put<T>(url: string, body: any, queryParams?: Record<string, any>): Promise<T> {
    const normalizedUrl = this.normalizeUrl(url) + this.buildQueryString(queryParams);
    const res = await fetch(`${this.baseUrl}${normalizedUrl}`, {
      method: 'PUT',
      headers: this.headers,
      credentials: 'include',
      body: JSON.stringify(body),
    });
    if (!res.ok) throw new Error(await res.text());
    return res.json();
  }


  async delete<T>(url: string, queryParams?: Record<string, any>): Promise<T> {
    const normalizedUrl = this.normalizeUrl(url) + this.buildQueryString(queryParams);
    const res = await fetch(`${this.baseUrl}${normalizedUrl}`, {
      method: 'DELETE',
      credentials: 'include',
      headers: this.headers,
    });
    if (!res.ok) throw new Error(await res.text());
    return res.json();
  }

  private normalizeUrl(url: string): string {
    return "/"+url.replace(/^\//, '') ;
  }

}