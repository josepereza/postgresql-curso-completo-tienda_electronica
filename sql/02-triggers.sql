-- ============================================================
-- MÓDULO 2: TRIGGERS AVANZADOS
-- Sistema Profesional de Tienda Electrónica
-- ============================================================

-- Asegúrese de que las tablas existen (ejecutar 01-esquemas.sql primero)

-- ============================================================
-- TRIGGER 1: ACTUALIZAR updated_at AUTOMÁTICAMENTE
-- ============================================================

-- Función para actualizar timestamp
CREATE OR REPLACE FUNCTION actualizar_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para usuarios
CREATE TRIGGER IF NOT EXISTS trigger_usuarios_updated_at
BEFORE UPDATE ON public.usuarios
FOR EACH ROW
EXECUTE FUNCTION actualizar_updated_at();

-- Trigger para productos
CREATE TRIGGER IF NOT EXISTS trigger_productos_updated_at
BEFORE UPDATE ON public.productos
FOR EACH ROW
EXECUTE FUNCTION actualizar_updated_at();

-- Trigger para órdenes
CREATE TRIGGER IF NOT EXISTS trigger_ordenes_updated_at
BEFORE UPDATE ON ventas.ordenes
FOR EACH ROW
EXECUTE FUNCTION actualizar_updated_at();

-- ============================================================
-- TRIGGER 2: CALCULAR TOTAL DE ORDEN AUTOMÁTICAMENTE
-- ============================================================

CREATE OR REPLACE FUNCTION calcular_total_orden()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE ventas.ordenes
    SET total = (
        SELECT COALESCE(SUM(subtotal), 0)
        FROM ventas.detalles_orden
        WHERE orden_id = NEW.orden_id
    )
    WHERE id = NEW.orden_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger al insertar detalle
CREATE TRIGGER IF NOT EXISTS trigger_calcular_total_insert
AFTER INSERT ON ventas.detalles_orden
FOR EACH ROW
EXECUTE FUNCTION calcular_total_orden();

-- Trigger al actualizar detalle
CREATE TRIGGER IF NOT EXISTS trigger_calcular_total_update
AFTER UPDATE ON ventas.detalles_orden
FOR EACH ROW
EXECUTE FUNCTION calcular_total_orden();

-- Trigger al eliminar detalle
CREATE TRIGGER IF NOT EXISTS trigger_calcular_total_delete
AFTER DELETE ON ventas.detalles_orden
FOR EACH ROW
EXECUTE FUNCTION calcular_total_orden();

-- ============================================================
-- TRIGGER 3: VALIDAR STOCK DISPONIBLE
-- ============================================================

CREATE OR REPLACE FUNCTION validar_stock()
RETURNS TRIGGER AS $$
DECLARE
    v_stock INT;
BEGIN
    SELECT stock INTO v_stock
    FROM public.productos
    WHERE id = NEW.producto_id;

    IF v_stock < NEW.cantidad THEN
        RAISE EXCEPTION 'Stock insuficiente para producto ID %. Disponible: %, Solicitado: %',
            NEW.producto_id, v_stock, NEW.cantidad;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER IF NOT EXISTS trigger_validar_stock
BEFORE INSERT ON ventas.detalles_orden
FOR EACH ROW
EXECUTE FUNCTION validar_stock();

-- ============================================================
-- TRIGGER 4: REGISTRAR CAMBIOS EN AUDITORÍA
-- ============================================================

CREATE OR REPLACE FUNCTION registrar_cambios()
RETURNS TRIGGER AS $$
DECLARE
    v_datos_antiguos JSONB;
    v_datos_nuevos JSONB;
BEGIN
    v_datos_antiguos := CASE WHEN TG_OP != 'INSERT' THEN row_to_json(OLD) ELSE NULL END;
    v_datos_nuevos := CASE WHEN TG_OP != 'DELETE' THEN row_to_json(NEW) ELSE NULL END;

    INSERT INTO auditoria.logs_cambios (
        tabla, operacion, usuario, datos_nuevos, datos_antiguos
    ) VALUES (
        TG_TABLE_NAME,
        TG_OP,
        CURRENT_USER,
        v_datos_nuevos,
        v_datos_antiguos
    );

    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Auditoría en usuarios
CREATE TRIGGER IF NOT EXISTS trigger_auditoria_usuarios
AFTER INSERT OR UPDATE OR DELETE ON public.usuarios
FOR EACH ROW
EXECUTE FUNCTION registrar_cambios();

-- Auditoría en órdenes
CREATE TRIGGER IF NOT EXISTS trigger_auditoria_ordenes
AFTER INSERT OR UPDATE OR DELETE ON ventas.ordenes
FOR EACH ROW
EXECUTE FUNCTION registrar_cambios();

-- Auditoría en detalles de orden
CREATE TRIGGER IF NOT EXISTS trigger_auditoria_detalles_orden
AFTER INSERT OR UPDATE OR DELETE ON ventas.detalles_orden
FOR EACH ROW
EXECUTE FUNCTION registrar_cambios();

-- ============================================================
-- TRIGGER 5: PROTEGER ÓRDENES PAGADAS
-- ============================================================

CREATE OR REPLACE FUNCTION proteger_ordenes_pagadas()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.estado = 'pagado' THEN
        RAISE EXCEPTION 'No se pueden modificar órdenes pagadas. Estado actual: %', OLD.estado;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER IF NOT EXISTS trigger_proteger_ordenes_pagadas
BEFORE UPDATE ON ventas.ordenes
FOR EACH ROW
EXECUTE FUNCTION proteger_ordenes_pagadas();

-- ============================================================
-- VERIFICACIÓN
-- ============================================================

-- Ver todos los triggers
-- SELECT trigger_name, trigger_schema, event_object_table
-- FROM information_schema.triggers
-- WHERE trigger_schema NOT IN ('pg_catalog', 'information_schema')
-- ORDER BY trigger_schema, event_object_table;
