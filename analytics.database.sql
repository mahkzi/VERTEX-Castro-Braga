 
/*
OBJETIVO:
Definir consultas SQL orientadas a la generación de un tablero
de control (Dashboard) en Power BI para VERTEX.
====================================================

KPI 1 — TABLA MAESTRA DE VENTAS (Métrica: Revenue & Volumen)
----------------------------------------------------
MOTIVO:
Esta consulta genera la tabla de hechos principal para el informe.

OBJETIVO:
Visualizar la evolución temporal de ingresos y cantidad de pedidos.

USO:
KPI´s para analizar el paso del tiempo(como afecto a los productos).
====================================================
*/

SELECT 
    fecha_venta AS Fecha,
    total_linea AS Monto,
    id_pedido AS Pedido_ID,
    id_producto AS Producto_ID,
    cantidad_vendida AS Unidades
FROM Fact_Ventas;


/*
====================================================
KPI 2 — ESTADO DE INVENTARIO Y VALORIZACIÓN
----------------------------------------------------
MOTIVO:
Cruza el stock actual con los precios para obtener el capital
inmovilizado, manteniendo el detalle por producto y sucursal.

OBJETIVO:
Alimentar gráficos de barras por sucursal y tablas de alerta
de bajo stock en el informe.

USO:
Indicador clave para organización de stock.
====================================================
*/

SELECT 
    s.nombre_sucursal AS Sucursal,
    p.nombre_producto AS Producto,
    p.precio_producto AS Precio_Unitario,
    ss.cantidad_stock AS Stock_Actual,
    (ss.cantidad_stock * p.precio_producto) AS Valor_Inventario
FROM Stock_Sucursales ss
JOIN Sucursal s ON ss.id_sucursal = s.id_sucursal
JOIN Producto p ON ss.id_producto = p.id_producto;


/*
====================================================
KPI 3 — PERFORMANCE DE VENDEDORES Y SEDES
----------------------------------------------------
MOTIVO:
Relaciona cada transacción con el empleado y la sucursal responsable
de la venta.

OBJETIVO:
Comparar el rendimiento de los equipos y la rentabilidad física
de cada punto de venta.

USO:
Gráficos de embudo o tablas de ranking de empleados.
====================================================
*/

SELECT 
    p.fecha_pedido AS Fecha_Venta,
    s.nombre_sucursal AS Sucursal,
    CONCAT(e.nombre_empleado, ' ', e.apellido_empleado) AS Vendedor,
    p.total_pedido AS Monto_Pedido
FROM Pedido p
JOIN Empleados e ON p.id_empleado = e.id_empleado
JOIN Sucursal s ON p.id_sucursal = s.id_sucursal;


/*
====================================================
KPI 4 — ANÁLISIS DE LOGÍSTICA Y DEVOLUCIONES
----------------------------------------------------
MOTIVO:
Provee el detalle de las devoluciones y los motivos de falla
del hardware.

OBJETIVO:
Calcular la tasa de retorno sobre ventas y detectar productos
problemáticos en el dashboard de calidad.

USO:
Clave para identifcar productos no bien recibidos.
====================================================
*/

SELECT 
    d.fecha_devolucion AS Fecha,
    p.nombre_producto AS Producto,
    d.cantidad_devuelta AS Unidades_Devueltas,
    d.motivo_devolucion AS Motivo,
    d.estado_devolucion AS Estado
FROM devoluciones d
JOIN Producto p ON d.id_producto = p.id_producto;
