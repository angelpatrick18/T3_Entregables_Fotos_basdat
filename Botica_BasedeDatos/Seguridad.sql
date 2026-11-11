
USE master;
GO

-- CHECK_POLICY = ON aplica la política de contraseñas de Windows
-- (longitud mínima y complejidad).
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'login_admin')
    CREATE LOGIN login_admin WITH PASSWORD = 'Admin#Botica2026',
        DEFAULT_DATABASE = BoticaDB_Proyecto, CHECK_POLICY = ON, CHECK_EXPIRATION = OFF;

IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'login_quimico')
    CREATE LOGIN login_quimico WITH PASSWORD = 'Quimico#Botica2026',
        DEFAULT_DATABASE = BoticaDB_Proyecto, CHECK_POLICY = ON, CHECK_EXPIRATION = OFF;

IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'login_cajero')
    CREATE LOGIN login_cajero WITH PASSWORD = 'Cajero#Botica2026',
        DEFAULT_DATABASE = BoticaDB_Proyecto, CHECK_POLICY = ON, CHECK_EXPIRATION = OFF;

IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'login_almacen')
    CREATE LOGIN login_almacen WITH PASSWORD = 'Almacen#Botica2026',
        DEFAULT_DATABASE = BoticaDB_Proyecto, CHECK_POLICY = ON, CHECK_EXPIRATION = OFF;

IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'login_auditor')
    CREATE LOGIN login_auditor WITH PASSWORD = 'Auditor#Botica2026',
        DEFAULT_DATABASE = BoticaDB_Proyecto, CHECK_POLICY = ON, CHECK_EXPIRATION = OFF;
GO

-- =====================================================================
-- 2. USUARIOS (nivel base de datos), uno por cada login
-- =====================================================================
USE BoticaDB_Proyecto;
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'usr_admin')
    CREATE USER usr_admin FOR LOGIN login_admin WITH DEFAULT_SCHEMA = dbo;

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'usr_quimico')
    CREATE USER usr_quimico FOR LOGIN login_quimico WITH DEFAULT_SCHEMA = dbo;

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'usr_cajero')
    CREATE USER usr_cajero FOR LOGIN login_cajero WITH DEFAULT_SCHEMA = dbo;

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'usr_almacen')
    CREATE USER usr_almacen FOR LOGIN login_almacen WITH DEFAULT_SCHEMA = dbo;

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'usr_auditor')
    CREATE USER usr_auditor FOR LOGIN login_auditor WITH DEFAULT_SCHEMA = dbo;
GO

-- =====================================================================
-- 3. ROLES (nivel base de datos)
-- =====================================================================
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'rol_administrador' AND type = 'R')
    CREATE ROLE rol_administrador AUTHORIZATION dbo;

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'rol_quimico' AND type = 'R')
    CREATE ROLE rol_quimico AUTHORIZATION dbo;

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'rol_cajero' AND type = 'R')
    CREATE ROLE rol_cajero AUTHORIZATION dbo;

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'rol_almacen' AND type = 'R')
    CREATE ROLE rol_almacen AUTHORIZATION dbo;

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'rol_auditor' AND type = 'R')
    CREATE ROLE rol_auditor AUTHORIZATION dbo;
GO

-- =====================================================================
-- 4. PERMISOS DE CADA ROL
--    GRANT = otorga | DENY = prohíbe (DENY prevalece sobre GRANT)
-- =====================================================================

-- 4.1 rol_administrador: control total de BoticaDB_Proyecto.
--     Se agrega al rol fijo db_owner (crear tablas, gestionar usuarios,
--     respaldos, etc.). No recibe permisos de servidor (no es sysadmin).
ALTER ROLE db_owner ADD MEMBER rol_administrador;
GO

-- 4.2 rol_quimico: responsable técnico de los medicamentos.
--     Administra el catálogo y los lotes, puede vender y consultar todo,
--     pero no puede eliminar ventas ni compras.
GRANT SELECT, INSERT, UPDATE ON CATEGORIA TO rol_quimico;
GRANT SELECT, INSERT, UPDATE ON MARCA     TO rol_quimico;
GRANT SELECT, INSERT, UPDATE ON PRODUCTO  TO rol_quimico;
GRANT SELECT, INSERT, UPDATE ON LOTE      TO rol_quimico;
GRANT SELECT, INSERT, UPDATE ON CLIENTE   TO rol_quimico;
GRANT SELECT, INSERT, UPDATE ON PERSONA   TO rol_quimico;
GRANT SELECT ON vw_cliente         TO rol_quimico;
GRANT SELECT ON vw_empleado_basico TO rol_quimico;
GRANT SELECT, INSERT ON VENTA             TO rol_quimico;
GRANT SELECT, INSERT ON DETALLE_VENTA     TO rol_quimico;
GRANT SELECT ON MEDIO_PAGO     TO rol_quimico;
GRANT SELECT ON PROVEEDOR      TO rol_quimico;
GRANT SELECT ON COMPRA         TO rol_quimico;
GRANT SELECT ON DETALLE_COMPRA TO rol_quimico;
GRANT SELECT ON EMPLEADO       TO rol_quimico;
DENY DELETE ON VENTA           TO rol_quimico;
DENY DELETE ON DETALLE_VENTA   TO rol_quimico;
DENY DELETE ON COMPRA          TO rol_quimico;
DENY DELETE ON DETALLE_COMPRA  TO rol_quimico;
GO

-- 4.3 rol_cajero: registra ventas y clientes.
--     Solo puede actualizar el stock del lote (permiso por COLUMNA) y el
--     teléfono/dirección del cliente. No ve costos de compra ni proveedores.
--     Lee clientes y empleados con las vistas, no directamente de PERSONA,
--     para no ver el DNI ni el teléfono de los empleados.
GRANT SELECT ON CATEGORIA  TO rol_cajero;
GRANT SELECT ON MARCA      TO rol_cajero;
GRANT SELECT ON PRODUCTO   TO rol_cajero;
GRANT SELECT ON MEDIO_PAGO TO rol_cajero;
GRANT SELECT ON LOTE       TO rol_cajero;
GRANT UPDATE (stock) ON LOTE TO rol_cajero;
GRANT SELECT, INSERT ON CLIENTE TO rol_cajero;
GRANT UPDATE (direccion) ON CLIENTE TO rol_cajero;
GRANT INSERT ON PERSONA TO rol_cajero;
GRANT SELECT (id_persona) ON PERSONA TO rol_cajero;
GRANT UPDATE (telefono) ON PERSONA TO rol_cajero;
GRANT SELECT ON vw_cliente         TO rol_cajero;
GRANT SELECT ON vw_empleado_basico TO rol_cajero;
GRANT SELECT, INSERT ON VENTA         TO rol_cajero;
GRANT SELECT, INSERT ON DETALLE_VENTA TO rol_cajero;
DENY SELECT ON COMPRA         TO rol_cajero;
DENY SELECT ON DETALLE_COMPRA TO rol_cajero;
DENY SELECT ON PROVEEDOR      TO rol_cajero;
DENY UPDATE, DELETE ON VENTA         TO rol_cajero;
DENY UPDATE, DELETE ON DETALLE_VENTA TO rol_cajero;
GO

-- 4.4 rol_almacen: recepción de mercadería.
--     Registra compras a proveedores y los lotes que ingresan.
--     No tiene acceso a las ventas ni a los datos de clientes, por eso
--     tampoco recibe permisos sobre PERSONA.
GRANT SELECT, INSERT, UPDATE ON PROVEEDOR      TO rol_almacen;
GRANT SELECT, INSERT         ON COMPRA         TO rol_almacen;
GRANT SELECT, INSERT         ON DETALLE_COMPRA TO rol_almacen;
GRANT SELECT, INSERT, UPDATE ON LOTE           TO rol_almacen;
GRANT SELECT ON PRODUCTO  TO rol_almacen;
GRANT SELECT ON CATEGORIA TO rol_almacen;
GRANT SELECT ON MARCA     TO rol_almacen;
GRANT SELECT ON vw_empleado_basico TO rol_almacen;
DENY SELECT ON VENTA         TO rol_almacen;
DENY SELECT ON DETALLE_VENTA TO rol_almacen;
DENY SELECT ON CLIENTE       TO rol_almacen;
DENY DELETE ON COMPRA         TO rol_almacen;
DENY DELETE ON DETALLE_COMPRA TO rol_almacen;
GO

-- 4.5 rol_auditor: solo lectura de toda la base (permiso a nivel de ESQUEMA).
--     Por protección de datos personales (Ley N.° 29733) no ve el DNI ni
--     el teléfono de las personas (clientes y empleados).
GRANT SELECT ON SCHEMA::dbo TO rol_auditor;
DENY INSERT, UPDATE, DELETE ON SCHEMA::dbo TO rol_auditor;
DENY SELECT (dni, telefono) ON PERSONA    TO rol_auditor;
DENY SELECT (dni, telefono) ON vw_cliente TO rol_auditor;
GO

-- 4.6 Procedimientos almacenados: todos los roles pueden ejecutar el
--     reporte de productos (si el procedimiento ya fue creado).
IF OBJECT_ID('dbo.sp_productos_por_precio', 'P') IS NOT NULL
    EXEC ('GRANT EXECUTE ON dbo.sp_productos_por_precio TO rol_quimico, rol_cajero, rol_almacen, rol_auditor;');
GO

-- =====================================================================
-- 5. ASIGNAR CADA USUARIO A SU ROL
-- =====================================================================
ALTER ROLE rol_administrador ADD MEMBER usr_admin;
ALTER ROLE rol_quimico       ADD MEMBER usr_quimico;
ALTER ROLE rol_cajero        ADD MEMBER usr_cajero;
ALTER ROLE rol_almacen       ADD MEMBER usr_almacen;
ALTER ROLE rol_auditor       ADD MEMBER usr_auditor;
GO

-- =====================================================================
-- 6. VERIFICACIÓN
-- =====================================================================

-- 6.1 Logins creados en el servidor
SELECT name AS login, type_desc AS tipo, default_database_name AS base_por_defecto,
       is_disabled AS deshabilitado, create_date AS fecha_creacion
FROM sys.server_principals
WHERE name LIKE 'login[_]%';

-- 6.2 Usuarios de la base y el login al que pertenecen
SELECT dp.name AS usuario, sp.name AS login, dp.default_schema_name AS esquema
FROM sys.database_principals dp
INNER JOIN sys.server_principals sp ON dp.sid = sp.sid
WHERE dp.name LIKE 'usr[_]%';

-- 6.3 Miembros de cada rol
SELECT r.name AS rol, m.name AS miembro
FROM sys.database_role_members rm
INNER JOIN sys.database_principals r ON rm.role_principal_id = r.principal_id
INNER JOIN sys.database_principals m ON rm.member_principal_id = m.principal_id
WHERE r.name LIKE 'rol[_]%' OR m.name LIKE 'rol[_]%'
ORDER BY r.name;

-- 6.4 Permisos otorgados (GRANT) y denegados (DENY) a cada rol
SELECT pr.name AS rol,
       pe.state_desc AS estado,
       pe.permission_name AS permiso,
       CASE pe.class WHEN 3 THEN 'SCHEMA::' + SCHEMA_NAME(pe.major_id)
                     ELSE OBJECT_NAME(pe.major_id) END AS objeto,
       COL_NAME(pe.major_id, pe.minor_id) AS columna
FROM sys.database_permissions pe
INNER JOIN sys.database_principals pr ON pe.grantee_principal_id = pr.principal_id
WHERE pr.name LIKE 'rol[_]%'
ORDER BY pr.name, objeto, pe.state_desc, pe.permission_name;
GO

-- =====================================================================
-- 7. PRUEBAS DE PERMISOS (para la exposición)
--    EXECUTE AS USER suplanta al usuario; REVERT vuelve al usuario original.
-- =====================================================================

-- 7.1 Cajero: puede ver productos, pero NO los costos de compra
EXECUTE AS USER = 'usr_cajero';
    SELECT USER_NAME() AS usuario_actual;
    SELECT TOP 5 nombre, precio_venta FROM PRODUCTO;
    BEGIN TRY
        SELECT TOP 5 * FROM DETALLE_COMPRA;
    END TRY
    BEGIN CATCH
        PRINT 'usr_cajero -> DETALLE_COMPRA: ' + ERROR_MESSAGE();
    END CATCH
    BEGIN TRY
        DELETE FROM VENTA WHERE id_venta = -1;
    END TRY
    BEGIN CATCH
        PRINT 'usr_cajero -> DELETE VENTA: ' + ERROR_MESSAGE();
    END CATCH
REVERT;
GO

-- 7.2 Almacén: puede ver compras, pero NO las ventas
EXECUTE AS USER = 'usr_almacen';
    SELECT TOP 5 id_compra, fecha, total FROM COMPRA;
    BEGIN TRY
        SELECT TOP 5 * FROM VENTA;
    END TRY
    BEGIN CATCH
        PRINT 'usr_almacen -> VENTA: ' + ERROR_MESSAGE();
    END CATCH
REVERT;
GO

-- 7.3 Auditor: puede leer, pero NO modificar ni ver el DNI del cliente
EXECUTE AS USER = 'usr_auditor';
    SELECT TOP 5 id_cliente, nombres, apellido_paterno FROM vw_cliente;
    BEGIN TRY
        SELECT TOP 5 dni FROM PERSONA;
    END TRY
    BEGIN CATCH
        PRINT 'usr_auditor -> PERSONA.dni: ' + ERROR_MESSAGE();
    END CATCH
    BEGIN TRY
        UPDATE PRODUCTO SET precio_venta = precio_venta WHERE id_producto = -1;
    END TRY
    BEGIN CATCH
        PRINT 'usr_auditor -> UPDATE PRODUCTO: ' + ERROR_MESSAGE();
    END CATCH
REVERT;
GO

-- 7.4 Permisos efectivos de un usuario sobre una tabla
EXECUTE AS USER = 'usr_cajero';
    SELECT permission_name AS permiso, subentity_name AS columna
    FROM fn_my_permissions('dbo.LOTE', 'OBJECT');
REVERT;
GO


