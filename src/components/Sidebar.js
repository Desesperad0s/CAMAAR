import React from 'react';
import './styles.css';

function Sidebar() {
  return (
    <div className="sidebar">
      <div className="sidebar-item active">Avaliações</div>
      <div className="sidebar-item">Gerenciamento</div>
    </div>
  );
}

export default Sidebar;