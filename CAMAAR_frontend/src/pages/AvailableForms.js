import React, { useState, useEffect, useMemo } from "react";
import { useNavigate } from "react-router-dom";
import { Api } from "../utils/apiClient.ts";
import { useAuth } from "../context/AuthContext";
import Layout from "../components/Layout";
import "./AvailableForms.css";

function AvailableForms() {
  const [availableForms, setAvailableForms] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const { user } = useAuth();
  const navigate = useNavigate();
  
  const api = useMemo(() => new Api(), []);

  useEffect(() => {
    const fetchUserForms = async () => {
      try {
        setLoading(true);
        setError(null);
        
        const userTurmasResponse = await api.getUserTurmas();
        
        if (!userTurmasResponse || !Array.isArray(userTurmasResponse)) {
          setError("Não foi possível obter suas turmas.");
          return;
        }
        
        const formPromises = userTurmasResponse.map(turma => 
          api.getTurmaForms(turma.id)
        );
        
        const turmaFormsResponses = await Promise.all(formPromises);
        
        const allForms = turmaFormsResponses.flat().filter(Boolean);
        
        const uniqueFormsMap = {};
        allForms.forEach(form => {
          uniqueFormsMap[form.id] = form;
        });
        
        const formDetailsPromises = Object.values(uniqueFormsMap).map(form => 
          api.getFormularioDetails(form.id)
        );
        
        const formDetails = await Promise.all(formDetailsPromises);
        
        const formsWithDetails = [];
        
        for (const form of formDetails) {
          if (form && form.turma_id) {
            try {
              const turmaResponse = await api.getTurma(form.turma_id);
              
              if (turmaResponse && turmaResponse.disciplina_id) {
                const disciplinaResponse = await api.getDisciplina(turmaResponse.disciplina_id);
                
                if (disciplinaResponse) {
                  // Verificar se o formulário já foi respondido pelo usuário
                  const isResponded = false; // Aqui seria implementado a lógica para verificar se o usuário já respondeu
                  
                  formsWithDetails.push({
                    id: form.id,
                    name: form.name,
                    date: form.date ? new Date(form.date).toLocaleDateString('pt-BR') : 'Data não disponível',
                    turma: turmaResponse,
                    disciplina: disciplinaResponse,
                    isResponded: isResponded
                  });
                }
              }
            } catch (err) {
              console.error(`Erro ao buscar detalhes do formulário ${form.id}:`, err);
            }
          }
        }
        
        setAvailableForms(formsWithDetails);
      } catch (err) {
        console.error("Erro ao buscar formulários:", err);
        setError("Ocorreu um erro ao buscar seus formulários. Tente novamente.");
      } finally {
        setLoading(false);
      }
    };

    if (user) {
      fetchUserForms();
    } else {
      setError(`Você precisa estar logado para ver os formulários disponíveis.`);
      setLoading(false);
    }
  }, [api, user]);

  const handleFormClick = (formId) => {
    navigate(`/answer-form?formId=${formId}`);
  };



  return (
    <Layout title="Formulários Disponíveis">
      <div className="available-forms-container">
        <header className="forms-header">
          <div className="header-content">
            <h1>Formulários Disponíveis</h1>
          </div>
        </header>

        <main className="forms-content">
        {loading ? (
          <div className="loading-container">
            <div className="loading-spinner"></div>
            <p>Carregando formulários...</p>
          </div>
        ) : error ? (
          <div className="error-container">
            <p>{error}</p>
          </div>
        ) : availableForms.length === 0 ? (
          <div className="no-forms-container">
            <p>Não há formulários disponíveis para você no momento.</p>
          </div>
        ) : (
          <>
            <h2>Suas avaliações pendentes</h2>
            <div className="forms-grid">
              {availableForms.map(form => (
                <div 
                  key={form.id} 
                  className="form-card"
                  onClick={() => handleFormClick(form.id)}
                >
                  <div className="form-card-content">
                    <h3 className="form-title">
                      {form.name || form.disciplina.name}
                    </h3>
                    <p className="form-subtitle">
                      Disciplina: {form.disciplina.name}<br />
                      Turma: {form.turma.semester || 'Não especificado'}<br />
                      Data: {form.date}
                    </p>
                    <div className="form-card-footer">
                      <p className="form-professor">
                        {form.isResponded ? 
                          '✓ Respondido' : 
                          '⟳ Pendente'}
                      </p>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </>
        )}
      </main>
      </div>
    </Layout>
  );
}

export default AvailableForms;
