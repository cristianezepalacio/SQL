-- ============================================================================
--  SABORES DEL NORTE - Sistema de Gestión de Local de Empanadas
-- Autor: Palacio Cristian
-- Curso: SQL CODER 
-- Fecha: Febrero 2026
-- Descripción: Script de creación de base de datos y tablas
-- ============================================================================

-- ============================================================================
-- 1. CREACIÓN DE LA BASE DE DATOS
-- ============================================================================

DROP DATABASE IF EXISTS sabores_del_norte;

CREATE DATABASE sabores_del_norte
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

-- Usar la base de datos
USE sabores_del_norte;

-- ============================================================================
-- 2. CREACIÓN DE TABLAS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Tabla: CLIENTES
-- Descripción: Almacena información de los clientes del negocio
-- ----------------------------------------------------------------------------
CREATE TABLE CLIENTES (
    id_cliente INT AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    telefono VARCHAR(20) NOT NULL,
    email VARCHAR(100),
    fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE,
    
    -- Definir clave primaria
    PRIMARY KEY (id_cliente),
    
    -- Crear índices para búsquedas frecuentes
    INDEX idx_telefono (telefono),
    INDEX idx_email (email)
) ENGINE=InnoDB COMMENT='Clientes del negocio';

-- ----------------------------------------------------------------------------
-- Tabla: DIRECCIONES
-- Descripción: Direcciones de entrega de los clientes
-- ----------------------------------------------------------------------------
CREATE TABLE DIRECCIONES (
    id_direccion INT AUTO_INCREMENT,
    id_cliente INT NOT NULL,
    calle VARCHAR(150) NOT NULL,
    numero VARCHAR(10) NOT NULL,
    piso VARCHAR(10),
    barrio VARCHAR(100) NOT NULL,
    ciudad VARCHAR(100) DEFAULT 'Morón',
    codigo_postal VARCHAR(10),
    referencia VARCHAR(200),
    principal BOOLEAN DEFAULT FALSE,
    
    -- Definir clave primaria
    PRIMARY KEY (id_direccion),
    
    -- Definir clave foránea
    FOREIGN KEY (id_cliente) REFERENCES CLIENTES(id_cliente)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    
    -- Crear índice
    INDEX idx_barrio (barrio)
) ENGINE=InnoDB COMMENT='Direcciones de entrega de clientes';

-- ----------------------------------------------------------------------------
-- Tabla: CATEGORIAS_PRODUCTOS
-- Descripción: Categorías de productos (empanadas, bebidas, etc.)
-- ----------------------------------------------------------------------------
CREATE TABLE CATEGORIAS_PRODUCTOS (
    id_categoria INT AUTO_INCREMENT,
    nombre_categoria VARCHAR(50) NOT NULL UNIQUE,
    descripcion TEXT,
    
    -- Definir clave primaria
    PRIMARY KEY (id_categoria)
) ENGINE=InnoDB COMMENT='Categorías de productos';

-- ----------------------------------------------------------------------------
-- Tabla: PRODUCTOS
-- Descripción: Catálogo de productos disponibles para la venta
-- ----------------------------------------------------------------------------
CREATE TABLE PRODUCTOS (
    id_producto INT AUTO_INCREMENT,
    id_categoria INT NOT NULL,
    nombre_producto VARCHAR(100) NOT NULL,
    descripcion TEXT,
    precio_unitario DECIMAL(10,2) NOT NULL,
    costo_produccion DECIMAL(10,2),
    disponible BOOLEAN DEFAULT TRUE,
    tiempo_preparacion INT COMMENT 'Tiempo en minutos',
    
    -- Definir clave primaria
    PRIMARY KEY (id_producto),
    
    -- Definir clave foránea
    FOREIGN KEY (id_categoria) REFERENCES CATEGORIAS_PRODUCTOS(id_categoria)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    
    -- Validación: precio debe ser mayor a 0
    CHECK (precio_unitario > 0)
) ENGINE=InnoDB COMMENT='Catálogo de productos';

-- ----------------------------------------------------------------------------
-- Tabla: PROVEEDORES
-- Descripción: Proveedores de ingredientes e insumos
-- ----------------------------------------------------------------------------
CREATE TABLE PROVEEDORES (
    id_proveedor INT AUTO_INCREMENT,
    nombre_proveedor VARCHAR(150) NOT NULL,
    cuit VARCHAR(15) UNIQUE,
    telefono VARCHAR(20) NOT NULL,
    email VARCHAR(100),
    direccion VARCHAR(200),
    activo BOOLEAN DEFAULT TRUE,
    
    -- Definir clave primaria
    PRIMARY KEY (id_proveedor),
    
    -- Crear índice
    INDEX idx_cuit (cuit)
) ENGINE=InnoDB COMMENT='Proveedores de ingredientes';

-- ----------------------------------------------------------------------------
-- Tabla: INGREDIENTES
-- Descripción: Ingredientes e insumos para la producción
-- ----------------------------------------------------------------------------
CREATE TABLE INGREDIENTES (
    id_ingrediente INT AUTO_INCREMENT,
    id_proveedor INT NOT NULL,
    nombre_ingrediente VARCHAR(100) NOT NULL,
    unidad_medida VARCHAR(20) NOT NULL COMMENT 'kg, litros, unidades, etc.',
    stock_actual DECIMAL(10,2) DEFAULT 0,
    stock_minimo DECIMAL(10,2) NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    
    -- Definir clave primaria
    PRIMARY KEY (id_ingrediente),
    
    -- Definir clave foránea
    FOREIGN KEY (id_proveedor) REFERENCES PROVEEDORES(id_proveedor)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    
    -- Validaciones
    CHECK (stock_actual >= 0),
    CHECK (stock_minimo >= 0),
    CHECK (precio_unitario > 0)
) ENGINE=InnoDB COMMENT='Ingredientes e insumos';

-- ----------------------------------------------------------------------------
-- Tabla: PRODUCTOS_INGREDIENTES
-- Descripción: Relación N:M entre productos e ingredientes (recetas)
-- ----------------------------------------------------------------------------
CREATE TABLE PRODUCTOS_INGREDIENTES (
    id_producto_ingrediente INT AUTO_INCREMENT,
    id_producto INT NOT NULL,
    id_ingrediente INT NOT NULL,
    cantidad_necesaria DECIMAL(10,2) NOT NULL COMMENT 'Cantidad por unidad de producto',
    
    -- Definir clave primaria
    PRIMARY KEY (id_producto_ingrediente),
    
    -- Definir claves foráneas
    FOREIGN KEY (id_producto) REFERENCES PRODUCTOS(id_producto)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    FOREIGN KEY (id_ingrediente) REFERENCES INGREDIENTES(id_ingrediente)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    
    -- Evitar duplicados (un ingrediente no puede estar dos veces en el mismo producto)
    UNIQUE KEY uk_producto_ingrediente (id_producto, id_ingrediente),
    
    -- Validación
    CHECK (cantidad_necesaria > 0)
) ENGINE=InnoDB COMMENT='Recetas: ingredientes por producto';

-- ----------------------------------------------------------------------------
-- Tabla: ROLES_EMPLEADOS
-- Descripción: Roles o puestos de trabajo
-- ----------------------------------------------------------------------------
CREATE TABLE ROLES_EMPLEADOS (
    id_rol INT AUTO_INCREMENT,
    nombre_rol VARCHAR(50) NOT NULL UNIQUE,
    descripcion TEXT,
    
    -- Definir clave primaria
    PRIMARY KEY (id_rol)
) ENGINE=InnoDB COMMENT='Roles de empleados';

-- ----------------------------------------------------------------------------
-- Tabla: EMPLEADOS
-- Descripción: Personal del negocio
-- ----------------------------------------------------------------------------
CREATE TABLE EMPLEADOS (
    id_empleado INT AUTO_INCREMENT,
    id_rol INT NOT NULL,
    nombre_empleado VARCHAR(100) NOT NULL,
    dni VARCHAR(10) NOT NULL UNIQUE,
    telefono VARCHAR(20) NOT NULL,
    fecha_ingreso DATE NOT NULL,
    salario DECIMAL(10,2),
    activo BOOLEAN DEFAULT TRUE,
    
    -- Definir clave primaria
    PRIMARY KEY (id_empleado),
    
    -- Definir clave foránea
    FOREIGN KEY (id_rol) REFERENCES ROLES_EMPLEADOS(id_rol)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    
    -- Crear índice
    INDEX idx_dni (dni),
    
    -- Validación
    CHECK (salario >= 0)
) ENGINE=InnoDB COMMENT='Empleados del negocio';

-- ----------------------------------------------------------------------------
-- Tabla: PEDIDOS
-- Descripción: Pedidos realizados por los clientes
-- ----------------------------------------------------------------------------
CREATE TABLE PEDIDOS (
    id_pedido INT AUTO_INCREMENT,
    id_cliente INT NOT NULL,
    id_empleado INT NOT NULL,
    id_direccion INT NULL COMMENT 'NULL si es pedido en local',
    fecha_pedido DATETIME DEFAULT CURRENT_TIMESTAMP,
    fecha_entrega DATETIME,
    tipo_pedido ENUM('LOCAL', 'DELIVERY', 'ANTICIPADO') NOT NULL DEFAULT 'LOCAL',
    estado_pedido ENUM('PENDIENTE', 'PREPARACION', 'LISTO', 'ENTREGADO', 'CANCELADO') 
        NOT NULL DEFAULT 'PENDIENTE',
    subtotal DECIMAL(10,2) NOT NULL,
    costo_envio DECIMAL(10,2) DEFAULT 0,
    total DECIMAL(10,2) NOT NULL,
    observaciones TEXT,
    
    -- Definir clave primaria
    PRIMARY KEY (id_pedido),
    
    -- Definir claves foráneas
    FOREIGN KEY (id_cliente) REFERENCES CLIENTES(id_cliente)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    FOREIGN KEY (id_empleado) REFERENCES EMPLEADOS(id_empleado)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    FOREIGN KEY (id_direccion) REFERENCES DIRECCIONES(id_direccion)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    
    -- Crear índice para búsquedas por fecha
    INDEX idx_fecha_pedido (fecha_pedido),
    
    -- Validaciones
    CHECK (subtotal >= 0),
    CHECK (costo_envio >= 0),
    CHECK (total >= 0)
) ENGINE=InnoDB COMMENT='Pedidos de clientes';

-- ----------------------------------------------------------------------------
-- Tabla: DETALLE_PEDIDOS
-- Descripción: Detalle de productos en cada pedido
-- ----------------------------------------------------------------------------
CREATE TABLE DETALLE_PEDIDOS (
    id_detalle INT AUTO_INCREMENT,
    id_pedido INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL COMMENT 'Precio al momento de la venta',
    subtotal DECIMAL(10,2) NOT NULL,
    
    -- Definir clave primaria
    PRIMARY KEY (id_detalle),
    
    -- Definir claves foráneas
    FOREIGN KEY (id_pedido) REFERENCES PEDIDOS(id_pedido)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    FOREIGN KEY (id_producto) REFERENCES PRODUCTOS(id_producto)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    
    -- Validaciones
    CHECK (cantidad > 0),
    CHECK (precio_unitario > 0),
    CHECK (subtotal >= 0)
) ENGINE=InnoDB COMMENT='Detalle de productos por pedido';

-- ----------------------------------------------------------------------------
-- Tabla: METODOS_PAGO
-- Descripción: Formas de pago disponibles
-- ----------------------------------------------------------------------------
CREATE TABLE METODOS_PAGO (
    id_metodo_pago INT AUTO_INCREMENT,
    nombre_metodo VARCHAR(50) NOT NULL UNIQUE,
    activo BOOLEAN DEFAULT TRUE,
    
    -- Definir clave primaria
    PRIMARY KEY (id_metodo_pago)
) ENGINE=InnoDB COMMENT='Métodos de pago disponibles';

-- ----------------------------------------------------------------------------
-- Tabla: PAGOS
-- Descripción: Registro de pagos recibidos
-- ----------------------------------------------------------------------------
CREATE TABLE PAGOS (
    id_pago INT AUTO_INCREMENT,
    id_pedido INT NOT NULL,
    id_metodo_pago INT NOT NULL,
    monto DECIMAL(10,2) NOT NULL,
    fecha_pago DATETIME DEFAULT CURRENT_TIMESTAMP,
    comprobante VARCHAR(100),
    
    -- Definir clave primaria
    PRIMARY KEY (id_pago),
    
    -- Definir claves foráneas
    FOREIGN KEY (id_pedido) REFERENCES PEDIDOS(id_pedido)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    FOREIGN KEY (id_metodo_pago) REFERENCES METODOS_PAGO(id_metodo_pago)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    
    -- Validación
    CHECK (monto > 0)
) ENGINE=InnoDB COMMENT='Registro de pagos';

-- ----------------------------------------------------------------------------
-- Tabla: MOVIMIENTOS_STOCK
-- Descripción: Registro de entradas y salidas de ingredientes
-- ----------------------------------------------------------------------------
CREATE TABLE MOVIMIENTOS_STOCK (
    id_movimiento INT AUTO_INCREMENT,
    id_ingrediente INT NOT NULL,
    tipo_movimiento ENUM('ENTRADA', 'SALIDA', 'AJUSTE') NOT NULL,
    cantidad DECIMAL(10,2) NOT NULL,
    fecha_movimiento DATETIME DEFAULT CURRENT_TIMESTAMP,
    motivo VARCHAR(200),
    id_empleado INT NOT NULL,
    
    -- Definir clave primaria
    PRIMARY KEY (id_movimiento),
    
    -- Definir claves foráneas
    FOREIGN KEY (id_ingrediente) REFERENCES INGREDIENTES(id_ingrediente)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    FOREIGN KEY (id_empleado) REFERENCES EMPLEADOS(id_empleado)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    
    -- Crear índice
    INDEX idx_fecha_movimiento (fecha_movimiento)
) ENGINE=InnoDB COMMENT='Movimientos de stock de ingredientes';

-- ============================================================================
-- 3. DATOS EJEMPLO
-- ============================================================================

-- Insertar categorías de productos
INSERT INTO CATEGORIAS_PRODUCTOS (nombre_categoria, descripcion) VALUES
('Empanadas Tradicionales', 'Empanadas con recetas clásicas del norte argentino'),
('Empanadas Especiales', 'Empanadas gourmet con ingredientes premium'),
('Empanadas Dulces', 'Empanadas de sabores dulces'),
('Bebidas', 'Bebidas frías y calientes'),
('Adicionales', 'Salsas y acompañamientos');

-- Insertar productos de ejemplo
INSERT INTO PRODUCTOS (id_categoria, nombre_producto, descripcion, precio_unitario, costo_produccion, disponible, tiempo_preparacion) VALUES
(1, 'Empanada de Carne', 'Empanada criolla rellena de carne cortada a cuchillo, cebolla, huevo y especias', 800.00, 350.00, TRUE, 15),
(1, 'Empanada de Pollo', 'Pollo desmenuzado con cebolla, morrones y aceitunas', 750.00, 320.00, TRUE, 15),
(1, 'Empanada de Jamón y Queso', 'Jamón cocido y queso muzzarella', 700.00, 280.00, TRUE, 12),
(1, 'Empanada de Humita', 'Choclo fresco, cebolla, queso y especias', 750.00, 300.00, TRUE, 15),
(1, 'Empanada Caprese', 'Tomate, muzzarella, albahaca y aceite de oliva', 750.00, 300.00, TRUE, 12),
(2, 'Empanada de Cordero', 'Cordero patagónico con hierbas aromáticas', 1200.00, 550.00, TRUE, 20),
(2, 'Empanada de Quinoa', 'Quinoa, vegetales y queso de cabra', 900.00, 400.00, TRUE, 18),
(2, 'Empanada Vegetariana Gourmet', 'Berenjenas, pimientos, calabaza y queso azul', 850.00, 380.00, TRUE, 18),
(3, 'Empanada de Membrillo', 'Dulce de membrillo casero', 600.00, 250.00, TRUE, 10),
(3, 'Empanada de Dulce de Leche', 'Dulce de leche repostero', 650.00, 270.00, TRUE, 10),
(4, 'Coca Cola 500ml', 'Gaseosa cola', 500.00, 250.00, TRUE, 0),
(4, 'Agua Mineral 500ml', 'Agua sin gas', 350.00, 180.00, TRUE, 0),
(4, 'Vino Tinto Malbec', 'Vino tinto argentino 750ml', 2500.00, 1200.00, TRUE, 0),
(5, 'Chimichurri Artesanal', 'Salsa criolla picante 200ml', 800.00, 300.00, TRUE, 0),
(5, 'Salsa Criolla', 'Cebolla, tomate y especias 200ml', 700.00, 280.00, TRUE, 0);

-- Insertar roles de empleados
INSERT INTO ROLES_EMPLEADOS (nombre_rol, descripcion) VALUES
('Gerente', 'Responsable general del negocio'),
('Maestro Empanador', 'Encargado de producción y preparación'),
('Ayudante de Cocina', 'Asiste en la preparación de empanadas'),
('Cajero', 'Atiende ventas en mostrador'),
('Repartidor', 'Realiza entregas a domicilio'),
('Encargado de Compras', 'Gestiona proveedores y stock');

-- Insertar empleados de ejemplo
INSERT INTO EMPLEADOS (id_rol, nombre_empleado, dni, telefono, fecha_ingreso, salario, activo) VALUES
(1, 'Juan Carlos Pérez', '25123456', '1145678901', '2023-01-15', 450000.00, TRUE),
(2, 'María González', '32456789', '1156789012', '2023-02-01', 380000.00, TRUE),
(3, 'Roberto Fernández', '28789456', '1167890123', '2023-03-10', 300000.00, TRUE),
(4, 'Laura Martínez', '35123789', '1178901234', '2023-04-05', 320000.00, TRUE),
(5, 'Diego Rodríguez', '30456123', '1189012345', '2023-05-20', 280000.00, TRUE);

-- Insertar proveedores
INSERT INTO PROVEEDORES (nombre_proveedor, cuit, telefono, email, direccion, activo) VALUES
('Carnicería Don José', '20-12345678-9', '1134567890', 'contacto@carniceriadonjose.com.ar', 'Av. Rivadavia 1234, Morón', TRUE),
('Verduras del Campo', '20-98765432-1', '1145678901', 'ventas@verdurasdelcampo.com.ar', 'Calle 25 de Mayo 567, Morón', TRUE),
('Distribuidora La Masa', '30-11223344-5', '1156789012', 'pedidos@lamasa.com.ar', 'Av. Gaona 890, Morón', TRUE),
('Bebidas Sur', '30-55667788-9', '1167890123', 'info@bebidassur.com.ar', 'Calle Mitre 345, Morón', TRUE);

-- Insertar ingredientes
INSERT INTO INGREDIENTES (id_proveedor, nombre_ingrediente, unidad_medida, stock_actual, stock_minimo, precio_unitario) VALUES
(1, 'Carne picada', 'kg', 50.00, 10.00, 4500.00),
(1, 'Pollo', 'kg', 30.00, 8.00, 3200.00),
(1, 'Jamón cocido', 'kg', 15.00, 5.00, 5800.00),
(1, 'Cordero', 'kg', 10.00, 3.00, 8500.00),
(2, 'Cebolla', 'kg', 25.00, 5.00, 800.00),
(2, 'Tomate', 'kg', 20.00, 5.00, 1200.00),
(2, 'Morrón rojo', 'kg', 15.00, 3.00, 1500.00),
(2, 'Choclo', 'kg', 18.00, 4.00, 1800.00),
(3, 'Masa para empanadas', 'unidades', 500.00, 100.00, 45.00),
(3, 'Queso muzzarella', 'kg', 20.00, 5.00, 4200.00),
(3, 'Huevos', 'unidades', 100.00, 20.00, 85.00),
(4, 'Coca Cola 500ml', 'unidades', 48.00, 12.00, 250.00),
(4, 'Agua Mineral 500ml', 'unidades', 60.00, 15.00, 180.00);

-- Insertar métodos de pago
INSERT INTO METODOS_PAGO (nombre_metodo, activo) VALUES
('Efectivo', TRUE),
('Tarjeta de Débito', TRUE),
('Tarjeta de Crédito', TRUE),
('Transferencia Bancaria', TRUE),
('MercadoPago', TRUE);

-- Insertar clientes de ejemplo
INSERT INTO CLIENTES (nombre, telefono, email, activo) VALUES
('Ana López', '1134567890', 'ana.lopez@email.com', TRUE),
('Carlos Gómez', '1145678901', 'carlos.gomez@email.com', TRUE),
('Patricia Ruiz', '1156789012', 'patricia.ruiz@email.com', TRUE),
('Fernando Díaz', '1167890123', 'fernando.diaz@email.com', TRUE),
('Silvia Castro', '1178901234', 'silvia.castro@email.com', TRUE);

-- Insertar direcciones de clientes
INSERT INTO DIRECCIONES (id_cliente, calle, numero, piso, barrio, ciudad, codigo_postal, principal) VALUES
(1, 'Av. Rivadavia', '1234', '3B', 'Centro', 'Morón', '1708', TRUE),
(2, 'Calle Mitre', '567', NULL, 'Palomar', 'Morón', '1684', TRUE),
(3, 'Av. Gaona', '890', '2A', 'Castelar', 'Morón', '1712', TRUE),
(4, 'Calle Brown', '345', NULL, 'El Palomar', 'Morón', '1684', TRUE),
(5, 'Av. San Martín', '678', '5C', 'Morón Sur', 'Morón', '1708', TRUE);

SHOW TABLES;

-- Mostrar la estructura de una tabla de ejemplo
DESCRIBE PRODUCTOS;

