import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import Gerenciamento from './pages/Gerenciamento';
import Login from './pages/Login';
import Resultados from './pages/Resultados';
import EnviarFormulario from './pages/EnviarFormulario';
import Templates from './pages/Templates';
import './App.css';

function App() {
  return (
    <Router>
      <Routes>
        <Route path="/gerenciamento" element={<Gerenciamento />} />
        <Route path="/resultados" element={<Resultados />} />
        <Route path="/enviar" element={<EnviarFormulario />} />
        <Route path="/templates" element={<Templates />} />
        <Route path="/login" element={<Login />} />
      </Routes>
    </Router>
  );
}

export default App;
