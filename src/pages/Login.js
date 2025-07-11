import React from 'react';
import './styles.css';

function Login() {
  return (
    <div className="login-container">
      <div className="login-form">
        <h2>LOGIN</h2>
        <label>Senha</label>
        <input type="email" placeholder="admin@aluno.unb.br" />
        <label>Confirme a senha</label>
        <input type="password" placeholder="Password" />
        <button>Alterar senha</button>
      </div>
      <div className="login-welcome">
        <div>
          <p>Bem vindo<br />ao<br />Camaar</p>
        </div>
      </div>
    </div>
  );
}

export default Login;
