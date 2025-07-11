function Resultados() {
  return (
    <div className="page">
      <Sidebar />
      <div className="content">
        <Navbar title="Gerenciamento - Resultados" />
        <div className="grid">
          {[...Array(5)].map((_, i) => (
            <DashboardCard key={i} title="Nome da matéria" />
          ))}
        </div>
      </div>
    </div>
  );
}
