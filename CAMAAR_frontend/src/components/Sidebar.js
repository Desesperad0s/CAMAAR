import React from "react";
import "./styles.css";

function Sidebar({ selected, setSelected = () => {} }) {
  return (
    <div className="sidebar sidebar-custom">
      <div className="sidebar-list">
        <div
          className={`sidebar-item${
            selected === "Avaliações" ? " active" : ""
          }`}
          onClick={() => setSelected("Avaliações")}
        >
          Avaliações
        </div>
        <div
          className={`sidebar-item${
            selected === "Gerenciamento" ? " active" : ""
          }`}
          onClick={() => setSelected("Gerenciamento")}
        >
          Gerenciamento
        </div>
      </div>
    </div>
  );
}

export default Sidebar;
