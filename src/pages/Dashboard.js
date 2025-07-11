import React from 'react';
import Navbar from '../components/Navbar';
import Card from '../components/Card';
import './styles.css';

function Dashboard() {
  return (
    <div>
      <Navbar />
      <div className="cards-container">
        {[...Array(5)].map((_, i) => <Card key={i} />)}
      </div>
    </div>
  );
}

export default Dashboard;
