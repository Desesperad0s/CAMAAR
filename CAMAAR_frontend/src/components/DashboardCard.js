// src/components/DashboardCard.js
import React from 'react';
import './DashboardCard.css';

const DashboardCard = ({ materia, professor, semestre }) => {
  return (
    <div className="dashboard-card">
      <div className="card-title">{materia}</div>
      <div className="card-sub">{semestre}</div>
      <div className="card-footer">{professor}</div>
    </div>
  );
};

export default DashboardCard;
