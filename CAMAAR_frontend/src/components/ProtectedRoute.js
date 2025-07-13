import React from 'react';
import { Navigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';

// Componente para rotas protegidas que exigem autenticação
const ProtectedRoute = ({ children }) => {
  const { isAuthenticated, loading } = useAuth();
  
  // Se ainda estamos verificando a autenticação, mostra um loader
  if (loading) {
    return <div className="loading-screen">Carregando...</div>;
  }
  
  // Redireciona para o login se não estiver autenticado
  if (!isAuthenticated) {
    return <Navigate to="/login" replace />;
  }
  
  // Renderiza a rota protegida se estiver autenticado
  return children;
};

export default ProtectedRoute;
