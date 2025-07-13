import Sidebar from '../components/Sidebar';
import Navbar from '../components/Navbar';
import Card from '../components/Card';
import CriarTemplateModal from '../components/CriarTemplateModal';
import { useState } from 'react';
import './Gerenciamento.css';

function Gerenciamento() {
  const [modalOpen, setModalOpen] = useState(false);
  return (
    <div className="page gerenciamento-layout">
      <Sidebar />
      <div className="main-content">
        <Navbar title="Gerenciamento - Resultados" />
        <div style={{ display: 'flex', justifyContent: 'flex-end', margin: '24px 0 12px 0' }}>
          <button
            style={{ background: '#22b455', color: '#fff', border: 'none', borderRadius: 6, padding: '10px 24px', fontWeight: 600, fontSize: 16, cursor: 'pointer' }}
            onClick={() => setModalOpen(true)}
          >
            Criar template
          </button>
        </div>
        <div className="gerenciamento-grid">
          {[...Array(5)].map((_, i) => (
            <Card key={i} />
          ))}
        </div>
      </div>
      <CriarTemplateModal open={modalOpen} onClose={() => setModalOpen(false)} />
    </div>
  );
}

export default Gerenciamento;
