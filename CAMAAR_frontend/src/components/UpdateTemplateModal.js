import React, { useState, useEffect } from 'react';
import './CriarTemplateModal.css';
import { Api } from '../utils/apiClient.ts';

const tipos = [
  { value: 'texto', label: 'Texto' },
  { value: 'radio', label: 'Alternativas' },
];

function UpdateTemplateModal({ open, onClose, onSuccess, templateData }) {
  const [nome, setNome] = useState('');
  const [questoes, setQuestoes] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  
  const api = new Api();


  useEffect(() => {
    if (open && templateData) {
      setNome(templateData.content || '');
      
      const questoesFormatadas = templateData.questoes?.map(questao => {
        const temAlternativas = questao.alternativas && questao.alternativas.length > 0;
        
        return {
          tipo: temAlternativas ? 'radio' : 'texto',
          texto: questao.enunciado || '',
          opcoes: temAlternativas 
            ? questao.alternativas.map(alt => ({
                content: alt.content
              }))
            : [{ content: '' }],
          _destroy: false
        };
      }) || [];
      
      setQuestoes(questoesFormatadas);
    }
  }, [open, templateData]);


  useEffect(() => {
    if (!open) {
      setNome('');
      setQuestoes([]);
      setError('');
    }
  }, [open]);

  if (!open) return null;

  const handleAddQuestao = () => {
    setQuestoes([...questoes, { 
      tipo: 'radio', 
      texto: '', 
      opcoes: [{ content: '' }],
      _destroy: false
    }]);
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
      const novasOpcoes = q.opcoes.map((op, j) => 
        j === oIdx ? { ...op, content: value } : op
      );
      return { ...q, opcoes: novasOpcoes };
    });
    setQuestoes(novas);
  };

  const handleAddOpcao = (qIdx) => {
    const novas = questoes.map((q, i) =>
      i === qIdx ? { ...q, opcoes: [...q.opcoes, { content: '' }] } : q
    );
    setQuestoes(novas);
  };

  const handleRemoveOpcao = (qIdx, oIdx) => {
    const novas = questoes.map((q, i) => {
      if (i !== qIdx) return q;
      if (q.opcoes.length <= 1) return q;
      
      const opcaoToRemove = q.opcoes[oIdx];
      let novasOpcoes;
      
      novasOpcoes = q.opcoes.map((op, j) => 
        j === oIdx ? { ...op, _destroy: true } : op
      );
      
      return { ...q, opcoes: novasOpcoes };
    });
    setQuestoes(novas);
  };

  const handleRemoveQuestao = (idx) => {
    const novas = questoes.map((q, i) =>
      i === idx ? { ...q, _destroy: true } : q
    );
    setQuestoes(novas);
  };

  const handleRestoreQuestao = (idx) => {
    const novas = questoes.map((q, i) =>
      i === idx ? { ...q, _destroy: false } : q
    );
    setQuestoes(novas);
  };
  
  const handleSubmit = async () => {
    if (!nome.trim()) {
      setError('O nome do template não pode estar vazio');
      return;
    }
    
    const questoesAtivas = questoes.filter(q => !q._destroy);
    
    if (questoesAtivas.length === 0) {
      setError('O template precisa ter pelo menos uma questão');
      return;
    }
    
    for (let i = 0; i < questoesAtivas.length; i++) {
      const questao = questoesAtivas[i];
      if (!questao.texto.trim()) {
        setError(`O texto da questão ${i+1} não pode estar vazio`);
        return;
      }
      
      if (questao.tipo === 'radio') {
        const opcoesValidas = questao.opcoes.filter(op => !op._destroy && op.content.trim());
        if (opcoesValidas.length === 0) {
          setError(`A questão ${i+1} precisa ter pelo menos uma opção válida`);
          return;
        }
      }
    }
    
    setLoading(true);
    setError('');
    
    try {
      const currentUser = api.getCurrentUser();
      
      const novoTemplateData = {
        template: {
          content: nome,
          admin_id: currentUser?.id,
          questoes_attributes: questoesAtivas.map(q => {
            const questaoObj = {
              enunciado: q.texto
            };
            
            // Incluir alternativas se for tipo radio (sempre criando novas cópias)
            if (q.tipo === 'radio' && q.opcoes && q.opcoes.length > 0) {
              questaoObj.alternativas_attributes = q.opcoes
                .filter(opcao => !opcao._destroy && opcao.content.trim()) // Apenas opções válidas
                .map(opcao => ({
                  content: opcao.content // Criar nova alternativa (sem ID para forçar criação)
                }));
            }
            
            return questaoObj; // Questão sem ID para forçar criação de nova questão
          })
        }
      };
      

      const novoTemplate = await api.createTemplate(novoTemplateData);
      
      await api.deleteTemplate(templateData.id);
      
      if (onSuccess) {
        onSuccess();
      }
      
      onClose();
      
    } catch (err) {
      console.error('Erro ao atualizar template:', err);
      setError('Ocorreu um erro ao atualizar o template. Tente novamente.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="modal-bg">
      <div className="modal-box">
        <button className="modal-close" onClick={onClose}>&times;</button>
        
        <h3 style={{ marginBottom: '20px', color: '#333' }}>Editar Template</h3>
        <p style={{ fontSize: '14px', color: '#666', marginBottom: '15px' }}>
          Ao salvar, um novo template será criado com <strong>cópias independentes</strong> das questões modificadas. 
          O template atual será removido, mas as questões originais serão preservadas no banco de dados.
        </p>
        
        <label>Nome do template:</label>
        <input 
          className="modal-input" 
          value={nome} 
          onChange={e => setNome(e.target.value)} 
          placeholder="Nome do template" 
        />
        
        <div className="modal-content">
          {questoes.map((q, idx) => (
            <div key={idx} className={`modal-questao ${q._destroy ? 'questao-removida' : ''}`}>
              <div className="modal-questao-header">
                <div className="modal-questao-title">
                  Questão {idx + 1}
                  {q._destroy && <span className="questao-removida-label"> - SERÁ REMOVIDA</span>}
                </div>
                <div className="questao-actions">
                  {q._destroy ? (
                    <button 
                      type="button" 
                      className="questao-restore-btn"
                      onClick={() => handleRestoreQuestao(idx)}
                      title="Restaurar questão"
                    >
                      ↶ Restaurar
                    </button>
                  ) : (
                    <button 
                      type="button" 
                      className="questao-remove-btn"
                      onClick={() => handleRemoveQuestao(idx)}
                      title="Remover questão"
                    >
                      🗑️
                    </button>
                  )}
                </div>
              </div>
              
              {!q._destroy && (
                <>
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
                      placeholder="Texto da questão"
                    />
                  </div>
                  {q.tipo === 'radio' && (
                    <div className="modal-row">
                      <label>Opções:</label>
                      <div style={{ flex: 1 }}>
                        {q.opcoes.map((op, oIdx) => (
                          !op._destroy && (
                            <div key={oIdx} style={{ display: 'flex', marginBottom: 8, alignItems: 'center' }}>
                              <input
                                className="modal-input"
                                value={op.content}
                                onChange={e => handleChangeOpcao(idx, oIdx, e.target.value)}
                                placeholder="Opção"
                                style={{ marginRight: 8 }}
                              />
                              {q.opcoes.filter(o => !o._destroy).length > 1 && (
                                <button 
                                  type="button" 
                                  className="modal-remove-opcao"
                                  onClick={() => handleRemoveOpcao(idx, oIdx)}
                                  title="Remover opção"
                                >
                                  ✖
                                </button>
                              )}
                            </div>
                          )
                        ))}
                        <button 
                          type="button" 
                          className="modal-add-opcao" 
                          onClick={() => handleAddOpcao(idx)}
                        >
                          + Adicionar opção
                        </button>
                      </div>
                    </div>
                  )}
                </>
              )}
            </div>
          ))}
          <button 
            type="button" 
            className="modal-add-questao" 
            onClick={handleAddQuestao}
          >
            + Adicionar nova questão
          </button>
        </div>
        
        {error && (
          <div className="modal-error">
            {error}
          </div>
        )}
        
        <div style={{ display: 'flex', justifyContent: 'flex-end', marginTop: 20, gap: 10 }}>
          <button 
            className="modal-cancel" 
            onClick={onClose}
            disabled={loading}
          >
            Cancelar
          </button>
          <button 
            className="modal-criar" 
            onClick={handleSubmit} 
            disabled={loading}
          >
            {loading ? 'Salvando...' : 'Salvar nova versão'}
          </button>
        </div>
      </div>
    </div>
  );
}

export default UpdateTemplateModal;
