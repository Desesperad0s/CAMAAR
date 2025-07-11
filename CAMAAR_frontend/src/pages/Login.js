
import React from 'react';
import '../App.css';
import './Login.css';

function Login() {
  return (
    <div className="login-bg">
      <div className="login-box">
        <div className="login-form-side">
          <h2>LOGIN</h2>
          <label>Email</label>
          <input type="email" placeholder="admin@aluno.unb.br" />
          <label>Senha</label>
          <input type="password" placeholder="Password" />
          <button>Entrar</button>
        </div>
        <div className="login-welcome-side">
          <p>
            Bem vindo<br />ao<br />Camaar
          </p>
        </div>
      </div>
    </div>
  );
}

export default Login;
