import React from 'react';
import Navbar from './Navbar';
import SidebarMenu from './SidebarMenu';
import './Layout.css';

function Layout({ children, title = 'CAMAAR', showSidebar = true }) {
  return (
    <div className="app-container">
      {showSidebar && <SidebarMenu />}
      <div className={`content-area ${showSidebar ? 'with-sidebar' : ''}`}>
        <Navbar title={title} />
        <main className="main-content">
          {children}
        </main>
      </div>
    </div>
  );
}

export default Layout;
