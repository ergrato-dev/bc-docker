# ✅ Buenas Prácticas de Producción con Docker

## 1. Dockerfiles Optimizados y Seguros

### Orden de capas para máximo cache hit

```dockerfile
FROM python:3.12-slim

# 1. Dependencias del SO (cambian poco) → primero
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

# 2. Dependencias de la app (package files) → antes que el código
COPY --from=ghcr.io/astral-sh/uv:latest /uv /bin/uv
COPY requirements.txt .
RUN uv pip install --system --no-cache -r requirements.txt

# 3. Código fuente (cambia frecuentemente) → al final
COPY --chown=appuser:appuser src/ .
```

### .dockerignore siempre presente

```gitignore
# .dockerignore — crítico para seguridad y tamaño

# Control de versiones
.git
.gitignore

# Entornos virtuales y dependencias locales
.venv/
venv/
node_modules/
__pycache__/
*.pyc

# Archivos de desarrollo
.env
.env.local
*.env
docker-compose.override.yml

# Secrets (NUNCA en la imagen)
secrets/
*.key
*.pem
*.cert

# CI/CD
.github/
.gitlab-ci.yml

# Documentación y assets no necesarios en runtime
docs/
*.md
tests/
```

---

## 2. Usar Tags Específicos en Producción

```dockerfile
# ❌ Peligroso en producción
FROM node:latest        # No reproducible, puede cambiar sin aviso
FROM python:3.12        # El patch puede variar

# ✅ Reproducible y auditables
FROM node:22.12.0-alpine3.21    # Tag exacto
FROM python:3.12.12-slim-bookworm
FROM nginx:1.30-alpine

# ✅ con SHA para máxima seguridad
FROM python:3.12-slim@sha256:abc123...
```

---

## 3. Limitar el Tamaño de la Imagen

```bash
# Antes de optimizar: medir
docker build -t myapp:fat .
docker image ls myapp:fat

# Técnicas de reducción:
```

```dockerfile
# Técnica 1: Multi-stage build
FROM node:22-alpine AS build
WORKDIR /app
COPY package.json pnpm-lock.yaml .
RUN corepack enable && pnpm install --frozen-lockfile
COPY . .
RUN pnpm run build

FROM nginx:alpine           # Solo la imagen final con los artifacts
COPY --from=build /app/dist /usr/share/nginx/html
# Resultado: 30MB vs 500MB de la imagen de build

# Técnica 2: Combinar RUN para menos capas
RUN apt-get update && \
    apt-get install -y curl wget && \
    rm -rf /var/lib/apt/lists/*

# Técnica 3: Limpiar cache en el mismo RUN
RUN uv pip install --system --no-cache -r requirements.txt

# Técnica 4: Usar Alpine o Slim
FROM python:3.12-slim    # ~50MB vs python:3.12 ~900MB
```

---

## 4. Logging en Producción

```yaml
# docker-compose.yml
services:
  api:
    image: myapp:1.0
    logging:
      driver: json-file
      options:
        max-size: "10m"     # Máximo 10MB por archivo
        max-file: "3"       # Máximo 3 archivos rotados → 30MB total

# Para centralizar logs en producción
  api-with-loki:
    image: myapp:1.0
    logging:
      driver: loki
      options:
        loki-url: "http://loki:3100/loki/api/v1/push"
        loki-labels: "job=api,env=production"
```

```yaml
# Logging a nivel global con x-extensiones
x-logging: &logging
  logging:
    driver: json-file
    options:
      max-size: "10m"
      max-file: "3"

services:
  api:
    <<: *logging
    image: myapp:1.0
```

---

## 5. Variables de Entorno y Configuración

```bash
# Jerarquía de configuración (de menor a mayor prioridad):
# 1. Defaults en el Dockerfile (ENV)
# 2. docker-compose.yml (environment:)
# 3. Archivo .env
# 4. Variables del sistema del host
# 5. Flags -e en docker run
```

```yaml
# ✅ Patrón correcto: valores sensibles solo en .env (no commiteado)
services:
  db:
    image: postgres:16
    environment:
      # No sensibles: pueden ir directamente
      POSTGRES_DB: ${DB_NAME:-appdb}
      POSTGRES_USER: ${DB_USER:-appuser}
      # Sensibles: siempre de archivos secrets o .env
      POSTGRES_PASSWORD_FILE: /run/secrets/db_password
    secrets:
      - db_password
```

---

## 6. Health Checks y Restart

```yaml
services:
  api:
    image: myapp:1.0
    restart: unless-stopped    # Siempre recuperar (excepto stop manual)
    healthcheck:
      test: ["CMD-SHELL", "wget -qO- http://localhost:8000/health || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s        # Tiempo para que la app arranque
```

---

## 7. Redes y Exposición Mínima

```yaml
services:
  nginx:
    ports:
      - "80:80"                # Solo nginx expuesto al exterior
      - "443:443"

  api:
    # Sin ports: — solo accesible desde la red interna
    networks:
      - public-net
      - internal-net

  db:
    # Sin ports: — solo accesible desde la red interna
    networks:
      - internal-net

networks:
  public-net:
  internal-net:
    internal: true             # Sin acceso a internet
```

---

## 8. Checklist Pre-Producción Completo

```markdown
### Dockerfile
- [ ] FROM usa imagen base con tag específico (no latest)
- [ ] .dockerignore excluye .env, secrets, .git, docs
- [ ] La imagen corre como usuario no-root
- [ ] Dependencias instaladas con cache limpiada
- [ ] Puertos > 1024 (sin CAP_NET_BIND_SERVICE)

### docker-compose.yml
- [ ] restart: unless-stopped en servicios core
- [ ] healthcheck definido en db, cache y api
- [ ] depends_on con condition: service_healthy
- [ ] Redes separadas: public-net e internal-net
- [ ] Solo los servicios que deben ser públicos tienen ports:
- [ ] Credenciales usando secrets:, no en environment:
- [ ] logging con max-size y max-file configurados
- [ ] Límites de recursos con deploy.resources.limits

### Seguridad
- [ ] trivy image --severity CRITICAL sin resultados
- [ ] user: definido o USER en Dockerfile
- [ ] read_only: true y tmpfs para /tmp cuando sea posible
- [ ] cap_drop: [ALL] en servicios que no necesitan capacidades
- [ ] no-new-privileges en security_opt
- [ ] .env y secrets/ en .gitignore

### Operaciones
- [ ] Variables y secrets documentadas en .env.example
- [ ] secrets/README.md con instrucciones
- [ ] docker compose config pasa sin errores
- [ ] Stack funciona con docker compose up -d --build
- [ ] docker compose ps muestra todos los servicios healthy
```

---

## 📚 Siguiente Tema

[→ 05. Introducción a CI/CD con Docker](./05-cicd-basico.md)
