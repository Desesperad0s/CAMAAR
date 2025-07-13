import React from 'react';
import Navbar from '../components/Navbar';
import Sidebar from '../components/Sidebar';
import Card from '../components/Card';
import './styles.css';

function SidebarLayout() {
  return (
    <div>
      <Navbar />
      <div className="main">
        <Sidebar />
        <div className="cards-container">
          {[...Array(5)].map((_, i) => <Card key={i} />)}
        </div>
      </div>
    </div>
  );
}

export default SidebarLayout;
