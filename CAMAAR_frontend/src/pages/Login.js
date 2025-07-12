import React, { useState } from "react";
import "../App.css";
import "./Login.css";
import { Api } from "../utils/apiClient.ts";

function Login() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");

  const api = new Api();

  const handleLogin = async () => {
    const result = await api.login(email, password);
    if (result) {
      console.log("login deu certo", result);
    } else {
      alert("email ou senha incorretos");
    }
  };
  return (
    <div className="login-bg">
      <div className="login-box">
        <div className="login-form-side">
          <h2>LOGIN</h2>
          <label>Email</label>
          <input
            type="email"
            placeholder="admin@aluno.unb.br"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
          />
          <label>Senha</label>
          <input
            type="password"
            placeholder="Password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
          />
          <button onClick={handleLogin}>Entrar</button>
        </div>
        <div className="login-welcome-side">
          <p>
            Bem vindo
            <br />
            ao
            <br />
            Camaar
          </p>
        </div>
      </div>
    </div>
  );
}

export default Login;
