import React from 'react';
import './styles.css';

function Navbar({ title = 'Avaliações' }) {
  return (
    <div className="navbar">
      <div className="navbar-left">
        <span className="menu-icon">☰</span>
        {title}
      </div>
      <div className="avatar">U</div>
    </div>
  );
}

export default Navbar;