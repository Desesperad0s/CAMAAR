import React, { useState, useEffect } from "react";
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
  
  const api = new Api();

  useEffect(() => {
    const fetchData = async () => {
      try {
        setLoading(true);
        setError(null);
        
        const formId = searchParams.get('formId') || '1';
        
        const formularioResponse = await api.getFormulario(formId);
        if (formularioResponse) {
          setForm({
            id: formularioResponse.id,
            title: formularioResponse.name ,
            description: formularioResponse.description,
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
            const questoesResponse = await api.getQuestoes(formId);
            if (questoesResponse && Array.isArray(questoesResponse)) {
              const formattedQuestions = [];
              
              for (const questao of questoesResponse) {
                try {
                  const alternativasResponse = await api.getAlternativas(questao.id);
                  
                  if (alternativasResponse && Array.isArray(alternativasResponse) && alternativasResponse.length > 0) {
                    formattedQuestions.push({
                      id: questao.id,
                      text: questao.enunciado,
                      type: "radio",
                      options: alternativasResponse.map(alternativas => alternativas.content),
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
                }
              }
              
              setForm(prevForm => ({
                ...prevForm,
                questions: formattedQuestions
              }));
            }
          } catch (questoesError) {
          }
        }
        
      } catch (err) {        
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, [searchParams]);

  const handleAnswerChange = (questionId, value) => {
    setAnswers(prev => ({
      ...prev,
      [questionId]: value
    }));
  };

  const handleSubmit = (e) => {
    e.preventDefault();

  };

  if (loading) {
    return (
        <div className="loading-container">

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
            <h2>{form.title}</h2>
            <p className="form-description">{form.description}</p>
          </div>

          <form onSubmit={handleSubmit} className="answer-form">
            {form.questions.map((question, index) => (
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

      <button 
        type="submit" 
        className="floating-submit-button"
        onClick={handleSubmit}
      >
        ✓
      </button>
    </div>
  );
}

export default AnswerForm;
