# 🏥 Healthchecks Avanzados en Docker Compose

## Repaso: ¿Qué es un Healthcheck?

Un healthcheck es un comando que Docker ejecuta periódicamente dentro del contenedor para determinar si está "sano". El resultado determina el estado del contenedor: `starting` → `healthy` o `unhealthy`.

En Compose, además de declarar healthchecks, podemos usar `depends_on: condition: service_healthy` para hacer que un servicio espere a que sus dependencias estén realmente listas.

---

## Anatomía del Healthcheck

```yaml
services:
  db:
    image: postgres:16-alpine
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER} -d ${POSTGRES_DB}"]
      interval: 10s      # Tiempo entre chequeos
      timeout: 5s        # Tiempo máximo de espera del comando
      retries: 5         # Fallos consecutivos antes de "unhealthy"
      start_period: 30s  # Gracia inicial (no cuenta como fallo)
```

| Parámetro       | Default  | Descripción                                                    |
| --------------- | -------- | -------------------------------------------------------------- |
| `interval`      | 30s      | Frecuencia del chequeo                                         |
| `timeout`       | 30s      | Máxima espera para que el comando complete                     |
| `retries`       | 3        | Fallos consecutivos para marcar `unhealthy`                    |
| `start_period`  | 0s       | Período inicial donde los fallos no cuentan (espera de arranque)|

---

## Formas de test

```yaml
# Forma 1: CMD (lista, sin shell)
healthcheck:
  test: ["CMD", "redis-cli", "ping"]

# Forma 2: CMD-SHELL (string, con /bin/sh)
healthcheck:
  test: ["CMD-SHELL", "curl -f http://localhost/health || exit 1"]

# Forma 3: Deshabilitar
healthcheck:
  disable: true
```

> **CMD vs CMD-SHELL**: Usa `CMD` para binarios simples (`redis-cli ping`). Usa `CMD-SHELL` cuando necesitas operadores de shell (`||`, `&&`, redirecciones).

---

## Healthchecks por Tipo de Servicio

### API / Web (HTTP)

```yaml
api:
  build: ./api
  healthcheck:
    # wget (disponible en Alpine)
    test: ["CMD-SHELL", "wget -qO- http://localhost:8000/health || exit 1"]
    interval: 15s
    timeout: 5s
    retries: 3
    start_period: 20s
```

```yaml
api:
  build: ./api
  healthcheck:
    # curl (disponible en Debian/Ubuntu)
    test: ["CMD-SHELL", "curl -fsS http://localhost:8000/health || exit 1"]
    interval: 15s
    timeout: 5s
    retries: 3
    start_period: 20s
```

```yaml
api:
  build: ./api
  healthcheck:
    # Python puro (si no hay curl ni wget)
    test: ["CMD-SHELL", "python -c \"import urllib.request; urllib.request.urlopen('http://localhost:8000/health')\""]
    interval: 20s
    timeout: 10s
    retries: 3
    start_period: 30s
```

### PostgreSQL

```yaml
db:
  image: postgres:16-alpine
  environment:
    POSTGRES_USER: myuser
    POSTGRES_DB: mydb
  healthcheck:
    test: ["CMD-SHELL", "pg_isready -U myuser -d mydb"]
    interval: 10s
    timeout: 5s
    retries: 5
    start_period: 30s
```

### MySQL / MariaDB

```yaml
db:
  image: mysql:8.0
  environment:
    MYSQL_DATABASE: mydb
    MYSQL_USER: myuser
    MYSQL_PASSWORD: mypass
  healthcheck:
    test: ["CMD", "mysqladmin", "ping", "-hmysql", "-u$$MYSQL_USER", "-p$$MYSQL_PASSWORD"]
    interval: 10s
    timeout: 5s
    retries: 5
    start_period: 40s
```

### Redis

```yaml
cache:
  image: redis:7-alpine
  healthcheck:
    test: ["CMD", "redis-cli", "ping"]
    interval: 10s
    timeout: 3s
    retries: 3
```

### MongoDB

```yaml
mongo:
  image: mongo:7
  healthcheck:
    test: ["CMD-SHELL", "mongosh --quiet --eval 'db.adminCommand(\"ping\").ok' || exit 1"]
    interval: 15s
    timeout: 10s
    retries: 3
    start_period: 30s
```

### Nginx / Reverse Proxy

```yaml
nginx:
  image: nginx:alpine
  healthcheck:
    test: ["CMD-SHELL", "wget -qO /dev/null http://localhost/health || exit 1"]
    interval: 30s
    timeout: 10s
    retries: 3
```

---

## depends_on con Healthchecks

```yaml
services:
  db:
    image: postgres:16-alpine
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${DB_USER}"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s

  cache:
    image: redis:7-alpine
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 3s
      retries: 3

  api:
    build: ./api
    depends_on:
      db:
        condition: service_healthy    # Espera a que db reporte healthy
      cache:
        condition: service_healthy    # Espera a que redis reporte healthy
    # Sin healthcheck propio, pero podría tenerlo

  nginx:
    image: nginx:alpine
    depends_on:
      api:
        condition: service_started    # Solo espera a que arranque (default)
```

### Opciones de `condition`

| Condición           | Comportamiento                                              |
| ------------------- | ----------------------------------------------------------- |
| `service_started`   | Default. Espera solo a que el contenedor esté corriendo     |
| `service_healthy`   | Espera a que el healthcheck reporte `healthy`               |
| `service_completed_successfully` | Para servicios que terminan (init jobs)        |

---

## Ver Estado del Healthcheck

```bash
# Estado en docker compose ps
docker compose ps
# NAME    IMAGE       COMMAND    STATUS          PORTS
# db      postgres    ...        Up (healthy)    5432/tcp

# Inspeccionar historial de chequeos
docker inspect <container-id> | jq '.[0].State.Health'

# Logs del healthcheck
docker inspect <container-id> --format='{{range .State.Health.Log}}{{.Output}}{{end}}'
```

---

## Healthcheck en Dockerfile vs Compose

Puedes definir el healthcheck en el `Dockerfile` y sobreescribirlo (o deshabilitarlo) en Compose:

```dockerfile
# Dockerfile
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
  CMD curl -f http://localhost/health || exit 1
```

```yaml
# Compose sobreescribe el del Dockerfile
services:
  api:
    build: ./api
    healthcheck:
      test: ["CMD-SHELL", "wget -qO- http://localhost:8000/health || exit 1"]
      interval: 15s   # Más frecuente en desarrollo
```

```yaml
# Compose deshabilita el del Dockerfile (para testing)
services:
  api:
    build: ./api
    healthcheck:
      disable: true
```

---

## ✅ Buenas Prácticas

1. **Define `start_period`**: Los servicios necesitan tiempo para inicializarse antes del primer chequeo
2. **Endpoints dedicados**: Crea un `/health` que verifique conexiones internas (BD, cache)
3. **CMD over CMD-SHELL**: Usa `CMD` cuando no necesitas shell (más eficiente)
4. **`retries` razonables**: 3-5 es adecuado; muy alto retrasa la detección de fallos reales
5. **`timeout` < `interval`**: El timeout debe ser menor que el intervalo

---

## 📚 Siguiente Tema

[→ 03. Secrets y Configs](./03-secrets-configs.md)
