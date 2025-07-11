import React, { useState } from 'react';
import './CriarTemplateModal.css';

const tipos = [
  { value: 'texto', label: 'Texto' },
  { value: 'radio', label: 'Alternativas' },
];

function CriarTemplateModal({ open, onClose }) {
  const [nome, setNome] = useState('');
  const [questoes, setQuestoes] = useState([
    { tipo: 'radio', texto: '', opcoes: [''] },
  ]);

  if (!open) return null;

  const handleAddQuestao = () => {
    setQuestoes([...questoes, { tipo: 'texto', texto: '', opcoes: [''] }]);
  };

  const handleChangeQuestao = (idx, field, value) => {
    const novas = questoes.map((q, i) =>
      i === idx ? { ...q, [field]: value } : q
    );
    setQuestoes(novas);
  };

  const handleChangeOpcao = (qIdx, oIdx, value) => {
    const novas = questoes.map((q, i) => {
      if (i !== qIdx) return q;
      const novasOpcoes = q.opcoes.map((op, j) => (j === oIdx ? value : op));
      return { ...q, opcoes: novasOpcoes };
    });
    setQuestoes(novas);
  };

  const handleAddOpcao = (qIdx) => {
    const novas = questoes.map((q, i) =>
      i === qIdx ? { ...q, opcoes: [...q.opcoes, ''] } : q
    );
    setQuestoes(novas);
  };

  return (
    <div className="modal-bg">
      <div className="modal-box">
        <button className="modal-close" onClick={onClose}>&times;</button>
        <div className="modal-content">
          <label>Nome do template:</label>
          <input className="modal-input" value={nome} onChange={e => setNome(e.target.value)} placeholder="Placeholder" />
          {questoes.map((q, idx) => (
            <div key={idx} className="modal-questao">
              <div className="modal-questao-title">Questão {idx + 1}</div>
              <div className="modal-row">
                <label>Tipo:</label>
                <select
                  value={q.tipo}
                  onChange={e => handleChangeQuestao(idx, 'tipo', e.target.value)}
                  className="modal-select"
                >
                  {tipos.map(t => (
                    <option key={t.value} value={t.value}>{t.label}</option>
                  ))}
                </select>
              </div>
              <div className="modal-row">
                <label>Texto:</label>
                <input
                  className="modal-input"
                  value={q.texto}
                  onChange={e => handleChangeQuestao(idx, 'texto', e.target.value)}
                  placeholder="Placeholder"
                />
              </div>
              {q.tipo === 'radio' && (
                <div className="modal-row">
                  <label>Opções:</label>
                  <div style={{ flex: 1 }}>
                    {q.opcoes.map((op, oIdx) => (
                      <input
                        key={oIdx}
                        className="modal-input"
                        value={op}
                        onChange={e => handleChangeOpcao(idx, oIdx, e.target.value)}
                        placeholder="Placeholder"
                        style={{ marginBottom: 8 }}
                      />
                    ))}
                    <button type="button" className="modal-add-opcao" onClick={() => handleAddOpcao(idx)}>+</button>
                  </div>
                </div>
              )}
            </div>
          ))}
          <button type="button" className="modal-add-questao" onClick={handleAddQuestao}>+</button>
          <div style={{ display: 'flex', justifyContent: 'flex-end', marginTop: 10 }}>
            <button className="modal-criar">Criar</button>
          </div>
        </div>
      </div>
    </div>
  );
}

export default CriarTemplateModal;
