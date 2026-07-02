-- ============================================================
-- MÓDULO 1: DISEÑO DE ESQUEMAS
-- Sistema Profesional de Tienda Electrónica
-- ============================================================

-- Crear esquemas
CREATE SCHEMA IF NOT EXISTS ventas;
CREATE SCHEMA IF NOT EXISTS auditoria;
CREATE SCHEMA IF NOT EXISTS seguridad;

-- ============================================================
-- TABLA: USUARIOS (schema: public)
-- ============================================================

CREATE TABLE IF NOT EXISTS public.usuarios (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    nombre VARCHAR(255) NOT NULL,
    rol VARCHAR(50) NOT NULL DEFAULT 'cliente',
    activo BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_usuarios_email ON public.usuarios(email);
CREATE INDEX IF NOT EXISTS idx_usuarios_rol ON public.usuarios(rol);

-- ============================================================
-- TABLA: PRODUCTOS (schema: public)
-- ============================================================

CREATE TABLE IF NOT EXISTS public.productos (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    descripcion TEXT,
    precio DECIMAL(10, 2) NOT NULL CHECK (precio > 0),
    stock INT DEFAULT 0 CHECK (stock >= 0),
    categoria VARCHAR(100),
    activo BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_productos_categoria ON public.productos(categoria);
CREATE INDEX IF NOT EXISTS idx_productos_activo ON public.productos(activo);

-- ============================================================
-- TABLA: ÓRDENES (schema: ventas)
-- ============================================================

CREATE TABLE IF NOT EXISTS ventas.ordenes (
    id SERIAL PRIMARY KEY,
    usuario_id INT NOT NULL REFERENCES public.usuarios(id) ON DELETE CASCADE,
    estado VARCHAR(50) NOT NULL DEFAULT 'pendiente',
    total DECIMAL(12, 2) NOT NULL DEFAULT 0 CHECK (total >= 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_ordenes_usuario ON ventas.ordenes(usuario_id);
CREATE INDEX IF NOT EXISTS idx_ordenes_estado ON ventas.ordenes(estado);

-- ============================================================
-- TABLA: DETALLES DE ÓRDENES (schema: ventas)
-- ============================================================

CREATE TABLE IF NOT EXISTS ventas.detalles_orden (
    id SERIAL PRIMARY KEY,
    orden_id INT NOT NULL REFERENCES ventas.ordenes(id) ON DELETE CASCADE,
    producto_id INT NOT NULL REFERENCES public.productos(id) ON DELETE RESTRICT,
    cantidad INT NOT NULL CHECK (cantidad > 0),
    precio_unitario DECIMAL(10, 2) NOT NULL CHECK (precio_unitario > 0),
    subtotal DECIMAL(12, 2) NOT NULL CHECK (subtotal > 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_detalles_orden ON ventas.detalles_orden(orden_id);
CREATE INDEX IF NOT EXISTS idx_detalles_producto ON ventas.detalles_orden(producto_id);

-- ============================================================
-- TABLA: LOGS DE AUDITORÍA (schema: auditoria)
-- ============================================================

CREATE TABLE IF NOT EXISTS auditoria.logs_cambios (
    id SERIAL PRIMARY KEY,
    tabla VARCHAR(100) NOT NULL,
    operacion VARCHAR(10) NOT NULL,
    usuario VARCHAR(255) NOT NULL,
    datos_nuevos JSONB,
    datos_antiguos JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_logs_tabla ON auditoria.logs_cambios(tabla);
CREATE INDEX IF NOT EXISTS idx_logs_operacion ON auditoria.logs_cambios(operacion);
CREATE INDEX IF NOT EXISTS idx_logs_fecha ON auditoria.logs_cambios(created_at);

-- ============================================================
-- VERIFICACIÓN
-- ============================================================

-- Ver esquemas creados
-- SELECT schema_name FROM information_schema.schemata;

-- Ver tablas del schema ventas
-- SELECT table_name FROM information_schema.tables WHERE table_schema = 'ventas';

-- Ver estructura de tabla
-- \d ventas.ordenes
