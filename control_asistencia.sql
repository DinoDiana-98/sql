-- ============================================
-- SISTEMA DE CONTROL DE ASISTENCIA
-- Autor: Leidy Diana Principe Quispe
-- ============================================

-- CREACIÓN DE TABLAS
CREATE TABLE empleados (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre VARCHAR(100) NOT NULL,
    dni VARCHAR(8) UNIQUE NOT NULL,
    area VARCHAR(50) NOT NULL,
    cargo VARCHAR(50) NOT NULL,
    fecha_ingreso DATE NOT NULL,
    estado VARCHAR(15) DEFAULT 'Activo' CHECK (estado IN ('Activo', 'Inactivo', 'Vacaciones'))
);

CREATE TABLE proyectos (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre VARCHAR(150) NOT NULL,
    ubicacion VARCHAR(200),
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE,
    estado VARCHAR(20) DEFAULT 'En Curso' CHECK (estado IN ('En Curso', 'Finalizado', 'Suspendido'))
);

CREATE TABLE asignaciones (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    empleado_id INTEGER NOT NULL,
    proyecto_id INTEGER NOT NULL,
    rol VARCHAR(50) NOT NULL,
    fecha_asignacion DATE DEFAULT (date('now')),
    FOREIGN KEY (empleado_id) REFERENCES empleados(id),
    FOREIGN KEY (proyecto_id) REFERENCES proyectos(id)
);

CREATE TABLE asistencias (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    empleado_id INTEGER NOT NULL,
    fecha DATE NOT NULL,
    hora_entrada TIME,
    hora_salida TIME,
    tipo_jornada VARCHAR(15) DEFAULT 'Completa' CHECK (tipo_jornada IN ('Completa', 'Media', 'Extra')),
    observaciones TEXT,
    FOREIGN KEY (empleado_id) REFERENCES empleados(id)
);

CREATE TABLE faltas (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    empleado_id INTEGER NOT NULL,
    fecha DATE NOT NULL,
    tipo VARCHAR(15) CHECK (tipo IN ('Justificada', 'Injustificada')),
    motivo TEXT,
    FOREIGN KEY (empleado_id) REFERENCES empleados(id)
);


-- INSERCIÓN DE DATOS DE PRUEBA

-- Empleados
INSERT INTO empleados (nombre, dni, area, cargo, fecha_ingreso) VALUES
('Leidy Principe', '73267603', 'Tecnología', 'Especialista Ciberseguridad', '2023-11-15'),
('Carlos Mendoza', '12345678', 'Construcción', 'Ingeniero Civil', '2022-03-10'),
('María Torres', '23456789', 'Administración', 'Contadora', '2021-08-22'),
('José Rivera', '34567890', 'Recursos Humanos', 'Coordinador', '2023-01-15'),
('Luis Sánchez', '45678901', 'Logística', 'Supervisor', '2022-06-01'),
('Ana Castillo', '56789012', 'Tecnología', 'Desarrolladora', '2024-01-10');

-- Proyectos
INSERT INTO proyectos (nombre, ubicacion, fecha_inicio, fecha_fin, estado) VALUES
('Edificio Las Palmeras', 'Trujillo, Av. Larco 123', '2025-06-01', NULL, 'En Curso'),
('Colegio Bicentenario', 'Trujillo, Urb. Primavera', '2024-01-15', '2025-12-20', 'Finalizado'),
('Centro Comercial Norte', 'Chiclayo, Panamericana Norte', '2026-01-10', NULL, 'En Curso');

-- Asignaciones
INSERT INTO asignaciones (empleado_id, proyecto_id, rol) VALUES
(1, 1, 'Seguridad de la Información'),
(1, 2, 'Soporte Tecnológico'),
(2, 1, 'Ingeniero Residente'),
(2, 3, 'Supervisor de Obra'),
(3, 1, 'Administradora de Proyecto'),
(4, 2, 'Reclutamiento'),
(5, 3, 'Jefe de Logística'),
(6, 1, 'Desarrollo App Control Asistencia');

-- Asistencias (últimos 5 días)
INSERT INTO asistencias (empleado_id, fecha, hora_entrada, hora_salida, tipo_jornada, observaciones) VALUES
(1, '2026-04-21', '07:55', '17:05', 'Completa', 'Puntual'),
(1, '2026-04-22', '08:10', '17:00', 'Completa', 'Leve retraso'),
(1, '2026-04-23', '07:50', '18:30', 'Extra', 'Horas extra por escaneo seguridad'),
(2, '2026-04-21', '08:00', '17:00', 'Completa', 'Puntual'),
(2, '2026-04-22', '08:30', '17:00', 'Completa', 'Retraso 30 min'),
(2, '2026-04-23', '07:55', '17:05', 'Completa', 'Puntual'),
(3, '2026-04-21', '08:00', '16:30', 'Media', 'Cita médica'),
(3, '2026-04-22', '08:00', '17:00', 'Completa', 'Puntual'),
(3, '2026-04-23', '08:05', '17:00', 'Completa', 'Puntual'),
(6, '2026-04-21', '08:00', '17:00', 'Completa', 'Desarrollo de app'),
(6, '2026-04-22', '08:00', '18:00', 'Extra', 'Testing de geolocalización'),
(6, '2026-04-23', '08:00', '17:00', 'Completa', 'Puntual');

-- Faltas
INSERT INTO faltas (empleado_id, fecha, tipo, motivo) VALUES
(4, '2026-04-21', 'Justificada', 'Cita médica con descanso'),
(5, '2026-04-22', 'Injustificada', NULL);


-- CONSULTAS SQL

-- 1. Empleados con más de 2 retrasos en abril 2026 (entrada después de 08:15)
SELECT e.nombre, e.area, COUNT(a.id) as total_retrasos
FROM empleados e
JOIN asistencias a ON e.id = a.empleado_id
WHERE a.hora_entrada > '08:15'
  AND a.fecha BETWEEN '2026-04-01' AND '2026-04-30'
GROUP BY e.nombre, e.area
HAVING COUNT(a.id) >= 2
ORDER BY total_retrasos DESC;

-- 2. Horas trabajadas por empleado en abril 2026
SELECT e.nombre, e.area,
       COUNT(a.id) as dias_trabajados,
       SUM(CAST((julianday(a.fecha || ' ' || a.hora_salida) - julianday(a.fecha || ' ' || a.hora_entrada)) * 24 AS INTEGER)) as horas_totales
FROM empleados e
JOIN asistencias a ON e.id = a.empleado_id
WHERE a.fecha BETWEEN '2026-04-01' AND '2026-04-30'
GROUP BY e.nombre, e.area
ORDER BY horas_totales DESC;

-- 3. Proyectos con más personal asignado
SELECT p.nombre, p.ubicacion, COUNT(a.id) as total_personal
FROM proyectos p
JOIN asignaciones a ON p.id = a.proyecto_id
WHERE p.estado = 'En Curso'
GROUP BY p.nombre, p.ubicacion
ORDER BY total_personal DESC;

-- 4. Ausentismo por empleado (faltas del mes)
SELECT e.nombre, e.area,
       COUNT(f.id) as total_faltas,
       SUM(CASE WHEN f.tipo = 'Injustificada' THEN 1 ELSE 0 END) as injustificadas,
       SUM(CASE WHEN f.tipo = 'Justificada' THEN 1 ELSE 0 END) as justificadas
FROM empleados e
LEFT JOIN faltas f ON e.id = f.empleado_id AND f.fecha BETWEEN '2026-04-01' AND '2026-04-30'
GROUP BY e.nombre, e.area
ORDER BY total_faltas DESC;

-- 5. Vista completa de asistencia del día actual
SELECT e.nombre as empleado,
       e.area,
       e.cargo,
       a.hora_entrada,
       a.hora_salida,
       a.tipo_jornada,
       CASE 
           WHEN a.hora_entrada > '08:15' THEN 'RETRASO'
           WHEN a.hora_entrada IS NULL THEN 'NO REGISTRADO'
           ELSE 'PUNTUAL'
       END as estado_asistencia,
       p.nombre as proyecto_actual
FROM empleados e
LEFT JOIN asistencias a ON e.id = a.empleado_id AND a.fecha = date('now')
LEFT JOIN asignaciones ag ON e.id = ag.empleado_id
LEFT JOIN proyectos p ON ag.proyecto_id = p.id AND p.estado = 'En Curso'
WHERE e.estado = 'Activo'
ORDER BY e.area, e.nombre;