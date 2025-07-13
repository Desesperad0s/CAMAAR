import React, { useState, useEffect } from "react";
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
  const navigate = useNavigate();
  const api = new Api();

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
  }, [selected]);

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
            <button className="template-btn main">Resultados</button>
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
                  <div className="card" key={form.id}>
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
      </div>
    </div>
  );
}

export default Templates;
