import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import Gerenciamento from './pages/Gerenciamento';
import Login from './pages/Login';
import Resultados from './pages/Resultados';
import EnviarFormulario from './pages/EnviarFormulario';
import Templates from './pages/Templates';
import ProtectedRoute from './components/ProtectedRoute';
import AdminRoute from './components/AdminRoute';
import AdminRedirect from './components/AdminRedirect';
import { AuthProvider } from './context/AuthContext';
import AnswerForm from './pages/AnswerForm';
import AdminCreateForm from './pages/AdminCreateForm';
import AvailableForms from './pages/AvailableForms';
import RedefinirSenha from './pages/RedefinirSenha';
import NovaSenha from './pages/NovaSenha';
import './App.css';

function App() {
  return (
    <AuthProvider>
      <Router>
        <Routes>
          <Route path="/login" element={<Login />} />
          <Route path="/redefinir-senha" element={<RedefinirSenha />} />
          <Route path="/nova-senha" element={<NovaSenha />} />
          
          <Route path="/gerenciamento" element={
            <AdminRoute>
              <Templates />
            </AdminRoute>
          } />
          <Route path="/resultados" element={
            <AdminRoute>
              <Resultados />
            </AdminRoute>
          } />
          <Route path="/enviar" element={
            <AdminRoute>
              <EnviarFormulario />
            </AdminRoute>
          } />
          <Route path="/templates" element={
            <AdminRoute>
              <Gerenciamento />
            </AdminRoute>
          } />
          <Route path="/answer-form" element={
            <ProtectedRoute>
              <AnswerForm />
            </ProtectedRoute>
          } />
          <Route path="/admin/create-form" element={
            <AdminRoute>
              <AdminCreateForm />
            </AdminRoute>
          } />
          <Route path="/available-forms" element={
            <ProtectedRoute>
              <AvailableForms />
            </ProtectedRoute>
          } />
          
          <Route path="/" element={
            <ProtectedRoute>
              <AdminRedirect />
            </ProtectedRoute>
          } />
          <Route path="*" element={<Navigate to="/login" replace />} />
      </Routes>
      </Router>
    </AuthProvider>
  );
}

export default App;
