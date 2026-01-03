# 🚀 Proyecto Semana 01: Solución

## 📋 Solución Completa

Esta es la solución paso a paso del proyecto.

---

## Paso 1: Crear la Red

```bash
docker network create dev-network
```

**Verificación:**

```bash
docker network ls | grep dev
# Salida: xxxxxxxxxxxx   dev-network   bridge    local
```

---

## Paso 2: Iniciar PostgreSQL

```bash
docker run -d \
  --name db \
  --network dev-network \
  -e POSTGRES_USER=devuser \
  -e POSTGRES_PASSWORD=devpass \
  -e POSTGRES_DB=devdb \
  -p 5432:5432 \
  --restart unless-stopped \
  postgres:16-alpine
```

**Verificación:**

```bash
docker logs db
# Buscar: "database system is ready to accept connections"
```

---

## Paso 3: Iniciar Redis

```bash
docker run -d \
  --name cache \
  --network dev-network \
  -p 6379:6379 \
  --restart unless-stopped \
  redis:alpine
```

**Verificación:**

```bash
docker exec cache redis-cli ping
# Salida: PONG
```

---

## Paso 4: Iniciar Nginx

```bash
docker run -d \
  --name web \
  --network dev-network \
  -p 8080:80 \
  --restart unless-stopped \
  nginx:alpine
```

**Verificación:**

```bash
curl http://localhost:8080
# O visitar http://localhost:8080 en el navegador
```

---

## Paso 5: Iniciar Adminer

```bash
docker run -d \
  --name dbadmin \
  --network dev-network \
  -p 8081:8080 \
  --restart unless-stopped \
  adminer
```

**Verificación:**

- Visitar `http://localhost:8081`

---

## Paso 6: Conectar Adminer a PostgreSQL

En `http://localhost:8081`:

| Campo         | Valor      |
| ------------- | ---------- |
| Sistema       | PostgreSQL |
| Servidor      | `db`       |
| Usuario       | `devuser`  |
| Contraseña    | `devpass`  |
| Base de datos | `devdb`    |

---

## Paso 7: Verificar Conectividad

```bash
# Entrar al contenedor web
docker exec -it web sh

# Instalar curl (Alpine)
apk add --no-cache curl

# Probar conexión a PostgreSQL (verificar que el puerto responde)
nc -zv db 5432
# Salida: db (172.x.x.x:5432) open

# Probar conexión a Redis
nc -zv cache 6379
# Salida: cache (172.x.x.x:6379) open

# Alternativa con curl para verificar el propio nginx
curl -I localhost
# Salida: HTTP/1.1 200 OK

exit
```

---

## Verificación Final

```bash
docker ps
```

**Salida esperada:**

```
CONTAINER ID   IMAGE               COMMAND                  STATUS         PORTS                    NAMES
xxxxxxxxxxxx   adminer             "entrypoint.sh php …"   Up X minutes   0.0.0.0:8081->8080/tcp   dbadmin
xxxxxxxxxxxx   nginx:alpine        "/docker-entrypoint.…"   Up X minutes   0.0.0.0:8080->80/tcp     web
xxxxxxxxxxxx   redis:alpine        "docker-entrypoint.s…"   Up X minutes   0.0.0.0:6379->6379/tcp   cache
xxxxxxxxxxxx   postgres:16-alpine  "docker-entrypoint.s…"   Up X minutes   0.0.0.0:5432->5432/tcp   db
```

---

## Verificar la Red

```bash
docker network inspect dev-network
```

Deberías ver los 4 contenedores conectados a la red.

---

## Script de Limpieza

Ver archivo [commands.sh](commands.sh) para el script completo.

```bash
# Ejecutar limpieza
./commands.sh cleanup
```

---

## 📊 Resumen de Servicios

| Servicio   | URL/Puerto            | Credenciales    |
| ---------- | --------------------- | --------------- |
| Nginx      | http://localhost:8080 | -               |
| Adminer    | http://localhost:8081 | -               |
| PostgreSQL | localhost:5432        | devuser/devpass |
| Redis      | localhost:6379        | -               |

---

## 🔗 Navegación

| ← Starter                           | Proyecto                        |
| ----------------------------------- | ------------------------------- |
| [Ver Starter](../starter/README.md) | [README Proyecto](../README.md) |
