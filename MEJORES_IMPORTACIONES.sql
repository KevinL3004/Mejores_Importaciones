-- Tabla Persona
CREATE TABLE Persona (
    codigo NUMBER PRIMARY KEY,
    nombre1 VARCHAR2(50),
    nombre2 VARCHAR2(50),
    apellido1 VARCHAR2(50),
    apellido2 VARCHAR2(50),
    fecha_nacimiento DATE,
    correo_electronico VARCHAR2(100),
    telefono VARCHAR2(20)
);

-- Tabla Expediente
CREATE TABLE Expediente (
    numero NUMBER PRIMARY KEY,
    fecha DATE,
    descripcion VARCHAR2(200),
    codigo_persona_registro NUMBER,
    FOREIGN KEY (codigo_persona_registro) REFERENCES Persona(codigo)
);

-- Tabla Expediente_Persona (para la relación muchos a muchos entre Expediente y Persona)
CREATE TABLE Expediente_Persona (
    numero_expediente NUMBER,
    codigo_persona NUMBER,
    PRIMARY KEY (numero_expediente, codigo_persona),
    FOREIGN KEY (numero_expediente) REFERENCES Expediente(numero),
    FOREIGN KEY (codigo_persona) REFERENCES Persona(codigo)
);

-- Tabla Documento
CREATE TABLE Documento (
    codigo NUMBER PRIMARY KEY,
    numero_expediente NUMBER,
    descripcion VARCHAR2(200),
    valor_economico NUMBER(10,2),
    estado VARCHAR2(10) CHECK (estado IN ('activo', 'inactivo')),
    usuario_adicion VARCHAR2(50),
    FOREIGN KEY (numero_expediente) REFERENCES Expediente(numero)
);

-- Insertar datos de ejemplo

-- Insertar personas
INSERT INTO Persona VALUES (1, 'Juan', 'Carlos', 'Pérez', 'Gómez', TO_DATE('1990-05-15', 'YYYY-MM-DD'), 'juan@email.com', '123456789');
INSERT INTO Persona VALUES (2, 'María', 'Elena', 'López', 'Rodríguez', TO_DATE('1985-08-20', 'YYYY-MM-DD'), 'maria@email.com', '987654321');
INSERT INTO Persona VALUES (3, 'Pedro', 'Luis', 'González', 'Martínez', TO_DATE('1992-03-10', 'YYYY-MM-DD'), 'pedro@email.com', '456789123');

-- Insertar expedientes
INSERT INTO Expediente VALUES (1, TO_DATE('2024-09-19', 'YYYY-MM-DD'), 'Expediente 1', 1);
INSERT INTO Expediente VALUES (2, TO_DATE('2024-09-20', 'YYYY-MM-DD'), 'Expediente 2', 2);
INSERT INTO Expediente VALUES (3, TO_DATE('2024-09-21', 'YYYY-MM-DD'), 'Expediente 3', 3);
INSERT INTO Expediente VALUES (4, TO_DATE('2024-09-22', 'YYYY-MM-DD'), 'Expediente 4', 1);
INSERT INTO Expediente VALUES (5, TO_DATE('2024-09-23', 'YYYY-MM-DD'), 'Expediente 5', 2);
INSERT INTO Expediente VALUES (6, TO_DATE('2024-09-24', 'YYYY-MM-DD'), 'Expediente 6', 3);
INSERT INTO Expediente VALUES (7, TO_DATE('2024-09-25', 'YYYY-MM-DD'), 'Expediente 7', 1);
INSERT INTO Expediente VALUES (8, TO_DATE('2024-09-26', 'YYYY-MM-DD'), 'Expediente 8', 2);
INSERT INTO Expediente VALUES (9, TO_DATE('2024-09-27', 'YYYY-MM-DD'), 'Expediente 9', 3);
INSERT INTO Expediente VALUES (10, TO_DATE('2024-09-28', 'YYYY-MM-DD'), 'Expediente 10', 1);

-- Asociar expedientes con personas
INSERT INTO Expediente_Persona VALUES (1, 1);
INSERT INTO Expediente_Persona VALUES (1, 2);
INSERT INTO Expediente_Persona VALUES (2, 2);
INSERT INTO Expediente_Persona VALUES (3, 3);
INSERT INTO Expediente_Persona VALUES (4, 1);
INSERT INTO Expediente_Persona VALUES (5, 2);
INSERT INTO Expediente_Persona VALUES (6, 3);
INSERT INTO Expediente_Persona VALUES (7, 1);
INSERT INTO Expediente_Persona VALUES (8, 2);
INSERT INTO Expediente_Persona VALUES (9, 3);
INSERT INTO Expediente_Persona VALUES (10, 1);

-- Insertar documentos
INSERT INTO Documento VALUES (1, 1, 'Documento 1 Exp 1', 1000.00, 'activo', 'usuario1');
INSERT INTO Documento VALUES (2, 1, 'Documento 2 Exp 1', 2000.00, 'activo', 'usuario1');
INSERT INTO Documento VALUES (3, 1, 'Documento 3 Exp 1', 3000.00, 'inactivo', 'usuario2');
INSERT INTO Documento VALUES (4, 2, 'Documento 1 Exp 2', 1500.00, 'activo', 'usuario2');
INSERT INTO Documento VALUES (5, 2, 'Documento 2 Exp 2', 2500.00, 'activo', 'usuario2');
INSERT INTO Documento VALUES (6, 3, 'Documento 1 Exp 3', 3500.00, 'activo', 'usuario3');
INSERT INTO Documento VALUES (7, 3, 'Documento 2 Exp 3', 4500.00, 'inactivo', 'usuario3');
INSERT INTO Documento VALUES (8, 3, 'Documento 3 Exp 3', 5500.00, 'activo', 'usuario3');
-- Continuar insertando documentos para los demás expedientes...

-- Consulta para contar documentos por expediente
SELECT e.numero AS numero_expediente, e.descripcion, COUNT(d.codigo) AS cantidad_documentos
FROM Expediente e
LEFT JOIN Documento d ON e.numero = d.numero_expediente
GROUP BY e.numero, e.descripcion
ORDER BY e.numero;

-- Consulta para contar expedientes por persona
SELECT p.codigo AS codigo_persona, p.nombre1 || ' ' || p.apellido1 AS nombre_persona, COUNT(ep.numero_expediente) AS cantidad_expedientes
FROM Persona p
LEFT JOIN Expediente_Persona ep ON p.codigo = ep.codigo_persona
GROUP BY p.codigo, p.nombre1, p.apellido1
ORDER BY p.codigo;

-- Consulta Valor total de documentos activos por expediente
SELECT 
    e.numero AS numero_expediente,
    e.descripcion AS descripcion_expediente,
    COUNT(d.codigo) AS total_documentos,
    COUNT(CASE WHEN d.estado = 'activo' THEN 1 END) AS documentos_activos,
    SUM(CASE WHEN d.estado = 'activo' THEN d.valor_economico ELSE 0 END) AS valor_total_activos
FROM 
    Expediente e
LEFT JOIN 
    Documento d ON e.numero = d.numero_expediente
GROUP BY 
    e.numero, e.descripcion
ORDER BY 
    valor_total_activos DESC;

-- Consulta Personas con más de un expediente y sus documentos asociados
SELECT 
    p.codigo AS codigo_persona,
    p.nombre1 || ' ' || p.apellido1 AS nombre_persona,
    COUNT(DISTINCT ep.numero_expediente) AS cantidad_expedientes,
    COUNT(d.codigo) AS total_documentos,
    SUM(d.valor_economico) AS valor_total_documentos
FROM 
    Persona p
JOIN 
    Expediente_Persona ep ON p.codigo = ep.codigo_persona
JOIN 
    Expediente e ON ep.numero_expediente = e.numero
LEFT JOIN 
    Documento d ON e.numero = d.numero_expediente
GROUP BY 
    p.codigo, p.nombre1, p.apellido1
HAVING 
    COUNT(DISTINCT ep.numero_expediente) > 1
ORDER BY 
    cantidad_expedientes DESC, valor_total_documentos DESC;