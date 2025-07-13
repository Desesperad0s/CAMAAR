import React, { useState, useEffect } from "react";
import Sidebar from "../components/Sidebar";
import Navbar from "../components/Navbar";
import CriarTemplateModal from "../components/CriarTemplateModal";
import { Api } from "../utils/apiClient.ts";
import "./Templates.css";

function Templates() {
  const [templates, setTemplates] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [showModal, setShowModal] = useState(false);

  const api = new Api();

  // Carregar templates ao montar o componente
  useEffect(() => {
    loadTemplates();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const loadTemplates = async () => {
    setLoading(true);
    try {
      const response = await api.getTemplates();
      if (response) {
        setTemplates(response);
      } else {
        setError("Não foi possível carregar os templates");
      }
    } catch (err) {
      console.error("Erro ao carregar templates:", err);
      setError("Erro ao carregar templates. Tente novamente mais tarde.");
    } finally {
      setLoading(false);
    }
  };

  const handleDeleteTemplate = async (id) => {
    if (window.confirm("Tem certeza que deseja excluir este template?")) {
      try {
        await api.deleteTemplate(id);
        loadTemplates(); // Recarregar a lista após excluir
      } catch (err) {
        console.error("Erro ao excluir template:", err);
        alert("Não foi possível excluir o template");
      }
    }
  };

  return (
    <div className="page">
      <Sidebar />
      <div className="content">
        <Navbar title="Gerenciamento - Templates" />

        {error && <div className="error-message">{error}</div>}

        <div className="grid">
          {loading ? (
            <div className="loading">Carregando templates...</div>
          ) : templates.length > 0 ? (
            <>
              {templates.map((template) => (
                <div className="card" key={template.id}>
                  <strong>{template.content}</strong>
                  <span>
                    Criado em:{" "}
                    {new Date(template.created_at).toLocaleDateString()}
                  </span>
                  <div className="icons">
                    <span className="icon edit">✏️</span>
                    <span
                      className="icon delete"
                      onClick={() => handleDeleteTemplate(template.id)}
                    >
                      🗑️
                    </span>
                  </div>
                </div>
              ))}
              <div className="card add" onClick={() => setShowModal(true)}>
                ＋
              </div>
            </>
          ) : (
            <>
              <div className="no-templates">
                Nenhum template encontrado. Crie um novo template clicando no
                botão +.
              </div>
              <div className="card add" onClick={() => setShowModal(true)}>
                ＋
              </div>
            </>
          )}
        </div>
      </div>

      <CriarTemplateModal
        open={showModal}
        onClose={() => setShowModal(false)}
        onSuccess={loadTemplates}
      />
    </div>
  );
}

export default Templates;
