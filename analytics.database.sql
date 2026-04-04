/*
OBJETIVO:
Definir consultas SQL orientadas a KPIs clave del negocio
para la aplicación VERTEX - Gestión de Hardware.
====================================================

KPI 1 — FACTURACIÓN TOTAL MENSUAL (REVENUE)
MOTIVO:
Este KPI permite medir los ingresos brutos mensuales
generados por las ventas confirmadas en la plataforma.

OBJETIVO:
Evaluar la salud financiera, detectar estacionalidad en
las ventas y medir el crecimiento comercial del negocio.

USO:
Fundamental para dashboards de gerencia y reportes contables.
====================================================
*/
SELECT 
    DATE_FORMAT(fecha_venta, '%Y-%m') AS mes,
    SUM(total_linea) AS ingresos_totales,
    COUNT(DISTINCT id_pedido) AS cantidad_pedidos
FROM Fact_Ventas
GROUP BY mes
ORDER BY mes DESC;
