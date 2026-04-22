-- ============================================================================
-- PROYECTO: SABORES DEL NORTE - Estructura de Base de Datos
-- ============================================================================

DROP DATABASE IF EXISTS sabores_del_norte;
CREATE DATABASE sabores_del_norte CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE sabores_del_norte;

CREATE TABLE ROLES_EMPLEADOS (
    id_rol INT AUTO_INCREMENT PRIMARY KEY,
    nombre_rol VARCHAR(50) NOT NULL,
    descripcion VARCHAR(100)
);

CREATE TABLE METODOS_PAGO (
    id_metodo INT AUTO_INCREMENT PRIMARY KEY,
    nombre_metodo VARCHAR(50) NOT NULL,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE CATEGORIAS_PRODUCTOS (
    id_categoria INT AUTO_INCREMENT PRIMARY KEY,
    nombre_categoria VARCHAR(50) NOT NULL,
    descripcion VARCHAR(100)
);

CREATE TABLE CLIENTES (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    telefono VARCHAR(20),
    email VARCHAR(100),
    fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE DIRECCIONES (
    id_direccion INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT,
    calle VARCHAR(100),
    numero VARCHAR(10),
    localidad VARCHAR(50),
    FOREIGN KEY (id_cliente) REFERENCES CLIENTES(id_cliente)
);

CREATE TABLE EMPLEADOS (
    id_empleado INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    id_rol INT,
    fecha_ingreso DATE,
    FOREIGN KEY (id_rol) REFERENCES ROLES_EMPLEADOS(id_rol)
);

CREATE TABLE PROVEEDORES (
    id_proveedor INT AUTO_INCREMENT PRIMARY KEY,
    nombre_empresa VARCHAR(100) NOT NULL,
    contacto VARCHAR(50)
);

CREATE TABLE INGREDIENTES (
    id_ingrediente INT AUTO_INCREMENT PRIMARY KEY,
    nombre_ingrediente VARCHAR(100) NOT NULL,
    unidad_medida VARCHAR(20),
    stock_actual DECIMAL(10,4) DEFAULT 0,
    stock_minimo DECIMAL(10,4) DEFAULT 0,
    id_proveedor INT,
    FOREIGN KEY (id_proveedor) REFERENCES PROVEEDORES(id_proveedor)
);

CREATE TABLE PRODUCTOS (
    id_producto INT AUTO_INCREMENT PRIMARY KEY,
    nombre_producto VARCHAR(100) NOT NULL,
    id_categoria INT,
    precio_unitario DECIMAL(10,4) NOT NULL,
    tiempo_preparacion INT,
    disponible BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (id_categoria) REFERENCES CATEGORIAS_PRODUCTOS(id_categoria)
);

CREATE TABLE PRODUCTOS_INGREDIENTES (
    id_prod_ing INT AUTO_INCREMENT PRIMARY KEY,
    id_producto INT,
    id_ingrediente INT,
    cantidad_necesaria DECIMAL(10,4) NOT NULL,
    FOREIGN KEY (id_producto) REFERENCES PRODUCTOS(id_producto),
    FOREIGN KEY (id_ingrediente) REFERENCES INGREDIENTES(id_ingrediente)
);

CREATE TABLE PEDIDOS (
    id_pedido INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT,
    id_empleado INT,
    tipo_pedido ENUM('LOCAL', 'DELIVERY', 'ANTICIPADO'),
    fecha_pedido DATETIME DEFAULT CURRENT_TIMESTAMP,
    observaciones VARCHAR(200),
    FOREIGN KEY (id_cliente) REFERENCES CLIENTES(id_cliente),
    FOREIGN KEY (id_empleado) REFERENCES EMPLEADOS(id_empleado)
);

CREATE TABLE DETALLE_PEDIDOS (
    id_detalle INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido INT,
    id_producto INT,
    cantidad INT,
    precio_venta DECIMAL(10,4),
    FOREIGN KEY (id_pedido) REFERENCES PEDIDOS(id_pedido),
    FOREIGN KEY (id_producto) REFERENCES PRODUCTOS(id_producto)
);

CREATE TABLE PAGOS (
    id_pago INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido INT,
    monto DECIMAL(10,4),
    fecha_pago DATETIME,
    id_metodo INT,
    FOREIGN KEY (id_pedido) REFERENCES PEDIDOS(id_pedido),
    FOREIGN KEY (id_metodo) REFERENCES METODOS_PAGO(id_metodo)
);

CREATE TABLE MOVIMIENTOS_STOCK (
    id_movimiento INT AUTO_INCREMENT PRIMARY KEY,
    id_ingrediente INT,
    tipo_movimiento ENUM('ENTRADA', 'SALIDA', 'AJUSTE'),
    cantidad DECIMAL(10,4),
    fecha_movimiento DATETIME DEFAULT CURRENT_TIMESTAMP,
    id_empleado INT,
    FOREIGN KEY (id_ingrediente) REFERENCES INGREDIENTES(id_ingrediente),
    FOREIGN KEY (id_empleado) REFERENCES EMPLEADOS(id_empleado)
);

CREATE TABLE AUDITORIA_SISTEMA (
    id_auditoria INT AUTO_INCREMENT PRIMARY KEY,
    tabla_afectada VARCHAR(50),
    operacion VARCHAR(20),
    fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP,
    detalle VARCHAR(255)
);
USE sabores_del_norte;

DELIMITER //

CREATE OR REPLACE VIEW vw_productos_disponibles AS
SELECT p.nombre_producto, c.nombre_categoria, p.precio_unitario 
FROM PRODUCTOS p
JOIN CATEGORIAS_PRODUCTOS c ON p.id_categoria = c.id_categoria
WHERE p.disponible = TRUE;

CREATE OR REPLACE VIEW vw_pedidos_completos AS
SELECT p.id_pedido, c.nombre AS cliente, p.tipo_pedido, p.fecha_pedido
FROM PEDIDOS p
JOIN CLIENTES c ON p.id_cliente = c.id_cliente;

CREATE OR REPLACE VIEW vw_ingredientes_stock_bajo AS
SELECT nombre_ingrediente, stock_actual, stock_minimo 
FROM INGREDIENTES 
WHERE stock_actual <= stock_minimo;

CREATE OR REPLACE VIEW vw_productos_mas_vendidos AS
SELECT p.nombre_producto, COUNT(d.id_detalle) AS total_vendido
FROM PRODUCTOS p
JOIN DETALLE_PEDIDOS d ON p.id_producto = d.id_producto
GROUP BY p.nombre_producto ORDER BY total_vendido DESC;

CREATE OR REPLACE VIEW vw_ventas_por_empleado AS
SELECT e.nombre, COUNT(p.id_pedido) AS total_pedidos
FROM EMPLEADOS e
LEFT JOIN PEDIDOS p ON e.id_empleado = p.id_empleado
GROUP BY e.nombre;

CREATE FUNCTION fn_calcular_ganancia_pedido(p_id_pedido INT) 
RETURNS DECIMAL(10,4)
DETERMINISTIC
BEGIN
    DECLARE v_ingreso DECIMAL(10,4);
    SELECT SUM(precio_venta * cantidad) INTO v_ingreso FROM DETALLE_PEDIDOS WHERE id_pedido = p_id_pedido;
    RETURN v_ingreso;
END //

CREATE FUNCTION fn_contar_pedidos_cliente(p_id_cliente INT) 
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE v_total INT;
    SELECT COUNT(*) INTO v_total FROM PEDIDOS WHERE id_cliente = p_id_cliente;
    RETURN v_total;
END //

CREATE PROCEDURE sp_registrar_pedido(
    IN p_id_cliente INT, IN p_id_empleado INT, IN p_tipo ENUM('LOCAL', 'DELIVERY', 'ANTICIPADO')
)
BEGIN
    INSERT INTO PEDIDOS (id_cliente, id_empleado, tipo_pedido) VALUES (p_id_cliente, p_id_empleado, p_tipo);
END //

CREATE PROCEDURE sp_actualizar_estado_pedido(IN p_id_pedido INT, IN p_estado ENUM('PENDIENTE', 'PREPARACION', 'LISTO', 'ENTREGADO', 'CANCELADO'))
BEGIN
    UPDATE PEDIDOS SET tipo_pedido = p_estado WHERE id_pedido = p_id_pedido;
END //

CREATE TRIGGER trg_auditoria_precio
AFTER UPDATE ON PRODUCTOS
FOR EACH ROW
BEGIN
    IF OLD.precio_unitario <> NEW.precio_unitario THEN
        INSERT INTO AUDITORIA_SISTEMA (tabla_afectada, operacion, detalle) 
        VALUES ('PRODUCTOS', 'UPDATE_PRECIO', CONCAT('Producto ID: ', NEW.id_producto, ' cambio de ', OLD.precio_unitario, ' a ', NEW.precio_unitario));
    END IF;
END //

CREATE TRIGGER trg_descontar_stock
AFTER INSERT ON DETALLE_PEDIDOS
FOR EACH ROW
BEGIN
    UPDATE INGREDIENTES i
    JOIN PRODUCTOS_INGREDIENTES pi ON i.id_ingrediente = pi.id_ingrediente
    SET i.stock_actual = i.stock_actual - (pi.cantidad_necesaria * NEW.cantidad)
    WHERE pi.id_producto = NEW.id_producto;
END //

DELIMITER ;
USE sabores_del_norte;

SET SQL_SAFE_UPDATES = 0;
SET FOREIGN_KEY_CHECKS = 0;

INSERT INTO ROLES_EMPLEADOS (nombre_rol, descripcion) VALUES
('Gerente', 'Responsable general'),
('Maestro Empanador', 'Encargado de producción'),
('Ayudante', 'Asiste en cocina'),
('Cajero', 'Atención al público'),
('Repartidor', 'Delivery');

INSERT INTO METODOS_PAGO (nombre_metodo, activo) VALUES
('Efectivo', TRUE),
('Tarjeta', TRUE),
('Transferencia', TRUE);

INSERT INTO CATEGORIAS_PRODUCTOS (nombre_categoria, descripcion) VALUES
('Tradicionales', 'Empanadas clásicas'),
('Especiales', 'Empanadas gourmet'),
('Bebidas', 'Gaseosas y aguas');

INSERT INTO CLIENTES (nombre, telefono, email) VALUES
('Ana López', '1134567890', 'ana@email.com'),
('Carlos Gómez', '1145678901', 'carlos@email.com');

INSERT INTO EMPLEADOS (nombre, id_rol, fecha_ingreso) VALUES
('Juan Pérez', 1, '2023-01-15'),
('María González', 2, '2023-02-01');

INSERT INTO PROVEEDORES (nombre_empresa, contacto) VALUES
('Carnicería Don José', '1134567890'),
('Verduras del Campo', '1145678901');

INSERT INTO INGREDIENTES (nombre_ingrediente, unidad_medida, stock_actual, stock_minimo, id_proveedor) VALUES
('Carne picada', 'kg', 50.0000, 10.0000, 1),
('Cebolla', 'kg', 25.0000, 5.0000, 2);

INSERT INTO PRODUCTOS (nombre_producto, id_categoria, precio_unitario, tiempo_preparacion) VALUES
('Empanada Carne', 1, 800.0000, 15),
('Empanada Pollo', 1, 750.0000, 15);

INSERT INTO PRODUCTOS_INGREDIENTES (id_producto, id_ingrediente, cantidad_necesaria) VALUES
(1, 1, 0.0800),
(1, 2, 0.0200);

INSERT INTO PEDIDOS (id_cliente, id_empleado, tipo_pedido) VALUES 
(1, 1, 'LOCAL'),
(2, 2, 'DELIVERY'),
(1, 1, 'ANTICIPADO'),
(2, 2, 'LOCAL'),
(1, 2, 'DELIVERY'),
(2, 1, 'LOCAL');

INSERT INTO DETALLE_PEDIDOS (id_pedido, id_producto, cantidad, precio_venta) VALUES 
(2, 1, 10, 800.0000),
(2, 2, 5, 750.0000),
(3, 1, 2, 800.0000),
(4, 2, 8, 750.0000),
(5, 1, 15, 800.0000),
(6, 2, 3, 750.0000),
(7, 1, 1, 800.0000);

SET FOREIGN_KEY_CHECKS = 1;