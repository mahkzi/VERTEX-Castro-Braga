CREATE DATABASE schema_final;
USE schema_final;
-- TABLAS --

CREATE TABLE Cliente(
id_cliente INT PRIMARY KEY AUTO_INCREMENT,
nombre_cliente VARCHAR(50) NOT NULL,
apellido_cliente VARCHAR(50),
email VARCHAR(50) UNIQUE NOT NULL,
telefono VARCHAR (20) NOT NULL,
fecha_registro DATE
);

CREATE TABLE Categoria(
id_categoria INT PRIMARY KEY AUTO_INCREMENT,
nombre_categoria VARCHAR(50),
descripcion_categoria VARCHAR(100)
);

CREATE TABLE Proveedores(
	id_proveedor INT PRIMARY KEY AUTO_INCREMENT,
    nombre_proveedor VARCHAR(100) NOT NULL,
    contacto_nombre VARCHAR(50),
    email_proveedor VARCHAR (50) UNIQUE,
    telefono_proveedor VARCHAR(20),
    direccion_proveedor VARCHAR(100)
);

CREATE TABLE Sucursal(
	id_sucursal INT PRIMARY KEY AUTO_INCREMENT,
    nombre_sucursal VARCHAR (50) NOT NULL,
    ciudad VARCHAR (50),
    direccion_sucursal VARCHAR (100),
    telefono_sucursal VARCHAR (20)
);

CREATE TABLE Metodos_Pago(
	id_metodo_pago INT PRIMARY KEY AUTO_INCREMENT,
    nombre_metodo VARCHAR(30) NOT NULL,
    descripcion_metodo VARCHAR (100),
    habilitado BOOLEAN DEFAULT TRUE
);

CREATE TABLE Empleados(
	id_empleado INT PRIMARY KEY AUTO_INCREMENT,
    id_sucursal INT NOT NULL,
    nombre_empleado VARCHAR (25) NOT NULL,
    apellido_empleado VARCHAR (50),
    puesto VARCHAR (50),
    fecha_contratacion DATE,
    email_interno VARCHAR(50) UNIQUE,
    FOREIGN KEY (id_sucursal) REFERENCES Sucursal(id_sucursal)
);

CREATE TABLE Producto(
id_producto INT PRIMARY KEY AUTO_INCREMENT,
id_categoria INT NOT NULL,
id_proveedor INT NOT NULL,
nombre_producto VARCHAR(50),
precio_producto DECIMAL(19,4),
stock_producto INT,
descripcion_producto VARCHAR(100),
FOREIGN KEY (id_categoria) REFERENCES Categoria(id_categoria),
FOREIGN KEY (id_proveedor) REFERENCES Proveedores(id_proveedor)
);

CREATE TABLE Stock_Sucursales (
	id_sucursal INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad_stock INT DEFAULT 0,
    ultima_actualizacion DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id_sucursal, id_producto),
    FOREIGN KEY (id_sucursal) REFERENCES Sucursal(id_sucursal),
    FOREIGN KEY (id_producto) REFERENCES Producto(id_producto)
);


CREATE TABLE Pedido(
id_pedido INT PRIMARY KEY AUTO_INCREMENT,
id_cliente INT NOT NULL,
id_sucursal INT NOT NULL,
id_empleado INT NOT NULL,
fecha_pedido DATE,
estado_pedido VARCHAR(20),
total_pedido DECIMAL(19,4),
FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente),
FOREIGN KEY (id_sucursal) REFERENCES Sucursal(id_sucursal),
FOREIGN KEY (id_empleado) REFERENCES Empleados(id_empleado)
);

CREATE TABLE detalle_pedido(
id_pedido INT NOT NULL,
id_producto INT NOT NULL,
cantidad INT,
precio_unitario DECIMAL(19,4),
PRIMARY KEY(id_pedido, id_producto),
FOREIGN KEY (id_pedido) REFERENCES Pedido(id_pedido),
FOREIGN KEY (id_producto) REFERENCES Producto(id_producto)
);

CREATE TABLE pagos(
	id_pago INT PRIMARY KEY AUTO_INCREMENT,
    id_pedido INT NOT NULL,
    id_metodo_pago INT NOT NULL,
    fecha_pago DATETIME NOT NULL,
    monto_pagado DECIMAL (19,4) NOT NULL,
    nro_transaccion_ext VARCHAR(100),
    estado_pago ENUM("Pendiente", "Aprobado", "Rechazado"),
    FOREIGN KEY (id_pedido) REFERENCES Pedido(id_pedido),
    FOREIGN KEY (id_metodo_pago) REFERENCES Metodos_Pago(id_metodo_pago)
);

CREATE TABLE envios(
	id_envio INT PRIMARY KEY AUTO_INCREMENT,
    id_pedido INT NOT NULL,
    empresa_correo VARCHAR (50),
    numero_tracking VARCHAR(50) NOT NULL,
    fecha_de_entrega DATETIME,
    estado_de_envio ENUM ("En camino", "Entregado", "Cancelado"),
    FOREIGN KEY (id_pedido) REFERENCES Pedido(id_pedido)
);

CREATE TABLE devoluciones(
	id_devolucion INT PRIMARY KEY AUTO_INCREMENT,
    id_pedido INT NOT NULL,
    id_producto INT NOT NULL,
    fecha_devolucion DATETIME DEFAULT CURRENT_TIMESTAMP,
    motivo_devolucion VARCHAR (255),
    estado_devolucion ENUM("Pendiente","Recibido","Rechazado"),
    cantidad_devuelta INT NOT NULL,
    FOREIGN KEY (id_pedido, id_producto) REFERENCES detalle_pedido(id_pedido, id_producto)
);
-- tabla de hechos--

CREATE TABLE Fact_Ventas(
	id_fact_ventas INT PRIMARY KEY AUTO_INCREMENT,
    id_pedido INT NOT NULL,
    id_producto INT NOT NULL,
    id_cliente INT NOT NULL,
    cantidad_vendida INT,
    total_linea DECIMAL (19,4),
    fecha_venta DATE,
    FOREIGN KEY (id_pedido) REFERENCES Pedido(id_pedido),
    FOREIGN KEY (id_producto) REFERENCES Producto(id_producto),
    FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente)
);

CREATE TABLE IF NOT EXISTS auditoria_log(
id_log INT AUTO_INCREMENT PRIMARY KEY,
id_cliente_nuevo INT,
fecha_accion DATETIME,
mensaje VARCHAR(100)
);