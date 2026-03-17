-- ============================================================================
-- PROYECTO: SABORES DEL NORTE - Objetos de Base de Datos
-- Autor: Palacio Cristian
-- Curso: SQL
-- Fecha: Febrero 2026
-- Descripción: Script de creación de Vistas, Funciones, SP y Triggers
-- ============================================================================

USE sabores_del_norte;

-- ============================================================================
-- 1. CREACIÓN DE VISTAS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Vista: vw_productos_disponibles
-- Descripción: Muestra productos disponibles con su categoría y precio
-- Objetivo: Facilitar consultas de productos activos para mostrar en menú
-- Tablas: PRODUCTOS, CATEGORIAS_PRODUCTOS
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_productos_disponibles AS
SELECT 
    p.id_producto,
    p.nombre_producto,
    p.descripcion,
    c.nombre_categoria,
    p.precio_unitario,
    p.tiempo_preparacion
FROM PRODUCTOS p
INNER JOIN CATEGORIAS_PRODUCTOS c ON p.id_categoria = c.id_categoria
WHERE p.disponible = TRUE
ORDER BY c.nombre_categoria, p.nombre_producto;

-- ----------------------------------------------------------------------------
-- Vista: vw_pedidos_completos
-- Descripción: Muestra información completa de cada pedido
-- Objetivo: Consultar detalles de pedidos incluyendo cliente y empleado
-- Tablas: PEDIDOS, CLIENTES, EMPLEADOS, DIRECCIONES
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_pedidos_completos AS
SELECT 
    p.id_pedido,
    p.fecha_pedido,
    p.tipo_pedido,
    p.estado_pedido,
    c.nombre AS cliente,
    c.telefono AS telefono_cliente,
    e.nombre_empleado AS atendido_por,
    CONCAT(d.calle, ' ', d.numero, ', ', d.barrio) AS direccion_entrega,
    p.subtotal,
    p.costo_envio,
    p.total,
    p.observaciones
FROM PEDIDOS p
INNER JOIN CLIENTES c ON p.id_cliente = c.id_cliente
INNER JOIN EMPLEADOS e ON p.id_empleado = e.id_empleado
LEFT JOIN DIRECCIONES d ON p.id_direccion = d.id_direccion
ORDER BY p.fecha_pedido DESC;

-- ----------------------------------------------------------------------------
-- Vista: vw_detalle_pedidos_productos
-- Descripción: Muestra el detalle de productos en cada pedido
-- Objetivo: Ver qué productos se vendieron en cada pedido
-- Tablas: DETALLE_PEDIDOS, PEDIDOS, PRODUCTOS
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_detalle_pedidos_productos AS
SELECT 
    dp.id_pedido,
    pe.fecha_pedido,
    pr.nombre_producto,
    dp.cantidad,
    dp.precio_unitario,
    dp.subtotal,
    pe.estado_pedido
FROM DETALLE_PEDIDOS dp
INNER JOIN PEDIDOS pe ON dp.id_pedido = pe.id_pedido
INNER JOIN PRODUCTOS pr ON dp.id_producto = pr.id_producto
ORDER BY dp.id_pedido DESC, dp.id_detalle;

-- ----------------------------------------------------------------------------
-- Vista: vw_ingredientes_stock_bajo
-- Descripción: Muestra ingredientes que están por debajo del stock mínimo
-- Objetivo: Alertar sobre necesidad de reposición de stock
-- Tablas: INGREDIENTES, PROVEEDORES
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_ingredientes_stock_bajo AS
SELECT 
    i.id_ingrediente,
    i.nombre_ingrediente,
    i.stock_actual,
    i.stock_minimo,
    (i.stock_minimo - i.stock_actual) AS cantidad_a_reponer,
    i.unidad_medida,
    p.nombre_proveedor,
    p.telefono AS telefono_proveedor,
    p.email AS email_proveedor
FROM INGREDIENTES i
INNER JOIN PROVEEDORES p ON i.id_proveedor = p.id_proveedor
WHERE i.stock_actual <= i.stock_minimo
ORDER BY (i.stock_minimo - i.stock_actual) DESC;

-- ----------------------------------------------------------------------------
-- Vista: vw_ventas_por_empleado
-- Descripción: Total de ventas atendidas por cada empleado
-- Objetivo: Medir desempeño de empleados en ventas
-- Tablas: EMPLEADOS, PEDIDOS, ROLES_EMPLEADOS
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_ventas_por_empleado AS
SELECT 
    e.id_empleado,
    e.nombre_empleado,
    r.nombre_rol,
    COUNT(p.id_pedido) AS total_pedidos,
    SUM(p.total) AS monto_total_vendido,
    AVG(p.total) AS promedio_por_pedido
FROM EMPLEADOS e
INNER JOIN ROLES_EMPLEADOS r ON e.id_rol = r.id_rol
LEFT JOIN PEDIDOS p ON e.id_empleado = p.id_empleado
WHERE e.activo = TRUE
GROUP BY e.id_empleado, e.nombre_empleado, r.nombre_rol
ORDER BY monto_total_vendido DESC;

-- ----------------------------------------------------------------------------
-- Vista: vw_productos_mas_vendidos
-- Descripción: Ranking de productos más vendidos
-- Objetivo: Identificar productos populares para optimizar producción
-- Tablas: PRODUCTOS, DETALLE_PEDIDOS
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_productos_mas_vendidos AS
SELECT 
    p.id_producto,
    p.nombre_producto,
    COUNT(dp.id_detalle) AS veces_pedido,
    SUM(dp.cantidad) AS cantidad_total_vendida,
    SUM(dp.subtotal) AS ingresos_totales
FROM PRODUCTOS p
INNER JOIN DETALLE_PEDIDOS dp ON p.id_producto = dp.id_producto
GROUP BY p.id_producto, p.nombre_producto
ORDER BY cantidad_total_vendida DESC;

-- ----------------------------------------------------------------------------
-- Vista: vw_clientes_frecuentes
-- Descripción: Clientes con más pedidos realizados
-- Objetivo: Identificar clientes frecuentes para programas de fidelización
-- Tablas: CLIENTES, PEDIDOS
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_clientes_frecuentes AS
SELECT 
    c.id_cliente,
    c.nombre,
    c.telefono,
    c.email,
    COUNT(p.id_pedido) AS total_pedidos,
    SUM(p.total) AS gasto_total,
    AVG(p.total) AS promedio_gasto
FROM CLIENTES c
INNER JOIN PEDIDOS p ON c.id_cliente = p.id_cliente
WHERE c.activo = TRUE
GROUP BY c.id_cliente, c.nombre, c.telefono, c.email
HAVING COUNT(p.id_pedido) >= 2
ORDER BY total_pedidos DESC, gasto_total DESC;

-- ============================================================================
-- 2. CREACIÓN DE FUNCIONES
-- ============================================================================

DELIMITER //

-- ----------------------------------------------------------------------------
-- Función: fn_calcular_costo_produccion_pedido
-- Descripción: Calcula el costo total de producción de un pedido
-- Objetivo: Conocer el costo de ingredientes para calcular rentabilidad
-- Parámetros: p_id_pedido INT
-- Retorna: DECIMAL(10,2)
-- Tablas: DETALLE_PEDIDOS, PRODUCTOS
-- ----------------------------------------------------------------------------
CREATE FUNCTION fn_calcular_costo_produccion_pedido(p_id_pedido INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_costo_total DECIMAL(10,2);
    
    SELECT COALESCE(SUM(dp.cantidad * pr.costo_produccion), 0)
    INTO v_costo_total
    FROM DETALLE_PEDIDOS dp
    INNER JOIN PRODUCTOS pr ON dp.id_producto = pr.id_producto
    WHERE dp.id_pedido = p_id_pedido;
    
    RETURN v_costo_total;
END //

-- ----------------------------------------------------------------------------
-- Función: fn_calcular_ganancia_pedido
-- Descripción: Calcula la ganancia neta de un pedido
-- Objetivo: Medir rentabilidad real de cada pedido
-- Parámetros: p_id_pedido INT
-- Retorna: DECIMAL(10,2)
-- Tablas: PEDIDOS, y usa fn_calcular_costo_produccion_pedido
-- ----------------------------------------------------------------------------
CREATE FUNCTION fn_calcular_ganancia_pedido(p_id_pedido INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_ganancia DECIMAL(10,2);
    DECLARE v_subtotal DECIMAL(10,2);
    DECLARE v_costo DECIMAL(10,2);
    
    -- Obtener subtotal del pedido
    SELECT subtotal INTO v_subtotal
    FROM PEDIDOS
    WHERE id_pedido = p_id_pedido;
    
    -- Calcular costo de producción
    SET v_costo = fn_calcular_costo_produccion_pedido(p_id_pedido);
    
    -- Calcular ganancia
    SET v_ganancia = v_subtotal - v_costo;
    
    RETURN v_ganancia;
END //

-- ----------------------------------------------------------------------------
-- Función: fn_verificar_stock_producto
-- Descripción: Verifica si hay stock suficiente para producir un producto
-- Objetivo: Prevenir pedidos que no se pueden cumplir por falta de stock
-- Parámetros: p_id_producto INT, p_cantidad INT
-- Retorna: BOOLEAN (1 = hay stock, 0 = no hay stock)
-- Tablas: PRODUCTOS_INGREDIENTES, INGREDIENTES
-- ----------------------------------------------------------------------------
CREATE FUNCTION fn_verificar_stock_producto(p_id_producto INT, p_cantidad INT)
RETURNS BOOLEAN
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_ingredientes_faltantes INT DEFAULT 0;
    
    -- Contar ingredientes que no tienen stock suficiente
    SELECT COUNT(*)
    INTO v_ingredientes_faltantes
    FROM PRODUCTOS_INGREDIENTES pi
    INNER JOIN INGREDIENTES i ON pi.id_ingrediente = i.id_ingrediente
    WHERE pi.id_producto = p_id_producto
    AND i.stock_actual < (pi.cantidad_necesaria * p_cantidad);
    
    -- Si hay ingredientes faltantes, retorna 0 (FALSE), sino retorna 1 (TRUE)
    RETURN (v_ingredientes_faltantes = 0);
END //

-- ----------------------------------------------------------------------------
-- Función: fn_contar_pedidos_cliente
-- Descripción: Cuenta cuántos pedidos ha realizado un cliente
-- Objetivo: Identificar clientes frecuentes
-- Parámetros: p_id_cliente INT
-- Retorna: INT
-- Tablas: PEDIDOS
-- ----------------------------------------------------------------------------
CREATE FUNCTION fn_contar_pedidos_cliente(p_id_cliente INT)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_total_pedidos INT;
    
    SELECT COUNT(*)
    INTO v_total_pedidos
    FROM PEDIDOS
    WHERE id_cliente = p_id_cliente;
    
    RETURN v_total_pedidos;
END //

-- ----------------------------------------------------------------------------
-- Función: fn_obtener_nombre_categoria
-- Descripción: Obtiene el nombre de la categoría dado un ID de producto
-- Objetivo: Facilitar obtención de información de categoría
-- Parámetros: p_id_producto INT
-- Retorna: VARCHAR(50)
-- Tablas: PRODUCTOS, CATEGORIAS_PRODUCTOS
-- ----------------------------------------------------------------------------
CREATE FUNCTION fn_obtener_nombre_categoria(p_id_producto INT)
RETURNS VARCHAR(50)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_nombre_categoria VARCHAR(50);
    
    SELECT c.nombre_categoria
    INTO v_nombre_categoria
    FROM PRODUCTOS p
    INNER JOIN CATEGORIAS_PRODUCTOS c ON p.id_categoria = c.id_categoria
    WHERE p.id_producto = p_id_producto;
    
    RETURN v_nombre_categoria;
END //

DELIMITER ;

-- ============================================================================
-- 3. CREACIÓN DE STORED PROCEDURES
-- ============================================================================

DELIMITER //

-- ----------------------------------------------------------------------------
-- SP: sp_registrar_pedido
-- Descripción: Registra un nuevo pedido con validaciones
-- Objetivo: Centralizar la lógica de creación de pedidos
-- Parámetros: cliente, empleado, dirección, tipo, observaciones
-- Tablas: PEDIDOS
-- ----------------------------------------------------------------------------
CREATE PROCEDURE sp_registrar_pedido(
    IN p_id_cliente INT,
    IN p_id_empleado INT,
    IN p_id_direccion INT,
    IN p_tipo_pedido ENUM('LOCAL', 'DELIVERY', 'ANTICIPADO'),
    IN p_fecha_entrega DATETIME,
    IN p_observaciones TEXT,
    OUT p_id_pedido INT
)
BEGIN
    DECLARE v_costo_envio DECIMAL(10,2) DEFAULT 0;
    
    -- Calcular costo de envío si es delivery
    IF p_tipo_pedido = 'DELIVERY' THEN
        SET v_costo_envio = 500.00;
    END IF;
    
    -- Insertar el pedido
    INSERT INTO PEDIDOS (
        id_cliente, 
        id_empleado, 
        id_direccion, 
        fecha_pedido, 
        fecha_entrega,
        tipo_pedido, 
        estado_pedido, 
        subtotal, 
        costo_envio, 
        total, 
        observaciones
    ) VALUES (
        p_id_cliente,
        p_id_empleado,
        p_id_direccion,
        NOW(),
        p_fecha_entrega,
        p_tipo_pedido,
        'PENDIENTE',
        0.00,
        v_costo_envio,
        v_costo_envio,
        p_observaciones
    );
    
    -- Obtener el ID del pedido creado
    SET p_id_pedido = LAST_INSERT_ID();
    
    SELECT CONCAT('Pedido #', p_id_pedido, ' creado exitosamente') AS mensaje;
END //

-- ----------------------------------------------------------------------------
-- SP: sp_agregar_producto_pedido
-- Descripción: Agrega un producto al detalle de un pedido
-- Objetivo: Facilitar la adición de productos y actualizar totales
-- Parámetros: id_pedido, id_producto, cantidad
-- Tablas: DETALLE_PEDIDOS, PRODUCTOS, PEDIDOS
-- ----------------------------------------------------------------------------
CREATE PROCEDURE sp_agregar_producto_pedido(
    IN p_id_pedido INT,
    IN p_id_producto INT,
    IN p_cantidad INT
)
BEGIN
    DECLARE v_precio_unitario DECIMAL(10,2);
    DECLARE v_subtotal_detalle DECIMAL(10,2);
    DECLARE v_stock_disponible BOOLEAN;
    
    -- Verificar stock disponible
    SET v_stock_disponible = fn_verificar_stock_producto(p_id_producto, p_cantidad);
    
    IF NOT v_stock_disponible THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Stock insuficiente para este producto';
    END IF;
    
    -- Obtener precio actual del producto
    SELECT precio_unitario INTO v_precio_unitario
    FROM PRODUCTOS
    WHERE id_producto = p_id_producto;
    
    -- Calcular subtotal
    SET v_subtotal_detalle = v_precio_unitario * p_cantidad;
    
    -- Insertar detalle del pedido
    INSERT INTO DETALLE_PEDIDOS (id_pedido, id_producto, cantidad, precio_unitario, subtotal)
    VALUES (p_id_pedido, p_id_producto, p_cantidad, v_precio_unitario, v_subtotal_detalle);
    
    -- Actualizar totales del pedido
    UPDATE PEDIDOS
    SET subtotal = subtotal + v_subtotal_detalle,
        total = total + v_subtotal_detalle
    WHERE id_pedido = p_id_pedido;
    
    SELECT CONCAT('Producto agregado al pedido #', p_id_pedido) AS mensaje;
END //

-- ----------------------------------------------------------------------------
-- SP: sp_procesar_pago
-- Descripción: Registra un pago para un pedido
-- Objetivo: Gestionar pagos y actualizar estado del pedido
-- Parámetros: id_pedido, id_metodo_pago, monto
-- Tablas: PAGOS, PEDIDOS
-- ----------------------------------------------------------------------------
CREATE PROCEDURE sp_procesar_pago(
    IN p_id_pedido INT,
    IN p_id_metodo_pago INT,
    IN p_monto DECIMAL(10,2),
    IN p_comprobante VARCHAR(100)
)
BEGIN
    DECLARE v_total_pedido DECIMAL(10,2);
    DECLARE v_total_pagado DECIMAL(10,2);
    
    -- Obtener total del pedido
    SELECT total INTO v_total_pedido
    FROM PEDIDOS
    WHERE id_pedido = p_id_pedido;
    
    -- Registrar el pago
    INSERT INTO PAGOS (id_pedido, id_metodo_pago, monto, fecha_pago, comprobante)
    VALUES (p_id_pedido, p_id_metodo_pago, p_monto, NOW(), p_comprobante);
    
    -- Calcular total pagado
    SELECT COALESCE(SUM(monto), 0) INTO v_total_pagado
    FROM PAGOS
    WHERE id_pedido = p_id_pedido;
    
    -- Si el pedido está completamente pagado, actualizar estado
    IF v_total_pagado >= v_total_pedido THEN
        UPDATE PEDIDOS
        SET estado_pedido = 'PREPARACION'
        WHERE id_pedido = p_id_pedido;
        
        SELECT CONCAT('Pago registrado. Pedido #', p_id_pedido, ' pasa a PREPARACION') AS mensaje;
    ELSE
        SELECT CONCAT('Pago parcial registrado. Falta: $', v_total_pedido - v_total_pagado) AS mensaje;
    END IF;
END //

-- ----------------------------------------------------------------------------
-- SP: sp_actualizar_estado_pedido
-- Descripción: Cambia el estado de un pedido
-- Objetivo: Gestionar el flujo de estados de los pedidos
-- Parámetros: id_pedido, nuevo_estado
-- Tablas: PEDIDOS
-- ----------------------------------------------------------------------------
CREATE PROCEDURE sp_actualizar_estado_pedido(
    IN p_id_pedido INT,
    IN p_nuevo_estado ENUM('PENDIENTE', 'PREPARACION', 'LISTO', 'ENTREGADO', 'CANCELADO')
)
BEGIN
    UPDATE PEDIDOS
    SET estado_pedido = p_nuevo_estado
    WHERE id_pedido = p_id_pedido;
    
    SELECT CONCAT('Pedido #', p_id_pedido, ' actualizado a estado: ', p_nuevo_estado) AS mensaje;
END //

-- ----------------------------------------------------------------------------
-- SP: sp_registrar_cliente_completo
-- Descripción: Registra un cliente con su dirección principal
-- Objetivo: Simplificar el alta de clientes nuevos
-- Parámetros: datos del cliente y dirección
-- Tablas: CLIENTES, DIRECCIONES
-- ----------------------------------------------------------------------------
CREATE PROCEDURE sp_registrar_cliente_completo(
    IN p_nombre VARCHAR(100),
    IN p_telefono VARCHAR(20),
    IN p_email VARCHAR(100),
    IN p_calle VARCHAR(150),
    IN p_numero VARCHAR(10),
    IN p_piso VARCHAR(10),
    IN p_barrio VARCHAR(100),
    IN p_ciudad VARCHAR(100),
    IN p_codigo_postal VARCHAR(10),
    IN p_referencia VARCHAR(200),
    OUT p_id_cliente INT
)
BEGIN
    -- Insertar cliente
    INSERT INTO CLIENTES (nombre, telefono, email, activo)
    VALUES (p_nombre, p_telefono, p_email, TRUE);
    
    SET p_id_cliente = LAST_INSERT_ID();
    
    -- Insertar dirección principal
    INSERT INTO DIRECCIONES (
        id_cliente, calle, numero, piso, barrio, ciudad, 
        codigo_postal, referencia, principal
    ) VALUES (
        p_id_cliente, p_calle, p_numero, p_piso, p_barrio, 
        p_ciudad, p_codigo_postal, p_referencia, TRUE
    );
    
    SELECT CONCAT('Cliente #', p_id_cliente, ' registrado: ', p_nombre) AS mensaje;
END //

-- ----------------------------------------------------------------------------
-- SP: sp_reporte_ventas_periodo
-- Descripción: Genera reporte de ventas en un período de fechas
-- Objetivo: Análisis de ventas para toma de decisiones
-- Parámetros: fecha_inicio, fecha_fin
-- Tablas: PEDIDOS, DETALLE_PEDIDOS
-- ----------------------------------------------------------------------------
CREATE PROCEDURE sp_reporte_ventas_periodo(
    IN p_fecha_inicio DATE,
    IN p_fecha_fin DATE
)
BEGIN
    SELECT 
        DATE(fecha_pedido) AS fecha,
        COUNT(id_pedido) AS total_pedidos,
        SUM(subtotal) AS ingresos_brutos,
        SUM(costo_envio) AS ingresos_envios,
        SUM(total) AS ingresos_totales,
        AVG(total) AS ticket_promedio
    FROM PEDIDOS
    WHERE DATE(fecha_pedido) BETWEEN p_fecha_inicio AND p_fecha_fin
    AND estado_pedido != 'CANCELADO'
    GROUP BY DATE(fecha_pedido)
    ORDER BY fecha DESC;
END //

DELIMITER ;

-- ============================================================================
-- 4. CREACIÓN DE TRIGGERS
-- ============================================================================

DELIMITER //

-- ----------------------------------------------------------------------------
-- Trigger: trg_actualizar_stock_despues_detalle_pedido
-- Descripción: Descuenta automáticamente el stock de ingredientes
-- Objetivo: Mantener el stock actualizado al registrar ventas
-- Momento: AFTER INSERT en DETALLE_PEDIDOS
-- Tablas: DETALLE_PEDIDOS, PRODUCTOS_INGREDIENTES, INGREDIENTES
-- ----------------------------------------------------------------------------
CREATE TRIGGER trg_actualizar_stock_despues_detalle_pedido
AFTER INSERT ON DETALLE_PEDIDOS
FOR EACH ROW
BEGIN
    -- Descontar stock de todos los ingredientes del producto
    UPDATE INGREDIENTES i
    INNER JOIN PRODUCTOS_INGREDIENTES pi ON i.id_ingrediente = pi.id_ingrediente
    SET i.stock_actual = i.stock_actual - (pi.cantidad_necesaria * NEW.cantidad)
    WHERE pi.id_producto = NEW.id_producto;
END //

-- ----------------------------------------------------------------------------
-- Trigger: trg_validar_stock_antes_detalle_pedido
-- Descripción: Valida que haya stock suficiente antes de agregar al pedido
-- Objetivo: Prevenir ventas que no se pueden cumplir
-- Momento: BEFORE INSERT en DETALLE_PEDIDOS
-- Tablas: DETALLE_PEDIDOS, usa función fn_verificar_stock_producto
-- ----------------------------------------------------------------------------
CREATE TRIGGER trg_validar_stock_antes_detalle_pedido
BEFORE INSERT ON DETALLE_PEDIDOS
FOR EACH ROW
BEGIN
    DECLARE v_stock_ok BOOLEAN;
    
    SET v_stock_ok = fn_verificar_stock_producto(NEW.id_producto, NEW.cantidad);
    
    IF NOT v_stock_ok THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No hay stock suficiente de ingredientes para este producto';
    END IF;
END //

-- ----------------------------------------------------------------------------
-- Trigger: trg_registrar_movimiento_stock_entrada
-- Descripción: Registra automáticamente movimientos cuando se actualiza stock
-- Objetivo: Mantener trazabilidad de cambios en el inventario
-- Momento: AFTER UPDATE en INGREDIENTES
-- Tablas: INGREDIENTES, MOVIMIENTOS_STOCK
-- ----------------------------------------------------------------------------
CREATE TRIGGER trg_registrar_movimiento_stock_entrada
AFTER UPDATE ON INGREDIENTES
FOR EACH ROW
BEGIN
    DECLARE v_diferencia DECIMAL(10,2);
    DECLARE v_tipo_movimiento ENUM('ENTRADA', 'SALIDA', 'AJUSTE');
    
    SET v_diferencia = NEW.stock_actual - OLD.stock_actual;
    
    -- Solo registrar si hubo cambio en el stock
    IF v_diferencia != 0 THEN
        -- Determinar tipo de movimiento
        IF v_diferencia > 0 THEN
            SET v_tipo_movimiento = 'ENTRADA';
        ELSE
            SET v_tipo_movimiento = 'SALIDA';
            SET v_diferencia = ABS(v_diferencia);
        END IF;
        
        -- Registrar el movimiento
        INSERT INTO MOVIMIENTOS_STOCK (
            id_ingrediente, 
            tipo_movimiento, 
            cantidad, 
            fecha_movimiento, 
            motivo,
            id_empleado
        ) VALUES (
            NEW.id_ingrediente,
            v_tipo_movimiento,
            v_diferencia,
            NOW(),
            'Actualización automática de stock',
            1  -- ID del empleado sistema o gerente
        );
    END IF;
END //

-- ----------------------------------------------------------------------------
-- Trigger: trg_validar_precio_positivo
-- Descripción: Valida que el precio de productos sea siempre positivo
-- Objetivo: Garantizar integridad de datos de precios
-- Momento: BEFORE INSERT/UPDATE en PRODUCTOS
-- Tablas: PRODUCTOS
-- ----------------------------------------------------------------------------
CREATE TRIGGER trg_validar_precio_positivo_insert
BEFORE INSERT ON PRODUCTOS
FOR EACH ROW
BEGIN
    IF NEW.precio_unitario <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El precio unitario debe ser mayor a 0';
    END IF;
    
    IF NEW.costo_produccion < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El costo de producción no puede ser negativo';
    END IF;
END //

CREATE TRIGGER trg_validar_precio_positivo_update
BEFORE UPDATE ON PRODUCTOS
FOR EACH ROW
BEGIN
    IF NEW.precio_unitario <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El precio unitario debe ser mayor a 0';
    END IF;
    
    IF NEW.costo_produccion < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El costo de producción no puede ser negativo';
    END IF;
END //

-- ----------------------------------------------------------------------------
-- Trigger: trg_actualizar_fecha_modificacion_cliente
-- Descripción: Actualiza automáticamente timestamp de modificación
-- Objetivo: Auditoría de cambios en datos de clientes
-- Momento: BEFORE UPDATE en CLIENTES
-- Tablas: CLIENTES
-- Nota: Requiere agregar campo fecha_modificacion a CLIENTES
-- ----------------------------------------------------------------------------
-- Primero agregamos el campo si no existe
-- ALTER TABLE CLIENTES ADD COLUMN fecha_modificacion DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;

DELIMITER ;

-- ============================================================================
-- 5. VERIFICACIÓN DE OBJETOS CREADOS
-- ============================================================================

-- Mostrar todas las vistas creadas
SHOW FULL TABLES WHERE Table_type = 'VIEW';

-- Mostrar todas las funciones creadas
SHOW FUNCTION STATUS WHERE Db = 'sabores_del_norte';

-- Mostrar todos los procedimientos creados
SHOW PROCEDURE STATUS WHERE Db = 'sabores_del_norte';

-- Mostrar todos los triggers creados
SHOW TRIGGERS FROM sabores_del_norte;

-- ============================================================================
-- FIN DEL SCRIPT
-- ============================================================================

/*
EJEMPLOS DE USO:

-- Usar una vista:
SELECT * FROM vw_productos_disponibles;
SELECT * FROM vw_ingredientes_stock_bajo;

-- Usar una función:
SELECT fn_calcular_costo_produccion_pedido(1) AS costo_pedido_1;
SELECT fn_calcular_ganancia_pedido(1) AS ganancia_pedido_1;
SELECT fn_verificar_stock_producto(1, 10) AS tiene_stock;

-- Usar un stored procedure:
CALL sp_registrar_pedido(1, 4, 1, 'DELIVERY', '2026-02-10 13:00:00', 'Pedido urgente', @id_nuevo_pedido);
SELECT @id_nuevo_pedido;

CALL sp_agregar_producto_pedido(@id_nuevo_pedido, 1, 6);
CALL sp_procesar_pago(@id_nuevo_pedido, 1, 5300.00, NULL);

CALL sp_reporte_ventas_periodo('2026-02-01', '2026-02-07');

-- Los triggers se ejecutan automáticamente, no necesitan ser llamados
*/
SHOW FULL TABLES WHERE Table_type = 'VIEW';
SHOW FUNCTION STATUS WHERE Db = 'sabores_del_norte';
SHOW PROCEDURE STATUS WHERE Db = 'sabores_del_norte';
SHOW TRIGGERS;

SELECT * FROM vw_productos_disponibles;
SELECT * FROM vw_ingredientes_stock_bajo;

SELECT fn_calcular_costo_produccion_pedido(1);
SELECT fn_calcular_ganancia_pedido(1);
CALL sp_registrar_pedido(1, 4, 1, 'DELIVERY', '2026-02-15 12:00:00', 'Test', @nuevo_id);
SELECT @nuevo_id;