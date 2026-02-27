# 🚀 Proyecto Semana 05: Sistema de Archivos y Base de Datos Persistente

## 📋 Descripción del Proyecto

Construirás un sistema de **gestión de archivos y base de datos** completamente persistente usando Docker con volúmenes nombrados y bind mounts. El sistema incluirá un respaldo automático periódico y garantizará que ningún dato se pierda ante reinicios o fallos.

### Escenario Real

Eres el DevOps de una startup de e-commerce que necesita:

- Una base de datos PostgreSQL con datos de productos y órdenes
- Un servidor de archivos (Nginx) para imágenes y documentos subidos por usuarios
- Un sistema de backups automáticos
- Un entorno de desarrollo local con hot reload

---

## 🎯 Objetivos

Al completar este proyecto podrás:

- ✅ Diseñar una arquitectura de almacenamiento persistente con Docker
- ✅ Usar volúmenes nombrados para base de datos en producción
- ✅ Usar bind mounts para desarrollo y configuración
- ✅ Implementar una estrategia de backup automatizada
- ✅ Documentar la arquitectura y el proceso de recuperación

---

## 🗂️ Estructura del Proyecto

```
proyecto-persistencia/
├── docker-compose.yml          # Producción
├── docker-compose.dev.yml      # Override de desarrollo
├── docker-compose.backup.yml   # Servicio de backup
├── .env                        # Variables de entorno
├── .env.example                # Plantilla de variables
├── nginx/
│   └── nginx.conf              # Configuración del servidor de archivos
├── postgres/
│   └── init.sql                # Script de inicialización de BD
├── scripts/
│   ├── backup.sh               # Script de backup
│   └── restore.sh              # Script de restauración
└── README.md                   # Este archivo
```

---

## 📋 Requisitos del Proyecto

### Requisito 1: Base de Datos Persistente

Configura PostgreSQL con:

- Volumen nombrado `ecommerce-db-data` para datos
- Script de inicialización que crea el esquema de la base de datos
- Variables de entorno en archivo `.env` (no hardcodeadas)
- Health check configurado

```sql
-- postgres/init.sql (debes completarlo)
CREATE TABLE IF NOT EXISTS productos (
  id SERIAL PRIMARY KEY,
  nombre VARCHAR(200) NOT NULL,
  descripcion TEXT,
  precio DECIMAL(10,2) NOT NULL,
  stock INT NOT NULL DEFAULT 0,
  imagen_url VARCHAR(500),
  creado_en TIMESTAMP DEFAULT NOW()
);

-- TODO: Crear tabla de categorias
-- TODO: Crear tabla de ordenes
-- TODO: Insertar datos de muestra (mínimo 10 productos)
```

### Requisito 2: Servidor de Archivos

Configura Nginx como servidor de archivos con:

- Volumen nombrado `ecommerce-uploads` para archivos subidos
- Bind mount para la configuración (sin reconstruir imagen al cambiar config)
- Accesible en el puerto 8080

### Requisito 3: Sistema de Backup

Crea scripts que:

- Hagan backup de `ecommerce-db-data` a una carpeta `./backups/`
- Hagan backup del volumen `ecommerce-uploads`
- Tengan retención configurable (por defecto 7 días)
- Devuelvan código de salida 0 en éxito y 1 en error

### Requisito 4: Documentar la restauración

En tu `README.md` documenta:

- Cómo ejecutar los backups
- Los pasos exactos para restaurar en un servidor nuevo
- Cómo verificar la integridad de los datos

---

## 📁 Archivos Starter

### `docker-compose.yml` (completar)

```yaml
services:
  postgres:
    image: postgres:16-alpine
    container_name: ecommerce-db
    env_file: .env
    volumes:
      # TODO: Montar volumen nombrado para datos
      # TODO: Montar script de inicialización
    # TODO: Agregar healthcheck
    networks:
      - ecommerce-net
    restart: unless-stopped

  nginx:
    image: nginx:alpine
    container_name: ecommerce-files
    volumes:
      # TODO: Montar volumen para uploads
      # TODO: Montar configuración de nginx (bind mount)
    ports:
      - "8080:80"
    networks:
      - ecommerce-net
    restart: unless-stopped

volumes:
  # TODO: Declarar volúmenes nombrados

networks:
  ecommerce-net:
    driver: bridge
```

### `.env.example` (completar y renombrar a `.env`)

```bash
# Base de datos
POSTGRES_DB=ecommerce
POSTGRES_USER=ecommerce_user
POSTGRES_PASSWORD=  # TODO: Agregar contraseña segura

# Backup
BACKUP_RETENTION_DAYS=7
BACKUP_DIR=./backups
```

### `nginx/nginx.conf` (completar)

```nginx
server {
    listen 80;
    server_name localhost;
    
    # Servir archivos desde /uploads
    location /uploads/ {
        alias /var/www/uploads/;
        autoindex on;  # Listar archivos del directorio
    }
    
    # TODO: Agregar location para / con página de bienvenida
    # TODO: Configurar tipos MIME correctamente
}
```

### `scripts/backup.sh` (completar)

```bash
#!/bin/bash
# Script de backup del proyecto e-commerce
# TODO: Implementar backup de BD con pg_dump
# TODO: Implementar backup de volumen de uploads
# TODO: Implementar retención automática
# TODO: Agregar logging con timestamp
```

---

## ✅ Criterios de Evaluación

| Criterio | Puntos | Descripción |
|----------|--------|-------------|
| **Volúmenes correctamente configurados** | 20 | Named volumes para DB y uploads, bind mount para config |
| **BD inicializa con datos de muestra** | 15 | Script init.sql funcional con tabla y 10+ registros |
| **Persistencia verificada** | 20 | Datos sobreviven a `docker compose down && up` |
| **Script de backup funcional** | 20 | Crea archivos de backup, limpia backups viejos |
| **Restauración documentada y probada** | 15 | README con pasos exactos, demostración funcional |
| **Buenas prácticas** | 10 | `.env`, no secretos hardcodeados, healthchecks |

**Total: 100 puntos**

---

## 🏆 Desafíos Extra (Bonus)

- **+10 pts**: Implementar backup automático con `docker compose` profiles (perfil `backup`)
- **+10 pts**: Crear `docker-compose.dev.yml` con bind mount para desarrollo del frontend
- **+5 pts**: Agregar compresión y cifrado al backup (`gpg` o `openssl`)

---

## 📤 Entrega

1. Fork del repositorio del bootcamp
2. Carpeta `bootcamp/week-05/3-proyecto/solucion/` con todo el código
3. Capturas de pantalla mostrando:
   - `docker volume ls` (mostrando los volúmenes creados)
   - `docker compose ps` (servicios corriendo)
   - Datos en la base de datos tras `docker compose down && up`
   - Backup creado exitosamente
4. Pull Request con descripción del proceso

---

## 🔗 Navegación

[← Ejercicio 03: Backup y Restore](../2-ejercicios/03-backup-restore/) | [Semana 06: Docker Compose Básico →](../../week-06/README.md)
