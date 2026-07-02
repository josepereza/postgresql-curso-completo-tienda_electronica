# Procedimientos Almacenados - Módulo 3

## 🎯 Descripción

Procedimientos SQL que encapsulan lógica de negocio compleja para operaciones comunes en la tienda electrónica.

---

## 1️⃣ Crear Orden Completa

### Descripción
Crea una orden con todos sus detalles de una sola vez, validando stock y calculando totales.

### Función
```sql
CREATE OR REPLACE PROCEDURE crear_orden(
    p_usuario_id INT,
    p_productos_ids INT[],
    p_cantidades INT[]
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_orden_id INT;
    v_i INT;
    v_producto_id INT;
    v_cantidad INT;
    v_precio DECIMAL;
    v_subtotal DECIMAL;
BEGIN
    -- Validar que el usuario existe
    IF NOT EXISTS (SELECT 1 FROM public.usuarios WHERE id = p_usuario_id) THEN
        RAISE EXCEPTION 'Usuario ID % no existe', p_usuario_id;
    END IF;

    -- Crear orden pendiente
    INSERT INTO ventas.ordenes (usuario_id, estado)
    VALUES (p_usuario_id, 'pendiente')
    RETURNING id INTO v_orden_id;

    -- Iterar sobre los productos
    FOR v_i IN array_lower(p_productos_ids, 1) .. array_upper(p_productos_ids, 1)
    LOOP
        v_producto_id := p_productos_ids[v_i];
        v_cantidad := p_cantidades[v_i];

        -- Obtener precio del producto
        SELECT precio INTO v_precio
        FROM public.productos
        WHERE id = v_producto_id;

        IF v_precio IS NULL THEN
            RAISE EXCEPTION 'Producto ID % no existe', v_producto_id;
        END IF;

        v_subtotal := v_precio * v_cantidad;

        -- Insertar detalle de orden
        INSERT INTO ventas.detalles_orden (
            orden_id, producto_id, cantidad, precio_unitario, subtotal
        ) VALUES (
            v_orden_id, v_producto_id, v_cantidad, v_precio, v_subtotal
        );

        -- Restar stock
        UPDATE public.productos
        SET stock = stock - v_cantidad
        WHERE id = v_producto_id;
    END LOOP;

    RAISE NOTICE 'Orden % creada exitosamente', v_orden_id;
END;
$$;
```

### Uso
```sql
-- Crear orden con 2 productos
CALL crear_orden(1, ARRAY[1, 2], ARRAY[1, 2]);

-- Ver la orden creada
SELECT * FROM ventas.ordenes ORDER BY id DESC LIMIT 1;
SELECT * FROM ventas.detalles_orden WHERE orden_id = (SELECT MAX(id) FROM ventas.ordenes);
```

---

## 2️⃣ Procesar Pago

### Descripción
Procesa el pago de una orden y cambia su estado.

### Función
```sql
CREATE OR REPLACE PROCEDURE procesar_pago(
    p_orden_id INT,
    p_metodo VARCHAR(50) DEFAULT 'tarjeta'
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_total DECIMAL;
    v_estado VARCHAR(50);
BEGIN
    -- Obtener datos de la orden
    SELECT total, estado INTO v_total, v_estado
    FROM ventas.ordenes
    WHERE id = p_orden_id;

    -- Validar que la orden existe
    IF v_total IS NULL THEN
        RAISE EXCEPTION 'Orden ID % no existe', p_orden_id;
    END IF;

    -- Validar que no esté ya pagada
    IF v_estado = 'pagado' THEN
        RAISE EXCEPTION 'Orden % ya fue pagada', p_orden_id;
    END IF;

    -- Validar que hay un monto a pagar
    IF v_total <= 0 THEN
        RAISE EXCEPTION 'Orden % sin monto a pagar', p_orden_id;
    END IF;

    -- Actualizar estado
    UPDATE ventas.ordenes
    SET estado = 'pagado'
    WHERE id = p_orden_id;

    RAISE NOTICE 'Pago de % procesado mediante %. Orden: %', 
        v_total, p_metodo, p_orden_id;
END;
$$;
```

### Uso
```sql
-- Procesar pago
CALL procesar_pago(1, 'tarjeta_credito');

-- Verificar
SELECT id, estado, total FROM ventas.ordenes WHERE id = 1;
```

---

## 3️⃣ Cancelar Orden

### Descripción
Cancela una orden y devuelve el stock de los productos.

### Función
```sql
CREATE OR REPLACE PROCEDURE cancelar_orden(
    p_orden_id INT,
    p_motivo VARCHAR(255) DEFAULT 'Sin especificar'
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_producto_id INT;
    v_cantidad INT;
    v_estado VARCHAR(50);
    v_cursor CURSOR FOR 
        SELECT producto_id, cantidad FROM ventas.detalles_orden 
        WHERE orden_id = p_orden_id;
BEGIN
    -- Obtener estado de la orden
    SELECT estado INTO v_estado
    FROM ventas.ordenes
    WHERE id = p_orden_id;

    IF v_estado IS NULL THEN
        RAISE EXCEPTION 'Orden ID % no existe', p_orden_id;
    END IF;

    IF v_estado = 'pagado' THEN
        RAISE EXCEPTION 'No se pueden cancelar órdenes pagadas';
    END IF;

    -- Devolver stock de todos los productos
    OPEN v_cursor;
    LOOP
        FETCH v_cursor INTO v_producto_id, v_cantidad;
        EXIT WHEN NOT FOUND;

        UPDATE public.productos
        SET stock = stock + v_cantidad
        WHERE id = v_producto_id;
    END LOOP;
    CLOSE v_cursor;

    -- Actualizar estado
    UPDATE ventas.ordenes
    SET estado = 'cancelada'
    WHERE id = p_orden_id;

    RAISE NOTICE 'Orden % cancelada. Motivo: %', p_orden_id, p_motivo;
END;
$$;
```

### Uso
```sql
CALL cancelar_orden(1, 'Cliente cambió de opinión');
SELECT * FROM ventas.ordenes WHERE id = 1;
```

---

## 4️⃣ Generar Reporte de Ventas

### Función
```sql
CREATE OR REPLACE FUNCTION reporte_ventas(
    p_fecha_inicio DATE DEFAULT CURRENT_DATE - INTERVAL '30 days',
    p_fecha_fin DATE DEFAULT CURRENT_DATE
)
RETURNS TABLE (
    usuario_nombre VARCHAR,
    total_ordenes BIGINT,
    monto_total DECIMAL,
    estado VARCHAR,
    ultima_compra TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        u.nombre,
        COUNT(o.id)::BIGINT,
        COALESCE(SUM(o.total), 0)::DECIMAL,
        o.estado,
        MAX(o.created_at)
    FROM ventas.ordenes o
    JOIN public.usuarios u ON o.usuario_id = u.id
    WHERE DATE(o.created_at) BETWEEN p_fecha_inicio AND p_fecha_fin
    GROUP BY u.id, u.nombre, o.estado
    ORDER BY COALESCE(SUM(o.total), 0) DESC;
END;
$$ LANGUAGE plpgsql;
```

### Uso
```sql
-- Últimos 30 días
SELECT * FROM reporte_ventas();

-- Rango personalizado
SELECT * FROM reporte_ventas('2024-01-01', '2024-12-31');
```

---

## 5️⃣ Actualizar Stock

### Función
```sql
CREATE OR REPLACE PROCEDURE actualizar_stock(
    p_producto_id INT,
    p_nueva_cantidad INT,
    p_motivo VARCHAR(100) DEFAULT 'Ajuste manual'
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_stock_anterior INT;
    v_diferencia INT;
BEGIN
    -- Obtener stock anterior
    SELECT stock INTO v_stock_anterior
    FROM public.productos
    WHERE id = p_producto_id;

    IF v_stock_anterior IS NULL THEN
        RAISE EXCEPTION 'Producto ID % no existe', p_producto_id;
    END IF;

    v_diferencia := p_nueva_cantidad - v_stock_anterior;

    -- Actualizar stock
    UPDATE public.productos
    SET stock = p_nueva_cantidad
    WHERE id = p_producto_id;

    RAISE NOTICE 'Producto % - Stock: % -> %. Diferencia: %. Motivo: %',
        p_producto_id, v_stock_anterior, p_nueva_cantidad, v_diferencia, p_motivo;
END;
$$;
```

### Uso
```sql
CALL actualizar_stock(1, 20, 'Reposición de inventario');
SELECT id, nombre, stock FROM public.productos WHERE id = 1;
```

---

## ✅ Resumen

| Procedimiento | Tipo | Uso |
|---------------|------|-----|
| `crear_orden()` | PROCEDURE | Crear orden con detalles |
| `procesar_pago()` | PROCEDURE | Marcar como pagada |
| `cancelar_orden()` | PROCEDURE | Cancelar y devolver stock |
| `reporte_ventas()` | FUNCTION | Generar reportes |
| `actualizar_stock()` | PROCEDURE | Ajustar inventario |

---

## 🚀 Próximo Módulo

En el próximo módulo aprenderemos sobre **Roles y Permisos**.
