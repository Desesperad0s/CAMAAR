import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import Gerenciamento from './pages/Gerenciamento';
import Login from './pages/Login';
import Resultados from './pages/Resultados';
import EnviarFormulario from './pages/EnviarFormulario';
import Templates from './pages/Templates';
import ProtectedRoute from './components/ProtectedRoute';
import { AuthProvider } from './context/AuthContext';
import AnswerForm from './pages/AnswerForm';
import AdminCreateForm from './pages/AdminCreateForm';
import './App.css';

function App() {
  return (
    <AuthProvider>
      <Router>
        <Routes>
          {/* Rotas públicas */}
          <Route path="/login" element={<Login />} />
          
          {/* Rotas protegidas */}
          <Route path="/gerenciamento" element={
            <ProtectedRoute>
              <Gerenciamento />
            </ProtectedRoute>
          } />
          <Route path="/resultados" element={
            <ProtectedRoute>
              <Resultados />
            </ProtectedRoute>
          } />
          <Route path="/enviar" element={
            <ProtectedRoute>
              <EnviarFormulario />
            </ProtectedRoute>
          } />
          <Route path="/templates" element={
            <ProtectedRoute>
              <Templates />
            </ProtectedRoute>
          } />
          <Route path="/answer-form" element={<AnswerForm />} />
          <Route path="/admin/create-form" element={<AdminCreateForm />} />
          
          {/* Rota padrão - redireciona para login */}
          <Route path="/" element={<Navigate to="/login" replace />} />
          <Route path="*" element={<Navigate to="/login" replace />} />
      </Routes>
      </Router>
    </AuthProvider>
  );
}

export default App;
