import React, { useState } from "react";
import "./RedefinirSenha.css";
import { Api } from "../utils/apiClient.ts";

function RedefinirSenha() {
  const [email, setEmail] = useState("");
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState("");
  const [error, setError] = useState("");

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    if (!email) {
      setError("Por favor, digite seu e-mail.");
      setMessage("");
      return;
    }
    
    setLoading(true);
    setError("");
    setMessage("");
    
    try {
      const api = new Api();
      await api.forgotPassword(email);
      setMessage("Se existir uma conta com este e-mail, um link de redefinição foi enviado.");
      setError("");
    } catch (err) {
      if (err?.response?.data?.error) {
        setError(err.response.data.error);
      } else {
        setError("Erro ao enviar email de redefinição.");
      }
      setMessage("");
    } finally {
      setLoading(false);
    }
  };

  const handleKeyPress = (event) => {
    if (event.key === 'Enter') {
      handleSubmit(event);
    }
  };

  return (
    <div className="redefinir-bg-custom">
      <div className="redefinir-box-custom">
        <div className="redefinir-form-side-custom">
          <h2>REDEFINIR SENHA</h2>
          <p className="redefinir-subtitle">Digite seu e-mail para receber as instruções</p>
          
          {error && <div className="redefinir-error">{error}</div>}
          {message && <div className="redefinir-success">{message}</div>}
          
          <label>E-mail</label>
          <input
            type="email"
            placeholder="Digite seu e-mail institucional"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            onKeyPress={handleKeyPress}
            disabled={loading}
          />
          
          <button 
            onClick={handleSubmit} 
            disabled={loading}
            className="redefinir-btn-custom"
          >
            {loading ? "Enviando..." : "Enviar Link"}
          </button>
          
          <div className="redefinir-footer">
            <a href="/login" className="redefinir-link">← Voltar ao login</a>
          </div>
        </div>
        
        <div className="redefinir-welcome-side-custom">
          <div className="redefinir-welcome-text-custom">
            <span>Redefinir</span>
            <br />
            <span>sua</span>
            <br />
            <span>Senha</span>
          </div>
        </div>
      </div>
    </div>
  );
}

export default RedefinirSenha;
