import React, { useState } from "react";
import { useNavigate } from "react-router-dom";
import { useAuth } from "../context/AuthContext";
import "./styles.css";
import "./NavbarMenu.css";

function Navbar({ title = "Avaliações" }) {
  const navigate = useNavigate();
  const { user, logout } = useAuth();
  const [isMenuOpen, setIsMenuOpen] = useState(false);

  const handleLogout = async () => {
    await logout();
    navigate("/login");
  };

  const toggleMenu = () => {
    setIsMenuOpen(!isMenuOpen);
  };

  const handleLogoutClick = async () => {
    setIsMenuOpen(false);
    await logout();
    navigate("/login");
  };

  const getUserInitial = () => {
    if (user && user.name) {
      return user.name.charAt(0).toUpperCase();
    }
    return "U";
  };

  return (
    <div className="navbar navbar-custom">
      <div className="navbar-left">
        <span className="menu-icon">☰</span>
        <span className="navbar-title">{title}</span>
      </div>
      <div className="navbar-right">
        <input className="navbar-search" placeholder="Pesquisar..." />
        <div className="user-menu">
          <div className="avatar" onClick={toggleMenu}>
            {getUserInitial()}
          </div>
          {isMenuOpen && (
            <div className="dropdown-menu">
              <div className="user-info">
                {user && (
                  <>
                    <div className="user-name">{user.name}</div>
                    <div className="user-email">{user.email}</div>
                  </>
                )}
              </div>
              <div className="menu-items">
                <div className="menu-item" onClick={handleLogoutClick}>
                  Sair
                </div>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

export default Navbar;
