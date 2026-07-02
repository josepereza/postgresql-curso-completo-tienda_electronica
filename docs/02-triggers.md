# Módulo 2: Triggers Avanzados

## 🎯 Objetivo

Crear triggers para automatizar lógica de negocio en PostgreSQL.

---

## 📚 Concepto Fundamental

Un **trigger** es un bloque de código que se ejecuta **automáticamente** cuando ocurre un evento (INSERT, UPDATE, DELETE) en una tabla.

### Ventajas

- ✅ Automatiza tareas repetitivas
- ✅ Mantiene integridad de datos
- ✅ Implementa lógica de negocio en la base de datos
- ✅ Centraliza reglas de validación

---

## 🛠️ Paso a Paso

### 1. Trigger para Actualizar `updated_at`

**Función:**
```sql
CREATE OR REPLACE FUNCTION actualizar_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    -- Actualizar el timestamp
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

**Trigger en usuarios:**
```sql
CREATE TRIGGER trigger_usuarios_updated_at
BEFORE UPDATE ON public.usuarios
FOR EACH ROW
EXECUTE FUNCTION actualizar_updated_at();
```

**Trigger en productos:**
```sql
CREATE TRIGGER trigger_productos_updated_at
BEFORE UPDATE ON public.productos
FOR EACH ROW
EXECUTE FUNCTION actualizar_updated_at();
```

**Trigger en órdenes:**
```sql
CREATE TRIGGER trigger_ordenes_updated_at
BEFORE UPDATE ON ventas.ordenes
FOR EACH ROW
EXECUTE FUNCTION actualizar_updated_at();
```

### 2. Trigger para Calcular Total de Orden

**Función:**
```sql
CREATE OR REPLACE FUNCTION calcular_total_orden()
RETURNS TRIGGER AS $$
BEGIN
    -- Calcular total de la orden
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
```

**Trigger:**
```sql
CREATE TRIGGER trigger_calcular_total_insert
AFTER INSERT ON ventas.detalles_orden
FOR EACH ROW
EXECUTE FUNCTION calcular_total_orden();

CREATE TRIGGER trigger_calcular_total_update
AFTER UPDATE ON ventas.detalles_orden
FOR EACH ROW
EXECUTE FUNCTION calcular_total_orden();

CREATE TRIGGER trigger_calcular_total_delete
AFTER DELETE ON ventas.detalles_orden
FOR EACH ROW
EXECUTE FUNCTION calcular_total_orden();
```

---

### 3. Trigger para Validar Stock

**Función:**
```sql
CREATE OR REPLACE FUNCTION validar_stock()
RETURNS TRIGGER AS $$
DECLARE
    v_stock INT;
BEGIN
    -- Obtener stock del producto
    SELECT stock INTO v_stock
    FROM public.productos
    WHERE id = NEW.producto_id;

    -- Validar que hay suficiente stock
    IF v_stock < NEW.cantidad THEN
        RAISE EXCEPTION 'Stock insuficiente. Disponible: %', v_stock;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

**Trigger:**
```sql
CREATE TRIGGER trigger_validar_stock
BEFORE INSERT ON ventas.detalles_orden
FOR EACH ROW
EXECUTE FUNCTION validar_stock();
```

---

### 4. Trigger para Auditoría

**Función:**
```sql
CREATE OR REPLACE FUNCTION registrar_cambios()
RETURNS TRIGGER AS $$
DECLARE
    v_datos_antiguos JSONB;
    v_datos_nuevos JSONB;
BEGIN
    -- Preparar datos
    v_datos_antiguos := CASE WHEN TG_OP != 'INSERT' THEN row_to_json(OLD) ELSE NULL END;
    v_datos_nuevos := CASE WHEN TG_OP != 'DELETE' THEN row_to_json(NEW) ELSE NULL END;

    -- Registrar en auditoría
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
```

**Triggers:**
```sql
CREATE TRIGGER trigger_auditoria_usuarios
AFTER INSERT OR UPDATE OR DELETE ON public.usuarios
FOR EACH ROW
EXECUTE FUNCTION registrar_cambios();

CREATE TRIGGER trigger_auditoria_ordenes
AFTER INSERT OR UPDATE OR DELETE ON ventas.ordenes
FOR EACH ROW
EXECUTE FUNCTION registrar_cambios();

CREATE TRIGGER trigger_auditoria_detalles_orden
AFTER INSERT OR UPDATE OR DELETE ON ventas.detalles_orden
FOR EACH ROW
EXECUTE FUNCTION registrar_cambios();
```

---

### 5. Trigger para Restricción de Cambios

**Función - No permitir cambios en órdenes pagadas:**
```sql
CREATE OR REPLACE FUNCTION proteger_ordenes_pagadas()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.estado = 'pagado' THEN
        RAISE EXCEPTION 'No se pueden modificar órdenes pagadas';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

**Trigger:**
```sql
CREATE TRIGGER trigger_proteger_ordenes_pagadas
BEFORE UPDATE ON ventas.ordenes
FOR EACH ROW
EXECUTE FUNCTION proteger_ordenes_pagadas();
```

---

## 📊 Verificación

### Listar triggers

```sql
-- Ver todos los triggers
SELECT trigger_name, trigger_schema, event_object_table
FROM information_schema.triggers
WHERE trigger_schema NOT IN ('pg_catalog', 'information_schema')
ORDER BY trigger_schema, event_object_table;
```

### Ver definición de trigger

```sql
SELECT pg_get_triggerdef(oid)
FROM pg_trigger
WHERE tgname = 'trigger_usuarios_updated_at';
```

### Ver logs de auditoría

```sql
SELECT * FROM auditoria.logs_cambios ORDER BY created_at DESC;
```

---

## 🧪 Pruebas

### Insertar usuario (prueba `updated_at`)

```sql
INSERT INTO public.usuarios (email, nombre, rol)
VALUES ('test@correo.com', 'Test User', 'cliente');

SELECT * FROM public.usuarios WHERE email = 'test@correo.com';
```

### Actualizar usuario (prueba `updated_at`)

```sql
UPDATE public.usuarios
SET nombre = 'Test User Actualizado'
WHERE email = 'test@correo.com';

-- Ver que updated_at cambió
SELECT email, nombre, updated_at FROM public.usuarios
WHERE email = 'test@correo.com';
```

### Crear orden completa (prueba de triggers)

```sql
-- Insertar usuario
INSERT INTO public.usuarios (email, nombre, rol)
VALUES ('juan@tienda.com', 'Juan Pérez', 'cliente')
RETURNING id;

-- Insertar productos
INSERT INTO public.productos (nombre, precio, stock, categoria)
VALUES
    ('Laptop', 800.00, 10, 'Electrónica'),
    ('Mouse', 25.00, 50, 'Accesorios')
RETURNING id;

-- Crear orden
INSERT INTO ventas.ordenes (usuario_id, estado)
VALUES (1, 'pendiente')
RETURNING id;

-- Agregar detalles (prueba de validación de stock)
INSERT INTO ventas.detalles_orden (orden_id, producto_id, cantidad, precio_unitario, subtotal)
VALUES
    (1, 1, 2, 800.00, 1600.00),
    (1, 2, 3, 25.00, 75.00);

-- Verificar que el total se calculó automáticamente
SELECT * FROM ventas.ordenes WHERE id = 1;

-- Ver logs de auditoría
SELECT * FROM auditoria.logs_cambios ORDER BY created_at DESC LIMIT 10;
```

---

## 🚨 Errores Comunes

### 1. Trigger infinito
```sql
-- ❌ MAL - causa recursión
CREATE FUNCTION bad_trigger() RETURNS TRIGGER AS $$
BEGIN
    UPDATE public.usuarios SET updated_at = NOW() WHERE id = NEW.id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ✅ BIEN - usa NEW directamente
CREATE FUNCTION good_trigger() RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

### 2. Olvidar RETURN
```sql
-- ❌ MAL - trigger falla
CREATE FUNCTION bad_trigger() RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO auditoria.logs_cambios VALUES (...);
    -- Falta RETURN
END;

-- ✅ BIEN
CREATE FUNCTION good_trigger() RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO auditoria.logs_cambios VALUES (...);
    RETURN NEW;
END;
```

---

## 🎓 Aprendizajes Clave

- ✅ BEFORE triggers modifica los datos antes de insertarlos
- ✅ AFTER triggers ejecuta después de los cambios
- ✅ FOR EACH ROW ejecuta para cada fila afectada
- ✅ TG_OP indica si es INSERT, UPDATE o DELETE
- ✅ RAISE EXCEPTION detiene la operación

---

## 🚀 Próximo Módulo

En el próximo módulo aprenderemos sobre **Procedimientos Almacenados** para encapsular lógica compleja.
