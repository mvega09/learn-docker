import axios from "axios";

const API = axios.create({
  baseURL: "https://learn-docker-zxf3.onrender.com", // Backend FastAPI
});

// Interceptor para tokens administrativos
API.interceptors.request.use((req) => {
  const token = localStorage.getItem("token");
  if (token) {
    req.headers.Authorization = `Bearer ${token}`;
  }
  return req;
});

// API específica para familiares
const FamilyAPI = axios.create({
  baseURL: "https://learn-docker-zxf3.onrender.com",
});

FamilyAPI.interceptors.request.use((req) => {
  const familyToken = localStorage.getItem("family_token");
  if (familyToken) {
    req.headers.Authorization = `Bearer ${familyToken}`;
  }
  return req;
});

export default API;
export { FamilyAPI };
