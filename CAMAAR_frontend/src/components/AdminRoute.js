import React from 'react';
import { Navigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';

const AdminRoute = ({ children }) => {
  const { user, isAuthenticated, loading } = useAuth();
  
  if (loading) {
    return <div>Carregando...</div>;
  }
  
  if (!isAuthenticated) {
    return <Navigate to="/login" replace />;
  }
  
  const isAdmin = user && (user.admin === true || user.role === 'admin' || user.is_admin === true);
  
  return isAdmin ? children : <Navigate to="/available-forms" replace />;
};

export default AdminRoute;
