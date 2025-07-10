function Gerenciamento() {
  return (
    <div className="page">
      <Sidebar />
      <div className="content">
        <Navbar title="Gerenciamento" />
        <div className="central-box">
          <button className="btn green">Importar dados</button>
          <button className="btn light-green">Editar Templates</button>
          <button className="btn light-green">Enviar Formularios</button>
          <button className="btn light-green">Resultados</button>
        </div>
      </div>
    </div>
  );
}
