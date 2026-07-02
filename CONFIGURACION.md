# Configuración - Primeros Pasos

## ⚡ Instalación Rápida (5 minutos)

### 1. Crear la base de datos
```bash
createdb tienda_electronica
```

### 2. Ejecutar scripts SQL
```bash
psql -U postgres -d tienda_electronica -f sql/01-esquemas.sql
psql -U postgres -d tienda_electronica -f sql/02-triggers.sql
psql -U postgres -d tienda_electronica -f sql/03-procedimientos.sql
psql -U postgres -d tienda_electronica -f sql/datos-prueba.sql
```

### 3. Verificar
```bash
psql -U postgres -d tienda_electronica
```

```sql
-- Ver tablas
\dt

-- Contar registros
SELECT COUNT(*) FROM public.usuarios;
SELECT COUNT(*) FROM public.productos;
SELECT COUNT(*) FROM ventas.ordenes;
```

---

## 📚 Archivos Principales

### Lectura Obligatoria
1. **[README.md](../README.md)** - Curso completo
2. **[ESTRUCTURA.md](../ESTRUCTURA.md)** - Organización del proyecto
3. **[INSTALACION.md](../INSTALACION.md)** - Guía detallada de instalación

### Documentación por Módulo
- **[01-esquemas.md](01-esquemas.md)** - Diseño de BD
- **[02-triggers.md](02-triggers.md)** - Automatización
- **[GUIA-RAPIDA.md](GUIA-RAPIDA.md)** - Consultas útiles

### Scripts SQL Listos
- **[sql/01-esquemas.sql](../sql/01-esquemas.sql)** - Crear tablas
- **[sql/02-triggers.sql](../sql/02-triggers.sql)** - Crear triggers
- **[sql/03-procedimientos.sql](../sql/03-procedimientos.sql)** - Procedimientos
- **[sql/datos-prueba.sql](../sql/datos-prueba.sql)** - Datos de ejemplo

---

## 🎯 Camino de Aprendizaje Recomendado

```
START
  ↓
┌─────────────────────────────┐
│ Leer README.md              │ ← Comprende el proyecto
└──────────────┬──────────────┘
               ↓
┌─────────────────────────────┐
│ Leer ESTRUCTURA.md          │ ← Entiende la organización
└──────────────┬──────────────┘
               ↓
┌─────────────────────────────┐
│ Leer INSTALACION.md         │ ← Instala todo
└──────────────┬──────────────┘
               ↓
┌─────────────────────────────┐
│ Ejecutar sql/*.sql          │ ← Crea esquemas
└──────────────┬──────────────┘
               ↓
┌─────────────────────────────┐
│ Leer docs/01-esquemas.md    │ ← Aprende conceptos
└──────────────┬──────────────┘
               ↓
┌─────────────────────────────┐
│ Leer docs/02-triggers.md    │ ← Profundiza
└──────────────┬──────────────┘
               ↓
┌─────────────────────────────┐
│ Consultar GUIA-RAPIDA.md    │ ← Usa como referencia
└──────────────┬──────────────┘
               ↓
              END
            (Experto)
```

---

## 🗂️ Estructura Completa del Proyecto

```
📦 postgresql-curso-completo-tienda_electronica
├── 📄 README.md                    ← START HERE (Curso completo)
├── 📄 INSTALACION.md               ← Guía paso a paso
├── 📄 ESTRUCTURA.md                ← Mapa del proyecto
├── 📄 CONFIGURACION.md             ← Este archivo
│
├── 📁 docs/                        (Documentación)
│   ├── 01-esquemas.md
│   ├── 02-triggers.md
│   ├── GUIA-RAPIDA.md
│   └── ... (más módulos)
│
├── 📁 sql/                         (Scripts ejecutables)
│   ├── 01-esquemas.sql
│   ├── 02-triggers.sql
│   ├── 03-procedimientos.sql
│   ├── datos-prueba.sql
│   └── ... (más scripts)
│
└── 📁 .git/                        (Control de versiones)
```

---

## 📊 Diagrama de la Base de Datos

```
TIENDA ELECTRÓNICA
│
├─ public (Schema por defecto)
│  ├─ usuarios ──────────┐
│  │                     │
│  └─ productos ─────────┼──────────────┐
│                        │              │
├─ ventas (Schema)      1:N           M:1
│  ├─ ordenes ◄──────────┘              │
│  │   (usuario_id FK)                  │
│  │                                    │
│  └─ detalles_orden ◄──────────────────┘
│      (producto_id FK)
│
└─ auditoria (Schema)
   └─ logs_cambios
      (auditoría de cambios)
```

---

## 🚀 Comandos Útiles

### Conectarse a la BD
```bash
psql -U postgres -d tienda_electronica
```

### Ver ayuda en psql
```
\? ................. Listar comandos
\l ................. Listar bases de datos
\dt ............... Listar tablas
\dn ............... Listar esquemas
\d tablename ....... Ver estructura de tabla
\q ................ Salir
```

### Ejecutar scripts
```bash
# Un script
psql -U postgres -d tienda_electronica -f sql/01-esquemas.sql

# Múltiples scripts
psql -U postgres -d tienda_electronica <<EOF
\i sql/01-esquemas.sql
\i sql/02-triggers.sql
\i sql/03-procedimientos.sql
\i sql/datos-prueba.sql
EOF
```

---

## ✅ Checklist de Configuración

- [ ] PostgreSQL instalado (`psql --version`)
- [ ] Base de datos creada (`createdb tienda_electronica`)
- [ ] Scripts SQL ejecutados
  - [ ] `sql/01-esquemas.sql`
  - [ ] `sql/02-triggers.sql`
  - [ ] `sql/03-procedimientos.sql`
  - [ ] `sql/datos-prueba.sql`
- [ ] Verificación (`SELECT COUNT(*) FROM public.usuarios;`)

---

## 💡 Tips Importantes

1. **Siempre ejecuta en orden:** esquemas → triggers → procedimientos → datos
2. **Los scripts son idempotentes:** puedes ejecutarlos varias veces
3. **Usa psql interactivo** para practicar queries
4. **Consulta docs/** cuando necesites aprender
5. **Consulta GUIA-RAPIDA.md** para comandos frecuentes

---

## 🆘 ¿Algo No Funciona?

1. Leer **[INSTALACION.md](../INSTALACION.md)** - Sección de "Solución de Problemas"
2. Verificar que PostgreSQL está corriendo
3. Verificar conexión: `psql -U postgres -d tienda_electronica`
4. Ejecutar scripts nuevamente si es necesario

---

## 🎓 Próximo Paso

👉 **Abre [README.md](../README.md)** para comenzar el curso completo.

---

**¡Bienvenido al Curso de PostgreSQL Avanzado! 🎉**
