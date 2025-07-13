import React from 'react';
import { Navigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';

const AdminRedirect = () => {
  const { user } = useAuth();
  
  const isAdmin = user && (user.admin === true || user.role === 'admin' || user.is_admin === true);
  
  if (isAdmin) {
    return <Navigate to="/gerenciamento" replace />;
  } else {
    return <Navigate to="/available-forms" replace />;
  }
};

export default AdminRedirect;
