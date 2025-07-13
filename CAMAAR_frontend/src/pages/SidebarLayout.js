import React, { useState } from "react";
import Navbar from "../components/Navbar";
import Sidebar from "../components/Sidebar";
import Card from "../components/Card";
import "./styles.css";

function SidebarLayout() {
  const [selected, setSelected] = useState("Avaliações");

  return (
    <div>
      <Navbar />
      <div className="main">
        <Sidebar selected={selected} setSelected={setSelected} />
        <div className="cards-container">
          {selected === "Avaliações" ? (
            <div className="avaliacoes-placeholder">
              <div
                style={{
                  fontSize: 24,
                  color: "#333",
                  margin: "40px auto",
                  textAlign: "center",
                }}
              >
                Você está nas avaliações
              </div>
            </div>
          ) : (
            [...Array(5)].map((_, i) => <Card key={i} />)
          )}
        </div>
      </div>
    </div>
  );
}

export default SidebarLayout;
