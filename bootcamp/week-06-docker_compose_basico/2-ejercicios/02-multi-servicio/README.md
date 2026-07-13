# 💻 Ejercicio 02: Aplicación Multi-Servicio

## 📋 Información del Ejercicio

| Atributo          | Valor                                                |
| ----------------- | ---------------------------------------------------- |
| **Duración**      | 50 minutos                                           |
| **Nivel**         | Intermedio                                           |
| **Objetivos**     | Construir stack completo con API + BD + cache        |
| **Prerequisitos** | Ejercicio 01 completado                              |

---

## 🎯 Objetivos de Aprendizaje

- ✅ Definir múltiples servicios con `build:` y `image:`
- ✅ Configurar redes separadas para aislamiento
- ✅ Usar `depends_on` con `condition: service_healthy`
- ✅ Gestionar variables con `.env`
- ✅ Verificar conectividad entre servicios

---

## 📖 Contexto

Construirás el stack de una API REST con:
- **FastAPI** (Python) como backend
- **PostgreSQL** como base de datos
- **Redis** como cache de sesiones
- **Nginx** como reverse proxy

---

## 🗂️ Estructura del Ejercicio

```
multi-servicio/
├── docker-compose.yml
├── .env
├── nginx/
│   └── nginx.conf
└── api/
    ├── Dockerfile
    ├── requirements.txt
    └── main.py
```

---

## 📝 Instrucciones

### Parte 1: Crear los archivos de la API (15 min)

```bash
mkdir -p multi-servicio/api multi-servicio/nginx
cd multi-servicio
```

**`api/main.py`**:

```bash
cat > api/main.py << 'EOF'
from fastapi import FastAPI
from datetime import datetime
import redis
import os

app = FastAPI(title="Bootcamp Docker API")

# Conexión a Redis
try:
    r = redis.Redis(host=os.getenv("REDIS_HOST", "cache"), 
                    port=6379, decode_responses=True)
except:
    r = None

@app.get("/")
def root():
    return {"message": "🐳 Docker Compose Multi-Servicio", "version": "1.0"}

@app.get("/health")
def health():
    return {"status": "healthy", "timestamp": datetime.now().isoformat()}

@app.get("/hits")
def hits():
    if r:
        count = r.incr("page_hits")
        return {"hits": count, "source": "redis"}
    return {"hits": -1, "source": "unavailable"}

@app.get("/info")
def info():
    return {
        "db_host": os.getenv("DB_HOST", "unknown"),
        "redis_host": os.getenv("REDIS_HOST", "unknown"),
        "environment": os.getenv("ENVIRONMENT", "unknown")
    }
EOF
```

**`api/requirements.txt`**:

```bash
cat > api/requirements.txt << 'EOF'
fastapi==0.115.0
uvicorn[standard]==0.30.0
redis==5.0.0
psycopg2-binary==2.9.9
EOF
```

**`api/Dockerfile`**:

```bash
cat > api/Dockerfile << 'EOF'
FROM python:3.12-slim

WORKDIR /app

COPY --from=ghcr.io/astral-sh/uv:latest /uv /bin/uv
COPY requirements.txt .
RUN uv pip install --system --no-cache -r requirements.txt

COPY main.py .

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')"

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
EOF
```

**`nginx/nginx.conf`**:

```bash
cat > nginx/nginx.conf << 'EOF'
upstream api_backend {
    server api:8000;
}

server {
    listen 80;
    
    location / {
        proxy_pass http://api_backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
EOF
```

---

### Parte 2: Crear el docker-compose.yml (15 min)

**`.env`**:

```bash
cat > .env << 'EOF'
ENVIRONMENT=development

# PostgreSQL
DB_HOST=db
DB_PORT=5432
DB_NAME=appdb
DB_USER=appuser
DB_PASS=dev_pass_123

# Redis
REDIS_HOST=cache
REDIS_PORT=6379

# App
APP_VERSION=1.0
EOF
```

**`docker-compose.yml`**:

```bash
cat > docker-compose.yml << 'EOF'
services:

  nginx:
    image: nginx:alpine
    ports:
      - "8080:80"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/conf.d/default.conf:ro
    depends_on:
      api:
        condition: service_healthy
    networks:
      - public-net
    restart: unless-stopped

  api:
    build: ./api
    environment:
      DB_HOST: ${DB_HOST}
      DB_PORT: ${DB_PORT}
      DB_NAME: ${DB_NAME}
      DB_USER: ${DB_USER}
      DB_PASS: ${DB_PASS}
      REDIS_HOST: ${REDIS_HOST}
      ENVIRONMENT: ${ENVIRONMENT}
    depends_on:
      db:
        condition: service_healthy
      cache:
        condition: service_healthy
    networks:
      - public-net
      - internal-net
    restart: unless-stopped

  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: ${DB_NAME}
      POSTGRES_USER: ${DB_USER}
      POSTGRES_PASSWORD: ${DB_PASS}
    volumes:
      - db-data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${DB_USER} -d ${DB_NAME}"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s
    networks:
      - internal-net
    restart: unless-stopped

  cache:
    image: redis:7-alpine
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 3s
      retries: 3
    networks:
      - internal-net
    restart: unless-stopped

volumes:
  db-data:

networks:
  public-net:
    driver: bridge
  internal-net:
    driver: bridge
    internal: true
EOF
```

---

### Parte 3: Levantar y Verificar (20 min)

```bash
# Construir y levantar
docker compose up -d --build

# Seguir el progreso de arranque
docker compose logs -f

# Esperar hasta que todos los servicios estén healthy
docker compose ps
# Todos deben mostrar: Up (healthy)
```

**Verificar endpoints**:

```bash
# A través de Nginx (puerto 8080)
curl http://localhost:8080/
curl http://localhost:8080/health
curl http://localhost:8080/info

# Probar el contador de Redis
curl http://localhost:8080/hits   # hits: 1
curl http://localhost:8080/hits   # hits: 2
curl http://localhost:8080/hits   # hits: 3
```

**Verificar las redes**:

```bash
# Ver las redes creadas
docker network ls | grep multi

# Verificar que nginx NO puede acceder a db directamente
docker compose exec nginx ping db
# Debe fallar (están en redes separadas)

# Verificar que api SÍ puede acceder a db
docker compose exec api ping db
# Debe funcionar
```

---

## ✅ Checklist de Verificación

- [ ] La API responde en `http://localhost:8080`
- [ ] El healthcheck de todos los servicios muestra "healthy"
- [ ] Redis incrementa el contador en `/hits`
- [ ] nginx NO puede alcanzar `db` (aislamiento de redes verificado)
- [ ] api SÍ puede alcanzar `db` y `cache`
- [ ] Los logs muestran el orden correcto de inicio

---

## 🔗 Siguiente Ejercicio

[→ Ejercicio 03: Múltiples Entornos](../03-entornos/README.md)
