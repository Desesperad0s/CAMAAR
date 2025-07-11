function EnviarForm() {
  return (
    <div className="modal">
      <div className="modal-content">
        <label>
          Template:
          <select>
            <option>Template</option>
          </select>
        </label>
        <table>
          <thead>
            <tr>
              <th></th>
              <th>Nome</th>
              <th>Semestre</th>
              <th>Código</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td><input type="checkbox" checked /></td>
              <td>Estudos Em</td>
              <td>2024.1</td>
              <td>CIC1024</td>
            </tr>
            <tr>
              <td><input type="checkbox" /></td>
              <td>Estudos Em</td>
              <td>2024.1</td>
              <td>CIC1024</td>
            </tr>
          </tbody>
        </table>
        <button className="btn green">Enviar</button>
      </div>
    </div>
  );
}