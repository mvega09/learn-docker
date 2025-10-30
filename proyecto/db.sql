-- ========================================
-- SCRIPT UNIFICADO DE BASE DE DATOS SIACOM
-- Sistema Integral de Acompañamiento Hospitalario
-- Versión: 2.0 - Sin valores NULL
-- ========================================

DROP DATABASE IF EXISTS siacom_db;
CREATE DATABASE siacom_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE siacom_db;

-- ========================================
-- TABLAS PRINCIPALES
-- ========================================

-- Tabla de Usuarios del Sistema (Solo médicos y administradores)
CREATE TABLE usuarios (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    tipo_usuario ENUM('medico', 'administrador') NOT NULL,
    activo BOOLEAN DEFAULT TRUE NOT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP NOT NULL
);

-- Tabla de Especialidades Médicas
CREATE TABLE especialidades (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT NOT NULL,
    activo BOOLEAN DEFAULT TRUE NOT NULL
);

-- Tabla de Médicos Especialistas
CREATE TABLE medicos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    usuario_id INT NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    cedula VARCHAR(20) UNIQUE NOT NULL,
    especialidad_id INT NOT NULL,
    telefono VARCHAR(20) NOT NULL DEFAULT '3000000000',
    registro_medico VARCHAR(50) UNIQUE NOT NULL,
    activo BOOLEAN DEFAULT TRUE NOT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    FOREIGN KEY (especialidad_id) REFERENCES especialidades(id)
);

-- Tabla de Pacientes
CREATE TABLE pacientes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    cedula VARCHAR(20) UNIQUE NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    sexo ENUM('M', 'F', 'Otro') NOT NULL,
    direccion VARCHAR(500) NOT NULL DEFAULT 'Dirección no especificada',
    telefono VARCHAR(20) NOT NULL DEFAULT '3000000000',
    email VARCHAR(100) NOT NULL DEFAULT 'sin-email@hospital.com',
    eps VARCHAR(100) NOT NULL DEFAULT 'EPS No especificada',
    tipo_sangre VARCHAR(5) NOT NULL DEFAULT 'O+',
    alergias VARCHAR(500) NOT NULL DEFAULT 'Sin alergias conocidas',
    enfermedades_previas VARCHAR(500) NOT NULL DEFAULT 'Sin enfermedades previas',
    medicamentos_actuales VARCHAR(500) NOT NULL DEFAULT 'Sin medicamentos actuales',
    contacto_emergencia VARCHAR(200) NOT NULL DEFAULT 'Sin contacto de emergencia',
    activo BOOLEAN DEFAULT TRUE NOT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP NOT NULL
);

-- Tabla de Contactos/Familiares
CREATE TABLE contactos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    paciente_id INT NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    relacion VARCHAR(50) NOT NULL,
    telefono VARCHAR(20) NOT NULL DEFAULT '3000000000',
    email VARCHAR(100) NOT NULL DEFAULT 'sin-email@contacto.com',
    es_contacto_principal BOOLEAN DEFAULT FALSE NOT NULL,
    notificaciones_activas BOOLEAN DEFAULT TRUE NOT NULL,
    puede_recibir_info_medica BOOLEAN DEFAULT FALSE NOT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    FOREIGN KEY (paciente_id) REFERENCES pacientes(id) ON DELETE CASCADE
);

-- Tabla de Códigos Familiares (Reemplaza autenticación de familiares)
CREATE TABLE codigos_familiares (
    id INT PRIMARY KEY AUTO_INCREMENT,
    paciente_id INT NOT NULL,
    codigo_paciente VARCHAR(20) UNIQUE NOT NULL,
    codigo_familiar VARCHAR(20) UNIQUE NOT NULL,
    contacto_id INT NOT NULL,
    activo BOOLEAN DEFAULT TRUE NOT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    fecha_expiracion DATETIME NOT NULL,
    FOREIGN KEY (paciente_id) REFERENCES pacientes(id) ON DELETE CASCADE,
    FOREIGN KEY (contacto_id) REFERENCES contactos(id) ON DELETE CASCADE
);

-- Tabla de Tipos de Cirugía
CREATE TABLE tipos_cirugia (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    descripcion VARCHAR(500) NOT NULL DEFAULT 'Procedimiento quirúrgico',
    duracion_estimada_minutos INT NOT NULL DEFAULT 60,
    complejidad ENUM('Baja', 'Media', 'Alta') DEFAULT 'Media' NOT NULL
);

-- Tabla de Gestión Transoperatoria (Cirugías)
CREATE TABLE cirugias (
    id INT PRIMARY KEY AUTO_INCREMENT,
    paciente_id INT NOT NULL,
    medico_principal_id INT NOT NULL,
    tipo_cirugia_id INT NOT NULL,
    fecha_programada DATETIME NOT NULL,
    fecha_inicio DATETIME DEFAULT NULL,
    fecha_fin DATETIME DEFAULT NULL,
    estado ENUM('Programada', 'Pre-operatorio', 'En_proceso', 'Post-operatorio', 'Finalizada', 'Cancelada') DEFAULT 'Programada' NOT NULL,
    quirofano VARCHAR(20) NOT NULL DEFAULT 'Q1',
    notas_preoperatorias VARCHAR(1000) NOT NULL DEFAULT 'Sin observaciones preoperatorias',
    notas_transoperatorias VARCHAR(1000) NOT NULL DEFAULT 'Sin observaciones transoperatorias',
    notas_postoperatorias VARCHAR(1000) NOT NULL DEFAULT 'Sin observaciones postoperatorias',
    complicaciones VARCHAR(1000) NOT NULL DEFAULT 'Sin complicaciones',
    resultado ENUM('Exitosa', 'Complicaciones_menores', 'Complicaciones_mayores', 'Pendiente') DEFAULT 'Pendiente' NOT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP NOT NULL,
    FOREIGN KEY (paciente_id) REFERENCES pacientes(id) ON DELETE CASCADE,
    FOREIGN KEY (medico_principal_id) REFERENCES medicos(id),
    FOREIGN KEY (tipo_cirugia_id) REFERENCES tipos_cirugia(id)
);

-- Tabla de Signos Vitales
CREATE TABLE signos_vitales (
    id INT PRIMARY KEY AUTO_INCREMENT,
    paciente_id INT NOT NULL,
    cirugia_id INT DEFAULT NULL,
    fecha_registro DATETIME NOT NULL,
    presion_sistolica INT NOT NULL DEFAULT 120,
    presion_diastolica INT NOT NULL DEFAULT 80,
    frecuencia_cardiaca INT NOT NULL DEFAULT 75,
    temperatura DECIMAL(4,2) NOT NULL DEFAULT 36.5,
    saturacion_oxigeno INT NOT NULL DEFAULT 98,
    frecuencia_respiratoria INT NOT NULL DEFAULT 16,
    dolor_escala INT NOT NULL DEFAULT 0 CHECK (dolor_escala >= 0 AND dolor_escala <= 10),
    observaciones VARCHAR(500) NOT NULL DEFAULT 'Sin observaciones',
    registrado_por_medico_id INT NOT NULL,
    FOREIGN KEY (paciente_id) REFERENCES pacientes(id) ON DELETE CASCADE,
    FOREIGN KEY (cirugia_id) REFERENCES cirugias(id) ON DELETE CASCADE,
    FOREIGN KEY (registrado_por_medico_id) REFERENCES medicos(id)
);

-- Tabla de Evolución Clínica
CREATE TABLE evoluciones_clinicas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    paciente_id INT NOT NULL,
    cirugia_id INT DEFAULT NULL,
    fecha_registro DATETIME NOT NULL,
    estado_general ENUM('Estable', 'Mejorado', 'Regular', 'Crítico') NOT NULL,
    descripcion VARCHAR(1000) NOT NULL,
    plan_tratamiento VARCHAR(1000) NOT NULL DEFAULT 'Continuar tratamiento',
    medicamentos VARCHAR(1000) NOT NULL DEFAULT 'Sin medicamentos',
    restricciones VARCHAR(500) NOT NULL DEFAULT 'Sin restricciones',
    observaciones_familiares VARCHAR(1000) NOT NULL DEFAULT 'Sin observaciones para familiares',
    proxima_evaluacion DATETIME NOT NULL,
    medico_id INT NOT NULL,
    FOREIGN KEY (paciente_id) REFERENCES pacientes(id) ON DELETE CASCADE,
    FOREIGN KEY (cirugia_id) REFERENCES cirugias(id) ON DELETE CASCADE,
    FOREIGN KEY (medico_id) REFERENCES medicos(id)
);

-- Tabla de Notificaciones
CREATE TABLE notificaciones (
    id INT PRIMARY KEY AUTO_INCREMENT,
    contacto_id INT NOT NULL,
    paciente_id INT NOT NULL,
    cirugia_id INT DEFAULT NULL,
    tipo ENUM('info_general', 'cambio_estado', 'complicacion', 'alta_medica') NOT NULL,
    titulo VARCHAR(200) NOT NULL,
    mensaje VARCHAR(1000) NOT NULL,
    leida BOOLEAN DEFAULT FALSE NOT NULL,
    fecha_envio TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    FOREIGN KEY (contacto_id) REFERENCES contactos(id) ON DELETE CASCADE,
    FOREIGN KEY (paciente_id) REFERENCES pacientes(id) ON DELETE CASCADE,
    FOREIGN KEY (cirugia_id) REFERENCES cirugias(id) ON DELETE CASCADE
);

-- Tabla de Auditoría
CREATE TABLE auditoria (
    id INT PRIMARY KEY AUTO_INCREMENT,
    tabla_afectada VARCHAR(50) NOT NULL,
    id_registro INT NOT NULL,
    accion ENUM('INSERT', 'UPDATE', 'DELETE') NOT NULL,
    usuario_id INT NOT NULL,
    fecha_accion TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    datos_anteriores JSON DEFAULT NULL,
    datos_nuevos JSON DEFAULT NULL,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
);

-- ========================================
-- ÍNDICES PARA OPTIMIZACIÓN
-- ========================================
CREATE INDEX idx_pacientes_cedula ON pacientes(cedula);
CREATE INDEX idx_cirugias_fecha ON cirugias(fecha_programada);
CREATE INDEX idx_cirugias_estado ON cirugias(estado);
CREATE INDEX idx_signos_vitales_fecha ON signos_vitales(fecha_registro);
CREATE INDEX idx_evoluciones_fecha ON evoluciones_clinicas(fecha_registro);
CREATE INDEX idx_notificaciones_contacto ON notificaciones(contacto_id);
CREATE INDEX idx_codigos_paciente ON codigos_familiares(codigo_paciente);
CREATE INDEX idx_codigos_familiar ON codigos_familiares(codigo_familiar);
CREATE INDEX idx_codigos_activo ON codigos_familiares(activo);

-- ========================================
-- DATOS INICIALES
-- ========================================

-- Especialidades
INSERT INTO especialidades (nombre, descripcion) VALUES
('Cirugía General', 'Especialidad médica quirúrgica general'),
('Cardiología', 'Especialidad del corazón y sistema cardiovascular'),
('Neurología', 'Especialidad del sistema nervioso'),
('Ortopedia', 'Especialidad de huesos y articulaciones'),
('Anestesiología', 'Especialidad de anestesia y cuidados perioperatorios'),
('Pediatría', 'Especialidad médica de niños y adolescentes'),
('Ginecología', 'Especialidad de salud femenina'),
('Urología', 'Especialidad del sistema urinario');

-- Tipos de Cirugía
INSERT INTO tipos_cirugia (nombre, descripcion, duracion_estimada_minutos, complejidad) VALUES
('Apendicectomía', 'Extirpación del apéndice', 60, 'Baja'),
('Colecistectomía', 'Extirpación de la vesícula biliar', 90, 'Media'),
('Cirugía de Corazón Abierto', 'Cirugía cardíaca mayor', 300, 'Alta'),
('Reemplazo de Rodilla', 'Cirugía ortopédica de rodilla', 120, 'Media'),
('Neurocirugía', 'Cirugía del sistema nervioso', 240, 'Alta'),
('Cesárea', 'Nacimiento por cirugía abdominal', 45, 'Baja'),
('Hernioplastia', 'Reparación de hernia', 75, 'Media'),
('Laparoscopia Diagnóstica', 'Cirugía mínimamente invasiva', 60, 'Baja');

-- Usuarios con contraseñas simples para pruebas
INSERT INTO usuarios (username, password_hash, email, tipo_usuario) VALUES
('superadmin', 'password123', 'superadmin@hospital.com', 'administrador'),
('enfermera.jefe', 'password123', 'enfermera.jefe@hospital.com', 'administrador'),
('coordinador.quirurgico', 'password123', 'coordinador@hospital.com', 'administrador'),
('dr.anestesiologo', 'password123', 'anestesiologo@hospital.com', 'medico'),
('dr.cirujano', 'password123', 'cirujano@hospital.com', 'medico');

-- Médicos
INSERT INTO medicos (usuario_id, nombre, apellido, cedula, especialidad_id, telefono, registro_medico) VALUES
(1, 'Carlos', 'Martínez', '12345678', 1, '3001234567', 'RM001'),
(2, 'Ana', 'Rodríguez', '87654321', 2, '3009876543', 'RM002'),
(3, 'Miguel', 'García', '11223344', 3, '3005566778', 'RM003'),
(4, 'Roberto', 'Silva', '99887766', 5, '3001122334', 'RM004'),
(5, 'Patricia', 'Mendoza', '55443322', 1, '3005566778', 'RM005');

-- ========================================
-- PROCEDIMIENTOS PARA DATOS MASIVOS
-- ========================================

-- Generar 2000+ Pacientes
DELIMITER //
CREATE PROCEDURE GenerarPacientes()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE nombre_var VARCHAR(100);
    DECLARE apellido_var VARCHAR(100);
    DECLARE cedula_var VARCHAR(20);
    DECLARE fecha_nac DATE;
    DECLARE sexo_var CHAR(1);
    
    WHILE i <= 2000 DO
        SET nombre_var = CASE (i % 20)
            WHEN 0 THEN 'Juan' WHEN 1 THEN 'María' WHEN 2 THEN 'Carlos'
            WHEN 3 THEN 'Ana' WHEN 4 THEN 'Luis' WHEN 5 THEN 'Carmen'
            WHEN 6 THEN 'José' WHEN 7 THEN 'Elena' WHEN 8 THEN 'Miguel'
            WHEN 9 THEN 'Laura' WHEN 10 THEN 'Antonio' WHEN 11 THEN 'Isabel'
            WHEN 12 THEN 'Francisco' WHEN 13 THEN 'Rosa' WHEN 14 THEN 'David'
            WHEN 15 THEN 'Patricia' WHEN 16 THEN 'Roberto' WHEN 17 THEN 'Marta'
            WHEN 18 THEN 'Fernando' ELSE 'Lucía'
        END;
        
        SET apellido_var = CASE (i % 15)
            WHEN 0 THEN 'González' WHEN 1 THEN 'Rodríguez' WHEN 2 THEN 'García'
            WHEN 3 THEN 'Martínez' WHEN 4 THEN 'López' WHEN 5 THEN 'Hernández'
            WHEN 6 THEN 'Pérez' WHEN 7 THEN 'Sánchez' WHEN 8 THEN 'Ramírez'
            WHEN 9 THEN 'Cruz' WHEN 10 THEN 'Torres' WHEN 11 THEN 'Flores'
            WHEN 12 THEN 'Gómez' WHEN 13 THEN 'Díaz' ELSE 'Vargas'
        END;
        
        SET cedula_var = CONCAT('100', LPAD(i, 6, '0'));
        SET fecha_nac = DATE_SUB(CURDATE(), INTERVAL (FLOOR(RAND() * 60) + 20) YEAR);
        SET sexo_var = IF(i % 2 = 0, 'M', 'F');
        
        INSERT INTO pacientes (nombre, apellido, cedula, fecha_nacimiento, sexo, telefono, email, eps, tipo_sangre, direccion, alergias, contacto_emergencia)
        VALUES (
            nombre_var, 
            apellido_var, 
            cedula_var, 
            fecha_nac, 
            sexo_var,
            CONCAT('300', FLOOR(RAND() * 9000000) + 1000000),
            CONCAT(LOWER(nombre_var), '.', LOWER(apellido_var), i, '@email.com'),
            CASE (i % 5) 
                WHEN 0 THEN 'EPS SURA' WHEN 1 THEN 'Nueva EPS'
                WHEN 2 THEN 'Sanitas' WHEN 3 THEN 'Compensar'
                ELSE 'Salud Total'
            END,
            CASE (i % 8)
                WHEN 0 THEN 'O+' WHEN 1 THEN 'A+' WHEN 2 THEN 'B+'
                WHEN 3 THEN 'AB+' WHEN 4 THEN 'O-' WHEN 5 THEN 'A-'
                WHEN 6 THEN 'B-' ELSE 'AB-'
            END,
            CONCAT('Calle ', FLOOR(RAND() * 100), ' # ', FLOOR(RAND() * 100), '-', FLOOR(RAND() * 100)),
            CASE (i % 4)
                WHEN 0 THEN 'Penicilina' WHEN 1 THEN 'Sin alergias conocidas'
                WHEN 2 THEN 'Ibuprofeno' ELSE 'Polen'
            END,
            CONCAT('Familiar: ', CONCAT('300', FLOOR(RAND() * 9000000) + 1000000))
        );
        
        SET i = i + 1;
    END WHILE;
END //
DELIMITER ;

CALL GenerarPacientes();
DROP PROCEDURE GenerarPacientes;

-- Generar 2500+ Contactos
DELIMITER //
CREATE PROCEDURE GenerarContactos()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE max_paciente_id INT;
    
    SELECT MAX(id) INTO max_paciente_id FROM pacientes;
    
    WHILE i <= 2500 DO
        INSERT INTO contactos (paciente_id, nombre, apellido, relacion, telefono, email, es_contacto_principal, notificaciones_activas, puede_recibir_info_medica)
        VALUES (
            (i % max_paciente_id) + 1,
            CASE (i % 10)
                WHEN 0 THEN 'Pedro' WHEN 1 THEN 'Sandra' WHEN 2 THEN 'Ricardo'
                WHEN 3 THEN 'Mónica' WHEN 4 THEN 'Andrés' WHEN 5 THEN 'Claudia'
                WHEN 6 THEN 'Javier' WHEN 7 THEN 'Diana' WHEN 8 THEN 'Sergio'
                ELSE 'Alejandra'
            END,
            CASE (i % 8)
                WHEN 0 THEN 'Morales' WHEN 1 THEN 'Jiménez' WHEN 2 THEN 'Ruiz'
                WHEN 3 THEN 'Herrera' WHEN 4 THEN 'Medina' WHEN 5 THEN 'Castro'
                WHEN 6 THEN 'Ortiz' ELSE 'Ramos'
            END,
            CASE (i % 6)
                WHEN 0 THEN 'Hijo/a' WHEN 1 THEN 'Esposo/a' WHEN 2 THEN 'Padre/Madre'
                WHEN 3 THEN 'Hermano/a' WHEN 4 THEN 'Abuelo/a' ELSE 'Primo/a'
            END,
            CONCAT('300', FLOOR(RAND() * 9000000) + 1000000),
            CONCAT('contacto', i, '@email.com'),
            IF(i % 3 = 0, TRUE, FALSE),
            TRUE,
            IF(i % 2 = 0, TRUE, FALSE)
        );
        
        SET i = i + 1;
    END WHILE;
END //
DELIMITER ;

CALL GenerarContactos();
DROP PROCEDURE GenerarContactos;

-- Generar Códigos Familiares
DELIMITER //
CREATE PROCEDURE GenerarCodigosFamiliares()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE max_contacto_id INT;
    DECLARE paciente_actual INT;
    
    SELECT MAX(id) INTO max_contacto_id FROM contactos;
    
    WHILE i <= max_contacto_id DO
        SELECT paciente_id INTO paciente_actual FROM contactos WHERE id = i;
        
        INSERT INTO codigos_familiares (paciente_id, codigo_paciente, codigo_familiar, contacto_id, fecha_expiracion)
        VALUES (
            paciente_actual,
            CONCAT('PAC-', LPAD(i, 6, '0')),
            CONCAT('FAM-', LPAD(i, 6, '0')),
            i,
            DATE_ADD(CURDATE(), INTERVAL 90 DAY)
        );
        
        SET i = i + 1;
    END WHILE;
END //
DELIMITER ;

CALL GenerarCodigosFamiliares();
DROP PROCEDURE GenerarCodigosFamiliares;

-- Generar 2500+ Cirugías
DELIMITER //
CREATE PROCEDURE GenerarCirugias()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE max_paciente_id INT;
    DECLARE max_medico_id INT;
    DECLARE fecha_prog DATETIME;
    DECLARE estado_var VARCHAR(20);
    
    SELECT MAX(id) INTO max_paciente_id FROM pacientes;
    SELECT MAX(id) INTO max_medico_id FROM medicos;
    
    WHILE i <= 2500 DO
        SET fecha_prog = DATE_ADD(CURDATE(), INTERVAL (FLOOR(RAND() * 60) - 30) DAY);
        SET estado_var = CASE (i % 6)
            WHEN 0 THEN 'Programada' WHEN 1 THEN 'Pre-operatorio' 
            WHEN 2 THEN 'En_proceso' WHEN 3 THEN 'Post-operatorio' 
            WHEN 4 THEN 'Finalizada' ELSE 'Programada'
        END;
        
        INSERT INTO cirugias (paciente_id, medico_principal_id, tipo_cirugia_id, fecha_programada, 
                             fecha_inicio, fecha_fin, estado, quirofano, resultado,
                             notas_preoperatorias, notas_transoperatorias, notas_postoperatorias, complicaciones)
        VALUES (
            (i % max_paciente_id) + 1,
            (i % max_medico_id) + 1,
            (i % 8) + 1,
            fecha_prog,
            IF(estado_var IN ('En_proceso', 'Post-operatorio', 'Finalizada'), 
               DATE_ADD(fecha_prog, INTERVAL 2 HOUR), NULL),
            IF(estado_var = 'Finalizada', 
               DATE_ADD(fecha_prog, INTERVAL 4 HOUR), NULL),
            estado_var,
            CONCAT('Q', (i % 10) + 1),
            IF(estado_var = 'Finalizada', 
               CASE (i % 3) WHEN 0 THEN 'Exitosa' WHEN 1 THEN 'Complicaciones_menores' ELSE 'Exitosa' END,
               'Pendiente'),
            'Paciente preparado para cirugía. Exámenes preoperatorios completos.',
            IF(estado_var IN ('En_proceso', 'Post-operatorio', 'Finalizada'), 
               'Procedimiento dentro de parámetros normales. Sangrado controlado.', 
               'Pendiente'),
            IF(estado_var IN ('Post-operatorio', 'Finalizada'), 
               'Paciente en recuperación. Signos vitales estables.', 
               'Pendiente'),
            IF(estado_var = 'Finalizada' AND (i % 10 = 0), 
               'Sangrado menor controlado', 
               'Sin complicaciones')
        );
        
        SET i = i + 1;
    END WHILE;
END //
DELIMITER ;

CALL GenerarCirugias();
DROP PROCEDURE GenerarCirugias;

-- Generar 3000+ Signos Vitales
DELIMITER //
CREATE PROCEDURE GenerarSignosVitales()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE max_paciente_id INT;
    DECLARE max_cirugia_id INT;
    DECLARE max_medico_id INT;
    
    SELECT MAX(id) INTO max_paciente_id FROM pacientes;
    SELECT MAX(id) INTO max_cirugia_id FROM cirugias;
    SELECT MAX(id) INTO max_medico_id FROM medicos;
    
    WHILE i <= 3000 DO
        INSERT INTO signos_vitales (paciente_id, cirugia_id, fecha_registro, presion_sistolica, 
                                   presion_diastolica, frecuencia_cardiaca, temperatura, 
                                   saturacion_oxigeno, frecuencia_respiratoria, dolor_escala, 
                                   observaciones, registrado_por_medico_id)
        VALUES (
            (i % max_paciente_id) + 1,
            IF(i % 3 = 0, (i % max_cirugia_id) + 1, NULL),
            DATE_SUB(NOW(), INTERVAL (FLOOR(RAND() * 720)) HOUR),
            FLOOR(RAND() * 60) + 100,
            FLOOR(RAND() * 40) + 60,
            FLOOR(RAND() * 60) + 60,
            ROUND(35.5 + (RAND() * 2.5), 1),
            FLOOR(RAND() * 10) + 90,
            FLOOR(RAND() * 10) + 12,
            FLOOR(RAND() * 11),
            CASE (i % 5)
                WHEN 0 THEN 'Paciente estable' WHEN 1 THEN 'Sin observaciones'
                WHEN 2 THEN 'Signos vitales normales' WHEN 3 THEN 'Monitoreo continuo'
                ELSE 'Control de rutina'
            END,
            (i % max_medico_id) + 1
        );
        
        SET i = i + 1;
    END WHILE;
END //
DELIMITER ;

CALL GenerarSignosVitales();
DROP PROCEDURE GenerarSignosVitales;

-- Generar 2500+ Evoluciones Clínicas
DELIMITER //
CREATE PROCEDURE GenerarEvolucionesClinicas()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE max_paciente_id INT;
    DECLARE max_cirugia_id INT;
    DECLARE max_medico_id INT;
    
    SELECT MAX(id) INTO max_paciente_id FROM pacientes;
    SELECT MAX(id) INTO max_cirugia_id FROM cirugias;
    SELECT MAX(id) INTO max_medico_id FROM medicos;
    
    WHILE i <= 2500 DO
        INSERT INTO evoluciones_clinicas (paciente_id, cirugia_id, fecha_registro, estado_general, 
                                         descripcion, plan_tratamiento, medicamentos, restricciones,
                                         observaciones_familiares, proxima_evaluacion, medico_id)
        VALUES (
            (i % max_paciente_id) + 1,
            IF(i % 4 = 0, (i % max_cirugia_id) + 1, NULL),
            DATE_SUB(NOW(), INTERVAL (FLOOR(RAND() * 168)) HOUR),
            CASE (i % 4)
                WHEN 0 THEN 'Estable' WHEN 1 THEN 'Mejorado'
                WHEN 2 THEN 'Regular' ELSE 'Estable'
            END,
            CASE (i % 8)
                WHEN 0 THEN 'Paciente en evolución favorable, sin complicaciones evidentes'
                WHEN 1 THEN 'Signos vitales estables, dolor controlado adecuadamente'
                WHEN 2 THEN 'Recuperación dentro de parámetros normales esperados'
                WHEN 3 THEN 'Requiere monitoreo constante, sin cambios significativos'
                WHEN 4 THEN 'Evolución satisfactoria post-cirugía, responde bien al tratamiento'
                WHEN 5 THEN 'Paciente consciente, orientado y cooperador'
                WHEN 6 THEN 'Tolerando dieta, movilización progresiva sin dificultades'
                ELSE 'Control de dolor adecuado, herida quirúrgica en buen estado'
            END,
            CASE (i % 6)
                WHEN 0 THEN 'Continuar tratamiento actual, monitoreo cada 6 horas'
                WHEN 1 THEN 'Ajustar medicación para dolor según escala EVA'
                WHEN 2 THEN 'Iniciar fisioterapia respiratoria y movilización temprana'
                WHEN 3 THEN 'Control de signos vitales cada 4 horas'
                WHEN 4 THEN 'Preparar para alta médica en 24-48 horas'
                ELSE 'Monitoreo estrecho, evaluación por especialista'
            END,
            CASE (i % 7)
                WHEN 0 THEN 'Paracetamol 1g c/8h, Omeprazol 40mg c/24h'
                WHEN 1 THEN 'Tramadol 50mg c/8h PRN, Metamizol 1g c/8h'
                WHEN 2 THEN 'Antibiótico profiláctico, analgesia multimodal'
                WHEN 3 THEN 'Enoxaparina 40mg SC c/24h, analgesia según necesidad'
                WHEN 4 THEN 'Medicación vía oral bien tolerada'
                WHEN 5 THEN 'Ketorolaco 30mg IV c/8h, Ranitidina 50mg c/12h'
                ELSE 'Manejo multimodal del dolor, profilaxis antitrombótica'
            END,
            CASE (i % 5)
                WHEN 0 THEN 'Reposo relativo 48 horas, deambulación asistida'
                WHEN 1 THEN 'Dieta blanda por 24 horas, luego dieta general'
                WHEN 2 THEN 'No cargar peso mayor a 5kg por 2 semanas'
                WHEN 3 THEN 'Evitar esfuerzos abdominales, movilización progresiva'
                ELSE 'Sin restricciones especiales, actividad según tolerancia'
            END,
            CASE (i % 6)
                WHEN 0 THEN 'Paciente estable, puede recibir visitas cortas'
                WHEN 1 THEN 'Evolución favorable, familiar puede acompañar'
                WHEN 2 THEN 'En recuperación normal, mantener apoyo familiar'
                WHEN 3 THEN 'Requiere tranquilidad, visitas restringidas'
                WHEN 4 THEN 'Mejorando satisfactoriamente, puede conversar con familiares'
                ELSE 'Colaboración familiar importante para recuperación'
            END,
            DATE_ADD(NOW(), INTERVAL (FLOOR(RAND() * 48) + 12) HOUR),
            (i % max_medico_id) + 1
        );
        
        SET i = i + 1;
    END WHILE;
END //
DELIMITER ;

CALL GenerarEvolucionesClinicas();
DROP PROCEDURE GenerarEvolucionesClinicas;

-- Generar 1500+ Notificaciones
DELIMITER //
CREATE PROCEDURE GenerarNotificaciones()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE max_contacto_id INT;
    DECLARE max_paciente_id INT;
    DECLARE max_cirugia_id INT;
    
    SELECT MAX(id) INTO max_contacto_id FROM contactos;
    SELECT MAX(id) INTO max_paciente_id FROM pacientes;
    SELECT MAX(id) INTO max_cirugia_id FROM cirugias;
    
    WHILE i <= 1500 DO
        INSERT INTO notificaciones (contacto_id, paciente_id, cirugia_id, tipo, titulo, mensaje, leida)
        VALUES (
            (i % max_contacto_id) + 1,
            (i % max_paciente_id) + 1,
            IF(i % 2 = 0, (i % max_cirugia_id) + 1, NULL),
            CASE (i % 4)
                WHEN 0 THEN 'info_general' WHEN 1 THEN 'cambio_estado'
                WHEN 2 THEN 'info_general' ELSE 'alta_medica'
            END,
            CASE (i % 10)
                WHEN 0 THEN 'Actualización de estado del paciente'
                WHEN 1 THEN 'Cirugía programada confirmada'
                WHEN 2 THEN 'Paciente en recuperación'
                WHEN 3 THEN 'Alta médica programada'
                WHEN 4 THEN 'Cambio de estado post-operatorio'
                WHEN 5 THEN 'Actualización de evolución clínica'
                WHEN 6 THEN 'Signos vitales estables'
                WHEN 7 THEN 'Preparación para procedimiento'
                WHEN 8 THEN 'Visita médica realizada'
                ELSE 'Información importante para familiar'
            END,
            CASE (i % 12)
                WHEN 0 THEN 'Su familiar se encuentra estable y en recuperación favorable.'
                WHEN 1 THEN 'La cirugía ha sido programada exitosamente para la fecha indicada.'
                WHEN 2 THEN 'El paciente está respondiendo bien al tratamiento post-operatorio.'
                WHEN 3 THEN 'Se ha programado el alta médica. Por favor, comunicarse con el hospital.'
                WHEN 4 THEN 'Estado actualizado a post-operatorio. Evolución satisfactoria.'
                WHEN 5 THEN 'Última evaluación médica muestra mejora progresiva.'
                WHEN 6 THEN 'Signos vitales dentro de parámetros normales. Paciente estable.'
                WHEN 7 THEN 'Preparativos completados para el procedimiento quirúrgico.'
                WHEN 8 THEN 'El médico tratante ha realizado evaluación de rutina.'
                WHEN 9 THEN 'Se requiere firma de consentimiento informado.'
                WHEN 10 THEN 'Horario de visita disponible. Consulte restricciones vigentes.'
                ELSE 'Medicación ajustada según evolución. Sin complicaciones.'
            END,
            IF(i % 3 = 0, TRUE, FALSE)
        );
        
        SET i = i + 1;
    END WHILE;
END //
DELIMITER ;

CALL GenerarNotificaciones();
DROP PROCEDURE GenerarNotificaciones;

-- ========================================
-- VISTAS PARA REPORTES Y ANÁLISIS
-- ========================================

-- Vista de Pacientes Completa
CREATE VIEW vista_pacientes_completa AS
SELECT 
    p.id,
    p.nombre,
    p.apellido,
    p.cedula,
    p.fecha_nacimiento,
    TIMESTAMPDIFF(YEAR, p.fecha_nacimiento, CURDATE()) AS edad,
    p.sexo,
    p.direccion,
    p.telefono,
    p.email,
    p.eps,
    p.tipo_sangre,
    p.alergias,
    p.enfermedades_previas,
    p.medicamentos_actuales,
    p.contacto_emergencia,
    COUNT(DISTINCT c.id) AS total_cirugias,
    COUNT(DISTINCT co.id) AS total_contactos,
    MAX(c.fecha_programada) AS ultima_cirugia,
    p.activo,
    p.fecha_creacion
FROM pacientes p
LEFT JOIN cirugias c ON p.id = c.paciente_id
LEFT JOIN contactos co ON p.id = co.paciente_id
GROUP BY p.id;

-- Vista de Cirugías Detallada
CREATE VIEW vista_cirugias_detallada AS
SELECT 
    c.id,
    c.paciente_id,
    CONCAT(p.nombre, ' ', p.apellido) AS paciente_nombre,
    p.cedula AS paciente_cedula,
    TIMESTAMPDIFF(YEAR, p.fecha_nacimiento, CURDATE()) AS paciente_edad,
    p.sexo AS paciente_sexo,
    c.medico_principal_id,
    CONCAT(m.nombre, ' ', m.apellido) AS medico_nombre,
    e.nombre AS especialidad,
    c.tipo_cirugia_id,
    tc.nombre AS tipo_cirugia,
    tc.complejidad,
    c.fecha_programada,
    c.fecha_inicio,
    c.fecha_fin,
    CASE 
        WHEN c.fecha_fin IS NOT NULL AND c.fecha_inicio IS NOT NULL 
        THEN TIMESTAMPDIFF(MINUTE, c.fecha_inicio, c.fecha_fin)
        ELSE NULL
    END AS duracion_minutos,
    c.estado,
    c.quirofano,
    c.resultado,
    c.complicaciones,
    c.notas_preoperatorias,
    c.notas_transoperatorias,
    c.notas_postoperatorias,
    c.fecha_creacion
FROM cirugias c
JOIN pacientes p ON c.paciente_id = p.id
JOIN medicos m ON c.medico_principal_id = m.id
JOIN especialidades e ON m.especialidad_id = e.id
JOIN tipos_cirugia tc ON c.tipo_cirugia_id = tc.id;

-- Vista de Signos Vitales Resumen
CREATE VIEW vista_signos_vitales_resumen AS
SELECT 
    sv.paciente_id,
    CONCAT(p.nombre, ' ', p.apellido) AS paciente_nombre,
    p.cedula,
    DATE(sv.fecha_registro) AS fecha,
    COUNT(*) AS total_registros,
    AVG(sv.presion_sistolica) AS promedio_sistolica,
    AVG(sv.presion_diastolica) AS promedio_diastolica,
    AVG(sv.frecuencia_cardiaca) AS promedio_fc,
    AVG(sv.temperatura) AS promedio_temperatura,
    AVG(sv.saturacion_oxigeno) AS promedio_saturacion,
    AVG(sv.frecuencia_respiratoria) AS promedio_fr,
    AVG(sv.dolor_escala) AS promedio_dolor,
    MIN(sv.fecha_registro) AS primer_registro,
    MAX(sv.fecha_registro) AS ultimo_registro
FROM signos_vitales sv
JOIN pacientes p ON sv.paciente_id = p.id
GROUP BY sv.paciente_id, DATE(sv.fecha_registro);

-- Vista de Evoluciones Clínicas
CREATE VIEW vista_evoluciones_clinicas AS
SELECT 
    ec.id,
    ec.paciente_id,
    CONCAT(p.nombre, ' ', p.apellido) AS paciente_nombre,
    p.cedula AS paciente_cedula,
    ec.cirugia_id,
    ec.fecha_registro,
    ec.estado_general,
    ec.descripcion,
    ec.plan_tratamiento,
    ec.medicamentos,
    ec.restricciones,
    ec.observaciones_familiares,
    ec.proxima_evaluacion,
    CONCAT(m.nombre, ' ', m.apellido) AS medico_nombre,
    e.nombre AS especialidad_medico
FROM evoluciones_clinicas ec
JOIN pacientes p ON ec.paciente_id = p.id
JOIN medicos m ON ec.medico_id = m.id
JOIN especialidades e ON m.especialidad_id = e.id;

-- Vista de Códigos Familiares Activos
CREATE VIEW vista_codigos_activos AS
SELECT 
    cf.id,
    cf.codigo_paciente,
    cf.codigo_familiar,
    cf.paciente_id,
    CONCAT(p.nombre, ' ', p.apellido) AS paciente_nombre,
    p.cedula AS paciente_cedula,
    p.telefono AS paciente_telefono,
    cf.contacto_id,
    CONCAT(c.nombre, ' ', c.apellido) AS familiar_nombre,
    c.relacion,
    c.telefono AS familiar_telefono,
    c.email AS familiar_email,
    c.es_contacto_principal,
    c.puede_recibir_info_medica,
    cf.fecha_creacion,
    cf.fecha_expiracion,
    DATEDIFF(cf.fecha_expiracion, CURDATE()) AS dias_para_expirar,
    cf.activo
FROM codigos_familiares cf
JOIN pacientes p ON cf.paciente_id = p.id
JOIN contactos c ON cf.contacto_id = c.id
WHERE cf.activo = TRUE AND cf.fecha_expiracion > CURDATE();

-- Vista de Estadísticas Generales
CREATE VIEW vista_estadisticas_generales AS
SELECT 
    (SELECT COUNT(*) FROM pacientes WHERE activo = TRUE) AS total_pacientes,
    (SELECT COUNT(*) FROM medicos WHERE activo = TRUE) AS total_medicos,
    (SELECT COUNT(*) FROM cirugias WHERE estado = 'Programada') AS cirugias_programadas,
    (SELECT COUNT(*) FROM cirugias WHERE estado = 'En_proceso') AS cirugias_en_proceso,
    (SELECT COUNT(*) FROM cirugias WHERE estado = 'Finalizada') AS cirugias_finalizadas,
    (SELECT COUNT(*) FROM contactos) AS total_contactos,
    (SELECT COUNT(*) FROM codigos_familiares WHERE activo = TRUE) AS codigos_activos,
    (SELECT COUNT(*) FROM notificaciones WHERE leida = FALSE) AS notificaciones_pendientes;

-- Vista de Cirugías por Especialidad
CREATE VIEW vista_cirugias_por_especialidad AS
SELECT 
    e.id AS especialidad_id,
    e.nombre AS especialidad,
    COUNT(c.id) AS total_cirugias,
    SUM(CASE WHEN c.estado = 'Finalizada' THEN 1 ELSE 0 END) AS cirugias_finalizadas,
    SUM(CASE WHEN c.estado = 'Programada' THEN 1 ELSE 0 END) AS cirugias_programadas,
    SUM(CASE WHEN c.resultado = 'Exitosa' THEN 1 ELSE 0 END) AS cirugias_exitosas,
    AVG(CASE 
        WHEN c.fecha_fin IS NOT NULL AND c.fecha_inicio IS NOT NULL 
        THEN TIMESTAMPDIFF(MINUTE, c.fecha_inicio, c.fecha_fin)
        ELSE NULL
    END) AS duracion_promedio_minutos
FROM especialidades e
JOIN medicos m ON e.id = m.especialidad_id
JOIN cirugias c ON m.id = c.medico_principal_id
GROUP BY e.id, e.nombre;

-- Vista de Notificaciones Pendientes
CREATE VIEW vista_notificaciones_pendientes AS
SELECT 
    n.id,
    n.contacto_id,
    CONCAT(c.nombre, ' ', c.apellido) AS familiar_nombre,
    c.email AS familiar_email,
    c.telefono AS familiar_telefono,
    n.paciente_id,
    CONCAT(p.nombre, ' ', p.apellido) AS paciente_nombre,
    n.tipo,
    n.titulo,
    n.mensaje,
    n.fecha_envio,
    TIMESTAMPDIFF(HOUR, n.fecha_envio, NOW()) AS horas_desde_envio
FROM notificaciones n
JOIN contactos c ON n.contacto_id = c.id
JOIN pacientes p ON n.paciente_id = p.id
WHERE n.leida = FALSE
ORDER BY n.fecha_envio DESC;

-- ========================================
-- TRIGGERS PARA AUDITORÍA
-- ========================================

-- Trigger para auditoría de pacientes
DELIMITER //
CREATE TRIGGER auditoria_pacientes_update
AFTER UPDATE ON pacientes
FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla_afectada, id_registro, accion, usuario_id, datos_anteriores, datos_nuevos)
    VALUES (
        'pacientes',
        NEW.id,
        'UPDATE',
        1, -- Usuario del sistema
        JSON_OBJECT(
            'nombre', OLD.nombre,
            'apellido', OLD.apellido,
            'telefono', OLD.telefono,
            'email', OLD.email,
            'direccion', OLD.direccion
        ),
        JSON_OBJECT(
            'nombre', NEW.nombre,
            'apellido', NEW.apellido,
            'telefono', NEW.telefono,
            'email', NEW.email,
            'direccion', NEW.direccion
        )
    );
END //
DELIMITER ;

-- Trigger para auditoría de cirugías
DELIMITER //
CREATE TRIGGER auditoria_cirugias_update
AFTER UPDATE ON cirugias
FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla_afectada, id_registro, accion, usuario_id, datos_anteriores, datos_nuevos)
    VALUES (
        'cirugias',
        NEW.id,
        'UPDATE',
        1,
        JSON_OBJECT(
            'estado', OLD.estado,
            'fecha_inicio', OLD.fecha_inicio,
            'fecha_fin', OLD.fecha_fin,
            'resultado', OLD.resultado
        ),
        JSON_OBJECT(
            'estado', NEW.estado,
            'fecha_inicio', NEW.fecha_inicio,
            'fecha_fin', NEW.fecha_fin,
            'resultado', NEW.resultado
        )
    );
END //
DELIMITER ;

-- ========================================
-- DATOS DE VALIDACIÓN
-- ========================================

-- Verificar totales
SELECT 
    'Pacientes' AS tabla, 
    COUNT(*) AS total,
    SUM(CASE WHEN activo = TRUE THEN 1 ELSE 0 END) AS activos
FROM pacientes
UNION ALL
SELECT 
    'Contactos' AS tabla, 
    COUNT(*) AS total,
    COUNT(*) AS activos
FROM contactos
UNION ALL
SELECT 
    'Códigos Familiares' AS tabla, 
    COUNT(*) AS total,
    SUM(CASE WHEN activo = TRUE THEN 1 ELSE 0 END) AS activos
FROM codigos_familiares
UNION ALL
SELECT 
    'Cirugías' AS tabla, 
    COUNT(*) AS total,
    SUM(CASE WHEN estado != 'Cancelada' THEN 1 ELSE 0 END) AS activos
FROM cirugias
UNION ALL
SELECT 
    'Signos Vitales' AS tabla, 
    COUNT(*) AS total,
    COUNT(*) AS activos
FROM signos_vitales
UNION ALL
SELECT 
    'Evoluciones Clínicas' AS tabla, 
    COUNT(*) AS total,
    COUNT(*) AS activos
FROM evoluciones_clinicas
UNION ALL
SELECT 
    'Notificaciones' AS tabla, 
    COUNT(*) AS total,
    SUM(CASE WHEN leida = FALSE THEN 1 ELSE 0 END) AS pendientes
FROM notificaciones;

-- ========================================
-- SCRIPT COMPLETADO
-- ========================================

COMMIT;

SELECT '✅ Base de datos SIACOM creada exitosamente!' AS mensaje;
SELECT '📊 Total de registros generados:' AS mensaje;
SELECT * FROM vista_estadisticas_generales;