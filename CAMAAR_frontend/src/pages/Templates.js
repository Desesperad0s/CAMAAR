import React, { useEffect, useState } from "react";
import Sidebar from "../components/Sidebar";
import Navbar from "../components/Navbar";
import "../App.css";
import { Api } from "../utils/apiClient.ts";

function Templates() {
  const [templates, setTemplates] = useState([]);
  const [selected, setSelected] = useState("Avaliações");

  useEffect(() => {
    if (selected === "Avaliações") {
      const api = new Api();
      async function fetchFormularios() {
        try {
          const data = await api.getFormularios();
          setTemplates(data);
        } catch (err) {
          setTemplates([]);
        }
      }
      fetchFormularios();
    }
  }, [selected]);

  return (
    <div className="page">
      <Sidebar selected={selected} setSelected={setSelected} />
      <div className="content">
        <Navbar title={selected} />
        {selected === "Avaliações" ? (
          <div className="grid">
            {templates.map((template) => (
              <div className="card" key={template.id}>
                <strong>{template.name || template.nome}</strong>
                <span>{template.semester || template.semestre}</span>
                <span>{template.professor}</span>
              </div>
            ))}
            <div className="card add">＋</div>
          </div>
        ) : (
          <div style={{ padding: 32 }}>
            gerenciamento quero me matar por favor alguém me mata socorro vou me matar
          </div>
        )}
      </div>
    </div>
  );
}

export default Templates;
