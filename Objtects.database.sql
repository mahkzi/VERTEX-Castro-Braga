-- DOCUMENTACION FUCNIONAL DE OBJETOS -- 
USE schema_final;
-- VISTAS -- 
/*
1) vista_bajo_stock
Motivo:
Identificar productos que requieren reposición inmediata.

Objetivo:
Prevenir quiebres de stock y facilitar la gestión de compras.

2) vista_detalle_facturacion
Motivo:
Consolidar la información de ventas con datos de clientes y productos.

Objetivo:
Generar reportes de facturación legibles para administración.

3) v_envios_monitoreo
Motivo:
Rastrear el estado logístico de los pedidos que aún no han sido entregados.

Objetivo:
Control operativo de despacho y atención al cliente.

4) vista_top5_productos
Motivo:
Ranking de los productos con mayor volumen de salida.

Objetivo:
Analítica de rotación de inventario y preferencias de mercado.

5) v_valor_stock_sucursal
Motivo:
Calcular el valor monetario del inventario distribuido por sede.

Objetivo:
KPIs financieros y auditoría de activos en almacén.
*/
CREATE OR REPLACE VIEW vista_bajo_stock AS
SELECT id_producto, nombre_producto, stock_producto
FROM Producto
WHERE stock_producto < 10;

CREATE OR REPLACE VIEW vista_detalle_facturacion AS
SELECT p.id_pedido, c.nombre_cliente, c.apellido_cliente, pr.nombre_producto, 
       dp.cantidad, dp.precio_unitario, (dp.cantidad * dp.precio_unitario) AS SUBTOTAL
FROM Pedido p
JOIN Cliente c ON p.id_cliente = c.id_cliente
JOIN detalle_pedido dp ON p.id_pedido = dp.id_pedido
JOIN Producto pr ON dp.id_producto = pr.id_producto;

CREATE OR REPLACE VIEW v_envios_monitoreo AS
SELECT e.id_envio, p.id_pedido, c.nombre_cliente, e.empresa_correo, 
       e.numero_tracking, e.estado_de_envio, p.fecha_pedido
FROM envios e
JOIN Pedido p ON e.id_pedido = p.id_pedido
JOIN Cliente c ON p.id_cliente = c.id_cliente
WHERE e.estado_de_envio != "Entregado";

CREATE OR REPLACE VIEW vista_top5_productos AS 
SELECT
	pr.id_producto,
    pr.nombre_producto,
    SUM(dp.cantidad) AS total_unidades_vendidas
FROM Producto pr
JOIN detalle_pedido dp ON pr.id_producto = dp.id_producto
GROUP BY pr.id_producto, pr.nombre_producto
ORDER BY total_unidades_vendidas DESC
LIMIT 5;

CREATE OR REPLACE VIEW v_valor_stock_sucursal AS
SELECT
	s.nombre_sucursal,
    pr.nombre_producto,
    ss.cantidad_stock,
    pr.precio_producto,
    (ss.cantidad_stock * pr.precio_producto) AS valor_total_stock
FROM Stock_Sucursales ss
JOIN Sucursal s ON ss.id_sucursal = s.id_sucursal
JOIN Producto pr ON ss.id_producto = pr.id_producto;
-- FUNCIONES --
/*
1) funcion_calcular_descuento
Motivo:
Obtener el precio final de un producto tras aplicar una rebaja porcentual.

Objetivo:
Automatizar el cálculo de promociones en la capa de base de datos.

2) funcion_total_gastos_cliente
Motivo:
Determinar el valor histórico de compras de un usuario específico.

Objetivo:
Segmentación de clientes y programas de fidelización.

3) funcion_nombre_completo
Motivo:
Unificar los campos de nombre y apellido en una sola cadena de texto.

Objetivo:
Estandarizar la presentación de datos en reportes y correspondencia.
*/


DELIMITER // 
CREATE FUNCTION funcion_calcular_descuento(p_id_producto INT, p_porcentaje DECIMAL(5,2))
RETURNS DECIMAL (19,4)
DETERMINISTIC
BEGIN
	DECLARE v_precio_original DECIMAL(19,4);
    DECLARE v_precio_final DECIMAL(19,4);
    
    SELECT precio_producto INTO v_precio_original
    FROM Producto
    WHERE id_producto = p_id_producto;
    
    SET v_precio_final = v_precio_original - (v_precio_original * (p_porcentaje / 100));
    
    RETURN v_precio_final;
END //
DELIMITER ;

DELIMITER // 
CREATE FUNCTION funcion_total_gastos_cliente(p_id_cliente INT)
RETURNS DECIMAL (19,4)
DETERMINISTIC
BEGIN
	DECLARE v_total_gastado DECIMAL (19,4);
    
    SELECT SUM(total_pedido) INTO v_total_gastado
    FROM Pedido
    WHERE id_cliente = p_id_cliente;
    
	RETURN COALESCE(v_total_gastado, 0);
END //
DELIMITER ;	

DELIMITER //
CREATE FUNCTION funcion_nombre_completo(p_id_cliente INT)
RETURNS VARCHAR(101)
DETERMINISTIC
BEGIN
	DECLARE v_nombre VARCHAR(101);
    SELECT CONCAT(nombre_cliente, " ", COALESCE(apellido_cliente,"")) INTO v_nombre
    FROM Cliente WHERE id_cliente = p_id_cliente;
    RETURN v_nombre;
END //
DELIMITER ;
-- STORED PROCEDURES --
/*
1) sp_registrar_pedido
Motivo:
Ejecutar el alta de una venta impactando simultáneamente cabecera y detalle.

Objetivo:
Garantizar la integridad transaccional en el proceso de venta.

2) sp_gestionar_devolucion
Motivo:
Procesar el retorno de mercadería, afectando el registro de devoluciones y el stock.

Objetivo:
Automatizar la logística inversa y la corrección de inventarios.
*/
DELIMITER //
CREATE PROCEDURE sp_registrar_pedido(
	IN p_id_cliente INT,
    IN p_id_sucursal INT,
    IN p_id_empleado INT,
	IN p_id_producto INT,
	IN p_cantidad INT, 
	IN p_precio_unitario DECIMAL(19,4)
)
BEGIN
	DECLARE v_nuevo_id_pedido INT;
    DECLARE v_total DECIMAL(19,4);
    
    SET v_total = p_cantidad * p_precio_unitario;
    
    INSERT INTO Pedido(id_cliente, id_sucursal, id_empleado, fecha_pedido, estado_pedido, total_pedido)
    VALUES(p_id_cliente, p_id_sucursal, p_id_empleado, CURDATE(), "En progreso", v_total);
    
    SET v_nuevo_id_pedido = LAST_INSERT_ID();
    
    INSERT INTO detalle_pedido(id_pedido, id_producto, cantidad, precio_unitario)
    VALUES(v_nuevo_id_pedido, p_id_producto, p_cantidad, p_precio_unitario);
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE sp_gestionar_devolucion(
    IN p_id_pedido INT,
    IN p_id_producto INT,
    IN p_cantidad INT,
    IN p_motivo VARCHAR(255)
)
BEGIN
    DECLARE v_id_sucursal INT;

    INSERT INTO devoluciones (id_pedido, id_producto, fecha_devolucion, motivo_devolucion, estado_devolucion, cantidad_devuelta)
    VALUES (p_id_pedido, p_id_producto, NOW(), p_motivo, 'Recibido', p_cantidad);

    SELECT id_sucursal INTO v_id_sucursal 
    FROM Pedido 
    WHERE id_pedido = p_id_pedido;

    UPDATE Stock_Sucursales 
    SET cantidad_stock = cantidad_stock + p_cantidad
    WHERE id_producto = p_id_producto AND id_sucursal = v_id_sucursal;
    
    UPDATE Producto 
    SET stock_producto = stock_producto + p_cantidad
    WHERE id_producto = p_id_producto;
END //
DELIMITER ;

-- TRIGGERS -- 

/*
1) trigger_auditoria_cliente
Motivo:
Mantener un historial de nuevos ingresos de usuarios.

Objetivo:
Seguridad y trazabilidad de altas en el sistema.

2) trigger_validacion_stock
Motivo:
Impedir la venta de productos que no cuentan con existencias físicas.

Objetivo:
Asegurar la integridad de las reglas de negocio en cada transacción.

3) trigger_actualizar_stock_sucursal
Motivo:
Sincronizar la salida de mercadería con el inventario de la sede vendedora.

Objetivo:
Mantener el stock por sucursal siempre actualizado en tiempo real.

4) tr_llenar_fact_ventas
Motivo:
Alimentar la tabla de hechos automáticamente tras cada venta confirmada.

Objetivo:
Mantener la tabla de Hechos (Fact_Ventas) preparada para procesos de Data Warehousing.
*/
DELIMITER // 
CREATE TRIGGER trigger_auditoria_cliente
AFTER INSERT ON Cliente
FOR EACH ROW
BEGIN
	INSERT INTO auditoria_log(id_cliente_nuevo, fecha_accion, mensaje)
    VALUES (NEW.id_cliente, NOW(), "Nuevo cliente registrado en el sistema");
END //
DELIMITER ;

DELIMITER // 
CREATE TRIGGER trigger_validacion_stock
BEFORE INSERT ON detalle_pedido
FOR EACH ROW
BEGIN
	DECLARE v_stock_actual INT;
    
    SELECT stock_producto INTO v_stock_actual
    FROM Producto
    WHERE id_producto = NEW.id_producto;
    
    IF v_stock_actual < NEW.cantidad THEN
		SIGNAL SQLSTATE "45000"
		SET MESSAGE_TEXT = "Error: Stock insuficiente para completar el pedido.";
    END IF;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER trigger_actualizar_stock_sucursal
AFTER INSERT ON detalle_pedido
FOR EACH ROW
BEGIN
	DECLARE v_sucursal_id INT;
    
    SELECT id_sucursal INTO v_sucursal_id
    FROM Pedido WHERE id_pedido = NEW.id_pedido;
    
    UPDATE Stock_Sucursales
    SET cantidad_stock = cantidad_stock - NEW.cantidad
    WHERE id_producto = NEW.id_producto AND id_sucursal = v_sucursal_id;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER tr_llenar_fact_ventas
AFTER INSERT ON detalle_pedido
FOR EACH ROW
BEGIN
	DECLARE v_cliente_id INT;
    DECLARE v_fecha DATE;
    
    SELECT id_cliente, fecha_pedido INTO v_cliente_id, v_fecha
    FROM Pedido WHERE id_pedido = NEW.id_pedido;
    
    INSERT INTO Fact_Ventas (id_pedido, id_producto, id_cliente, cantidad_vendida, total_linea, fecha_venta)
    VALUES (NEW.id_pedido, NEW.id_producto, v_cliente_id, NEW.cantidad, (NEW.cantidad * NEW.precio_unitario), v_fecha);
END // 
DELIMITER ;