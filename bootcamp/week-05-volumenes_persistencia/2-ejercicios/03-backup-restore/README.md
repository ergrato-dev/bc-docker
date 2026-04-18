# 💻 Ejercicio 03: Backup y Restore de Volúmenes

## 📋 Información del Ejercicio

| Atributo          | Valor                                                   |
| ----------------- | ------------------------------------------------------- |
| **Duración**      | 50 minutos                                              |
| **Nivel**         | Intermedio                                              |
| **Objetivos**     | Implementar estrategia completa de backup y restauración |
| **Prerequisitos** | Ejercicios 01 y 02 completados                          |

---

## 🎯 Objetivos de Aprendizaje

Al finalizar este ejercicio serás capaz de:

- ✅ Hacer backup de un volumen Docker a un archivo comprimido
- ✅ Restaurar un volumen desde un backup
- ✅ Usar `pg_dump` para backup consistente de PostgreSQL
- ✅ Migrar datos de un volumen a otro
- ✅ Crear un script de backup automatizado

---

## 📖 Escenario

Eres el responsable de infraestructura de una aplicación en producción. Tu tarea es:

1. Simular una base de datos con datos de producción
2. Crear un backup antes de una actualización
3. Simular un fallo (eliminando los datos)
4. Restaurar desde el backup

---

## 📝 Instrucciones

### Parte 1: Crear "Base de Datos de Producción" (10 min)

**Paso 1**: Crear volumen y contenedor con datos

```bash
# Crear volumen de "producción"
docker volume create prod-postgres-data

# Crear contenedor PostgreSQL con datos de prueba
docker run -d \
  --name prod-postgres \
  -e POSTGRES_USER=admin \
  -e POSTGRES_PASSWORD=prod_secreto \
  -e POSTGRES_DB=tienda \
  -v prod-postgres-data:/var/lib/postgresql/data \
  -p 5433:5432 \
  postgres:16-alpine

# Esperar que esté listo
sleep 8
```

**Paso 2**: Insertar datos de "producción"

```bash
docker exec prod-postgres psql -U admin -d tienda << 'SQL'
CREATE TABLE productos (
  id SERIAL PRIMARY KEY,
  nombre VARCHAR(200) NOT NULL,
  precio DECIMAL(10,2) NOT NULL,
  stock INT NOT NULL
);

CREATE TABLE ventas (
  id SERIAL PRIMARY KEY,
  producto_id INT REFERENCES productos(id),
  cantidad INT,
  fecha TIMESTAMP DEFAULT NOW()
);

INSERT INTO productos (nombre, precio, stock) VALUES
  ('Laptop Pro 15"', 1299.99, 50),
  ('Mouse Inalámbrico', 29.99, 200),
  ('Teclado Mecánico', 89.99, 150),
  ('Monitor 4K', 449.99, 75),
  ('Auriculares BT', 149.99, 100);

INSERT INTO ventas (producto_id, cantidad) VALUES
  (1, 3), (2, 10), (3, 5), (1, 2), (4, 1), (5, 8);

SELECT 'Datos insertados correctamente' AS status;
SQL
```

**Paso 3**: Verificar datos

```bash
docker exec prod-postgres psql -U admin -d tienda -c "
  SELECT p.nombre, p.precio, COUNT(v.id) as ventas
  FROM productos p
  LEFT JOIN ventas v ON p.id = v.producto_id
  GROUP BY p.id, p.nombre, p.precio
  ORDER BY ventas DESC;
"
```

---

### Parte 2: Crear Backup (15 min)

**Paso 4**: Crear directorio de backups

```bash
mkdir -p backups
```

**Paso 5**: Método 1 - Backup del volumen completo (datos binarios)

```bash
# Detener contenedor para backup consistente
docker stop prod-postgres

# Crear backup del volumen completo
docker run --rm \
  --volumes-from prod-postgres \
  -v $(pwd)/backups:/backup \
  alpine \
  tar czf /backup/postgres-full-$(date +%Y%m%d-%H%M%S).tar.gz /var/lib/postgresql/data

# Verificar backup
ls -lh backups/
echo "Tamaño del backup:"
du -sh backups/*.tar.gz

# Reiniciar contenedor
docker start prod-postgres
sleep 5
```

**Paso 6**: Método 2 - `pg_dump` (backup lógico, recomendado)

```bash
# pg_dump funciona con la BD activa (sin detenerla)
docker exec prod-postgres \
  pg_dump -U admin -d tienda \
  --format=custom \
  --verbose \
  > backups/tienda-$(date +%Y%m%d-%H%M%S).dump

# Verificar
ls -lh backups/*.dump
```

---

### Parte 3: Simular Desastre y Restaurar (15 min)

> ⚠️ Vamos a simular una pérdida de datos. ¡Asegúrate de tener los backups del paso anterior!

**Paso 7**: ¡Simular el desastre!

```bash
# Dar de baja y eliminar el contenedor Y el volumen
docker stop prod-postgres
docker rm prod-postgres
docker volume rm prod-postgres-data

echo "💀 Datos eliminados. Verificando..."
docker volume ls | grep prod-postgres-data || echo "Volumen eliminado correctamente"
```

**Paso 8**: Restaurar desde backup de volumen

```bash
# Crear nuevo volumen
docker volume create prod-postgres-data-restored

# Restaurar datos
BACKUP_FILE=$(ls -t backups/*.tar.gz | head -1)
echo "📦 Restaurando desde: $BACKUP_FILE"

docker run --rm \
  -v prod-postgres-data-restored:/var/lib/postgresql/data \
  -v $(pwd)/backups:/backup:ro \
  alpine \
  sh -c "cd / && tar xzf /backup/$(basename $BACKUP_FILE)"

# Crear nuevo contenedor con los datos restaurados
docker run -d \
  --name prod-postgres-restored \
  -e POSTGRES_USER=admin \
  -e POSTGRES_PASSWORD=prod_secreto \
  -e POSTGRES_DB=tienda \
  -v prod-postgres-data-restored:/var/lib/postgresql/data \
  -p 5433:5432 \
  postgres:16-alpine

sleep 8

# Verificar que los datos están completos
docker exec prod-postgres-restored psql -U admin -d tienda -c "
  SELECT 'Productos recuperados' as info, COUNT(*) as total FROM productos;
"
docker exec prod-postgres-restored psql -U admin -d tienda -c "
  SELECT 'Ventas recuperadas' as info, COUNT(*) as total FROM ventas;
"
```

---

### Parte 4: Script de Backup Automatizable (10 min)

**Paso 9**: Crear script de backup

```bash
cat > backups/backup.sh << 'SCRIPT'
#!/bin/sh
# Script de backup para contenedores Docker
# Uso: ./backup.sh <nombre-contenedor> <nombre-base-datos>

set -e

CONTAINER=${1:-prod-postgres}
DATABASE=${2:-tienda}
BACKUP_DIR="$(dirname $0)"
DATE=$(date +%Y%m%d-%H%M%S)
RETENTION=7  # días

echo "🚀 Iniciando backup de $DATABASE en $CONTAINER..."

# Backup con pg_dump
docker exec $CONTAINER \
  pg_dump -U admin -d $DATABASE --format=custom \
  > "$BACKUP_DIR/${DATABASE}-${DATE}.dump"

echo "✅ Backup creado: ${DATABASE}-${DATE}.dump"
echo "📦 Tamaño: $(ls -lh $BACKUP_DIR/${DATABASE}-${DATE}.dump | awk '{print $5}')"

# Limpiar backups viejos
echo "🧹 Eliminando backups más viejos de $RETENTION días..."
find "$BACKUP_DIR" -name "*.dump" -mtime +$RETENTION -delete

echo "✅ Backup completado exitosamente"
SCRIPT

chmod +x backups/backup.sh

# Probar el script
./backups/backup.sh prod-postgres-restored tienda
ls -lh backups/*.dump
```

---

### Limpieza

```bash
docker stop prod-postgres-restored 2>/dev/null; true
docker rm prod-postgres-restored 2>/dev/null; true
docker volume rm prod-postgres-data-restored 2>/dev/null; true
```

---

## ✅ Checklist de Verificación

- [ ] Creé una base de datos con datos de prueba en un volumen
- [ ] Hice backup del volumen completo con `tar czf`
- [ ] Hice backup lógico con `pg_dump`
- [ ] Eliminé el volumen simulando un desastre
- [ ] Restauré los datos desde el backup y verifiqué integridad
- [ ] Creé un script de backup reutilizable

---

## 🤔 Preguntas de Reflexión

1. ¿Por qué es mejor `pg_dump` que el backup de volumen binario para bases de datos en producción?
2. ¿Qué diferencia hay entre un backup consistente y uno inconsistente?
3. ¿Cómo configurarías el retention del backup para un entorno de producción real?

---

## 🔗 Ir al Proyecto

[→ Proyecto Semanal: Sistema de Archivos Persistente](../../3-proyecto/README.md)
