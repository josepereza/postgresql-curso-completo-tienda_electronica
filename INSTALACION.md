# Guía de Instalación

## 📋 Requisitos Previos

### Software Necesario

- **PostgreSQL** 14+ (recomendado: 15 o superior)
- **psql** (cliente de línea de comandos)
- **Git** (para clonar el repositorio)

---

## 🔧 Instalación por Sistema Operativo

### 1️⃣ Linux (Ubuntu/Debian)

```bash
# Actualizar repositorios
sudo apt-get update

# Instalar PostgreSQL
sudo apt-get install postgresql postgresql-contrib

# Iniciar servicio
sudo service postgresql start

# Verificar instalación
psql --version
```

**Acceder a PostgreSQL:**
```bash
sudo -u postgres psql
```

---

### 2️⃣ macOS (Homebrew)

```bash
# Instalar Homebrew (si no lo tienes)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Instalar PostgreSQL
brew install postgresql@15

# Iniciar servicio
brew services start postgresql@15

# Verificar instalación
psql --version
```

**Acceder a PostgreSQL:**
```bash
psql postgres
```

---

### 3️⃣ Windows

1. Descargar instalador desde [postgresql.org](https://www.postgresql.org/download/windows/)
2. Ejecutar el instalador `.exe`
3. Seguir el asistente de instalación
4. Anotar la contraseña del usuario `postgres`

**Acceder a PostgreSQL:**
```bash
psql -U postgres
```

---

## 📦 Clonar y Configurar Proyecto

```bash
# Clonar repositorio
git clone https://github.com/josepereza/postgresql-curso-completo-tienda_electronica.git

# Entrar al directorio
cd postgresql-curso-completo-tienda_electronica

# Verificar estructura
ls -la
```

---

## 🗄️ Crear Base de Datos

### Método 1: Usando `createdb` (recomendado)

```bash
# Crear la base de datos
createdb -U postgres tienda_electronica

# Verificar que se creó
psql -U postgres -l | grep tienda_electronica
```

### Método 2: Desde psql

```bash
# Conectarse a PostgreSQL
psql -U postgres

# Dentro de psql, crear base de datos
CREATE DATABASE tienda_electronica;

# Verificar
\l

# Conectarse a la nueva BD
\c tienda_electronica
```

---

## 🚀 Ejecutar Scripts SQL

### Opción 1: Ejecutar desde psql

```bash
# Conectarse a la base de datos
psql -U postgres -d tienda_electronica

# Dentro de psql, ejecutar scripts en orden:
\i sql/01-esquemas.sql
\i sql/02-triggers.sql
\i sql/datos-prueba.sql

# Verificar que funcionó
\dt
\dt ventas.*
```

### Opción 2: Ejecutar desde terminal

```bash
# Ejecutar todos los scripts de una vez
cat sql/01-esquemas.sql sql/02-triggers.sql sql/datos-prueba.sql | psql -U postgres -d tienda_electronica

# O uno por uno
psql -U postgres -d tienda_electronica -f sql/01-esquemas.sql
psql -U postgres -d tienda_electronica -f sql/02-triggers.sql
psql -U postgres -d tienda_electronica -f sql/datos-prueba.sql
```

---

## ✅ Verificación de Instalación

Una vez ejecutados los scripts, verifica que todo esté bien:

```bash
# Conectarse a la BD
psql -U postgres -d tienda_electronica

# Ver esquemas
\dn

# Ver tablas
\dt

# Ver tablas en schema específico
\dt ventas.*
\dt public.*

# Contar registros
SELECT COUNT(*) FROM public.usuarios;
SELECT COUNT(*) FROM public.productos;
SELECT COUNT(*) FROM ventas.ordenes;

# Ver órdenes con detalles
SELECT 
    o.id, 
    u.nombre, 
    COUNT(do.id) as productos,
    o.total
FROM ventas.ordenes o
JOIN public.usuarios u ON o.usuario_id = u.id
LEFT JOIN ventas.detalles_orden do ON o.id = do.orden_id
GROUP BY o.id, u.nombre, o.total;
```

**Salida esperada:**
```
 id |  nombre   | productos | total
----+-----------+-----------+--------
  1 | Juan Pérez|     2     | 850.00
  2 | Carlos López|   2     | 470.00
  3 | Pedro Ramírez|  2     | 250.00
```

---

## 🎯 Próximos Pasos

1. ✅ Leer [README.md](README.md) para entender el curso
2. ✅ Leer [ESTRUCTURA.md](ESTRUCTURA.md) para conocer la organización
3. ✅ Consultar [docs/01-esquemas.md](docs/01-esquemas.md) para profundizar
4. ✅ Usar [docs/GUIA-RAPIDA.md](docs/GUIA-RAPIDA.md) como referencia

---

## 🐛 Solución de Problemas

### Error: "psql: command not found"

**Linux/macOS:**
```bash
# Agregar PostgreSQL al PATH
export PATH="/usr/lib/postgresql/15/bin:$PATH"
# O instalar postgresql-client
sudo apt-get install postgresql-client
```

**Windows:**
Agregar la ruta de PostgreSQL al PATH:
- Buscar "Variables de entorno"
- Editar PATH
- Agregar `C:\Program Files\PostgreSQL\15\bin`

---

### Error: "could not connect to server"

```bash
# Verificar que PostgreSQL está corriendo
sudo systemctl status postgresql  # Linux
brew services list | grep postgresql  # macOS

# Iniciar PostgreSQL si está detenido
sudo systemctl start postgresql  # Linux
brew services start postgresql@15  # macOS
```

---

### Error: "FATAL: Peer authentication failed"

Editar `/etc/postgresql/15/main/pg_hba.conf` (Linux):
```
# Cambiar de "peer" a "md5"
local   all             all                                     md5
```

Luego reiniciar PostgreSQL:
```bash
sudo systemctl restart postgresql
```

---

### Error: "relation does not exist"

Asegúrate de:
1. Estar conectado a la BD correcta: `\c tienda_electronica`
2. Haber ejecutado los scripts SQL
3. Usar el nombre completo con schema: `SELECT * FROM ventas.ordenes;`

---

## 📞 Recursos Útiles

- **PostgreSQL Documentation:** https://www.postgresql.org/docs/
- **psql Manual:** https://www.postgresql.org/docs/current/app-psql.html
- **Tutorial PostgreSQL:** https://www.postgresql.org/docs/current/tutorial.html

---

## 🎉 ¡Listo!

Si todo funcionó correctamente, ya tienes:
✅ PostgreSQL instalado
✅ Base de datos creada
✅ Esquemas y tablas configurados
✅ Triggers funcionando
✅ Datos de prueba listos

**¡Ahora estás listo para aprender PostgreSQL avanzado!**
