import React, { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import "../App.css";
import "./Login.css";
import "./LoginError.css";
import { useAuth } from "../context/AuthContext";
 
function Login() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
 
  const navigate = useNavigate();
  const { login, isAuthenticated } = useAuth();
 
  useEffect(() => {
    if (isAuthenticated) {
      navigate("/gerenciamento");
    }
  }, [isAuthenticated, navigate]);
 
  const handleLogin = async () => {
    if (!email || !password) {
      setError("Por favor, preencha email e senha.");
      return;
    }
 
    setLoading(true);
    setError("");
 
    try {
      const success = await login(email, password);
      if (success) {
        navigate("/gerenciamento");
      } else {
        setError("Email ou senha incorretos");
      }
    } catch (err) {
      console.error("Erro no login:", err);
      setError("Erro ao tentar fazer login. Tente novamente.");
    } finally {
      setLoading(false);
    }
  };
  const handleKeyPress = (event) => {
    if (event.key === 'Enter') {
      handleLogin();
    }
  };
 
  return (
    <div className="login-bg-custom">
      <div className="login-box-custom">
        <div className="login-form-side-custom">
          <h2>LOGIN</h2>
          {error && <div className="login-error">{error}</div>}
          <label>Email</label>
          <input
            type="email"
            placeholder="admin@aluno.unb.br"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            onKeyPress={handleKeyPress}
            disabled={loading}
          />
          <label>Senha</label>
          <input
            type="password"
            placeholder="Password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            onKeyPress={handleKeyPress}
            disabled={loading}
          />
          <button 
            onClick={handleLogin} 
            disabled={loading}
            className="login-btn-custom"
          >
            {loading ? "Entrando..." : "Acessar senha"}
          </button>
          <div style={{ marginTop: '1rem', textAlign: 'center' }}>
            <a href="/redefinir-senha" className="login-link">Esqueci minha senha</a>
          </div>
        </div>
        <div className="login-welcome-side-custom">
          <div className="welcome-text-custom">
            <span>Bem vindo</span>
            <br />
            <span>ao</span>
            <br />
            <span>Camaar</span>
          </div>
        </div>
      </div>
    </div>
  );
}
 
export default Login;