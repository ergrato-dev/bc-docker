# 👤 Usuarios No-Root en Dockerfiles

## ¿Por qué No Root?

Por defecto, los procesos dentro de un contenedor se ejecutan como **root (UID 0)**. Aunque Docker aísla el contenedor, si existe una vulnerabilidad que permite "escapar" del contenedor, el proceso tendría privilegios de root en el host.

```bash
# Verificar usuario actual en un contenedor estándar
docker run --rm nginx id
# uid=0(root) gid=0(root) groups=0(root)    ← ❌ root

# Lo que queremos
docker run --rm mi-app id
# uid=1001(appuser) gid=1001(appgroup) groups=1001(appgroup)  ← ✅
```

---

## Crear Usuario No-Root en Dockerfile

### Imágenes basadas en Alpine

```dockerfile
FROM alpine:3.21

# Crear grupo y usuario sin shell de login
RUN addgroup -S appgroup && \
    adduser -S appuser -G appgroup

# Crear directorio de trabajo y asignar permisos
RUN mkdir -p /app && chown appuser:appgroup /app

WORKDIR /app

# Copiar archivos con el usuario correcto
COPY --chown=appuser:appgroup . .

# Cambiar al usuario no-root
USER appuser

CMD ["./app"]
```

### Imágenes basadas en Debian/Ubuntu

```dockerfile
FROM python:3.12-slim

# Crear usuario de la aplicación
RUN groupadd --gid 1001 appgroup && \
    useradd --uid 1001 --gid appgroup --shell /bin/false --no-create-home appuser

# Directorio de trabajo con permisos correctos
RUN mkdir -p /app && chown appuser:appgroup /app
WORKDIR /app

# Instalar dependencias ANTES de cambiar usuario
COPY --from=ghcr.io/astral-sh/uv:latest /uv /bin/uv
COPY requirements.txt .
RUN uv pip install --system --no-cache -r requirements.txt

# Copiar código con el propietario correcto
COPY --chown=appuser:appgroup . .

# Cambiar al usuario no-root
USER appuser

EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### Imágenes Node.js

```dockerfile
FROM node:22-alpine

# node:alpine ya incluye el usuario "node" (UID 1000)
WORKDIR /app

# Instalar dependencias como root (para acceder a la caché de pnpm)
COPY package.json pnpm-lock.yaml ./
RUN corepack enable && pnpm install --prod --frozen-lockfile

# Copiar código con el usuario node
COPY --chown=node:node . .

# Cambiar al usuario predefinido
USER node

EXPOSE 3000
CMD ["node", "server.js"]
```

### Imágenes Golang (Multi-Stage)

```dockerfile
# Stage de build (puede ser root)
FROM golang:1.25-alpine AS builder
WORKDIR /build
COPY . .
RUN CGO_ENABLED=0 go build -o app .

# Stage final mínimo
FROM scratch                    # Imagen vacía, solo el binario

# Copiar certificados TLS (para HTTPS)
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

# Copiar el binario
COPY --from=builder /build/app /app

# User en imagen scratch (UID numérico, no existe /etc/passwd)
USER 65534:65534                # nobody:nogroup

EXPOSE 8080
ENTRYPOINT ["/app"]
```

---

## Permisos y Propietarios

```dockerfile
# COPY --chown evita tener que hacer chown después
COPY --chown=appuser:appgroup config/ /app/config/

# Para múltiples archivos con chown posterior
RUN chown -R appuser:appgroup /app/data /app/logs

# Para directorios que la app necesita crear en runtime
RUN mkdir -p /app/uploads && \
    chown appuser:appgroup /app/uploads && \
    chmod 755 /app/uploads
```

---

## El Problema con Puertos Privilegiados

Los puertos menores a 1024 requieren `CAP_NET_BIND_SERVICE`. La solución es usar puertos altos dentro del contenedor:

```dockerfile
# ❌ requiere privilegios
EXPOSE 80
CMD ["./server", "--port", "80"]

# ✅ sin privilegios  
EXPOSE 8080
CMD ["./server", "--port", "8080"]
```

```yaml
# En compose: mapear puerto privilegiado del host al no-privilegiado del contenedor
services:
  web:
    build: .
    ports:
      - "80:8080"    # Host:80 → Container:8080 (no-root)
    user: "1001:1001"
```

---

## USER en Multi-Stage Builds

```dockerfile
FROM node:22-alpine AS build
WORKDIR /build
COPY package.json pnpm-lock.yaml .
RUN corepack enable && pnpm install --frozen-lockfile
COPY . .
RUN pnpm run build

FROM nginx:alpine AS final

# nginx:alpine usa el usuario 'nginx' (UID 101)
COPY --from=build --chown=nginx:nginx /build/dist /usr/share/nginx/html

# Nginx puede correr en modo no-root si configuramos el puerto > 1024
COPY nginx.conf /etc/nginx/conf.d/default.conf
# En nginx.conf: listen 8080;  (no-privilegiado)

USER nginx
EXPOSE 8080
```

---

## Sobrescribir el Usuario en Compose

```yaml
# Sobrescribir el usuario definido en el Dockerfile
services:
  app:
    image: myapp:latest
    user: "1001:1001"     # UID:GID
    # o
    user: appuser         # Por nombre (debe existir en la imagen)
    # o
    user: "1001"          # Solo UID
```

---

## Verificar que no Corre como Root

```bash
# Durante el build
docker build -t myapp .
docker run --rm myapp id
# Debe mostrar algo DIFERENTE de uid=0(root)

# Para un contenedor en ejecución
docker compose exec api id

# docker-bench-security también lo verifica automáticamente

# Listar todos los contenedores con su usuario
docker ps --format "table {{.Names}}\t{{.Image}}" | while read name image; do
  echo "$name: $(docker exec $name id 2>/dev/null || echo 'no exec')";
done
```

---

## ✅ Checklist Dockerfile Seguro (Usuarios)

```dockerfile
# ✅ Lista completa para imágenes seguras
FROM base-image:specific-tag NOT latest

# 1. Instalar dependencias como root (es necesario)
RUN apt-get update && apt-get install -y ...

# 2. Crear usuario dedicado
RUN useradd --uid 1001 --no-create-home --shell /bin/false appuser

# 3. Crear directorios necesarios con permisos correctos
RUN mkdir -p /app && chown appuser /app
WORKDIR /app

# 4. Instalar dependencias de la app
COPY --from=ghcr.io/astral-sh/uv:latest /uv /bin/uv
COPY requirements.txt .
RUN uv pip install --system -r requirements.txt

# 5. Copiar código con el propietario correcto
COPY --chown=appuser:appuser . .

# 6. ¡Cambiar el usuario ANTES del CMD!
USER appuser

# 7. Usar puerto > 1024
EXPOSE 8080
CMD ["./app"]
```

---

## 📚 Siguiente Tema

[→ 03. Escaneo de Vulnerabilidades](./03-escaneo-vulnerabilidades.md)
