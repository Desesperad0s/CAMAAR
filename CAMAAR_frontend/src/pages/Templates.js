import React, { useState, useEffect, useMemo } from "react";
import { useNavigate } from "react-router-dom";
import Sidebar from "../components/Sidebar";
import Navbar from "../components/Navbar";
import { Api } from "../utils/apiClient.ts";
import "./Templates.css";

function Templates() {
  const [selected, setSelected] = useState("Avaliações");
  const [formularios, setFormularios] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const [downloadingReport, setDownloadingReport] = useState(false);
  const [showModal, setShowModal] = useState(false);
  const [selectedForm, setSelectedForm] = useState(null);
  const navigate = useNavigate();
  const api = useMemo(() => new Api(), []);

  useEffect(() => {
    if (selected === "Avaliações") {
      setLoading(true);
      setError("");
      api
        .getFormularios()
        .then((data) => {
          setFormularios(Array.isArray(data) ? data : []);
        })
        .catch(() => setError("Erro ao carregar formulários."))
        .finally(() => setLoading(false));
    }
  }, [selected, api]);

  const handleGenerateExcelReport = () => {
    setDownloadingReport(true);
    setError("");
    api
      .generateExcelReport()
      .then((response) => {
        const url = window.URL.createObjectURL(new Blob([response]));

        const link = document.createElement("a");
        link.href = url;
        const fileName = `relatorio_formularios_${new Date().toISOString().slice(0,10)}.xlsx`;
        link.setAttribute("download", fileName);
        document.body.appendChild(link);
        link.click();

        window.URL.revokeObjectURL(url);
        document.body.removeChild(link);
      })
      .catch((error) => {
        console.error("Erro ao gerar relatório Excel:", error);
        setError("Erro ao gerar relatório Excel. Por favor, tente novamente mais tarde.");
      })
      .finally(() => {
        setDownloadingReport(false);
      });
  };

  const handleCardClick = (form) => {
    setSelectedForm(form);
    setShowModal(true);
  };

  const closeModal = () => {
    setShowModal(false);
    setSelectedForm(null);
  };

  const FormularioModal = () => {
    if (!selectedForm) return null;

    return (
      <div className="modal-overlay" onClick={closeModal}>
        <div className="modal-content" onClick={(e) => e.stopPropagation()}>
          <div className="modal-header">
            <h2>{selectedForm.nome || selectedForm.name || `Formulário #${selectedForm.id}`}</h2>
            <button className="close-button" onClick={closeModal}>×</button>
          </div>
          <div className="modal-body">
            {selectedForm.respostas && selectedForm.respostas.length > 0 ? (
              <div className="questoes-respostas">
                <h3>Questões e Respostas</h3>
                <ul>
                  {selectedForm.respostas.map((resposta) => (
                    <li key={resposta.id} className="questao-resposta-item">
                      <div className="questao">
                        <strong>Questão:</strong> {resposta.questao ? resposta.questao.enunciado || `Questão #${resposta.questao.id}` : 'Questão não encontrada'}
                      </div>
                      <div className="resposta">
                        <strong>Resposta:</strong> {resposta.content || 'Sem resposta'}
                      </div>
                    </li>
                  ))}
                </ul>
              </div>
            ) : (
              <p className="no-respostas">Este formulário não possui respostas.</p>
            )}
          </div>
          <div className="modal-footer">
            <button onClick={closeModal} className="modal-button">Fechar</button>
          </div>
        </div>
      </div>
    );
  };

  return (
    <div className="page">
      <Sidebar selected={selected} setSelected={setSelected} />
      <div className="content">
        <Navbar
          title={selected === "Gerenciamento" ? "Gerenciamento" : "Avaliações"}
        />
        {selected === "Gerenciamento" ? (
          <div className="template-center-panel">
            <button className="template-btn main">Importar dados</button>
            <button
              className="template-btn main"
              onClick={() => navigate("/gerenciamento")}
            >
              Editar Formularios
            </button>
            <button className="template-btn main">Enviar Formulários</button>
            <button
              className="template-btn main"
              onClick={handleGenerateExcelReport}
              disabled={downloadingReport}
            >
              {downloadingReport ? "Gerando..." : "Resultados"}
            </button>
          </div>
        ) : (
          <div className="avaliacoes-list">
            {loading ? (
              <div className="loading">Carregando formulários...</div>
            ) : error ? (
              <div className="error-message">{error}</div>
            ) : formularios.length === 0 ? (
              <div className="no-templates">Nenhum formulário encontrado.</div>
            ) : (
              <div className="grid">
                {formularios.map((form) => (
                  <div className="card" key={form.id} onClick={() => handleCardClick(form)}>
                    <strong>
                      {form.nome || form.titulo || `Formulário #${form.id}`}
                    </strong>
                    {form.descricao && <span>{form.descricao}</span>}
                    {form.created_at && (
                      <span>
                        Criado em:{" "}
                        {new Date(form.created_at).toLocaleDateString()}
                      </span>
                    )}
                  </div>
                ))}
              </div>
            )}
          </div>
        )}
        {showModal && <FormularioModal />}
      </div>
    </div>
  );
}

export default Templates;
