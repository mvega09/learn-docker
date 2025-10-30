from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional
import mysql.connector
import os
from database import db_manager
from fastapi import HTTPException

app = FastAPI(title="SIACOM API", version="1.0.0")


# CORS configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Database connection
def get_db_connection():
    return mysql.connector.connect(
        host="db",
        user="root",
        password="superrootpassword",
        database="siacom_db",
        port=3306
    )

# Pydantic models
class UserLogin(BaseModel):
    username: str
    password: str

class FamilyLogin(BaseModel):
    patient_code: str
    family_code: str

class Token(BaseModel):
    access_token: str
    token_type: str
    user_type: str
    user_id: int

class FamilyToken(BaseModel):
    access_token: str
    token_type: str
    user_type: str
    patient_id: int
    family_id: int

class PacienteBase(BaseModel):
    nombre: str
    apellido: str
    cedula: str
    fecha_nacimiento: str
    sexo: str
    telefono: Optional[str] = None
    eps: Optional[str] = None
    tipo_sangre: Optional[str] = None

class ContactoBase(BaseModel):
    nombre: str
    apellido: str
    relacion: str
    telefono: Optional[str] = None
    email: Optional[str] = None
    es_contacto_principal: bool = False

class CirugiaBase(BaseModel):
    tipo_cirugia_id: int
    fecha_programada: str
    quirofano: Optional[str] = None
    notas_preoperatorias: Optional[str] = None

class SignosVitalesBase(BaseModel):
    presion_sistolica: Optional[int] = None
    presion_diastolica: Optional[int] = None
    frecuencia_cardiaca: Optional[int] = None
    temperatura: Optional[float] = None
    saturacion_oxigeno: Optional[int] = None
    dolor_escala: Optional[int] = None

class EvolucionClinicaBase(BaseModel):
    estado_general: str
    descripcion: str
    plan_tratamiento: Optional[str] = None
    observaciones: Optional[str] = None
    medico_id: int 


# API Endpoints
@app.post("/login")
def login(user_login: UserLogin):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    try:
        cursor.execute("SELECT * FROM usuarios WHERE username = %s AND activo = TRUE", (user_login.username,))
        user = cursor.fetchone()

        if not user or user_login.password != user['password_hash']:
            raise HTTPException(status_code=401, detail="Usuario o contraseña incorrectos")

        return {
            "message": "Inicio de sesión exitoso",
            "user_id": user["id"],
            "username": user["username"],
            "tipo_usuario": user["tipo_usuario"]
        }
    finally:
        cursor.close()
        conn.close()


@app.post("/family/login")
def family_login(family_login: FamilyLogin):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    try:
        cursor.execute("""
            SELECT cf.*, p.id as paciente_id, p.nombre as paciente_nombre, p.apellido as paciente_apellido,
                   c.id as contacto_id, c.nombre as familiar_nombre, c.apellido as familiar_apellido
            FROM codigos_familiares cf
            JOIN pacientes p ON cf.paciente_id = p.id
            JOIN contactos c ON cf.contacto_id = c.id
            WHERE cf.codigo_paciente = %s AND cf.codigo_familiar = %s 
              AND cf.activo = TRUE AND p.activo = TRUE
              AND (cf.fecha_expiracion IS NULL OR cf.fecha_expiracion > NOW())
        """, (family_login.patient_code, family_login.family_code))
        
        family_data = cursor.fetchone()
        if not family_data:
            raise HTTPException(status_code=401, detail="Códigos familiares inválidos")

        return {
            "message": "Inicio de sesión familiar exitoso",
            "paciente_id": family_data["paciente_id"],
            "contacto_id": family_data["contacto_id"],
            "paciente_nombre": family_data["paciente_nombre"],
            "familiar_nombre": family_data["familiar_nombre"]
        }
    finally:
        cursor.close()
        conn.close()


# Endpoints para familiares
@app.get("/family/patient/{patient_id}")
def get_family_patient_data(patient_id: int):
    """
    Devuelve información general del paciente, su cirugía más reciente,
    signos vitales actuales y notificaciones.
    """
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    try:
        # Obtener datos del paciente
        cursor.execute("""
            SELECT id, nombre, apellido, cedula, fecha_nacimiento, sexo, eps, tipo_sangre
            FROM pacientes 
            WHERE id = %s AND activo = TRUE
        """, (patient_id,))
        patient = cursor.fetchone()

        if not patient:
            raise HTTPException(status_code=404, detail="Paciente no encontrado")

        # Obtener la cirugía más reciente
        cursor.execute("""
            SELECT c.*, tc.nombre AS tipo_cirugia_nombre,
                   CONCAT(m.nombre, ' ', m.apellido) AS medico_nombre,
                   CASE 
                       WHEN c.estado = 'Programada' THEN 'preparacion'
                       WHEN c.estado = 'En_proceso' THEN 'en_progreso'
                       WHEN c.estado = 'Finalizada' THEN 'finalizada'
                       WHEN c.estado = 'Cancelada' THEN 'complicacion'
                       ELSE 'preparacion'
                   END AS current_status,
                   CASE 
                       WHEN c.estado = 'Programada' THEN 0
                       WHEN c.estado = 'Pre-operatorio' THEN 25
                       WHEN c.estado = 'En_proceso' THEN 75
                       WHEN c.estado = 'Post-operatorio' THEN 90
                       WHEN c.estado = 'Finalizada' THEN 100
                       ELSE 0
                   END AS progress,
                   CASE 
                       WHEN c.fecha_inicio IS NOT NULL 
                       THEN TIMESTAMPDIFF(MINUTE, c.fecha_inicio, COALESCE(c.fecha_fin, NOW()))
                       ELSE 0
                   END AS elapsed_time
            FROM cirugias c
            JOIN tipos_cirugia tc ON c.tipo_cirugia_id = tc.id
            JOIN medicos m ON c.medico_principal_id = m.id
            WHERE c.paciente_id = %s
            ORDER BY c.fecha_programada DESC
            LIMIT 1
        """, (patient_id,))
        surgery = cursor.fetchone()

        # Obtener signos vitales más recientes
        cursor.execute("""
            SELECT presion_sistolica, presion_diastolica, frecuencia_cardiaca, 
                   temperatura, saturacion_oxigeno
            FROM signos_vitales 
            WHERE paciente_id = %s
            ORDER BY fecha_registro DESC
            LIMIT 1
        """, (patient_id,))
        vital_signs = cursor.fetchone()

        # Obtener notificaciones recientes
        cursor.execute("""
            SELECT n.titulo AS message, n.fecha_envio AS timestamp
            FROM notificaciones n
            JOIN codigos_familiares cf ON n.contacto_id = cf.contacto_id
            WHERE cf.paciente_id = %s AND cf.activo = TRUE
            ORDER BY n.fecha_envio DESC
            LIMIT 5
        """, (patient_id,))
        notifications = cursor.fetchall()

        # Respuesta combinada
        return {
            "patient": patient,
            "surgery_status": {
                "current_status": surgery["current_status"] if surgery else "preparacion",
                "progress": surgery["progress"] if surgery else 0,
                "elapsed_time": (
                    f"{surgery['elapsed_time']//60:02d}:{surgery['elapsed_time']%60:02d}"
                    if surgery else "00:00"
                ),
                "heart_rate": vital_signs["frecuencia_cardiaca"] if vital_signs else 72,
                "blood_pressure": (
                    f"{vital_signs['presion_sistolica']}/{vital_signs['presion_diastolica']}"
                    if vital_signs else "120/80"
                ),
                "temperature": vital_signs["temperatura"] if vital_signs else 36.5,
                "oxygen_saturation": vital_signs["saturacion_oxigeno"] if vital_signs else 98,
                "notifications": notifications
            }
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error al obtener datos del paciente: {str(e)}")

    finally:
        cursor.close()
        conn.close()


@app.get("/pacientes")
def get_pacientes():
    conn = db_manager.get_connection()
    if not conn:
        raise HTTPException(status_code=500, detail="❌ No se pudo conectar con la base de datos")

    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute("""
            SELECT 
                id, nombre, apellido, cedula, fecha_nacimiento, sexo, 
                telefono, eps, tipo_sangre
            FROM pacientes
            WHERE activo = TRUE
            LIMIT 50
        """)
        pacientes = cursor.fetchall()
        return pacientes
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error en la consulta: {str(e)}")
    finally:
        cursor.close()
        conn.close()


@app.get("/pacientes")
def get_pacientes():
    conn = db_manager.get_connection()
    if not conn:
        raise HTTPException(status_code=500, detail="❌ No se pudo conectar con la base de datos")

    cursor = None
    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute("""
            SELECT 
                id, nombre, apellido, cedula, fecha_nacimiento, sexo, 
                telefono, eps, tipo_sangre
            FROM pacientes
            WHERE activo = TRUE
            LIMIT 50
        """)
        pacientes = cursor.fetchall()
        return pacientes
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error en la consulta: {str(e)}")
    finally:
        if cursor:
            cursor.close()
        conn.close()

@app.get("/cirugias/{paciente_id}")
def get_cirugias_paciente(paciente_id: int):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    
    try:
        cursor.execute("""
            SELECT c.*, tc.nombre as tipo_cirugia_nombre,
                   CONCAT(m.nombre, ' ', m.apellido) as medico_nombre
            FROM cirugias c
            JOIN tipos_cirugia tc ON c.tipo_cirugia_id = tc.id
            JOIN medicos m ON c.medico_principal_id = m.id
            WHERE c.paciente_id = %s
            ORDER BY c.fecha_programada DESC
        """, (paciente_id,))
        cirugias = cursor.fetchall()
        return cirugias
    finally:
        cursor.close()
        conn.close()

@app.put("/cirugias/{cirugia_id}/estado")
def actualizar_estado_cirugia(cirugia_id: int, estado: str):
    conn = get_db_connection()
    cursor = conn.cursor()
    
    try:
        # Actualizar estado
        cursor.execute("""
            UPDATE cirugias 
            SET estado = %s, 
                fecha_inicio = CASE WHEN %s = 'En_proceso' THEN NOW() ELSE fecha_inicio END,
                fecha_fin = CASE WHEN %s = 'Finalizada' THEN NOW() ELSE fecha_fin END
            WHERE id = %s
        """, (estado, estado, estado, cirugia_id))
        
        # Notificar a contactos
        cursor.execute("""
            INSERT INTO notificaciones (contacto_id, paciente_id, cirugia_id, tipo, titulo, mensaje)
            SELECT c.id, ci.paciente_id, ci.id, 'cambio_estado',
                   CONCAT('Cambio de estado en cirugía'),
                   CONCAT('La cirugía ha cambiado a estado: ', %s)
            FROM contactos c
            JOIN cirugias ci ON c.paciente_id = ci.paciente_id
            WHERE ci.id = %s AND c.notificaciones_activas = TRUE
        """, (estado, cirugia_id))
        
        conn.commit()
        return {"message": "Estado actualizado correctamente"}
    finally:
        cursor.close()
        conn.close()

@app.get("/contactos")
def get_contactos(limit: int = 50, offset: int = 0):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    
    try:
        cursor.execute("""
            SELECT * FROM contactos
            ORDER BY id ASC
            LIMIT %s OFFSET %s
        """, (limit, offset))
        contactos = cursor.fetchall()
        return contactos
    finally:
        cursor.close()
        conn.close()


@app.get("/signos-vitales/{paciente_id}")
def get_signos_vitales(paciente_id: int):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    
    try:
        cursor.execute("""
            SELECT * FROM signos_vitales 
            WHERE paciente_id = %s
            ORDER BY fecha_registro DESC
            LIMIT 20
        """, (paciente_id,))
        signos = cursor.fetchall()
        return signos
    finally:
        cursor.close()
        conn.close()

# Registrar signos vitales (sin token)
@app.post("/signos-vitales/{paciente_id}")
def crear_signos_vitales(paciente_id: int, signos: SignosVitalesBase):
    conn = get_db_connection()
    cursor = conn.cursor()

    try:
        cursor.execute("""
            INSERT INTO signos_vitales 
            (paciente_id, fecha_registro, presion_sistolica, presion_diastolica, 
             frecuencia_cardiaca, temperatura, saturacion_oxigeno, dolor_escala)
            VALUES (%s, NOW(), %s, %s, %s, %s, %s, %s)
        """, (
            paciente_id,
            signos.presion_sistolica,
            signos.presion_diastolica,
            signos.frecuencia_cardiaca,
            signos.temperatura,
            signos.saturacion_oxigeno,
            signos.dolor_escala
        ))
        conn.commit()
        return {"message": "Signos vitales registrados correctamente"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error al registrar signos vitales: {str(e)}")
    finally:
        cursor.close()
        conn.close()


# Obtener evoluciones clínicas (sin token)
@app.get("/evoluciones/{paciente_id}")
def get_evoluciones(paciente_id: int):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    try:
        cursor.execute("""
            SELECT e.*, CONCAT(m.nombre, ' ', m.apellido) AS medico_nombre
            FROM evoluciones_clinicas e
            JOIN medicos m ON e.medico_id = m.id
            WHERE e.paciente_id = %s
            ORDER BY e.fecha_registro DESC
            LIMIT 10
        """, (paciente_id,))
        evoluciones = cursor.fetchall()
        return evoluciones
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error al obtener evoluciones: {str(e)}")
    finally:
        cursor.close()
        conn.close()


# Crear evolución clínica (sin token)
@app.post("/evoluciones/{paciente_id}")
def crear_evolucion(paciente_id: int, evolucion: EvolucionClinicaBase):
    conn = get_db_connection()
    cursor = conn.cursor()

    try:
        cursor.execute("""
            INSERT INTO evoluciones_clinicas 
            (paciente_id, fecha_registro, estado_general, descripcion, plan_tratamiento, observaciones_familiares, medico_id)
            VALUES (%s, NOW(), %s, %s, %s, %s, %s)
        """, (
            paciente_id,
            evolucion.estado_general,
            evolucion.descripcion,
            evolucion.plan_tratamiento,
            evolucion.observaciones,
            evolucion.medico_id
        ))
        conn.commit()
        return {"message": "Evolución clínica registrada correctamente"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error al registrar evolución clínica: {str(e)}")
    finally:
        cursor.close()
        conn.close()


# Dashboard general (sin token)
@app.get("/dashboard/stats")
def get_dashboard_stats():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    try:
        stats = {}

        # Total pacientes
        cursor.execute("SELECT COUNT(*) AS total FROM pacientes WHERE activo = TRUE")
        stats["total_pacientes"] = cursor.fetchone()["total"]

        # Cirugías hoy
        cursor.execute("""
            SELECT COUNT(*) AS total FROM cirugias 
            WHERE DATE(fecha_programada) = CURDATE()
        """)
        stats["cirugias_hoy"] = cursor.fetchone()["total"]

        # Cirugías en proceso
        cursor.execute("""
            SELECT COUNT(*) AS total FROM cirugias 
            WHERE estado IN ('Pre-operatorio', 'En_proceso')
        """)
        stats["cirugias_activas"] = cursor.fetchone()["total"]

        # Pacientes críticos
        cursor.execute("""
            SELECT COUNT(DISTINCT paciente_id) AS total 
            FROM evoluciones_clinicas 
            WHERE estado_general = 'Crítico' 
            AND fecha_registro > DATE_SUB(NOW(), INTERVAL 24 HOUR)
        """)
        stats["pacientes_criticos"] = cursor.fetchone()["total"]

        return stats
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error al obtener estadísticas: {str(e)}")
    finally:
        cursor.close()
        conn.close()


# Probar conexión con base de datos
@app.get("/test-db")
def test_db():
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT NOW() AS fecha")
        result = cursor.fetchone()
        return {"conexion_exitosa": True, "resultado": result}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error de conexión: {str(e)}")
    finally:
        cursor.close()
        conn.close()


# Punto de entrada
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
