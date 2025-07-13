import React, { createContext, useState, useEffect, useContext } from 'react';
import { Api } from '../utils/apiClient.ts';

const AuthContext = createContext(null);

export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  const api = new Api();

  useEffect(() => {
    const checkAuthStatus = async () => {
      try {
        if (api.isAuthenticated()) {
          const storedUser = api.getCurrentUser();
          
          if (storedUser) {
            const profileResponse = await api.getUserProfile();
            
            if (profileResponse && profileResponse.user) {
              setUser(profileResponse.user);
            } else {
              api.clearAuth();
            }
          }
        }
      } catch (error) {
        console.error('Erro ao verificar status de autenticação:', error);
        api.clearAuth();
      } finally {
        setLoading(false);
      }
    };
    
    checkAuthStatus();
  }, []);

  const login = async (email, password) => {
    try {
      const result = await api.login(email, password);
      if (result && result.user) {
        setUser(result.user);
        return true;
      }
      return false;
    } catch (error) {
      console.error('Erro ao fazer login:', error);
      return false;
    }
  };

  // Logout
  const logout = async () => {
    try {
      await api.logout();
      setUser(null);
      return true;
    } catch (error) {
      console.error('Erro ao fazer logout:', error);
      return false;
    }
  };

  // Valores expostos pelo contexto
  const contextValue = {
    isAuthenticated: !!user,
    user,
    loading,
    login,
    logout
  };

  return (
    <AuthContext.Provider value={contextValue}>
      {children}
    </AuthContext.Provider>
  );
};

// Hook personalizado para facilitar o uso do contexto
export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth deve ser usado dentro de um AuthProvider');
  }
  return context;
};

export default AuthContext;
