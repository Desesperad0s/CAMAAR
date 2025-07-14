import React from 'react';
import './NovaSenha.css';

function NovaSenha() {
  return (
    <div className="login-container">
      <div className="login-box">
        <h2 className="login-title">Criar nova senha</h2>
        <p className="login-subtitle">Digite e confirme a nova senha para concluir</p>
        <form className="login-form">
          <input type="password" placeholder="Nova senha" className="login-input" required />
          <input type="password" placeholder="Confirmar nova senha" className="login-input" required />
          <button type="submit" className="login-button">Salvar nova senha</button>
        </form>
        <div className="login-footer">
          <a href="/login" className="login-link">Voltar ao login</a>
        </div>
      </div>
    </div>
  );
}

export default NovaSenha;
