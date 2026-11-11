CREATE DATABASE BoticaDB_Proyecto;
GO

USE BoticaDB_Proyecto;
GO

-- Tabla: CATEGORIA
CREATE TABLE CATEGORIA (
    id_categoria  INT IDENTITY(1,1) NOT NULL,
    nombre        VARCHAR(50)       NOT NULL,
    CONSTRAINT PK_CATEGORIA PRIMARY KEY (id_categoria),
    CONSTRAINT UQ_CATEGORIA_nombre UNIQUE (nombre)
);
GO

-- Tabla: MARCA
CREATE TABLE MARCA (
    id_marca  INT IDENTITY(1,1) NOT NULL,
    nombre    VARCHAR(80)       NOT NULL,
    CONSTRAINT PK_MARCA PRIMARY KEY (id_marca),
    CONSTRAINT UQ_MARCA_nombre UNIQUE (nombre)
);
GO

-- Tabla: PROVEEDOR
CREATE TABLE PROVEEDOR (
    id_proveedor  INT IDENTITY(1,1) NOT NULL,
    ruc           CHAR(11)          NOT NULL,
    razon_social  VARCHAR(100)      NOT NULL,
    telefono      VARCHAR(15)       NULL,
    direccion     VARCHAR(150)      NULL,
    CONSTRAINT PK_PROVEEDOR PRIMARY KEY (id_proveedor),
    CONSTRAINT UQ_PROVEEDOR_ruc UNIQUE (ruc)
);
GO

-- Tabla: MEDIO_PAGO
CREATE TABLE MEDIO_PAGO (
    id_medio_pago      INT IDENTITY(1,1) NOT NULL,
    nombre_medio_pago  VARCHAR(20)       NOT NULL,
    CONSTRAINT PK_MEDIO_PAGO PRIMARY KEY (id_medio_pago),
    CONSTRAINT UQ_MEDIO_PAGO_nombre UNIQUE (nombre_medio_pago)
);
GO

-- Tabla: PERSONA (tabla padre de CLIENTE y EMPLEADO)
CREATE TABLE PERSONA (
    id_persona        INT IDENTITY(1,1) NOT NULL,
    dni               CHAR(8)           NOT NULL,
    nombres           VARCHAR(100)      NOT NULL,
    apellido_paterno  VARCHAR(50)       NOT NULL,
    apellido_materno  VARCHAR(50)       NULL,
    telefono          VARCHAR(15)       NULL,
    CONSTRAINT PK_PERSONA PRIMARY KEY (id_persona),
    CONSTRAINT UQ_PERSONA_dni UNIQUE (dni)
);
GO

-- Tabla: CLIENTE
CREATE TABLE CLIENTE (
    id_cliente  INT IDENTITY(1,1) NOT NULL,
    id_persona  INT               NOT NULL,
    direccion   VARCHAR(150)      NULL,
    CONSTRAINT PK_CLIENTE PRIMARY KEY (id_cliente),
    CONSTRAINT FK_CLIENTE_PERSONA FOREIGN KEY (id_persona) REFERENCES PERSONA (id_persona),
    CONSTRAINT UQ_CLIENTE_persona UNIQUE (id_persona)
);
GO

-- Tabla: EMPLEADO
CREATE TABLE EMPLEADO (
    id_empleado  INT IDENTITY(1,1) NOT NULL,
    id_persona   INT               NOT NULL,
    cargo        VARCHAR(50)       NOT NULL,
    CONSTRAINT PK_EMPLEADO PRIMARY KEY (id_empleado),
    CONSTRAINT FK_EMPLEADO_PERSONA FOREIGN KEY (id_persona) REFERENCES PERSONA (id_persona),
    CONSTRAINT UQ_EMPLEADO_persona UNIQUE (id_persona)
);
GO

-- Tabla: PRODUCTO
CREATE TABLE PRODUCTO (
    id_producto      INT IDENTITY(1,1) NOT NULL,
    id_categoria     INT               NOT NULL,
    id_marca         INT               NOT NULL,
    nombre           VARCHAR(100)      NOT NULL,
    descripcion      VARCHAR(200)      NULL,
    presentacion     VARCHAR(50)       NOT NULL,
    concentracion    VARCHAR(30)       NULL,
    precio_venta     DECIMAL(10,2)     NOT NULL,
    requiere_receta  BIT               NOT NULL,
    stock_minimo     INT               NOT NULL,
    CONSTRAINT PK_PRODUCTO PRIMARY KEY (id_producto),
    CONSTRAINT FK_PRODUCTO_CATEGORIA FOREIGN KEY (id_categoria) REFERENCES CATEGORIA (id_categoria),
    CONSTRAINT FK_PRODUCTO_MARCA FOREIGN KEY (id_marca) REFERENCES MARCA (id_marca),
    CONSTRAINT CK_PRODUCTO_precio CHECK (precio_venta > 0),
    CONSTRAINT CK_PRODUCTO_stock_minimo CHECK (stock_minimo >= 0)
);
GO

-- Tabla: LOTE
CREATE TABLE LOTE (
    id_lote            INT IDENTITY(1,1) NOT NULL,
    id_producto        INT               NOT NULL,
    nro_lote           VARCHAR(50)       NOT NULL,
    fecha_vencimiento  DATE              NOT NULL,
    stock              INT               NOT NULL,
    CONSTRAINT PK_LOTE PRIMARY KEY (id_lote),
    CONSTRAINT FK_LOTE_PRODUCTO FOREIGN KEY (id_producto) REFERENCES PRODUCTO (id_producto),
    CONSTRAINT UQ_LOTE_producto_nro UNIQUE (id_producto, nro_lote),
    CONSTRAINT CK_LOTE_stock CHECK (stock >= 0)
);
GO

-- Tabla: COMPRA
CREATE TABLE COMPRA (
    id_compra     INT IDENTITY(1,1) NOT NULL,
    id_proveedor  INT               NOT NULL,
    id_empleado   INT               NOT NULL,
    fecha         DATETIME          NOT NULL CONSTRAINT DF_COMPRA_fecha DEFAULT GETDATE(),
    total         DECIMAL(10,2)     NOT NULL,
    CONSTRAINT PK_COMPRA PRIMARY KEY (id_compra),
    CONSTRAINT FK_COMPRA_PROVEEDOR FOREIGN KEY (id_proveedor) REFERENCES PROVEEDOR (id_proveedor),
    CONSTRAINT FK_COMPRA_EMPLEADO FOREIGN KEY (id_empleado) REFERENCES EMPLEADO (id_empleado),
    CONSTRAINT CK_COMPRA_total CHECK (total >= 0)
);
GO

-- Tabla: DETALLE_COMPRA
CREATE TABLE DETALLE_COMPRA (
    id_detalle_compra       INT IDENTITY(1,1) NOT NULL,
    id_compra               INT               NOT NULL,
    id_producto             INT               NOT NULL,
    cantidad                INT               NOT NULL,
    precio_compra_unitario  DECIMAL(10,2)     NOT NULL,
    CONSTRAINT PK_DETALLE_COMPRA PRIMARY KEY (id_detalle_compra),
    CONSTRAINT FK_DETCOMPRA_COMPRA FOREIGN KEY (id_compra) REFERENCES COMPRA (id_compra),
    CONSTRAINT FK_DETCOMPRA_PRODUCTO FOREIGN KEY (id_producto) REFERENCES PRODUCTO (id_producto),
    CONSTRAINT CK_DETCOMPRA_cantidad CHECK (cantidad > 0),
    CONSTRAINT CK_DETCOMPRA_precio CHECK (precio_compra_unitario > 0)
);
GO

-- Tabla: VENTA
CREATE TABLE VENTA (
    id_venta          INT IDENTITY(1,1) NOT NULL,
    id_cliente        INT               NULL,
    id_empleado       INT               NOT NULL,
    id_medio_pago     INT               NOT NULL,
    fecha             DATETIME          NOT NULL CONSTRAINT DF_VENTA_fecha DEFAULT GETDATE(),
    tipo_comprobante  VARCHAR(30)       NOT NULL,
    nro_comprobante   VARCHAR(20)       NOT NULL,
    total             DECIMAL(10,2)     NOT NULL,
    CONSTRAINT PK_VENTA PRIMARY KEY (id_venta),
    CONSTRAINT FK_VENTA_CLIENTE FOREIGN KEY (id_cliente) REFERENCES CLIENTE (id_cliente),
    CONSTRAINT FK_VENTA_EMPLEADO FOREIGN KEY (id_empleado) REFERENCES EMPLEADO (id_empleado),
    CONSTRAINT FK_VENTA_MEDIO_PAGO FOREIGN KEY (id_medio_pago) REFERENCES MEDIO_PAGO (id_medio_pago),
    CONSTRAINT UQ_VENTA_nro_comprobante UNIQUE (nro_comprobante),
    CONSTRAINT CK_VENTA_tipo CHECK (tipo_comprobante IN ('Boleta', 'Nota de Venta')),
    CONSTRAINT CK_VENTA_total CHECK (total >= 0)
);
GO

-- Tabla: DETALLE_VENTA
CREATE TABLE DETALLE_VENTA (
    id_detalle_venta  INT IDENTITY(1,1) NOT NULL,
    id_venta          INT               NOT NULL,
    id_producto       INT               NOT NULL,
    cantidad          INT               NOT NULL,
    precio_unitario   DECIMAL(10,2)     NOT NULL,
    subtotal          DECIMAL(10,2)     NOT NULL,
    CONSTRAINT PK_DETALLE_VENTA PRIMARY KEY (id_detalle_venta),
    CONSTRAINT FK_DETVENTA_VENTA FOREIGN KEY (id_venta) REFERENCES VENTA (id_venta),
    CONSTRAINT FK_DETVENTA_PRODUCTO FOREIGN KEY (id_producto) REFERENCES PRODUCTO (id_producto),
    CONSTRAINT CK_DETVENTA_cantidad CHECK (cantidad > 0),
    CONSTRAINT CK_DETVENTA_precio CHECK (precio_unitario > 0)
);
GO

-- Vista: datos completos del cliente
CREATE VIEW vw_cliente AS
SELECT c.id_cliente, c.id_persona, p.dni, p.nombres, p.apellido_paterno,
       p.apellido_materno, p.telefono, c.direccion
FROM CLIENTE c
INNER JOIN PERSONA p ON c.id_persona = p.id_persona;
GO

-- Vista: empleado sin DNI ni teléfono
CREATE VIEW vw_empleado_basico AS
SELECT e.id_empleado, p.nombres, p.apellido_paterno, e.cargo
FROM EMPLEADO e
INNER JOIN PERSONA p ON e.id_persona = p.id_persona;
GO

-- Tabla: CATEGORIA
INSERT INTO CATEGORIA (nombre) VALUES
('Analgésicos'),
('Antigripales'),
('Antibióticos'),
('Vitaminas'),
('Antiácidos'),
('Antialérgicos');
GO

-- Tabla: MARCA
INSERT INTO MARCA (nombre) VALUES
('Medifarma'),
('Genfar'),
('Bayer'),
('Portugal'),
('Pfizer'),
('Farmindustria');
GO

-- Tabla: PROVEEDOR
INSERT INTO PROVEEDOR (ruc, razon_social, telefono, direccion) VALUES
('20481234567', 'Droguería Salud Norte S.A.C.', '976123456', 'Av. Los Incas 123, Trujillo'),
('20512345678', 'Distribuidora Farmacéutica Andina S.A.C.', '987234567', 'Jr. Comercio 456, Lima'),
('20601234567', 'Corporación Médica del Perú S.R.L.', '954345678', 'Av. Arequipa 789, Lima'),
('20456789012', 'Droguería Cajamarca E.I.R.L.', '963456789', 'Jr. Amazonas 321, Cajamarca'),
('20567890123', 'Representaciones Médicas Líder S.A.C.', '945567890', 'Av. Grau 654, Chiclayo');
GO

-- Tabla: MEDIO_PAGO
INSERT INTO MEDIO_PAGO (nombre_medio_pago) VALUES
('Efectivo'),
('Yape'),
('Plin'),
('Tarjeta'),
('Transferencia');
GO

-- Tabla: PERSONA (id 1 al 6: clientes, id 7 al 11: empleados)
INSERT INTO PERSONA (dni, nombres, apellido_paterno, apellido_materno, telefono) VALUES
('72145896', 'Rosa María', 'Cabrera', 'Díaz', '976541230'),
('45128936', 'Luis Alberto', 'Chávez', 'Rojas', '987654321'),
('71236548', 'María Elena', 'Torres', NULL, '954123789'),
('40125874', 'José Manuel', 'Vásquez', 'Lingán', NULL),
('76543210', 'Ana Lucía', 'Mendoza', 'Silva', '963852741'),
('43219876', 'Carlos Enrique', 'Ramos', 'Pérez', '945632187'),
('41236587', 'Patricia', 'Vargas', 'Cueva', '976123450'),
('47852136', 'Miguel Ángel', 'Sánchez', 'Terrones', '987321654'),
('72458963', 'Daniela', 'Huamán', 'Llamo', '954781236'),
('70145236', 'Jorge', 'Tello', NULL, '963214785'),
('46985214', 'Carmen', 'Rodríguez', 'Bustamante', NULL);
GO

-- Tabla: CLIENTE
INSERT INTO CLIENTE (id_persona, direccion) VALUES
(1, 'Jr. Los Pinos 120'),
(2, 'Av. Independencia 450'),
(3, 'Psje. Las Flores 15'),
(4, 'Jr. San Martín 678'),
(5, NULL),
(6, 'Av. Perú 890');
GO

-- Tabla: EMPLEADO
INSERT INTO EMPLEADO (id_persona, cargo) VALUES
(7, 'Químico Farmacéutico'),
(8, 'Técnico en Farmacia'),
(9, 'Cajero'),
(10, 'Atención'),
(11, 'Limpieza');
GO

-- Tabla: PRODUCTO
INSERT INTO PRODUCTO (id_categoria, id_marca, nombre, descripcion, presentacion, concentracion, precio_venta, requiere_receta, stock_minimo) VALUES
(1, 2, 'Paracetamol', 'Analgésico y antipirético', 'Tabletas', '500 mg', 0.50, 0, 100),
(1, 1, 'Ibuprofeno', 'Antiinflamatorio y analgésico', 'Tabletas', '400 mg', 0.80, 0, 80),
(2, 4, 'Antigripal Noche', 'Alivio de síntomas de gripe y resfrío', 'Tabletas', NULL, 1.20, 0, 60),
(3, 1, 'Amoxicilina', 'Antibiótico de amplio espectro', 'Cápsulas', '500 mg', 1.00, 1, 60),
(3, 5, 'Azitromicina', 'Antibiótico macrólido', 'Tabletas', '500 mg', 6.50, 1, 30),
(4, 3, 'Vitamina C', 'Suplemento de vitamina C', 'Tabletas efervescentes', '1000 mg', 1.50, 0, 50),
(4, 4, 'Complejo B', 'Suplemento de vitaminas del complejo B', 'Jarabe 120 ml', NULL, 12.00, 0, 20),
(5, 2, 'Hidróxido de Aluminio', 'Antiácido en suspensión', 'Jarabe 180 ml', NULL, 5.50, 0, 25),
(5, 6, 'Omeprazol', 'Inhibidor de la bomba de protones', 'Cápsulas', '20 mg', 0.70, 0, 70),
(6, 2, 'Loratadina', 'Antihistamínico para alergias', 'Tabletas', '10 mg', 0.60, 0, 60);
GO

-- Tabla: LOTE
INSERT INTO LOTE (id_producto, nro_lote, fecha_vencimiento, stock) VALUES
(1, 'L-PAR-2501', '2027-06-30', 300),
(1, 'L-PAR-2602', '2028-02-28', 500),
(2, 'L-IBU-2503', '2026-12-15', 150),
(3, 'L-ANT-2504', '2027-03-31', 120),
(4, 'L-AMO-2505', '2027-09-30', 200),
(5, 'L-AZI-2506', '2027-11-30', 25),
(6, 'L-VTC-2507', '2026-11-30', 90),
(7, 'L-CMB-2508', '2027-08-31', 35),
(8, 'L-HAL-2509', '2027-05-31', 45),
(9, 'L-OME-2510', '2028-01-31', 250),
(10, 'L-LOR-2511', '2027-10-31', 180);
GO

-- Tabla: COMPRA
INSERT INTO COMPRA (id_proveedor, id_empleado, fecha, total) VALUES
(1, 1, '2026-09-01T09:30:00', 245.00),
(2, 1, '2026-09-05T10:15:00', 310.00),
(3, 2, '2026-09-12T11:00:00', 360.00),
(4, 1, '2026-09-20T15:45:00', 225.00),
(5, 2, '2026-10-02T09:00:00', 165.00);
GO

-- Tabla: DETALLE_COMPRA
INSERT INTO DETALLE_COMPRA (id_compra, id_producto, cantidad, precio_compra_unitario) VALUES
(1, 1, 500, 0.25),
(1, 2, 300, 0.40),
(2, 4, 200, 0.55),
(2, 5, 50, 4.00),
(3, 6, 100, 0.80),
(3, 7, 40, 7.00),
(4, 8, 50, 3.00),
(4, 9, 250, 0.30),
(5, 10, 200, 0.30),
(5, 3, 150, 0.70);
GO

-- Tabla: VENTA
INSERT INTO VENTA (id_cliente, id_empleado, id_medio_pago, fecha, tipo_comprobante, nro_comprobante, total) VALUES
(1, 3, 1, '2026-10-05T10:20:00', 'Boleta', 'B001-000001', 9.80),
(NULL, 3, 2, '2026-10-05T12:40:00', 'Nota de Venta', 'N001-000001', 7.80),
(2, 4, 1, '2026-10-06T16:10:00', 'Boleta', 'B001-000002', 24.00),
(3, 2, 3, '2026-10-07T09:50:00', 'Boleta', 'B001-000003', 18.50),
(NULL, 4, 1, '2026-10-08T11:30:00', 'Nota de Venta', 'N001-000002', 20.80),
(4, 3, 4, '2026-10-09T18:05:00', 'Boleta', 'B001-000004', 49.00),
(5, 4, 2, '2026-10-10T10:00:00', 'Boleta', 'B001-000005', 9.20),
(2, 3, 3, '2026-10-12T17:25:00', 'Boleta', 'B001-000006', 31.40);
GO

-- Tabla: DETALLE_VENTA
INSERT INTO DETALLE_VENTA (id_venta, id_producto, cantidad, precio_unitario, subtotal) VALUES
(1, 1, 10, 0.50, 5.00),
(1, 2, 6, 0.80, 4.80),
(2, 3, 4, 1.20, 4.80),
(2, 6, 2, 1.50, 3.00),
(3, 4, 21, 1.00, 21.00),
(3, 10, 5, 0.60, 3.00),
(4, 5, 1, 6.50, 6.50),
(4, 7, 1, 12.00, 12.00),
(5, 9, 14, 0.70, 9.80),
(5, 8, 2, 5.50, 11.00),
(6, 1, 20, 0.50, 10.00),
(6, 6, 10, 1.50, 15.00),
(6, 7, 2, 12.00, 24.00),
(7, 1, 4, 0.50, 2.00),
(7, 3, 6, 1.20, 7.20),
(8, 8, 3, 5.50, 16.50),
(8, 9, 7, 0.70, 4.90),
(8, 4, 10, 1.00, 10.00);
GO

-- Verificación: muestra los datos de cada tabla
SELECT * FROM CATEGORIA;
SELECT * FROM MARCA;
SELECT * FROM PROVEEDOR;
SELECT * FROM MEDIO_PAGO;
SELECT * FROM PERSONA;
SELECT * FROM CLIENTE;
SELECT * FROM EMPLEADO;
SELECT * FROM PRODUCTO;
SELECT * FROM LOTE;
SELECT * FROM COMPRA;
SELECT * FROM DETALLE_COMPRA;
SELECT * FROM VENTA;
SELECT * FROM DETALLE_VENTA;
GO