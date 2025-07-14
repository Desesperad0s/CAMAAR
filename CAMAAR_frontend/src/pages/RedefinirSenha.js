import React from 'react';
import './RedefinirSenha.css';

function RedefinirSenha() {
  return (
    <div className="login-container">
      <div className="login-box">
        <h2 className="login-title">Redefinir Senha</h2>
        <p className="login-subtitle">Digite seu e-mail para redefinir sua senha</p>
        <form className="login-form">
          <input type="email" placeholder="E-mail institucional" className="login-input" required />
          <button type="submit" className="login-button">Enviar link de redefinição</button>
        </form>
        <div className="login-footer">
          <a href="/" className="login-link">Voltar ao login</a>
        </div>
      </div>
    </div>
  );
}

export default RedefinirSenha;
