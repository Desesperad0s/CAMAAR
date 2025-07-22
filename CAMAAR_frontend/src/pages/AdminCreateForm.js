import React, { useState, useEffect, useMemo } from "react";
import { Api } from "../utils/apiClient.ts";
import { useNavigate } from "react-router-dom";
import "./AdminCreateForm.css";

function AdminCreateForm() {
  const [templates, setTemplates] = useState([]);
  const [turmas, setTurmas] = useState([]);
  const [disciplinas, setDisciplinas] = useState([]);
  const [selectedTemplate, setSelectedTemplate] = useState("");
  const [selectedTurmas, setSelectedTurmas] = useState([]);
  const [publicoAlvo, setPublicoAlvo] = useState("discente");
  const [loading, setLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState(null);
  const [success, setSuccess] = useState(false);
  const navigate = useNavigate();
  const api = useMemo(() => new Api(), []);

  useEffect(() => {
    const fetchData = async () => {
      try {
        setLoading(true);
        setError(null);

        const [templatesResponse, turmasResponse, disciplinasResponse] =
          await Promise.all([
            api.getTemplates(),
            api.getTurmas(),
            api.getDisciplinas(),
          ]);

        setTemplates(templatesResponse || []);
        setTurmas(turmasResponse || []);
        setDisciplinas(disciplinasResponse || []);
      } catch (err) {
        setError("Erro ao carregar dados. Tente novamente.");
        console.error("Error fetching data:", err);
        if (
          err.message &&
          (err.message.includes("401") || err.message.includes("Unauthorized"))
        ) {
          setError("Erro de autenticação. Por favor, faça login novamente.");
          setTimeout(() => {
            navigate("/login");
          }, 2000);
        } else {
          setError("Erro ao carregar dados. Tente novamente.");
        }
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, []);

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!selectedTemplate || selectedTurmas.length === 0) {
      return;
    }
    try {
      setSubmitting(true);
      setError(null);
      const selectedTemplateObj = templates.find(
        (t) => t.id == selectedTemplate
      );
      const promises = selectedTurmas.map((turmaId) => {
        const turmaObj = turmas.find((t) => t.id === turmaId);
        const turmaNome = turmaObj
          ? turmaObj.name || turmaObj.code || turmaObj.number
          : turmaId;
        const templateNome = selectedTemplateObj
          ? selectedTemplateObj.content || `Template ${selectedTemplateObj.id}`
          : selectedTemplate;
        const formName = `Formulário ${turmaNome} - ${templateNome}`;
        return api.createFormularioWithTemplate(
          selectedTemplate,
          turmaId,
          formName,
          publicoAlvo
        );
      });
      const responses = await Promise.all(promises);
      if (responses.length > 0) {
        setSuccess(true);
        setSelectedTemplate("");
        setSelectedTurmas([]);
        setPublicoAlvo("discente");
      }
    } catch (err) {
    } finally {
      setSubmitting(false);
    }
  };

  const handleTurmaToggle = (turmaId) => {
    setSelectedTurmas((prev) => {
      if (prev.includes(turmaId)) {
        return prev.filter((id) => id !== turmaId);
      } else {
        return [...prev, turmaId];
      }
    });
  };

  const getTurmaDisplayName = (turma) => {
    const disciplina = disciplinas.find((d) => d.id === turma.disciplina_id);
    return {
      nome: turma.name,
      semestre: turma.semester,
      codigo: turma.code || turma.number,
      disciplina: disciplina ? disciplina.name : "",
    };
  };

  if (loading) {
    return <div className="admin-create-form-container"></div>;
  }

  return (
    <div className="admin-create-form-container">
      <div className="modal-overlay">
        <div className="modal-content">
          {error && (
            <div className="error-message">
              <p>{error}</p>
            </div>
          )}

          {success && (
            <div className="success-message">
              <p>Formulários criados com sucesso!</p>
            </div>
          )}

          <form onSubmit={handleSubmit} className="create-form">
            <div className="template-section">
              <label htmlFor="template">Template</label>
              <select
                id="template"
                value={selectedTemplate}
                onChange={(e) => setSelectedTemplate(e.target.value)}
                required
                className="template-select"
              >
                <option value="">Selecione um template</option>
                {templates.map((template) => (
                  <option key={template.id} value={template.id}>
                    {template.content || `Template ${template.id}`}
                  </option>
                ))}
              </select>
            </div>

            <div className="template-section">
              <label htmlFor="publicoAlvo">Público alvo</label>
              <select
                id="publicoAlvo"
                value={publicoAlvo}
                onChange={(e) => setPublicoAlvo(e.target.value)}
                required
                className="template-select"
              >
                <option value="discente">Aluno</option>
                <option value="docente">Professor</option>
              </select>
            </div>

            <div className="turmas-section">
              <h3>Turmas</h3>
              <div className="turmas-table">
                <div className="table-headers">
                  <div className="header-checkbox"></div>
                  <div className="header-nome">Nome</div>
                  <div className="header-semestre">Semestre</div>
                  <div className="header-codigo">Código</div>
                </div>

                <div className="turmas-list">
                  {turmas.map((turma) => {
                    const turmaInfo = getTurmaDisplayName(turma);
                    return (
                      <div
                        key={turma.id}
                        className={`turma-row ${
                          selectedTurmas.includes(turma.id) ? "selected" : ""
                        }`}
                        onClick={() => handleTurmaToggle(turma.id)}
                      >
                        <div className="turma-checkbox">
                          <input
                            type="checkbox"
                            checked={selectedTurmas.includes(turma.id)}
                            onChange={() => handleTurmaToggle(turma.id)}
                          />
                        </div>
                        <div className="turma-nome">{turmaInfo.disciplina}</div>
                        <div className="turma-semestre">
                          {turmaInfo.semestre}
                        </div>
                        <div className="turma-codigo">{turmaInfo.codigo}</div>
                      </div>
                    );
                  })}
                </div>
              </div>
            </div>

            <div className="form-actions">
              <button
                type="submit"
                className="submit-button"
                disabled={
                  submitting || !selectedTemplate || selectedTurmas.length === 0
                }
              >
                {submitting
                  ? "Criando..."
                  : `Criar ${selectedTurmas.length} Formulário${
                      selectedTurmas.length !== 1 ? "s" : ""
                    }`}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  );
}

export default AdminCreateForm;
