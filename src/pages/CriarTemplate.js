function CriarTemplate() {
  return (
    <div className="modal">
      <div className="modal-content">
        <input placeholder="Nome do template" />
        <h3>Questão 1</h3>
        <label>Tipo: <select><option>Radio</option></select></label>
        <input placeholder="Texto" />
        <input placeholder="Opções" />
        <button>＋</button>
        <h3>Questão 2</h3>
        <label>Tipo: <select><option>Texto</option></select></label>
        <input placeholder="Texto" />
        <button className="btn purple">＋</button>
        <button className="btn green">Criar</button>
      </div>
    </div>
  );
}