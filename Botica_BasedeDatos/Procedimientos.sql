USE BoticaDB_Proyecto;
GO

CREATE OR ALTER PROCEDURE sp_productos_por_precio
AS
BEGIN
    SELECT nombre, presentacion, precio_venta
    FROM PRODUCTO
    ORDER BY precio_venta DESC;
END
GO

EXEC sp_productos_por_precio;
