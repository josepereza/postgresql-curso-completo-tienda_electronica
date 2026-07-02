# Módulo 1: Diseño de Esquemas Profesionales

## 🎯 Objetivo

Aprender a organizar una base de datos PostgreSQL usando esquemas (schemas) para separar componentes lógicos.

---

## 📚 Concepto Fundamental

Los **esquemas** en PostgreSQL son contenedores de objetos de base de datos (tablas, vistas, índices, etc.). Permiten:

- ✅ Organizar lógicamente la base de datos
- ✅ Evitar conflictos de nombres
- ✅ Aplicar permisos a nivel de schema
- ✅ Facilitar mantenimiento y escalabilidad

---

## 🗂️ Estructura de Esquemas

```
database: tienda_electronica
├── public (defecto)
│   ├── usuarios
│   └── productos
│
├── ventas (personalizado)
│   ├── ordenes
│   ├── detalles_orden
│   └── pagos
│
├── auditoria (personalizado)
│   ├── logs_cambios
│   └── logs_acceso
│
└── seguridad (personalizado)
    ├── roles_usuarios
    └── permisos
```

---

## 🛠️ Paso a Paso

### 1. Crear Esquemas

```sql
-- Crear esquema para ventas
CREATE SCHEMA IF NOT EXISTS ventas;

-- Crear esquema para auditoría
CREATE SCHEMA IF NOT EXISTS auditoria;

-- Crear esquema para seguridad
CREATE SCHEMA IF NOT EXISTS seguridad;

-- Verificar esquemas creados
\dn
```

**Salida esperada:**
```
     List of schemas
    Name    |  Owner
------------+----------
 auditoria  | postgres
 public     | postgres
 seguridad  | postgres
 ventas     | postgres
```

---

### 2. Crear Tabla de Usuarios (Schema: public)

```sql
CREATE TABLE public.usuarios (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    nombre VARCHAR(255) NOT NULL,
    rol VARCHAR(50) NOT NULL DEFAULT 'cliente',
    activo BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Crear índices
CREATE INDEX idx_usuarios_email ON public.usuarios(email);
CREATE INDEX idx_usuarios_rol ON public.usuarios(rol);

-- Ver estructura
\d public.usuarios
```

---

### 3. Crear Tabla de Productos (Schema: public)

```sql
CREATE TABLE public.productos (
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

-- Crear índices
CREATE INDEX idx_productos_categoria ON public.productos(categoria);
CREATE INDEX idx_productos_activo ON public.productos(activo);

-- Ver estructura
\d public.productos
```

---

### 4. Crear Tabla de Órdenes (Schema: ventas)

```sql
CREATE TABLE ventas.ordenes (
    id SERIAL PRIMARY KEY,
    usuario_id INT NOT NULL REFERENCES public.usuarios(id) ON DELETE CASCADE,
    estado VARCHAR(50) NOT NULL DEFAULT 'pendiente',
    total DECIMAL(12, 2) NOT NULL DEFAULT 0 CHECK (total >= 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Crear índices
CREATE INDEX idx_ordenes_usuario ON ventas.ordenes(usuario_id);
CREATE INDEX idx_ordenes_estado ON ventas.ordenes(estado);

-- Ver estructura
\d ventas.ordenes
```

---

### 5. Crear Tabla de Detalles de Órdenes (Schema: ventas)

```sql
CREATE TABLE ventas.detalles_orden (
    id SERIAL PRIMARY KEY,
    orden_id INT NOT NULL REFERENCES ventas.ordenes(id) ON DELETE CASCADE,
    producto_id INT NOT NULL REFERENCES public.productos(id) ON DELETE RESTRICT,
    cantidad INT NOT NULL CHECK (cantidad > 0),
    precio_unitario DECIMAL(10, 2) NOT NULL CHECK (precio_unitario > 0),
    subtotal DECIMAL(12, 2) NOT NULL CHECK (subtotal > 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Crear índices
CREATE INDEX idx_detalles_orden ON ventas.detalles_orden(orden_id);
CREATE INDEX idx_detalles_producto ON ventas.detalles_orden(producto_id);

-- Ver estructura
\d ventas.detalles_orden
```

---

### 6. Crear Tabla de Auditoría (Schema: auditoria)

```sql
CREATE TABLE auditoria.logs_cambios (
    id SERIAL PRIMARY KEY,
    tabla VARCHAR(100) NOT NULL,
    operacion VARCHAR(10) NOT NULL,
    usuario VARCHAR(255) NOT NULL,
    datos_nuevos JSONB,
    datos_antiguos JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Crear índices
CREATE INDEX idx_logs_tabla ON auditoria.logs_cambios(tabla);
CREATE INDEX idx_logs_operacion ON auditoria.logs_cambios(operacion);
CREATE INDEX idx_logs_fecha ON auditoria.logs_cambios(created_at);

-- Ver estructura
\d auditoria.logs_cambios
```

---

## 📊 Relaciones entre Tablas

```
┌──────────────────┐
│   usuarios       │
│─────────────────│
│ id (PK)          │
│ email            │
│ nombre           │
│ rol              │
└─────────┬────────┘
          │
          │ 1:N
          │
┌─────────▼────────────────┐
│    ventas.ordenes        │
│──────────────────────────│
│ id (PK)                  │
│ usuario_id (FK)          │
│ estado                   │
│ total                    │
└─────────┬────────────────┘
          │
          │ 1:N
          │
┌─────────▼──────────────────────────┐
│  ventas.detalles_orden             │
│──────────────────────────────────  │
│ id (PK)                            │
│ orden_id (FK)                      │
│ producto_id (FK)  ─────────┐       │
│ cantidad                   │       │
│ precio_unitario            │       │
│ subtotal                   │       │
└────────────────────────────┼───────┘
                             │
                             │
          ┌──────────────────▼──────────┐
          │   public.productos         │
          │───────────────────────────  │
          │ id (PK)                    │
          │ nombre                     │
          │ descripcion                │
          │ precio                     │
          │ stock                      │
          │ categoria                  │
          └────────────────────────────┘
```

---

## ✅ Verificación

### Listar todos los esquemas

```sql
SELECT schema_name FROM information_schema.schemata;
```

### Listar tablas de un schema

```sql
SELECT table_name FROM information_schema.tables
WHERE table_schema = 'ventas';
```

### Ver todas las tablas con sus schemas

```sql
SELECT table_schema, table_name FROM information_schema.tables
WHERE table_schema NOT IN ('pg_catalog', 'information_schema')
ORDER BY table_schema, table_name;
```

---

## 🎓 Aprendizajes Clave

- ✅ Los esquemas separados mejoran la organización
- ✅ Los índices mejoran el rendimiento de búsquedas
- ✅ Las restricciones (CHECK, FOREIGN KEY) garantizan integridad
- ✅ Los nombres con schema completo evitan conflictos (ej: `ventas.ordenes`)

---

## 🚀 Próximo Módulo

En el próximo módulo aprenderemos sobre **Triggers Avanzados** para automatizar acciones.
