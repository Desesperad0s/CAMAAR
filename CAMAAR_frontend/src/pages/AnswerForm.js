import React, { useState, useEffect, useMemo } from "react";
import { useSearchParams } from "react-router-dom";
import { Api } from "../utils/apiClient.ts";
import "./AnswerForm.css";

function AnswerForm() {
  const [form, setForm] = useState(null);
  const [answers, setAnswers] = useState({});
  const [loading, setLoading] = useState(true);
  const [disciplina, setDisciplina] = useState(null);
  const [turma, setTurma] = useState(null);
  const [error, setError] = useState(null);
  const [searchParams] = useSearchParams();
  
  const api = useMemo(() => new Api(), []);

  useEffect(() => {
    const fetchData = async () => {
      try {
        setLoading(true);
        setError(null);
        
        const formId = searchParams.get('formId') || '1';
        
        const formularioResponse = await api.getFormularioDetails(formId);
        if (formularioResponse) {
          setForm({
            id: formularioResponse.id,
            title: formularioResponse.name || "Formulário",
            description: formularioResponse.description || "",
            date: formularioResponse.date,
            questions: [] 
          });
          
          if (formularioResponse.turma_id || formularioResponse.turmas_id) {
            const turmaId = formularioResponse.turma_id || formularioResponse.turmas_id;
            const turmaResponse = await api.getTurma(turmaId);
            if (turmaResponse) {
              setTurma(turmaResponse);
            if (turmaResponse.disciplinas_id || turmaResponse.disciplina_id) {
                const disciplinaId = turmaResponse.disciplinas_id || turmaResponse.disciplina_id;
                const disciplinaResponse = await api.getDisciplina(disciplinaId);
                if (disciplinaResponse) {
                  setDisciplina(disciplinaResponse);
                }
              }
            }
          }
          try {
            console.log(`Buscando questões para o formulário ${formId}...`);
            const questoesResponse = await api.getQuestoes(formId);
            console.log("Resposta de questões:", questoesResponse);
            
            if (questoesResponse && Array.isArray(questoesResponse)) {
              const formattedQuestions = [];
              
              for (const questao of questoesResponse) {
                try {
                  console.log(`Buscando alternativas para a questão ${questao.id}...`);
                  const alternativasResponse = await api.getAlternativas(questao.id);
                  console.log("Alternativas encontradas:", alternativasResponse);
                  
                  if (alternativasResponse && Array.isArray(alternativasResponse) && alternativasResponse.length > 0) {
                    formattedQuestions.push({
                      id: questao.id,
                      text: questao.enunciado,
                      type: "radio",
                      options: alternativasResponse.map(alternativa => alternativa.content),
                      required: true
                    });
                  } else {
                    formattedQuestions.push({
                      id: questao.id,
                      text: questao.enunciado,
                      type: "textarea",
                      required: true
                    });
                  }
                } catch (alternativasError) {
                  console.error(`Erro ao buscar alternativas para questão ${questao.id}:`, alternativasError);
                }
              }
              
              setForm(prevForm => ({
                ...prevForm,
                questions: formattedQuestions
              }));
            }
          } catch (questoesError) {
            console.error("Erro ao buscar questões:", questoesError);
            setError("Não foi possível carregar as questões deste formulário.");
          }
        }
        
      } catch (err) {
        console.error("Erro ao buscar dados do formulário:", err);
        setError("Ocorreu um erro ao carregar o formulário. Por favor, tente novamente mais tarde.");
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, [searchParams, api]);

  const handleAnswerChange = (questionId, value) => {
    setAnswers(prev => ({
      ...prev,
      [questionId]: value
    }));
  };

  const [submitting, setSubmitting] = useState(false);
  const [submitSuccess, setSubmitSuccess] = useState(false);
  const [submitError, setSubmitError] = useState(null);

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    try {
      setSubmitting(true);
      setSubmitError(null);
      
      const unansweredQuestions = form.questions
        .filter(q => q.required && !answers[q.id]);
      
      if (unansweredQuestions.length > 0) {
        setSubmitError(`Por favor, responda todas as questões obrigatórias. Faltam ${unansweredQuestions.length} respostas.`);
        return;
      }
      
      const formattedAnswers = Object.keys(answers).map(questionId => ({
        content: answers[questionId],
        questao_id: parseInt(questionId),
        formulario_id: form.id
      }));
      
      await api.submitFormAnswers(formattedAnswers);
      
      setSubmitSuccess(true);
      
      setTimeout(() => {
        window.location.href = '/available-forms';
      }, 3000);
      
    } catch (error) {
      console.error("Erro ao enviar formulário:", error);
      setSubmitError("Ocorreu um erro ao enviar suas respostas. Por favor, tente novamente.");
    } finally {
      setSubmitting(false);
    }
  };

  if (loading || !form) {
    return (
        <div className="loading-container">
          <div className="loading-spinner"></div>
          <p>Carregando formulário...</p>
        </div>
    );
  }

  return (
    <div className="answer-form-container">
      <header className="answer-form-header">
        <div className="header-content">
          <h1>
            Avaliação - {disciplina ? disciplina.name : 'Carregando...'} - {turma ? turma.semester : 'Carregando...'}
          </h1>
        </div>
      </header>

      <main className="form-content">
        <div className="form-modal">
          {error && (
            <div className="error-message">
              <p>{error}</p>
            </div>
          )}
          
          <div className="form-header">
            <h2>{form?.title || "Formulário"}</h2>
            <p className="form-description">{form?.description || ""}</p>
          </div>

          <form onSubmit={handleSubmit} className="answer-form">
            {form?.questions?.map((question, index) => (
              <div key={question.id} className="question-box">
                <label className="question-label">
                  {index + 1}. {question.text}
                </label>

                {question.type === "radio" && (
                  <div className="radio-group">
                    {question.options.map((option, optionIndex) => (
                      <label key={optionIndex} className="radio-option">
                        <input
                          type="radio"
                          name={`question_${question.id}`}
                          value={option}
                          checked={answers[question.id] === option}
                          onChange={(e) => handleAnswerChange(question.id, e.target.value)}
                        />
                        <span className="radio-text">{option}</span>
                      </label>
                    ))}
                  </div>
                )}

                {question.type === "textarea" && (
                  <textarea
                    className="answer-textarea"
                    placeholder="Digite sua resposta aqui..."
                    value={answers[question.id] || ""}
                    onChange={(e) => handleAnswerChange(question.id, e.target.value)}
                    rows={4}
                  />
                )}
              </div>
            ))}
          </form>
        </div>
      </main>

      {submitSuccess ? (
        <div className="success-message floating-message">
          <p>✅ Respostas enviadas com sucesso!</p>
          <p>Você será redirecionado em instantes...</p>
        </div>
      ) : (
        <button 
          type="submit" 
          className={`floating-submit-button ${submitting ? 'submitting' : ''}`}
          onClick={handleSubmit}
          disabled={submitting}
        >
          {submitting ? '...' : '✓'}
        </button>
      )}

      {submitError && (
        <div className="error-message floating-message">
          <p>{submitError}</p>
        </div>
      )}
    </div>
  );
}

export default AnswerForm;
