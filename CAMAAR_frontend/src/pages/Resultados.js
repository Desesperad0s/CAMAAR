import Sidebar from '../components/Sidebar';
import Navbar from '../components/Navbar';
import Card from '../components/Card';

function Resultados() {
  return (
    <div className="page">
      <Sidebar />
      <div className="content">
        <Navbar title="Gerenciamento - Resultados" />
        <div className="grid">
          {[...Array(5)].map((_, i) => (
            <Card key={i} />
          ))}
        </div>
      </div>
    </div>
  );
}

export default Resultados;
