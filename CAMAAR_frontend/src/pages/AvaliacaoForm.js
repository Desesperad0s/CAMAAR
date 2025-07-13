import React from 'react';
import Navbar from '../components/Navbar';
import './styles.css';

function AvaliacaoForm() {
  return (
    <div>
      <Navbar title="Avaliação - Nome da matéria - Semestre" />
      <div className="form-container">
        <div className="question-block">
          <p>Pergunta</p>
          {["Muito bom", "Bom", "Satisfatório", "Ruim", "Péssimo"].map((item, idx) => (
            <label key={idx}><input type="radio" name="q1" /> {item}</label>
          ))}
        </div>
        <div className="question-block">
          <p>Pergunta</p>
          <input type="text" placeholder="Placeholder" className="text-input" />
        </div>
        <div className="question-block">
          <p>Pergunta</p>
          <input type="text" placeholder="Placeholder" className="text-input" />
        </div>
        <div className="question-block">
          <p>Pergunta</p>
          {["Muito bom", "Bom", "Satisfatório", "Ruim", "Péssimo"].map((item, idx) => (
            <label key={idx}><input type="radio" name="q2" /> {item}</label>
          ))}
        </div>
      </div>
      <div className="floating-button">▶</div>
    </div>
  );
}

export default AvaliacaoForm;
