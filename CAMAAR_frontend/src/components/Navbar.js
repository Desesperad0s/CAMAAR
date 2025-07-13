import React from 'react';
import './styles.css';

function Navbar({ title = 'Avaliações' }) {
  return (
    <div className="navbar navbar-custom">
      <div className="navbar-left">
        <span className="menu-icon">☰</span>
        <span className="navbar-title">{title}</span>
      </div>
      <div className="navbar-right">
        <input className="navbar-search" placeholder="" />
        <div className="avatar">U</div>
      </div>
    </div>
  );
}

export default Navbar;