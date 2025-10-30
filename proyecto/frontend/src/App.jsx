import { BrowserRouter as Router, Routes, Route, Navigate } from "react-router-dom";
import { useState, useEffect } from "react";
import Sidebar from "./components/Sidebar";
import Login from "./pages/Login";
import Dashboard from "./pages/Dashboard";
import Pacientes from "./pages/Pacientes";
import Cirugias from "./pages/Cirugias";
import Contactos from "./pages/Contactos";
import Evolucion from "./pages/Evolucion";
import FamilyLogin from "./pages/FamilyLogin";
import FamilyDashboard from "./pages/FamilyDashboard";
import HomePage from "./pages/HomePage";

export default function App() {
  const [token, setToken] = useState(localStorage.getItem("token"));
  const [familyToken, setFamilyToken] = useState(localStorage.getItem("family_token"));

  // Detectar cambios en localStorage y actualizar estado
  useEffect(() => {
    const syncTokens = () => {
      setToken(localStorage.getItem("token"));
      setFamilyToken(localStorage.getItem("family_token"));
    };

    window.addEventListener("storage", syncTokens);
    window.addEventListener("tokenChanged", syncTokens); // evento personalizado opcional

    return () => {
      window.removeEventListener("storage", syncTokens);
      window.removeEventListener("tokenChanged", syncTokens);
    };
  }, []);

  return (
    <Router>
      <Routes>
        {/* Página de inicio */}
        <Route path="/home" element={<HomePage />} />

        {familyToken ? (
          // Rutas para familiares
          <>
            <Route path="/family/login" element={<FamilyLogin />} />
            <Route path="/family/dashboard" element={<FamilyDashboard />} />
            <Route path="/family/*" element={<FamilyLogin />} />
          </>
        ) : !token ? (
          // Rutas públicas (login)
          <>
            <Route path="/" element={<Navigate to="/home" />} />
            <Route path="/login" element={<Login />} />
            <Route path="/family/login" element={<FamilyLogin />} />
            <Route path="/*" element={<Login />} />
          </>
        ) : (
          // Rutas para administradores
          <>
            <Route
              path="/dashboard"
              element={
                <div className="flex">
                  <Sidebar />
                  <Dashboard />
                </div>
              }
            />
            <Route
              path="/pacientes"
              element={
                <div className="flex">
                  <Sidebar />
                  <Pacientes />
                </div>
              }
            />
            <Route
              path="/cirugias"
              element={
                <div className="flex">
                  <Sidebar />
                  <Cirugias />
                </div>
              }
            />
            <Route
              path="/contactos"
              element={
                <div className="flex">
                  <Sidebar />
                  <Contactos />
                </div>
              }
            />
            <Route
              path="/evolucion"
              element={
                <div className="flex">
                  <Sidebar />
                  <Evolucion />
                </div>
              }
            />
            <Route
              path="/"
              element={
                <div className="flex">
                  <Sidebar />
                  <Dashboard />
                </div>
              }
            />
          </>
        )}
      </Routes>
    </Router>
  );
}
