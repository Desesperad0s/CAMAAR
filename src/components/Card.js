import React from 'react';
import './styles.css';

function Card() {
  return (
    <div className="card">
      <div className="card-title">Nome da matéria</div>
      <div className="card-semester">semestre</div>
      <div className="card-professor">Professor</div>
    </div>
  );
}

export default Card;