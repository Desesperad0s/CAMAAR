import Sidebar from '../components/Sidebar';
import Navbar from '../components/Navbar';

function Templates() {
  return (
    <div className="page">
      <Sidebar />
      <div className="content">
        <Navbar title="Gerenciamento - Templates" />
        <div className="grid">
          {[...Array(5)].map((_, i) => (
            <div className="card" key={i}>
              <strong>Template 1</strong>
              <span>semestre</span>
              <div className="icons">✏️ 🗑️</div>
            </div>
          ))}
          <div className="card add">＋</div>
        </div>
      </div>
    </div>
  );
}

export default Templates;
