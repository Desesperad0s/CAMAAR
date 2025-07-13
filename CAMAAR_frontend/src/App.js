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
import AvailableForms from './pages/AvailableForms';
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
          <Route path="/answer-form" element={
            <ProtectedRoute>
              <AnswerForm />
            </ProtectedRoute>
          } />
          <Route path="/admin/create-form" element={
            <ProtectedRoute>
              <AdminCreateForm />
            </ProtectedRoute>
          } />
          <Route path="/available-forms" element={
            <ProtectedRoute>
              <AvailableForms />
            </ProtectedRoute>
          } />
          
          <Route path="/" element={<Navigate to="/login" replace />} />
          <Route path="*" element={<Navigate to="/login" replace />} />
      </Routes>
      </Router>
    </AuthProvider>
  );
}

export default App;
