-- ============================================================================
-- PROYECTO: SABORES DEL NORTE - Inserción de Datos
-- Autor: Palacio Cristian
-- Curso: SQL
-- Fecha: Febrero 2026
-- Descripción: Script de inserción de datos de prueba para todas las tablas
-- ============================================================================

USE sabores_del_norte;

-- 1. Desactivamos las restricciones para poder limpiar las tablas con FK
SET FOREIGN_KEY_CHECKS = 0;

-- 2. Limpiamos las tablas (en orden inverso de dependencia o masivo)
TRUNCATE TABLE DETALLE_PEDIDOS;
TRUNCATE TABLE PAGOS;
TRUNCATE TABLE PEDIDOS;
TRUNCATE TABLE PRODUCTOS_INGREDIENTES;
TRUNCATE TABLE PRODUCTOS;
TRUNCATE TABLE CATEGORIAS_PRODUCTOS;
TRUNCATE TABLE MOVIMIENTOS_STOCK;
TRUNCATE TABLE INGREDIENTES;
TRUNCATE TABLE PROVEEDORES;
TRUNCATE TABLE DIRECCIONES;
TRUNCATE TABLE CLIENTES;
TRUNCATE TABLE EMPLEADOS;
TRUNCATE TABLE ROLES_EMPLEADOS;
TRUNCATE TABLE METODOS_PAGO;

-- 3. Volvemos a activar las restricciones
SET FOREIGN_KEY_CHECKS = 1;


-- ============================================================================
-- 1. INSERCIÓN DE DATOS EN TABLAS MAESTRAS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Tabla: CATEGORIAS_PRODUCTOS
-- ----------------------------------------------------------------------------
INSERT INTO CATEGORIAS_PRODUCTOS (nombre_categoria, descripcion) VALUES
('Empanadas Tradicionales', 'Empanadas con recetas clásicas del norte argentino'),
('Empanadas Especiales', 'Empanadas gourmet con ingredientes premium'),
('Empanadas Dulces', 'Empanadas de sabores dulces'),
('Bebidas', 'Bebidas frías y calientes'),
('Adicionales', 'Salsas y acompañamientos');

-- ----------------------------------------------------------------------------
-- Tabla: PRODUCTOS
-- ----------------------------------------------------------------------------
INSERT INTO PRODUCTOS (id_categoria, nombre_producto, descripcion, precio_unitario, costo_produccion, disponible, tiempo_preparacion) VALUES
-- Empanadas Tradicionales
(1, 'Empanada de Carne', 'Empanada criolla rellena de carne cortada a cuchillo, cebolla, huevo y especias', 800.00, 350.00, TRUE, 15),
(1, 'Empanada de Pollo', 'Pollo desmenuzado con cebolla, morrones y aceitunas', 750.00, 320.00, TRUE, 15),
(1, 'Empanada de Jamón y Queso', 'Jamón cocido y queso muzzarella', 700.00, 280.00, TRUE, 12),
(1, 'Empanada de Humita', 'Choclo fresco, cebolla, queso y especias', 750.00, 300.00, TRUE, 15),
(1, 'Empanada Caprese', 'Tomate, muzzarella, albahaca y aceite de oliva', 750.00, 300.00, TRUE, 12),
-- Empanadas Especiales
(2, 'Empanada de Cordero', 'Cordero patagónico con hierbas aromáticas', 1200.00, 550.00, TRUE, 20),
(2, 'Empanada de Quinoa', 'Quinoa, vegetales y queso de cabra', 900.00, 400.00, TRUE, 18),
(2, 'Empanada Vegetariana Gourmet', 'Berenjenas, pimientos, calabaza y queso azul', 850.00, 380.00, TRUE, 18),
-- Empanadas Dulces
(3, 'Empanada de Membrillo', 'Dulce de membrillo casero', 600.00, 250.00, TRUE, 10),
(3, 'Empanada de Dulce de Leche', 'Dulce de leche repostero', 650.00, 270.00, TRUE, 10),
(3, 'Empanada de Manzana', 'Manzanas caramelizadas con canela', 650.00, 280.00, TRUE, 10),
-- Bebidas
(4, 'Coca Cola 500ml', 'Gaseosa cola', 500.00, 250.00, TRUE, 0),
(4, 'Sprite 500ml', 'Gaseosa lima-limón', 500.00, 250.00, TRUE, 0),
(4, 'Agua Mineral 500ml', 'Agua sin gas', 350.00, 180.00, TRUE, 0),
(4, 'Agua Mineral con Gas 500ml', 'Agua con gas', 350.00, 180.00, TRUE, 0),
(4, 'Jugo Naranja 500ml', 'Jugo natural de naranja', 600.00, 300.00, TRUE, 0),
(4, 'Vino Tinto Malbec', 'Vino tinto argentino 750ml', 2500.00, 1200.00, TRUE, 0),
(4, 'Vino Blanco Torrontés', 'Vino blanco argentino 750ml', 2300.00, 1100.00, TRUE, 0),
-- Adicionales
(5, 'Chimichurri Artesanal', 'Salsa criolla picante 200ml', 800.00, 300.00, TRUE, 0),
(5, 'Salsa Criolla', 'Cebolla, tomate y especias 200ml', 700.00, 280.00, TRUE, 0),
(5, 'Salsa Picante', 'Salsa muy picante 200ml', 750.00, 290.00, TRUE, 0);

-- ----------------------------------------------------------------------------
-- Tabla: PROVEEDORES
-- ----------------------------------------------------------------------------
INSERT INTO PROVEEDORES (nombre_proveedor, cuit, telefono, email, direccion, activo) VALUES
('Carnicería Don José', '20-12345678-9', '1134567890', 'contacto@carniceriadonjose.com.ar', 'Av. Rivadavia 1234, Morón', TRUE),
('Verduras del Campo', '20-98765432-1', '1145678901', 'ventas@verdurasdelcampo.com.ar', 'Calle 25 de Mayo 567, Morón', TRUE),
('Distribuidora La Masa', '30-11223344-5', '1156789012', 'pedidos@lamasa.com.ar', 'Av. Gaona 890, Morón', TRUE),
('Bebidas Sur', '30-55667788-9', '1167890123', 'info@bebidassur.com.ar', 'Calle Mitre 345, Morón', TRUE),
('Lacteos La Vaca Feliz', '30-99887766-4', '1178901234', 'ventas@lavacafeliz.com.ar', 'Av. San Martín 678, Morón', TRUE),
('Especias del Norte', '20-44556677-8', '1189012345', 'contacto@especiasdelnorte.com.ar', 'Calle Brown 234, Morón', TRUE);

-- ----------------------------------------------------------------------------
-- Tabla: INGREDIENTES
-- ----------------------------------------------------------------------------
INSERT INTO INGREDIENTES (id_proveedor, nombre_ingrediente, unidad_medida, stock_actual, stock_minimo, precio_unitario) VALUES
-- Carnicería Don José (id_proveedor = 1)
(1, 'Carne picada', 'kg', 50.00, 10.00, 4500.00),
(1, 'Pollo', 'kg', 30.00, 8.00, 3200.00),
(1, 'Jamón cocido', 'kg', 15.00, 5.00, 5800.00),
(1, 'Cordero', 'kg', 10.00, 3.00, 8500.00),
-- Verduras del Campo (id_proveedor = 2)
(2, 'Cebolla', 'kg', 25.00, 5.00, 800.00),
(2, 'Tomate', 'kg', 20.00, 5.00, 1200.00),
(2, 'Morrón rojo', 'kg', 15.00, 3.00, 1500.00),
(2, 'Choclo', 'kg', 18.00, 4.00, 1800.00),
(2, 'Berenjena', 'kg', 12.00, 3.00, 1300.00),
(2, 'Calabaza', 'kg', 14.00, 3.00, 1100.00),
(2, 'Albahaca', 'kg', 2.00, 0.5, 4500.00),
(2, 'Manzana', 'kg', 20.00, 5.00, 1600.00),
-- Distribuidora La Masa (id_proveedor = 3)
(3, 'Masa para empanadas', 'unidades', 500.00, 100.00, 45.00),
(3, 'Harina', 'kg', 100.00, 20.00, 350.00),
-- Bebidas Sur (id_proveedor = 4)
(4, 'Coca Cola 500ml', 'unidades', 48.00, 12.00, 250.00),
(4, 'Sprite 500ml', 'unidades', 36.00, 12.00, 250.00),
(4, 'Agua Mineral 500ml', 'unidades', 60.00, 15.00, 180.00),
(4, 'Agua con Gas 500ml', 'unidades', 48.00, 12.00, 180.00),
(4, 'Jugo Naranja 500ml', 'unidades', 30.00, 10.00, 300.00),
(4, 'Vino Tinto', 'unidades', 24.00, 6.00, 1200.00),
(4, 'Vino Blanco', 'unidades', 18.00, 6.00, 1100.00),
-- Lacteos La Vaca Feliz (id_proveedor = 5)
(5, 'Queso muzzarella', 'kg', 20.00, 5.00, 4200.00),
(5, 'Queso de cabra', 'kg', 8.00, 2.00, 6500.00),
(5, 'Queso azul', 'kg', 5.00, 1.00, 7200.00),
(5, 'Huevos', 'unidades', 100.00, 20.00, 85.00),
-- Especias del Norte (id_proveedor = 6)
(6, 'Sal', 'kg', 10.00, 2.00, 150.00),
(6, 'Pimienta', 'kg', 5.00, 1.00, 3500.00),
(6, 'Comino', 'kg', 3.00, 0.5, 4200.00),
(6, 'Ají molido', 'kg', 4.00, 1.00, 3800.00),
(6, 'Aceitunas', 'kg', 12.00, 3.00, 2200.00),
(6, 'Canela', 'kg', 2.00, 0.5, 5500.00);

-- ----------------------------------------------------------------------------
-- Tabla: PRODUCTOS_INGREDIENTES (Recetas)
-- ----------------------------------------------------------------------------
INSERT INTO PRODUCTOS_INGREDIENTES (id_producto, id_ingrediente, cantidad_necesaria) VALUES
-- Empanada de Carne (id_producto = 1)
(1, 1, 0.080),  -- 80g carne picada
(1, 5, 0.020),  -- 20g cebolla
(1, 25, 1.000), -- 1 huevo
(1, 13, 1.000), -- 1 masa
(1, 26, 0.002), -- 2g sal
(1, 27, 0.001), -- 1g pimienta
(1, 28, 0.002), -- 2g comino
-- Empanada de Pollo (id_producto = 2)
(2, 2, 0.080),  -- 80g pollo
(2, 5, 0.020),  -- 20g cebolla
(2, 7, 0.015),  -- 15g morrón
(2, 30, 0.010), -- 10g aceitunas
(2, 13, 1.000), -- 1 masa
(2, 26, 0.002), -- 2g sal
(2, 27, 0.001), -- 1g pimienta
-- Empanada de Jamón y Queso (id_producto = 3)
(3, 3, 0.060),  -- 60g jamón
(3, 22, 0.050), -- 50g queso muzzarella
(3, 13, 1.000), -- 1 masa
-- Empanada de Humita (id_producto = 4)
(4, 8, 0.100),  -- 100g choclo
(4, 5, 0.020),  -- 20g cebolla
(4, 22, 0.030), -- 30g queso muzzarella
(4, 13, 1.000), -- 1 masa
-- Empanada Caprese (id_producto = 5)
(5, 6, 0.050),  -- 50g tomate
(5, 22, 0.050), -- 50g queso muzzarella
(5, 11, 0.005), -- 5g albahaca
(5, 13, 1.000), -- 1 masa
-- Empanada de Cordero (id_producto = 6)
(6, 4, 0.100),  -- 100g cordero
(6, 5, 0.020),  -- 20g cebolla
(6, 13, 1.000), -- 1 masa
(6, 26, 0.002), -- 2g sal
(6, 27, 0.001), -- 1g pimienta
-- Empanada de Quinoa (id_producto = 7)
(7, 23, 0.040), -- 40g queso de cabra
(7, 9, 0.030),  -- 30g berenjena
(7, 10, 0.030), -- 30g calabaza
(7, 13, 1.000), -- 1 masa
-- Empanada Vegetariana Gourmet (id_producto = 8)
(8, 9, 0.040),  -- 40g berenjena
(8, 7, 0.030),  -- 30g morrón
(8, 10, 0.030), -- 30g calabaza
(8, 24, 0.020), -- 20g queso azul
(8, 13, 1.000), -- 1 masa
-- Empanada de Membrillo (id_producto = 9)
(9, 13, 1.000), -- 1 masa
-- (El membrillo no está en ingredientes, se considera ya preparado)
-- Empanada de Dulce de Leche (id_producto = 10)
(10, 13, 1.000), -- 1 masa
-- (El dulce de leche no está en ingredientes)
-- Empanada de Manzana (id_producto = 11)
(11, 12, 0.100), -- 100g manzana
(11, 31, 0.003), -- 3g canela
(11, 13, 1.000); -- 1 masa

-- ----------------------------------------------------------------------------
-- Tabla: ROLES_EMPLEADOS
-- ----------------------------------------------------------------------------
INSERT INTO ROLES_EMPLEADOS (nombre_rol, descripcion) VALUES
('Gerente', 'Responsable general del negocio y toma de decisiones estratégicas'),
('Maestro Empanador', 'Encargado de producción y preparación de empanadas'),
('Ayudante de Cocina', 'Asiste en la preparación de empanadas y limpieza'),
('Cajero', 'Atiende ventas en mostrador y procesa pagos'),
('Repartidor', 'Realiza entregas a domicilio'),
('Encargado de Compras', 'Gestiona proveedores y control de stock');

-- ----------------------------------------------------------------------------
-- Tabla: EMPLEADOS
-- ----------------------------------------------------------------------------
INSERT INTO EMPLEADOS (id_rol, nombre_empleado, dni, telefono, fecha_ingreso, salario, activo) VALUES
(1, 'Juan Carlos Pérez', '25123456', '1145678901', '2023-01-15', 450000.00, TRUE),
(2, 'María González', '32456789', '1156789012', '2023-02-01', 380000.00, TRUE),
(3, 'Roberto Fernández', '28789456', '1167890123', '2023-03-10', 300000.00, TRUE),
(4, 'Laura Martínez', '35123789', '1178901234', '2023-04-05', 320000.00, TRUE),
(5, 'Diego Rodríguez', '30456123', '1189012345', '2023-05-20', 280000.00, TRUE),
(6, 'Carla Sánchez', '33789456', '1190123456', '2023-06-15', 340000.00, TRUE),
(3, 'Martín López', '29456789', '1101234567', '2023-07-10', 300000.00, TRUE),
(5, 'Andrea Castro', '31234567', '1112345678', '2023-08-01', 280000.00, TRUE);

-- ----------------------------------------------------------------------------
-- Tabla: METODOS_PAGO
-- ----------------------------------------------------------------------------
INSERT INTO METODOS_PAGO (nombre_metodo, activo) VALUES
('Efectivo', TRUE),
('Tarjeta de Débito', TRUE),
('Tarjeta de Crédito', TRUE),
('Transferencia Bancaria', TRUE),
('MercadoPago', TRUE),
('QR', TRUE);

-- ============================================================================
-- 2. INSERCIÓN DE DATOS DE CLIENTES
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Tabla: CLIENTES
-- ----------------------------------------------------------------------------
INSERT INTO CLIENTES (nombre, telefono, email, activo) VALUES
('Ana López', '1134567890', 'ana.lopez@email.com', TRUE),
('Carlos Gómez', '1145678901', 'carlos.gomez@email.com', TRUE),
('Patricia Ruiz', '1156789012', 'patricia.ruiz@email.com', TRUE),
('Fernando Díaz', '1167890123', 'fernando.diaz@email.com', TRUE),
('Silvia Castro', '1178901234', 'silvia.castro@email.com', TRUE),
('Roberto Morales', '1189012345', 'roberto.morales@email.com', TRUE),
('Claudia Fernández', '1190123456', 'claudia.fernandez@email.com', TRUE),
('Jorge Martínez', '1101234567', 'jorge.martinez@email.com', TRUE),
('Mónica Silva', '1112345678', 'monica.silva@email.com', TRUE),
('Pablo Rodríguez', '1123456789', 'pablo.rodriguez@email.com', TRUE),
('Gabriela Torres', '1134567891', 'gabriela.torres@email.com', TRUE),
('Hernán Pérez', '1145678902', 'hernan.perez@email.com', TRUE),
('Verónica García', '1156789013', 'veronica.garcia@email.com', TRUE),
('Marcelo González', '1167890124', 'marcelo.gonzalez@email.com', TRUE),
('Susana Ramírez', '1178901235', 'susana.ramirez@email.com', TRUE);

-- ----------------------------------------------------------------------------
-- Tabla: DIRECCIONES
-- ----------------------------------------------------------------------------
INSERT INTO DIRECCIONES (id_cliente, calle, numero, piso, barrio, ciudad, codigo_postal, referencia, principal) VALUES
-- Cliente 1: Ana López
(1, 'Av. Rivadavia', '1234', '3B', 'Centro', 'Morón', '1708', 'Edificio azul, portón negro', TRUE),
-- Cliente 2: Carlos Gómez
(2, 'Calle Mitre', '567', NULL, 'Palomar', 'Morón', '1684', 'Casa con rejas blancas', TRUE),
-- Cliente 3: Patricia Ruiz
(3, 'Av. Gaona', '890', '2A', 'Castelar', 'Morón', '1712', 'Torre Norte', TRUE),
(3, 'Calle Sarmiento', '456', NULL, 'Castelar Sur', 'Morón', '1712', 'Casa amarilla', FALSE),
-- Cliente 4: Fernando Díaz
(4, 'Calle Brown', '345', NULL, 'El Palomar', 'Morón', '1684', 'Al lado del kiosco', TRUE),
-- Cliente 5: Silvia Castro
(5, 'Av. San Martín', '678', '5C', 'Morón Sur', 'Morón', '1708', 'Edificio Torre Real', TRUE),
-- Cliente 6: Roberto Morales
(6, 'Calle Belgrano', '234', NULL, 'Centro', 'Morón', '1708', 'Frente a la plaza', TRUE),
-- Cliente 7: Claudia Fernández
(7, 'Av. Libertador', '1122', '4D', 'Haedo', 'Morón', '1706', 'Edificio Las Palmeras', TRUE),
-- Cliente 8: Jorge Martínez
(8, 'Calle Alsina', '789', NULL, 'Ramos Mejía', 'La Matanza', '1704', 'Casa con jardín', TRUE),
-- Cliente 9: Mónica Silva
(9, 'Av. de Mayo', '456', '1A', 'Centro', 'Morón', '1708', 'Sobre la avenida', TRUE),
-- Cliente 10: Pablo Rodríguez
(10, 'Calle Moreno', '890', NULL, 'Palomar', 'Morón', '1684', 'Esquina con San Martín', TRUE),
-- Cliente 11: Gabriela Torres
(11, 'Av. Gaona', '2345', '7B', 'Castelar', 'Morón', '1712', 'Torre Vista', TRUE),
-- Cliente 12: Hernán Pérez
(12, 'Calle Rivadavia', '567', NULL, 'Haedo', 'Morón', '1706', 'Casa roja', TRUE),
-- Cliente 13: Verónica García
(13, 'Av. San Martín', '1234', '2C', 'Centro', 'Morón', '1708', 'Edificio Central', TRUE),
-- Cliente 14: Marcelo González
(14, 'Calle 25 de Mayo', '678', NULL, 'Ramos Mejía', 'La Matanza', '1704', 'Al lado del supermercado', TRUE),
-- Cliente 15: Susana Ramírez
(15, 'Av. Libertador', '3456', '6A', 'Haedo', 'Morón', '1706', 'Torres del Sol', TRUE);

-- ============================================================================
-- 3. INSERCIÓN DE DATOS DE PEDIDOS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Tabla: PEDIDOS
-- ----------------------------------------------------------------------------
INSERT INTO PEDIDOS (id_cliente, id_empleado, id_direccion, fecha_pedido, fecha_entrega, tipo_pedido, estado_pedido, subtotal, costo_envio, total, observaciones) VALUES
-- Pedidos del día 2026-02-01
(1, 4, 1, '2026-02-01 12:30:00', '2026-02-01 13:00:00', 'DELIVERY', 'ENTREGADO', 4750.00, 500.00, 5250.00, 'Sin cebolla en las empanadas de carne'),
(2, 4, 2, '2026-02-01 13:15:00', NULL, 'LOCAL', 'ENTREGADO', 3200.00, 0.00, 3200.00, NULL),
(3, 4, 3, '2026-02-01 14:00:00', '2026-02-01 18:00:00', 'ANTICIPADO', 'ENTREGADO', 12000.00, 0.00, 12000.00, 'Pedido para evento familiar'),
-- Pedidos del día 2026-02-02
(4, 4, 4, '2026-02-02 11:00:00', '2026-02-02 12:00:00', 'DELIVERY', 'ENTREGADO', 5250.00, 500.00, 5750.00, 'Tocar timbre 2 veces'),
(5, 4, 5, '2026-02-02 12:45:00', NULL, 'LOCAL', 'ENTREGADO', 2800.00, 0.00, 2800.00, NULL),
(6, 4, 6, '2026-02-02 15:30:00', '2026-02-02 19:00:00', 'DELIVERY', 'ENTREGADO', 8400.00, 500.00, 8900.00, NULL),
-- Pedidos del día 2026-02-03
(7, 4, 7, '2026-02-03 10:30:00', '2026-02-03 11:00:00', 'DELIVERY', 'ENTREGADO', 6200.00, 500.00, 6700.00, 'Dejar en portería'),
(8, 4, 8, '2026-02-03 13:00:00', NULL, 'LOCAL', 'ENTREGADO', 4550.00, 0.00, 4550.00, NULL),
(9, 4, 9, '2026-02-03 16:00:00', '2026-02-03 20:00:00', 'ANTICIPADO', 'ENTREGADO', 15600.00, 0.00, 15600.00, 'Pedido para cumpleaños'),
-- Pedidos del día 2026-02-04
(10, 4, 10, '2026-02-04 11:30:00', '2026-02-04 12:30:00', 'DELIVERY', 'ENTREGADO', 7050.00, 500.00, 7550.00, NULL),
(11, 4, 11, '2026-02-04 14:00:00', NULL, 'LOCAL', 'ENTREGADO', 3600.00, 0.00, 3600.00, NULL),
(12, 4, 12, '2026-02-04 17:00:00', '2026-02-04 19:30:00', 'DELIVERY', 'ENTREGADO', 5900.00, 500.00, 6400.00, 'Casa de dos pisos'),
-- Pedidos del día 2026-02-05
(13, 4, 13, '2026-02-05 12:00:00', '2026-02-05 13:00:00', 'DELIVERY', 'ENTREGADO', 9250.00, 500.00, 9750.00, NULL),
(14, 4, 14, '2026-02-05 13:30:00', NULL, 'LOCAL', 'ENTREGADO', 4200.00, 0.00, 4200.00, NULL),
(15, 4, 15, '2026-02-05 18:00:00', '2026-02-06 12:00:00', 'ANTICIPADO', 'ENTREGADO', 18000.00, 0.00, 18000.00, 'Pedido para evento corporativo'),
-- Pedidos actuales (en proceso)
(1, 4, 1, '2026-02-06 11:00:00', '2026-02-06 12:00:00', 'DELIVERY', 'PREPARACION', 6400.00, 500.00, 6900.00, NULL),
(5, 4, 5, '2026-02-06 12:00:00', NULL, 'LOCAL', 'PENDIENTE', 3500.00, 0.00, 3500.00, NULL),
(10, 4, 10, '2026-02-06 13:00:00', '2026-02-06 14:00:00', 'DELIVERY', 'LISTO', 5800.00, 500.00, 6300.00, 'Llamar al llegar');

-- ----------------------------------------------------------------------------
-- Tabla: DETALLE_PEDIDOS
-- ----------------------------------------------------------------------------
INSERT INTO DETALLE_PEDIDOS (id_pedido, id_producto, cantidad, precio_unitario, subtotal) VALUES
-- Pedido 1 (Cliente: Ana López)
(1, 1, 4, 800.00, 3200.00),  -- 4 Empanadas de Carne
(1, 2, 2, 750.00, 1500.00),  -- 2 Empanadas de Pollo
(1, 14, 1, 350.00, 350.00),  -- 1 Agua
-- Pedido 2 (Cliente: Carlos Gómez)
(2, 3, 4, 700.00, 2800.00),  -- 4 Empanadas Jamón y Queso
(2, 12, 1, 500.00, 500.00),  -- 1 Coca Cola
-- Pedido 3 (Cliente: Patricia Ruiz - Evento)
(3, 1, 6, 800.00, 4800.00),  -- 6 Empanadas de Carne
(3, 2, 6, 750.00, 4500.00),  -- 6 Empanadas de Pollo
(3, 5, 4, 750.00, 3000.00),  -- 4 Empanadas Caprese
-- Pedido 4 (Cliente: Fernando Díaz)
(4, 6, 3, 1200.00, 3600.00), -- 3 Empanadas de Cordero
(4, 1, 2, 800.00, 1600.00),  -- 2 Empanadas de Carne
(4, 14, 1, 350.00, 350.00),  -- 1 Agua
-- Pedido 5 (Cliente: Silvia Castro)
(5, 4, 4, 750.00, 3000.00),  -- 4 Empanadas de Humita
-- Pedido 6 (Cliente: Roberto Morales)
(6, 1, 6, 800.00, 4800.00),  -- 6 Empanadas de Carne
(6, 2, 4, 750.00, 3000.00),  -- 4 Empanadas de Pollo
(6, 12, 2, 500.00, 1000.00), -- 2 Coca Cola
-- Pedido 7 (Cliente: Claudia Fernández)
(7, 7, 4, 900.00, 3600.00),  -- 4 Empanadas de Quinoa
(7, 8, 3, 850.00, 2550.00),  -- 3 Empanadas Vegetarianas
(7, 14, 2, 350.00, 700.00),  -- 2 Agua
-- Pedido 8 (Cliente: Jorge Martínez)
(8, 1, 3, 800.00, 2400.00),  -- 3 Empanadas de Carne
(8, 3, 3, 700.00, 2100.00),  -- 3 Empanadas Jamón y Queso
(8, 13, 1, 500.00, 500.00),  -- 1 Sprite
-- Pedido 9 (Cliente: Mónica Silva - Cumpleaños)
(9, 1, 8, 800.00, 6400.00),  -- 8 Empanadas de Carne
(9, 2, 8, 750.00, 6000.00),  -- 8 Empanadas de Pollo
(9, 9, 4, 600.00, 2400.00),  -- 4 Empanadas de Membrillo
(9, 10, 4, 650.00, 2600.00), -- 4 Empanadas de Dulce de Leche
(9, 12, 4, 500.00, 2000.00), -- 4 Coca Cola
-- Pedido 10 (Cliente: Pablo Rodríguez)
(10, 1, 5, 800.00, 4000.00), -- 5 Empanadas de Carne
(10, 2, 3, 750.00, 2250.00), -- 3 Empanadas de Pollo
(10, 12, 2, 500.00, 1000.00),-- 2 Coca Cola
-- Pedido 11 (Cliente: Gabriela Torres)
(11, 5, 4, 750.00, 3000.00), -- 4 Empanadas Caprese
(11, 14, 2, 350.00, 700.00), -- 2 Agua
-- Pedido 12 (Cliente: Hernán Pérez)
(12, 1, 4, 800.00, 3200.00), -- 4 Empanadas de Carne
(12, 4, 3, 750.00, 2250.00), -- 3 Empanadas de Humita
(12, 13, 1, 500.00, 500.00), -- 1 Sprite
-- Pedido 13 (Cliente: Verónica García)
(13, 6, 5, 1200.00, 6000.00),-- 5 Empanadas de Cordero
(13, 1, 4, 800.00, 3200.00), -- 4 Empanadas de Carne
(13, 14, 1, 350.00, 350.00), -- 1 Agua
-- Pedido 14 (Cliente: Marcelo González)
(14, 2, 4, 750.00, 3000.00), -- 4 Empanadas de Pollo
(14, 3, 2, 700.00, 1400.00), -- 2 Empanadas Jamón y Queso
-- Pedido 15 (Cliente: Susana Ramírez - Evento Corporativo)
(15, 1, 12, 800.00, 9600.00),  -- 12 Empanadas de Carne
(15, 2, 8, 750.00, 6000.00),   -- 8 Empanadas de Pollo
(15, 5, 6, 750.00, 4500.00),   -- 6 Empanadas Caprese
(15, 17, 2, 2500.00, 5000.00), -- 2 Vino Tinto
-- Pedidos en proceso (16, 17, 18)
(16, 1, 6, 800.00, 4800.00),   -- En preparación
(16, 2, 2, 750.00, 1500.00),
(16, 14, 2, 350.00, 700.00),
(17, 3, 5, 700.00, 3500.00),   -- Pendiente
(18, 1, 4, 800.00, 3200.00),   -- Listo para entregar
(18, 2, 3, 750.00, 2250.00),
(18, 12, 1, 500.00, 500.00);

-- ----------------------------------------------------------------------------
-- Tabla: PAGOS
-- ----------------------------------------------------------------------------
INSERT INTO PAGOS (id_pedido, id_metodo_pago, monto, fecha_pago, comprobante) VALUES
-- Pedido 1
(1, 1, 5250.00, '2026-02-01 13:00:00', NULL),
-- Pedido 2
(2, 2, 3200.00, '2026-02-01 13:20:00', '12345678'),
-- Pedido 3
(3, 4, 12000.00, '2026-02-01 18:00:00', 'TRANS-001'),
-- Pedido 4
(4, 5, 5750.00, '2026-02-02 12:00:00', 'MP-12345'),
-- Pedido 5
(5, 1, 2800.00, '2026-02-02 12:50:00', NULL),
-- Pedido 6
(6, 3, 8900.00, '2026-02-02 19:00:00', '23456789'),
-- Pedido 7
(7, 1, 6700.00, '2026-02-03 11:00:00', NULL),
-- Pedido 8
(8, 2, 4550.00, '2026-02-03 13:05:00', '34567890'),
-- Pedido 9
(9, 4, 15600.00, '2026-02-03 20:00:00', 'TRANS-002'),
-- Pedido 10
(10, 5, 7550.00, '2026-02-04 12:30:00', 'MP-23456'),
-- Pedido 11
(11, 1, 3600.00, '2026-02-04 14:05:00', NULL),
-- Pedido 12
(12, 3, 6400.00, '2026-02-04 19:30:00', '45678901'),
-- Pedido 13
(13, 2, 9750.00, '2026-02-05 13:00:00', '56789012'),
-- Pedido 14
(14, 1, 4200.00, '2026-02-05 13:35:00', NULL),
-- Pedido 15
(15, 4, 18000.00, '2026-02-06 12:00:00', 'TRANS-003');
-- Pedidos 16, 17, 18 aún no tienen pagos (están en proceso)

-- ============================================================================
-- 4. INSERCIÓN DE MOVIMIENTOS DE STOCK
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Tabla: MOVIMIENTOS_STOCK
-- ----------------------------------------------------------------------------
INSERT INTO MOVIMIENTOS_STOCK (id_ingrediente, tipo_movimiento, cantidad, fecha_movimiento, motivo, id_empleado) VALUES
-- Entradas de stock (compras a proveedores)
(1, 'ENTRADA', 50.00, '2026-01-15 09:00:00', 'Compra inicial - Carne picada', 6),
(2, 'ENTRADA', 30.00, '2026-01-15 09:00:00', 'Compra inicial - Pollo', 6),
(5, 'ENTRADA', 25.00, '2026-01-15 09:00:00', 'Compra inicial - Cebolla', 6),
(13, 'ENTRADA', 500.00, '2026-01-15 09:00:00', 'Compra inicial - Masas', 6),
(22, 'ENTRADA', 20.00, '2026-01-15 09:00:00', 'Compra inicial - Queso muzzarella', 6),
-- Salidas de stock (uso en producción)
(1, 'SALIDA', 5.00, '2026-02-01 12:00:00', 'Producción pedido #1', 2),
(2, 'SALIDA', 3.00, '2026-02-01 12:00:00', 'Producción pedido #1', 2),
(13, 'SALIDA', 50.00, '2026-02-01 12:00:00', 'Producción pedidos del día', 2),
-- Ajustes de stock
(5, 'AJUSTE', -2.00, '2026-01-20 10:00:00', 'Merma por deterioro', 6),
(6, 'AJUSTE', -1.00, '2026-01-22 10:00:00', 'Merma por deterioro', 6),
-- Más entradas de stock
(1, 'ENTRADA', 20.00, '2026-02-03 10:00:00', 'Reposición - Carne picada', 6),
(2, 'ENTRADA', 15.00, '2026-02-03 10:00:00', 'Reposición - Pollo', 6),
(13, 'ENTRADA', 200.00, '2026-02-03 10:00:00', 'Reposición - Masas', 6);

-- ============================================================================
-- FIN DEL SCRIPT DE INSERCIÓN
-- ============================================================================

-- Verificar datos insertados
SELECT 'CATEGORIAS_PRODUCTOS' AS Tabla, COUNT(*) AS Registros FROM CATEGORIAS_PRODUCTOS
UNION ALL
SELECT 'PRODUCTOS', COUNT(*) FROM PRODUCTOS
UNION ALL
SELECT 'PROVEEDORES', COUNT(*) FROM PROVEEDORES
UNION ALL
SELECT 'INGREDIENTES', COUNT(*) FROM INGREDIENTES
UNION ALL
SELECT 'PRODUCTOS_INGREDIENTES', COUNT(*) FROM PRODUCTOS_INGREDIENTES
UNION ALL
SELECT 'ROLES_EMPLEADOS', COUNT(*) FROM ROLES_EMPLEADOS
UNION ALL
SELECT 'EMPLEADOS', COUNT(*) FROM EMPLEADOS
UNION ALL
SELECT 'METODOS_PAGO', COUNT(*) FROM METODOS_PAGO
UNION ALL
SELECT 'CLIENTES', COUNT(*) FROM CLIENTES
UNION ALL
SELECT 'DIRECCIONES', COUNT(*) FROM DIRECCIONES
UNION ALL
SELECT 'PEDIDOS', COUNT(*) FROM PEDIDOS
UNION ALL
SELECT 'DETALLE_PEDIDOS', COUNT(*) FROM DETALLE_PEDIDOS
UNION ALL
SELECT 'PAGOS', COUNT(*) FROM PAGOS
UNION ALL
SELECT 'MOVIMIENTOS_STOCK', COUNT(*) FROM MOVIMIENTOS_STOCK;
INSERT IGNORE INTO CATEGORIAS_PRODUCTOS (nombre_categoria, descripcion) VALUES
('Empanadas Tradicionales', '...');