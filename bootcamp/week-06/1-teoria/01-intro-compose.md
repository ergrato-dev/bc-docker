# 🐙 Introducción a Docker Compose

<p align="center">
  <img src="../0-assets/01-intro-compose.svg" alt="Introducción Docker Compose" width="800">
</p>

## 📋 Tabla de Contenidos

- [¿Qué es Docker Compose?](#qué-es-docker-compose)
- [Compose vs docker run](#compose-vs-docker-run)
- [Instalación y Versión](#instalación-y-versión)
- [Tu Primer Compose](#tu-primer-compose)
- [Comandos Esenciales](#comandos-esenciales)

---

## ¿Qué es Docker Compose?

**Docker Compose** es una herramienta para definir y ejecutar aplicaciones Docker multi-contenedor. Con un único archivo YAML (`docker-compose.yml`) defines toda la infraestructura de tu aplicación: servicios, redes, volúmenes y configuraciones.

### El problema que resuelve

Sin Compose, para levantar una aplicación con backend + base de datos + cache necesitas:

```bash
# Sin Compose: 4 comandos, fácil cometer errores
docker network create app-net
docker volume create db-data
docker run -d --name postgres --network app-net -v db-data:/var/lib/postgresql/data \
  -e POSTGRES_PASSWORD=secreto -e POSTGRES_DB=app postgres:16-alpine
docker run -d --name redis --network app-net redis:7-alpine
docker run -d --name api --network app-net -p 3000:3000 \
  -e DATABASE_URL=postgres://postgres:secreto@postgres/app \
  -e REDIS_URL=redis://redis:6379 mi-api:latest
```

Con Compose:

```bash
# Con Compose: 1 archivo, 1 comando
docker compose up -d
```

---

## Compose vs docker run

| Aspecto | `docker run` | Docker Compose |
|---------|-------------|----------------|
| Uso ideal | Contenedor único, pruebas rápidas | Aplicaciones multi-servicio |
| Configuración | Flags en CLI (difícil de mantener) | Archivo YAML versionado en Git |
| Reproducibilidad | Manual, propenso a errores | Determinista |
| Redes | Manual | Automática (red por proyecto) |
| Dependencias | Manual | `depends_on` |
| Escalado | Manual | `--scale` |
| Desarrollo vs Prod | Mismo comando diferente | Override files |

---

## Instalación y Versión

Docker Compose v2 viene **integrado en Docker Desktop** y en las instalaciones modernas de Docker Engine como plugin.

```bash
# Verificar instalación
docker compose version
# Docker Compose version v2.31.0

# Docker Compose v2 se invoca como subcomando de docker
docker compose up    # ✅ v2 (plugin integrado)
docker-compose up    # ⚠️  v1 (binario separado, deprecated)
```

> 💡 Siempre usa `docker compose` (con espacio, v2), no `docker-compose` (con guion, v1 deprecated).

---

## Tu Primer Compose

### Estructura mínima

```yaml
# docker-compose.yml
services:
  nombre-servicio:
    image: imagen:tag
    ports:
      - "puerto-host:puerto-contenedor"
```

### Ejemplo: Nginx simple

```yaml
# docker-compose.yml
services:
  web:
    image: nginx:alpine
    ports:
      - "8080:80"
```

```bash
# Levantar en segundo plano
docker compose up -d

# Ver servicios corriendo
docker compose ps

# Ver logs
docker compose logs -f web

# Detener y eliminar
docker compose down
```

### Ejemplo: WordPress + MySQL

```yaml
# docker-compose.yml
services:
  db:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: rootpass
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wpuser
      MYSQL_PASSWORD: wppass
    volumes:
      - db-data:/var/lib/mysql

  wordpress:
    image: wordpress:latest
    ports:
      - "8080:80"
    environment:
      WORDPRESS_DB_HOST: db
      WORDPRESS_DB_USER: wpuser
      WORDPRESS_DB_PASSWORD: wppass
      WORDPRESS_DB_NAME: wordpress
    depends_on:
      - db

volumes:
  db-data:
```

---

## Comandos Esenciales

```bash
# ▶️ Levantar servicios (detached = en segundo plano)
docker compose up -d

# ▶️ Levantar y reconstruir imágenes
docker compose up -d --build

# ⏹️ Detener servicios (sin eliminar contenedores/redes)
docker compose stop

# 🗑️ Detener Y eliminar contenedores, redes
docker compose down

# 🗑️ Detener Y eliminar TODO (incluido volúmenes) - ¡cuidado!
docker compose down -v

# 📋 Ver estado de servicios
docker compose ps

# 📜 Ver logs de todos los servicios
docker compose logs -f

# 📜 Ver logs de un servicio específico
docker compose logs -f nombre-servicio

# 🔍 Ejecutar comando en servicio
docker compose exec nombre-servicio sh

# 🔨 Reconstruir imagen de un servicio
docker compose build nombre-servicio

# 📊 Ver uso de recursos
docker compose top
```

---

## Cómo Compose gestiona los contenedores

Compose usa un **identificador de proyecto** basado en el nombre del directorio. Cada servicio recibe el nombre: `<proyecto>-<servicio>-<número>`.

```bash
# En directorio mi-app/, servicio "web"
# Nombre del contenedor: mi-app-web-1

# Ver el nombre completo
docker compose ps
# NAME          IMAGE       STATUS    PORTS
# mi-app-web-1  nginx:alpine Running  0.0.0.0:8080->80/tcp

# Cambiar el nombre del proyecto
docker compose -p otro-nombre up -d
```

---

## 🔗 Siguiente

[02 - Estructura YAML →](02-estructura-yaml.md)
