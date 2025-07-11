import Sidebar from '../components/Sidebar';
import Navbar from '../components/Navbar';
import Card from '../components/Card';
import './Gerenciamento.css';

function Gerenciamento() {
  return (
    <div className="page gerenciamento-layout">
      <Sidebar />
      <div className="main-content">
        <Navbar title="Gerenciamento - Resultados" />
        <div className="gerenciamento-grid">
          {[...Array(5)].map((_, i) => (
            <Card key={i} />
          ))}
        </div>
      </div>
    </div>
  );
}

export default Gerenciamento;
