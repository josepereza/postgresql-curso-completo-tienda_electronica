# Estructura del Proyecto

```
postgresql-curso-completo-tienda_electronica/
├── README.md                          # 📘 Documento principal con todo el curso
├── docs/                              # 📚 Documentación detallada por módulo
│   ├── 01-esquemas.md                 # Módulo 1: Diseño de Esquemas
│   ├── 02-triggers.md                 # Módulo 2: Triggers Avanzados
│   ├── 03-procedimientos.md           # Módulo 3: Procedimientos Almacenados
│   ├── 04-roles-permisos.md           # Módulo 4: Roles y Permisos
│   ├── 05-rls.md                      # Módulo 5: Row-Level Security
│   ├── 06-vistas.md                   # Módulo 6: Vistas y Materialized Views
│   ├── 07-optimizacion.md             # Módulo 7: Optimización y EXPLAIN ANALYZE
│   ├── 08-transacciones.md            # Módulo 8: Transacciones y Bloqueos
│   ├── 09-scripts.md                  # Módulo 9: Scripts de Datos
│   └── GUIA-RAPIDA.md                 # 🚀 Guía rápida de consultas frecuentes
├── sql/                               # 🗄️ Scripts SQL listos para ejecutar
│   ├── 01-esquemas.sql                # Crear esquemas y tablas
│   ├── 02-triggers.sql                # Crear triggers
│   ├── 03-procedimientos.sql          # Crear procedimientos almacenados
│   ├── 04-roles-permisos.sql          # Crear roles y permisos
│   ├── 05-rls.sql                     # Crear políticas RLS
│   ├── 06-vistas.sql                  # Crear vistas
│   ├── 07-indices.sql                 # Crear índices adicionales
│   ├── 08-consultas.sql               # Consultas útiles
│   └── datos-prueba.sql               # Datos de prueba
└── .git/                              # Git repository
```

---

## 📖 Cómo Usar Este Proyecto

### 1️⃣ **Lectura Secuencial**
Comienza con [README.md](README.md) que contiene todo el curso estructurado con todos los módulos.

### 2️⃣ **Documentación Detallada**
Cada módulo tiene su propio archivo en `docs/`:
- [docs/01-esquemas.md](docs/01-esquemas.md) - Diseño de esquemas
- [docs/02-triggers.md](docs/02-triggers.md) - Triggers avanzados
- Y más...

### 3️⃣ **Ejecución de Scripts SQL**
Los archivos en `sql/` pueden ejecutarse directamente en PostgreSQL:

```bash
# Conectarse a PostgreSQL
psql -U postgres -d tienda_electronica

# Ejecutar scripts dentro de psql
\i sql/01-esquemas.sql
\i sql/02-triggers.sql
\i sql/datos-prueba.sql
```

### 4️⃣ **Referencia Rápida**
Consulta [docs/GUIA-RAPIDA.md](docs/GUIA-RAPIDA.md) para:
- Consultas frecuentes
- Comandos de mantenimiento
- Reportes útiles
- Tips de performance

---

## 🎯 Caminos de Aprendizaje

### 📚 Camino Teórico (Leer primero)
1. README.md (resumen general)
2. docs/01-esquemas.md (conceptos)
3. docs/02-triggers.md (conceptos)
4. Y así sucesivamente...

### 💻 Camino Práctico (Ejecutar código)
1. Crear base de datos: `CREATE DATABASE tienda_electronica;`
2. Ejecutar: `sql/01-esquemas.sql` (tablas)
3. Ejecutar: `sql/02-triggers.sql` (automatización)
4. Ejecutar: `sql/datos-prueba.sql` (datos)
5. Consultar: `docs/GUIA-RAPIDA.md` (pruebas)

### 🎓 Camino Completo (Teoría + Práctica)
Alterna entre leer documentación y ejecutar código correspondiente.

---

## 🔍 Búsqueda Rápida

| Si quieres aprender...               | Ve a...                    |
|--------------------------------------|---------------------------|
| Crear esquemas y tablas              | docs/01-esquemas.md        |
| Automatizar con triggers             | docs/02-triggers.md        |
| Programar procedimientos             | docs/03-procedimientos.md  |
| Gestionar roles                      | docs/04-roles-permisos.md  |
| Seguridad por fila (RLS)            | docs/05-rls.md             |
| Vistas y reportes                    | docs/06-vistas.md          |
| Optimizar consultas                  | docs/07-optimizacion.md    |
| Manejo de transacciones              | docs/08-transacciones.md   |
| Consultas frecuentes                 | docs/GUIA-RAPIDA.md        |

---

## 🚀 Empezar Ahora

### Instalación Rápida

```bash
# 1. Crear base de datos
createdb tienda_electronica

# 2. Conectarse
psql -U postgres -d tienda_electronica

# 3. Dentro de psql, ejecutar todos los scripts
\i sql/01-esquemas.sql
\i sql/02-triggers.sql
\i sql/datos-prueba.sql

# 4. Verificar
SELECT * FROM public.usuarios;
SELECT * FROM public.productos;
SELECT * FROM ventas.ordenes;
```

---

## 💡 Tips

- **Siempre lee el módulo antes de ejecutar el SQL**
- **Usa `psql` para practicar** interactivamente
- **Consulta GUIA-RAPIDA.md** para comandos útiles
- **Los scripts son idempotentes** (puedes ejecutarlos varias veces)

---

## 📞 Soporte

Consulta la documentación dentro de cada archivo `.md` para:
- Explicaciones detalladas
- Ejemplos prácticos
- Casos de uso reales
- Solución de problemas

**¡Disfruta aprendiendo PostgreSQL! 🎉**
