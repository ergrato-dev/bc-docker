# 💻 Ejercicio 02: Healthchecks Avanzados

## 📋 Información del Ejercicio

| Atributo          | Valor                                              |
| ----------------- | -------------------------------------------------- |
| **Duración**      | 50 minutos                                         |
| **Nivel**         | Intermedio                                         |
| **Objetivos**     | Configurar healthchecks reales y verificar estados |
| **Prerequisitos** | Ejercicio 01 completado                            |

---

## 🎯 Objetivos de Aprendizaje

- ✅ Configurar healthchecks para db, cache y api
- ✅ Usar `condition: service_healthy` en `depends_on`
- ✅ Ver el historial de healthchecks con `docker inspect`
- ✅ Simular un fallo de healthcheck

---

## 📝 Instrucciones

### Parte 1: Stack con Healthchecks Completos (20 min)

```bash
mkdir healthchecks-lab && cd healthchecks-lab
mkdir api
```

**`api/main.py`**:

```python
from fastapi import FastAPI
import redis, os, psycopg2
from datetime import datetime

app = FastAPI()

def check_redis():
    try:
        r = redis.Redis(host=os.getenv("REDIS_HOST", "cache"), port=6379)
        return r.ping()
    except:
        return False

def check_db():
    try:
        conn = psycopg2.connect(
            host=os.getenv("DB_HOST", "db"),
            dbname=os.getenv("DB_NAME", "appdb"),
            user=os.getenv("DB_USER", "user"),
            password=os.getenv("DB_PASS", "pass")
        )
        conn.close()
        return True
    except:
        return False

@app.get("/")
def root():
    return {"status": "ok"}

@app.get("/health")
def health():
    db_ok = check_db()
    cache_ok = check_redis()
    status = "healthy" if (db_ok and cache_ok) else "degraded"
    return {
        "status": status,
        "timestamp": datetime.now().isoformat(),
        "checks": {"db": db_ok, "cache": cache_ok}
    }
```

**`api/requirements.txt`**:

```
fastapi==0.115.0
uvicorn==0.30.0
redis==5.0.0
psycopg2-binary==2.9.9
```

**`api/Dockerfile`**:

```dockerfile
FROM python:3.12-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY main.py .
EXPOSE 8000
HEALTHCHECK --interval=15s --timeout=5s --retries=3 --start-period=20s \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')"
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

**`docker-compose.yml`**:

```yaml
services:
  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: appdb
      POSTGRES_USER: user
      POSTGRES_PASSWORD: pass
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U user -d appdb"]
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
    ports:
      - "8000:8000"
    environment:
      DB_HOST: db
      DB_NAME: appdb
      DB_USER: user
      DB_PASS: pass
      REDIS_HOST: cache
    depends_on:
      db:
        condition: service_healthy
      cache:
        condition: service_healthy
```

---

### Parte 2: Levantar y Monitorear (20 min)

```bash
# Construir y levantar
docker compose up -d --build

# Seguir los logs con el estado de healthchecks
docker compose logs -f

# En otra terminal, observar el estado (actualizar cada 2s)
watch -n 2 "docker compose ps"

# Esperar a que todos estén "healthy"
# Luego probar el endpoint
curl http://localhost:8000/health
```

**Inspeccionar el historial de healthchecks**:

```bash
# Obtener el container ID de db
DB_ID=$(docker compose ps -q db)

# Ver los últimos chequeos
docker inspect $DB_ID | python3 -c "
import json, sys
data = json.load(sys.stdin)
health = data[0]['State']['Health']
print(f'Status: {health[\"Status\"]}')
for log in health['Log'][-3:]:
    print(f'  Exit: {log[\"ExitCode\"]} | {log[\"Output\"][:60]}')"
```

---

### Parte 3: Simular un Fallo (10 min)

```bash
# Pausar Redis (simulará fallo de healthcheck)
docker compose pause cache

# Esperar unos segundos y ver el estado
docker compose ps
# cache debe cambiar a "unhealthy" después de 3 intentos

# Ver que la API reporta el fallo
curl http://localhost:8000/health
# {"status": "degraded", ..., "checks": {"db": true, "cache": false}}

# Restaurar
docker compose unpause cache

# Verificar recuperación
docker compose ps
# cache vuelve a "healthy"
```

---

### Limpieza

```bash
docker compose down -v
cd .. && rm -rf healthchecks-lab
```

---

## ✅ Checklist de Verificación

- [ ] Todos los servicios muestran `(healthy)` en `docker compose ps`
- [ ] La API solo arranca después de que db y cache están healthy
- [ ] `curl /health` muestra el estado de las dependencias
- [ ] Al pausar Redis, el status cambia a `unhealthy`
- [ ] Al restaurar Redis, el status vuelve a `healthy`
- [ ] vi el historial de chequeos con `docker inspect`

---

## 🔗 Siguiente Ejercicio

[→ Ejercicio 03: Secrets y Configuración Segura](../03-secrets/README.md)
