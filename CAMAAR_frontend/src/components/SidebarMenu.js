import React from 'react';
import { NavLink } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import './SidebarMenu.css';

function SidebarMenu() {
  const { user } = useAuth();
  
  if (!user) return null;
  
  return (
    <div className="sidebar-menu">
      <div className="sidebar-header">
        <h2>CAMAAR</h2>
      </div>
      
      <nav className="sidebar-nav">
        <ul>
          {/* Menu para estudantes */}
          {user.role === 'student' && (
            <>
              <li>
                <NavLink to="/available-forms" className={({ isActive }) => isActive ? "active" : ""}>
                  <span className="icon">📋</span>
                  <span className="label">Formulários Disponíveis</span>
                </NavLink>
              </li>
            </>
          )}
          
          {/* Menu para professores */}
          {user.role === 'professor' && (
            <>
              <li>
                <NavLink to="/gerenciamento" className={({ isActive }) => isActive ? "active" : ""}>
                  <span className="icon">📊</span>
                  <span className="label">Gerenciamento</span>
                </NavLink>
              </li>
              <li>
                <NavLink to="/resultados" className={({ isActive }) => isActive ? "active" : ""}>
                  <span className="icon">📈</span>
                  <span className="label">Resultados</span>
                </NavLink>
              </li>
            </>
          )}
          
          {/* Menu para administradores */}
          {user.role === 'admin' && (
            <>
              <li>
                <NavLink to="/admin/create-form" className={({ isActive }) => isActive ? "active" : ""}>
                  <span className="icon">✏️</span>
                  <span className="label">Criar Formulário</span>
                </NavLink>
              </li>
              <li>
                <NavLink to="/templates" className={({ isActive }) => isActive ? "active" : ""}>
                  <span className="icon">📑</span>
                  <span className="label">Templates</span>
                </NavLink>
              </li>
              <li>
                <NavLink to="/gerenciamento" className={({ isActive }) => isActive ? "active" : ""}>
                  <span className="icon">🔧</span>
                  <span className="label">Gerenciamento</span>
                </NavLink>
              </li>
            </>
          )}
        </ul>
      </nav>
    </div>
  );
}

export default SidebarMenu;
