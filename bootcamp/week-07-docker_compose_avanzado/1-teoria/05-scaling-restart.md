# ⚖️ Scaling y Restart Policies

## Scaling de Servicios en Docker Compose

Escalar significa ejecutar múltiples instancias del mismo servicio. Es útil para Workers, microservicios que procesan tareas, o para simular entornos de carga.

### Escalar en Línea de Comandos

```bash
# Escalar un servicio a 3 instancias
docker compose up -d --scale worker=3

# Verificar
docker compose ps
# NAME              IMAGE   STATUS   PORTS
# project-worker-1  app     Up       
# project-worker-2  app     Up       
# project-worker-3  app     Up       
```

> ⚠️ Solo puedes escalar servicios **sin puertos de host fijos**. Si `api` tiene `ports: - "8000:8000"`, no puedes tener dos instancias (conflicto de puerto).

---

## deploy.replicas (Compose con Swarm Mode)

La forma declarativa de definir réplicas es con `deploy:`:

```yaml
services:
  worker:
    build: ./worker
    deploy:
      replicas: 3           # 3 instancias
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 3
```

> **Importante**: `deploy:` completo (con `resources`, `placement`, etc.) solo se respeta en Docker Swarm. En Compose standalone, solo `deploy.replicas` y `deploy.restart_policy` son soportados desde Compose v2.

---

## Escalar sin Conflictos de Puerto

```yaml
services:
  api:
    build: ./api
    # Sin ports: → Nginx hará de load balancer
    networks:
      - app-net

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
    depends_on:
      - api
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/conf.d/default.conf:ro
    networks:
      - app-net
```

**nginx.conf con upstream para múltiples instancias:**

```nginx
upstream api_cluster {
    server api:8000;    # Docker DNS resuelve "api" a TODAS las instancias
    # No necesitas listar cada IP, Docker DNS lo gestiona
}

server {
    listen 80;
    location / {
        proxy_pass http://api_cluster;
    }
}
```

```bash
# Levantar con 3 instancias de api
docker compose up -d --scale api=3

# Nginx usará round-robin entre las 3 instancias automáticamente
curl http://localhost/    # Se distribuye entre api-1, api-2, api-3
```

---

## Restart Policies

La propiedad `restart` define el comportamiento del contenedor cuando termina:

```yaml
services:
  api:
    image: myapp:latest
    restart: unless-stopped
```

| Política           | Comportamiento                                             |
| ------------------ | ---------------------------------------------------------- |
| `no`               | (default) No reinicia nunca                               |
| `always`           | Siempre reinicia, incluso si se detuvo manualmente        |
| `on-failure`       | Solo si terminó con código de error (≠0)                  |
| `unless-stopped`   | Reinicia siempre excepto si el usuario lo detuvo explícitamente |

### Uso por Entorno

```yaml
x-restart-dev: &restart-dev
  restart: "no"              # En dev no queremos auto-restart (limpia errores)

x-restart-prod: &restart-prod
  restart: unless-stopped    # En producción siempre debe estar corriendo
```

---

## on-failure con Límite de Intentos

```yaml
services:
  job:
    image: myapp:latest
    command: python batch_job.py
    restart: on-failure     # Solo si falla
```

Para más control, usa `deploy.restart_policy`:

```yaml
services:
  unreliable-worker:
    image: myworker:latest
    deploy:
      restart_policy:
        condition: on-failure    # Solo si falla
        delay: 10s               # Esperar 10s entre intentos
        max_attempts: 5          # Máximo 5 reintentos
        window: 120s             # Ventana de evaluación
```

---

## Servicios que terminan (Jobs)

Para servicios que ejecutan una tarea y deben terminar (seeds, migraciones):

```yaml
services:
  db:
    image: postgres:16-alpine
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U appuser"]
      interval: 10s
      retries: 5
      start_period: 30s

  migrator:
    build: ./app
    command: python manage.py migrate
    restart: "no"             # Solo corre una vez
    depends_on:
      db:
        condition: service_healthy
        # condition: service_completed_successfully  # Para Compose v2.x
```

```bash
# Ejecutar el migrador y salir
docker compose run --rm migrator

# O con up (pero el contenedor quedará en Exited)
docker compose up migrator
```

> `service_completed_successfully` como condition de depends_on requiere Compose v2.4+

---

## Limite de Recursos (Compose)

```yaml
services:
  api:
    build: ./api
    deploy:
      resources:
        limits:
          cpus: '0.50'       # Máximo 50% de un CPU
          memory: 512M       # Máximo 512 MB RAM
        reservations:
          cpus: '0.25'       # Reservar 25% CPU
          memory: 128M       # Reservar 128 MB RAM
```

```bash
# Verificar uso de recursos
docker compose stats
docker stats $(docker compose ps -q)
```

---

## Ejemplo: Workers con Scaling

```yaml
# Stack de procesamiento de cola
services:
  redis:
    image: redis:7-alpine
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      retries: 3

  api:
    build: ./api
    ports:
      - "8000:8000"
    depends_on:
      redis:
        condition: service_healthy
    restart: unless-stopped

  worker:
    build: ./worker
    command: python worker.py   # Consume tareas de Redis
    environment:
      REDIS_URL: redis://redis:6379
    depends_on:
      redis:
        condition: service_healthy
    restart: on-failure         # Si falla procesando, reiniciar
    deploy:
      replicas: 2               # 2 workers por defecto
```

```bash
# Levantar
docker compose up -d

# Escalar workers ante alta carga
docker compose up -d --scale worker=5

# Reducir tras la carga
docker compose up -d --scale worker=2

# Ver distribución
docker compose ps
```

---

## ✅ Buenas Prácticas

1. **`unless-stopped` para producción**: Servicios siempre disponibles tras reinicios del host
2. **`no` en desarrollo**: Fallos silenciosos son difíciles de depurar con auto-restart
3. **`on-failure` para workers**: Permite reintento sin esconder errores permanentes
4. **Limita `max_attempts`**: Evita loops infinitos consumiendo recursos
5. **Usa Nginx como LB**: Para escalar servicios con puertos, pon Nginx delante sin port mapping en el servicio

---

## 📚 Siguiente

Continúa con los ejercicios:  
[→ 2-ejercicios/01-profiles/README.md](../2-ejercicios/01-profiles/README.md)
