import React, { useState } from 'react';
import './CriarTemplateModal.css';
import { Api } from '../utils/apiClient.ts';

const tipos = [
  { value: 'texto', label: 'Texto' },
  { value: 'radio', label: 'Alternativas' },
];

function CriarTemplateModal({ open, onClose, onSuccess }) {
  const [nome, setNome] = useState('');
  const [questoes, setQuestoes] = useState([
    { tipo: 'radio', texto: '', opcoes: [''] },
  ]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  
  const api = new Api();

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
  
  const handleSubmit = async () => {
    // Validações básicas
    if (!nome.trim()) {
      setError('O nome do template não pode estar vazio');
      return;
    }
    
    if (questoes.length === 0) {
      setError('O template precisa ter pelo menos uma questão');
      return;
    }
    
    // Validar cada questão
    for (let i = 0; i < questoes.length; i++) {
      const questao = questoes[i];
      if (!questao.texto.trim()) {
        setError(`O texto da questão ${i+1} não pode estar vazio`);
        return;
      }
      
      if (questao.tipo === 'radio') {
        // Verificar se há pelo menos uma opção e se nenhuma está vazia
        if (questao.opcoes.length === 0) {
          setError(`A questão ${i+1} precisa ter pelo menos uma opção`);
          return;
        }
      }
    }
    
    setLoading(true);
    setError('');
    
    try {
      const currentUser = api.getCurrentUser();
      
      const templateData = {
        template: {
          content: nome,
          admin_id: currentUser?.id,
          questoes_attributes: questoes.map(q => {
            const questaoObj = {
              enunciado: q.texto
            };
            
            if (q.tipo === 'radio' && q.opcoes && q.opcoes.length > 0) {
              questaoObj.alternativas_attributes = q.opcoes.map(opcao => ({
                content: opcao
              }));
            }
            
            return questaoObj;
          })
        }
      };
      
      console.log('Enviando dados para o backend:', JSON.stringify(templateData, null, 2));
      await api.createTemplate(templateData);
      
      setNome('');
      setQuestoes([{ tipo: 'radio', texto: '', opcoes: [''] }]);
      
      if (onSuccess) {
        onSuccess();
      }
      
      onClose();
      
    } catch (err) {
      console.error('Erro ao criar template:', err);
      setError('Ocorreu um erro ao criar o template. Tente novamente.');
    } finally {
      setLoading(false);
    }
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
          {error && (
            <div className="modal-error">
              {error}
            </div>
          )}
          <div style={{ display: 'flex', justifyContent: 'flex-end', marginTop: 10 }}>
            <button 
              className="modal-criar" 
              onClick={handleSubmit} 
              disabled={loading}
            >
              {loading ? 'Criando...' : 'Criar'}
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}

export default CriarTemplateModal;
