-- ============================================
-- SISTEMA DE TICKETS DE SOPORTE IT
-- Autor: Leidy Diana Principe Quispe
-- ============================================

-- CREACIÓN DE TABLAS
CREATE TABLE usuarios (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre VARCHAR(100) NOT NULL,
    departamento VARCHAR(50) NOT NULL,
    rol VARCHAR(30) NOT NULL,
    email VARCHAR(100) UNIQUE
);

CREATE TABLE agentes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre VARCHAR(100) NOT NULL,
    especialidad VARCHAR(50) NOT NULL,
    nivel VARCHAR(20) CHECK (nivel IN ('Junior', 'Semi-Senior', 'Senior'))
);

CREATE TABLE tickets (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    usuario_id INTEGER NOT NULL,
    titulo VARCHAR(200) NOT NULL,
    descripcion TEXT,
    prioridad VARCHAR(10) CHECK (prioridad IN ('Alta', 'Media', 'Baja')),
    estado VARCHAR(15) DEFAULT 'Abierto' CHECK (estado IN ('Abierto', 'En Proceso', 'Resuelto', 'Cerrado')),
    fecha_creacion DATE DEFAULT (date('now')),
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
);

CREATE TABLE asignaciones_ticket (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    ticket_id INTEGER NOT NULL,
    agente_id INTEGER NOT NULL,
    fecha_asignacion DATE DEFAULT (date('now')),
    FOREIGN KEY (ticket_id) REFERENCES tickets(id),
    FOREIGN KEY (agente_id) REFERENCES agentes(id)
);

CREATE TABLE historial_estados (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    ticket_id INTEGER NOT NULL,
    estado_anterior VARCHAR(15),
    estado_nuevo VARCHAR(15) NOT NULL,
    fecha_cambio DATE DEFAULT (date('now')),
    FOREIGN KEY (ticket_id) REFERENCES tickets(id)
);



-- Usuarios
INSERT INTO usuarios (nombre, departamento, rol, email) VALUES
('Carlos Mendoza', 'Ventas', 'Ejecutivo', 'carlos.m@empresa.com'),
('María Torres', 'Contabilidad', 'Analista', 'maria.t@empresa.com'),
('José Rivera', 'Recursos Humanos', 'Coordinador', 'jose.r@empresa.com'),
('Ana Castillo', 'Marketing', 'Diseñadora', 'ana.c@empresa.com'),
('Luis Sánchez', 'Logística', 'Supervisor', 'luis.s@empresa.com'),
('Diana Principe', 'TI', 'Ciberseguridad', 'dprincipe.q@gmail.com');

-- Agentes de soporte
INSERT INTO agentes (nombre, especialidad, nivel) VALUES
('Pedro López', 'Redes', 'Senior'),
('Carmen Díaz', 'Software', 'Semi-Senior'),
('Roberto Vega', 'Hardware', 'Junior'),
('Sofía Ramos', 'Ciberseguridad', 'Senior');

-- Tickets
INSERT INTO tickets (usuario_id, titulo, descripcion, prioridad, estado, fecha_creacion) VALUES
(1, 'No puedo acceder al CRM', 'Sale error 403 al ingresar', 'Alta', 'Abierto', '2026-04-20'),
(2, 'Impresora no funciona', 'No imprime desde ayer', 'Media', 'En Proceso', '2026-04-19'),
(3, 'Olvidé mi contraseña', 'Necesito resetear contraseña del sistema', 'Baja', 'Resuelto', '2026-04-18'),
(4, 'Photoshop se cierra solo', 'Al abrir archivos grandes', 'Media', 'Abierto', '2026-04-21'),
(1, 'VPN no conecta', 'Error de autenticación', 'Alta', 'Cerrado', '2026-04-17'),
(5, 'Página web caída', 'Error 500 en el sitio', 'Alta', 'En Proceso', '2026-04-22'),
(6, 'Posible phishing detectado', 'Reporte de correo sospechoso', 'Alta', 'Abierto', '2026-04-23');

-- Asignaciones
INSERT INTO asignaciones_ticket (ticket_id, agente_id, fecha_asignacion) VALUES
(1, 1, '2026-04-20'),
(2, 3, '2026-04-19'),
(3, 2, '2026-04-18'),
(4, 2, '2026-04-21'),
(5, 1, '2026-04-17'),
(6, 4, '2026-04-22'),
(7, 4, '2026-04-23');

-- Historial de estados
INSERT INTO historial_estados (ticket_id, estado_anterior, estado_nuevo, fecha_cambio) VALUES
(1, NULL, 'Abierto', '2026-04-20'),
(2, NULL, 'Abierto', '2026-04-19'),
(2, 'Abierto', 'En Proceso', '2026-04-20'),
(3, NULL, 'Abierto', '2026-04-18'),
(3, 'Abierto', 'En Proceso', '2026-04-18'),
(3, 'En Proceso', 'Resuelto', '2026-04-19'),
(5, NULL, 'Abierto', '2026-04-17'),
(5, 'Abierto', 'En Proceso', '2026-04-17'),
(5, 'En Proceso', 'Cerrado', '2026-04-18'),
(7, NULL, 'Abierto', '2026-04-23');


-- CONSULTAS SQL 


-- 1. Tickets abiertos agrupados por prioridad
SELECT prioridad, COUNT(*) as cantidad
FROM tickets
WHERE estado IN ('Abierto', 'En Proceso')
GROUP BY prioridad
ORDER BY cantidad DESC;

-- 2. Agentes con más tickets resueltos en abril 2026
SELECT a.nombre, a.especialidad, COUNT(t.id) as tickets_resueltos
FROM agentes a
JOIN asignaciones_ticket at ON a.id = at.agente_id
JOIN tickets t ON at.ticket_id = t.id
WHERE t.estado IN ('Resuelto', 'Cerrado')
  AND t.fecha_creacion BETWEEN '2026-04-01' AND '2026-04-30'
GROUP BY a.nombre, a.especialidad
ORDER BY tickets_resueltos DESC;

-- 3. Tiempo promedio de resolución por agente (en días)
SELECT a.nombre,
       ROUND(AVG(julianday(h.fecha_cambio) - julianday(t.fecha_creacion)), 1) as dias_promedio_resolucion
FROM agentes a
JOIN asignaciones_ticket at ON a.id = at.agente_id
JOIN tickets t ON at.ticket_id = t.id
JOIN historial_estados h ON t.id = h.ticket_id
WHERE h.estado_nuevo IN ('Resuelto', 'Cerrado')
GROUP BY a.nombre
ORDER BY dias_promedio_resolucion ASC;

-- 4. Departamentos con más tickets reportados
SELECT u.departamento, COUNT(t.id) as total_tickets
FROM usuarios u
JOIN tickets t ON u.id = t.usuario_id
GROUP BY u.departamento
ORDER BY total_tickets DESC;

-- 5. Tickets que involucran a Ciberseguridad (Diana)
SELECT t.titulo, t.prioridad, t.estado, a.nombre as agente_asignado
FROM tickets t
JOIN usuarios u ON t.usuario_id = u.id
LEFT JOIN asignaciones_ticket at ON t.id = at.ticket_id
LEFT JOIN agentes a ON at.agente_id = a.id
WHERE a.especialidad = 'Ciberseguridad' OR u.rol = 'Ciberseguridad'
ORDER BY t.fecha_creacion DESC;

-- 6. Vista consolidada de tickets con toda la información
SELECT 
    t.id as ticket_id,
    t.titulo,
    t.prioridad,
    t.estado,
    u.nombre as reportado_por,
    u.departamento,
    a.nombre as agente_asignado,
    a.especialidad,
    t.fecha_creacion
FROM tickets t
JOIN usuarios u ON t.usuario_id = u.id
LEFT JOIN asignaciones_ticket at ON t.id = at.ticket_id
LEFT JOIN agentes a ON at.agente_id = a.id
ORDER BY t.fecha_creacion DESC;