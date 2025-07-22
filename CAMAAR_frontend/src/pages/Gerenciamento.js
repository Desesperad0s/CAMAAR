import Sidebar from "../components/Sidebar";
import Navbar from "../components/Navbar";
import CriarTemplateModal from "../components/CriarTemplateModal";
import UpdateTemplateModal from "../components/UpdateTemplateModal";
import { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { Api } from "../utils/apiClient.ts";
import "./Gerenciamento.css";

function Gerenciamento() {
  const [modalOpen, setModalOpen] = useState(false);
  const [updateModalOpen, setUpdateModalOpen] = useState(false);
  const [selectedTemplate, setSelectedTemplate] = useState(null);
  const [templates, setTemplates] = useState([]);
  const [loading, setLoading] = useState(true);
  const navigate = useNavigate();
  const api = new Api();

  // Sidebar selection state
  const [selected, setSelected] = useState("Gerenciamento");

  useEffect(() => {
    loadTemplates();
    // eslint-disable-next-line
  }, []);

  // Redireciona para /templates se clicar em Avaliações
  useEffect(() => {
    if (selected === "Avaliações") {
      navigate("/avals");
    }
  }, [selected, navigate]);

  const loadTemplates = async () => {
    setLoading(true);
    try {
      const data = await api.getTemplates();
      setTemplates(Array.isArray(data) ? data : []);
    } catch {
      setTemplates([]);
    } finally {
      setLoading(false);
    }
  };

  const handleDelete = async (id) => {
    if (window.confirm("Tem certeza que deseja excluir este template?")) {
      try {
        await api.deleteTemplate(id);
        await loadTemplates();
      } catch {
        alert("Erro ao deletar template.");
      }
    }
  };

  const handleEdit = async (templateId) => {
    try {
      const templateData = await api.getTemplate(templateId);
      setSelectedTemplate(templateData);
      setUpdateModalOpen(true);
    } catch (error) {
      console.error('Erro ao carregar template:', error);
      alert("Erro ao carregar dados do template.");
    }
  };

  const handleUpdateSuccess = () => {
    setSelectedTemplate(null);
    loadTemplates();
  };

  const handleCloseUpdateModal = () => {
    setUpdateModalOpen(false);
    setSelectedTemplate(null);
  };

  return (
    <div className="page gerenciamento-layout">
      <Sidebar selected={selected} setSelected={setSelected} />
      <div className="main-content">
        <Navbar title="Gerenciamento - Resultados" />
        <div className="gerenciamento-header">
          <button className="button-green" onClick={() => setModalOpen(true)}>
            Criar template
          </button>
        </div>
        <div className="gerenciamento-grid">
          {loading ? (
            <div className="loading">Carregando templates...</div>
          ) : templates.length === 0 ? (
            <div className="no-templates">Nenhum template encontrado.</div>
          ) : (
            templates.map((template) => (
              <div className="card" key={template.id}>
                <div className="card-title">
                  {template.content || "Template"}
                </div>
                <div className="card-semester">semestre</div>
                <div className="card-professor">Professor</div>
                <div className="icons">
                  <span 
                    className="icon edit" 
                    title="Editar"
                    onClick={() => handleEdit(template.id)}
                    style={{ cursor: "pointer" }}
                  >
                    ✏️
                  </span>
                  <span
                    className="icon delete"
                    title="Deletar"
                    onClick={() => handleDelete(template.id)}
                    style={{ cursor: "pointer" }}
                  >
                    🗑️
                  </span>
                </div>
              </div>
            ))
          )}
        </div>
      </div>
      <CriarTemplateModal
        open={modalOpen}
        onClose={() => setModalOpen(false)}
        onSuccess={loadTemplates}
      />
      <UpdateTemplateModal
        open={updateModalOpen}
        onClose={handleCloseUpdateModal}
        onSuccess={handleUpdateSuccess}
        templateData={selectedTemplate}
      />
    </div>
  );
}

export default Gerenciamento;
