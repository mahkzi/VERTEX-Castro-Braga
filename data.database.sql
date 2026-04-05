USE schema_final;

-- 1. CATEGORÍAS
INSERT INTO Categoria (nombre_categoria, descripcion_categoria) VALUES
('Periféricos', 'Teclados, mouses y hardware de entrada'),
('Componentes', 'Procesadores, memorias RAM y placas de video'),
('Monitores', 'Pantallas gamer y profesionales'),
('Audio', 'Auriculares y micrófonos');

-- 2. PROVEEDORES
INSERT INTO Proveedores (nombre_proveedor, contacto_nombre, email_proveedor, telefono_proveedor, direccion_proveedor) VALUES
('Logitech Argentina', 'Juan Gomez', 'ventas@logitech.com.ar', '1144556677', 'Av. Santa Fe 1234, CABA'),
('ASUS Latam', 'Maria Lopez', 'soporte@asus.com', '1122334455', 'Florida 500, CABA'),
('MSI Official', 'Ricardo Torres', 'distribucion@msi.com', '1199887766', 'Av. Cabildo 2000, CABA');

-- 3. SUCURSALES
INSERT INTO Sucursal (nombre_sucursal, ciudad, direccion_sucursal, telefono_sucursal) VALUES
('Centro Store', 'CABA', 'Lavalle 700', '4321-5555'),
('Norte Outlet', 'Munro', 'Av. Mitre 2500', '4760-1111'),
('E-Commerce Hub', 'CABA', 'Deposito Logístico 4', '0800-999-222');

-- 4. CLIENTES
INSERT INTO Cliente (nombre_cliente, apellido_cliente, email, telefono, fecha_registro) VALUES
('Máximo', 'Pérez', 'maximo@mail.com', '1511223344', '2025-10-15'),
('Lucas', 'García', 'lucas@mail.com', '1522334455', '2026-01-20'),
('Micaela', 'Ríos', 'mica@mail.com', '1533445566', '2026-02-10'),
('Roque', 'Fernández', 'roque@mail.com', '1544556677', '2026-03-01');

-- 5. MÉTODOS DE PAGO
INSERT INTO Metodos_Pago (nombre_metodo, descripcion_metodo, habilitado) VALUES
('Tarjeta de Crédito', 'Visa, Mastercard o AMEX', TRUE),
('Transferencia', 'CBU/CVU bancario', TRUE),
('Efectivo', 'Pago en sucursal física', TRUE),
('Mercado Pago', 'Billetera virtual', TRUE);

-- 6. EMPLEADOS
INSERT INTO Empleados (id_sucursal, nombre_empleado, apellido_empleado, puesto, fecha_contratacion, email_interno) VALUES
(1, 'Nicole', 'Sosa', 'Vendedora Senior', '2025-01-10', 'nicole.s@tienda.com'),
(1, 'Tobias', 'Muller', 'Soporte Técnico', '2025-03-15', 'tobias.m@tienda.com'),
(3, 'Analía', 'Gómez', 'Manager Logística', '2024-11-01', 'analia.g@tienda.com');

-- 7. PRODUCTOS
INSERT INTO Producto (id_categoria, id_proveedor, nombre_producto, precio_producto, stock_producto, descripcion_producto) VALUES
(1, 1, 'Logitech G203', 25000.0000, 50, 'Mouse gaming RGB 8000 DPI'),
(2, 2, 'ASUS B550M-K', 120000.0000, 15, 'Motherboard AMD AM4 Micro-ATX'),
(2, 3, 'MSI RTX 4060', 450000.0000, 8, 'Placa de video 8GB GDDR6'),
(1, 1, 'Teclado ATK F1', 85000.0000, 5, 'Teclado mecánico ultra rápido');

-- 8. STOCK POR SUCURSAL (Inventario Inicial)
INSERT INTO Stock_Sucursales (id_sucursal, id_producto, cantidad_stock) VALUES
(1, 1, 20), (2, 1, 30), 
(1, 2, 10), (3, 2, 5),  
(3, 3, 8),              
(1, 4, 5);              

-- 9. PEDIDOS (Transacciones)
INSERT INTO Pedido (id_cliente, id_sucursal, id_empleado, fecha_pedido, estado_pedido, total_pedido) 
VALUES (1, 1, 1, '2026-03-25', 'Entregado', 25000.0000);

-- El detalle_pedido disparará automáticamente: 
-- 1. Descuento de stock en Sucursal 1 (vía trigger_actualizar_stock_sucursal)
-- 2. Carga en Fact_Ventas (vía tr_llenar_fact_ventas)
INSERT INTO detalle_pedido (id_pedido, id_producto, cantidad, precio_unitario)
VALUES (1, 1, 1, 25000.0000);

-- 10. PAGOS
INSERT INTO pagos (id_pedido, id_metodo_pago, fecha_pago, monto_pagado, nro_transaccion_ext, estado_pago)
VALUES (1, 4, '2026-03-25 10:30:00', 25000.0000, 'MP-998877', 'Aprobado');

-- 11. ENVÍOS
INSERT INTO envios (id_pedido, empresa_correo, numero_tracking, fecha_de_entrega, estado_de_envio)
VALUES (1, 'Andreani', 'TRACK-123456', '2026-03-27 14:00:00', 'Entregado');