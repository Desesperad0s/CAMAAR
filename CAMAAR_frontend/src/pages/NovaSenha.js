import React, { useState } from "react";
import "./NovaSenha.css";
import { Api } from "../utils/apiClient.ts";
import { useLocation } from "react-router-dom";

function NovaSenha() {
  const location = useLocation();
  // Extrai token e email da query string
  const searchParams = new URLSearchParams(location.search);
  const token = searchParams.get("token") || "";
  const email = searchParams.get("email") || "";
  const [password, setPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState("");
  const [error, setError] = useState("");

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError("");
    setMessage("");
    
    if (!password || !confirmPassword) {
      setError("Por favor, preencha todos os campos.");
      return;
    }
    
    if (password !== confirmPassword) {
      setError("As senhas não coincidem.");
      return;
    }
    
    if (password.length < 6) {
      setError("A senha deve ter pelo menos 6 caracteres.");
      return;
    }
    
    setLoading(true);
    try {
      const api = new Api();
      await api.resetPassword({
        token,
        email,
        password,
        password_confirmation: confirmPassword,
      });
      setMessage("Senha redefinida com sucesso! Você já pode fazer login.");
      setError("");
      setPassword("");
      setConfirmPassword("");
    } catch (err) {
      setError("Erro ao redefinir senha. Verifique o link ou tente novamente.");
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
    <div className="nova-senha-bg-custom">
      <div className="nova-senha-box-custom">
        <div className="nova-senha-form-side-custom">
          <h2>NOVA SENHA</h2>
          <p className="nova-senha-subtitle">Defina sua nova senha de acesso</p>
          
          {error && <div className="nova-senha-error">{error}</div>}
          {message && <div className="nova-senha-success">{message}</div>}
          
          <label>Nova Senha</label>
          <input
            type="password"
            placeholder="Digite sua nova senha"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            onKeyPress={handleKeyPress}
            disabled={loading}
          />
          
          <label>Confirmar Senha</label>
          <input
            type="password"
            placeholder="Confirme sua nova senha"
            value={confirmPassword}
            onChange={(e) => setConfirmPassword(e.target.value)}
            onKeyPress={handleKeyPress}
            disabled={loading}
          />
          
          <button 
            onClick={handleSubmit} 
            disabled={loading}
            className="nova-senha-btn-custom"
          >
            {loading ? "Salvando..." : "Salvar Nova Senha"}
          </button>
          
          <div className="nova-senha-footer">
            <a href="/login" className="nova-senha-link">← Voltar ao login</a>
          </div>
        </div>
        
        <div className="nova-senha-welcome-side-custom">
          <div className="nova-senha-welcome-text-custom">
            <span>Nova</span>
            <br />
            <span>Senha</span>
            <br />
            <span>Segura</span>
          </div>
        </div>
      </div>
    </div>
  );
}

export default NovaSenha;

