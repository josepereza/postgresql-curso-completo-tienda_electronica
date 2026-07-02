# Guía Rápida de Consultas

## 🔍 Consultas Frecuentes

### Gestión de Esquemas

```sql
-- Listar esquemas
\dn

-- Listar tablas de un schema
\dt ventas.*

-- Conectar a un schema por defecto
SET search_path TO ventas;
```

---

### Gestión de Usuarios y Órdenes

```sql
-- Contar usuarios
SELECT COUNT(*) as total_usuarios FROM public.usuarios;

-- Contar órdenes
SELECT COUNT(*) as total_ordenes FROM ventas.ordenes;

-- Órdenes por usuario
SELECT 
    u.nombre,
    COUNT(o.id) as cantidad_ordenes,
    SUM(o.total) as monto_total
FROM public.usuarios u
LEFT JOIN ventas.ordenes o ON u.id = o.usuario_id
GROUP BY u.id, u.nombre
ORDER BY cantidad_ordenes DESC;
```

---

### Gestión de Productos

```sql
-- Top 5 productos más vendidos
SELECT 
    p.nombre,
    COUNT(do.id) as veces_vendido,
    SUM(do.cantidad) as cantidad_total,
    SUM(do.subtotal) as ingresos
FROM public.productos p
LEFT JOIN ventas.detalles_orden do ON p.id = do.producto_id
GROUP BY p.id, p.nombre
ORDER BY veces_vendido DESC
LIMIT 5;

-- Productos con stock bajo
SELECT 
    nombre,
    stock,
    precio
FROM public.productos
WHERE stock < 10 AND activo = true
ORDER BY stock ASC;
```

---

### Análisis de Órdenes

```sql
-- Órdenes por estado
SELECT 
    estado,
    COUNT(*) as cantidad,
    SUM(total) as monto
FROM ventas.ordenes
GROUP BY estado;

-- Ingresos diarios
SELECT 
    DATE(created_at) as fecha,
    COUNT(*) as numero_ordenes,
    SUM(total) as ingresos
FROM ventas.ordenes
WHERE estado = 'pagado'
GROUP BY DATE(created_at)
ORDER BY fecha DESC;
```

---

### Auditoría

```sql
-- Últimos 10 cambios
SELECT 
    tabla,
    operacion,
    usuario,
    created_at
FROM auditoria.logs_cambios
ORDER BY created_at DESC
LIMIT 10;

-- Cambios en tabla específica
SELECT 
    operacion,
    COUNT(*) as total
FROM auditoria.logs_cambios
WHERE tabla = 'ordenes'
GROUP BY operacion;
```

---

## 🔧 Mantenimiento

### Limpiar datos

```sql
-- Eliminar órdenes vacías
DELETE FROM ventas.ordenes
WHERE id NOT IN (
    SELECT DISTINCT orden_id FROM ventas.detalles_orden
) AND estado = 'pendiente';

-- Desactivar productos sin stock
UPDATE public.productos
SET activo = false
WHERE stock = 0 AND activo = true;
```

---

### Vacío de tablas

```sql
-- Limpiar auditoría (mantener últimos 30 días)
DELETE FROM auditoria.logs_cambios
WHERE created_at < NOW() - INTERVAL '30 days';

-- Analizar tabla
ANALYZE ventas.ordenes;

-- Reindexar tabla
REINDEX TABLE ventas.ordenes;
```

---

## 📊 Reportes

### Reporte de Ventas

```sql
SELECT 
    u.nombre as cliente,
    COUNT(o.id) as total_ordenes,
    SUM(o.total) as monto_invertido,
    MAX(o.created_at) as ultima_compra
FROM public.usuarios u
LEFT JOIN ventas.ordenes o ON u.id = o.usuario_id
WHERE u.rol = 'cliente'
GROUP BY u.id, u.nombre
ORDER BY monto_invertido DESC;
```

### Reporte de Inventario

```sql
SELECT 
    categoria,
    COUNT(*) as productos,
    SUM(stock) as stock_total,
    ROUND(AVG(precio), 2) as precio_promedio,
    MIN(precio) as precio_minimo,
    MAX(precio) as precio_maximo
FROM public.productos
WHERE activo = true
GROUP BY categoria
ORDER BY stock_total DESC;
```

---

## ⚙️ Performance

### Ver índices de tabla

```sql
SELECT
    schemaname,
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
ORDER BY schemaname, tablename;
```

### Tamaño de tablas

```sql
SELECT
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as tamaño
FROM pg_tables
WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;
```
