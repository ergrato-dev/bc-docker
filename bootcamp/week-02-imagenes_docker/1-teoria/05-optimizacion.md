# 📚 Optimización de Imágenes Docker

## 🎯 Objetivos de Aprendizaje

Al finalizar esta sección, serás capaz de:

- Reducir el tamaño de imágenes Docker
- Implementar Multi-stage builds
- Optimizar el orden de capas para mejor caché
- Aplicar buenas prácticas de seguridad
- Elegir la imagen base adecuada

---

## 📊 ¿Por Qué Optimizar?

| Beneficio                      | Descripción                                      |
| ------------------------------ | ------------------------------------------------ |
| **Menor tamaño**               | Menos almacenamiento, transferencias más rápidas |
| **Builds más rápidos**         | Mejor uso del caché de capas                     |
| **Menor superficie de ataque** | Menos paquetes = menos vulnerabilidades          |
| **Despliegues más rápidos**    | Menos datos que transferir                       |
| **Menor costo**                | Menos recursos en registry y runtime             |

---

## 🏗️ Multi-Stage Builds

La técnica más poderosa para reducir tamaño: usar múltiples etapas de build.

### Problema: Imagen con herramientas de build

```dockerfile
# ❌ Sin multi-stage: imagen de 1.2 GB
FROM node:22

WORKDIR /app
COPY . .

# Dependencias de desarrollo + producción
RUN corepack enable && pnpm install

# Compilar TypeScript
RUN pnpm run build

# La imagen final incluye:
# - node_modules de desarrollo (grande)
# - Código fuente TypeScript (no necesario)
# - Herramientas de build (no necesario)

CMD ["node", "dist/server.js"]
```

### Solución: Multi-Stage Build

```dockerfile
# ✅ Con multi-stage: imagen de 150 MB

# ========== Etapa 1: Build ==========
FROM node:22 AS builder

WORKDIR /app

# Dependencias
COPY package.json pnpm-lock.yaml ./
RUN corepack enable && pnpm install --frozen-lockfile

# Compilar
COPY . .
RUN pnpm run build

# ========== Etapa 2: Producción ==========
FROM node:22-alpine AS production

WORKDIR /app

# Solo dependencias de producción
COPY package.json pnpm-lock.yaml ./
RUN corepack enable && pnpm install --prod --frozen-lockfile

# Solo el código compilado (no fuentes)
COPY --from=builder /app/dist ./dist

# Usuario no-root
USER node

EXPOSE 3000
CMD ["node", "dist/server.js"]
```

### Anatomía del Multi-Stage

| Etapa          | Propósito           | Contenido                                     |
| -------------- | ------------------- | --------------------------------------------- |
| **builder**    | Compilar código     | Node completo, devDependencies, código fuente |
| **production** | Ejecutar aplicación | Alpine, solo producción, código compilado     |

```dockerfile
# Copiar desde otra etapa
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules

# También puedes copiar desde imágenes externas
COPY --from=nginx:alpine /etc/nginx/nginx.conf /etc/nginx/
```

---

## 🖼️ Elegir la Imagen Base Correcta

### Comparativa de Imágenes Node.js

| Imagen             | Tamaño  | Base           | Uso                               |
| ------------------ | ------- | -------------- | --------------------------------- |
| `node:22`          | ~1 GB   | Debian         | Desarrollo, compatibilidad máxima |
| `node:22-slim`     | ~200 MB | Debian minimal | Producción general                |
| `node:22-alpine`   | ~140 MB | Alpine Linux   | Producción optimizada             |
| `node:22-bookworm` | ~1 GB   | Debian 12      | Cuando necesitas glibc            |

### Comparativa de Imágenes Python

| Imagen               | Tamaño  | Uso               |
| -------------------- | ------- | ----------------- |
| `python:3.12`        | ~1 GB   | Desarrollo        |
| `python:3.12-slim`   | ~150 MB | Producción        |
| `python:3.12-alpine` | ~50 MB  | Producción mínima |

### Guía de Selección

```dockerfile
# Desarrollo - máxima compatibilidad
FROM node:22

# Producción general - buen balance
FROM node:22-slim

# Producción optimizada - mínimo tamaño
FROM node:22-alpine

# Aplicaciones con dependencias nativas complejas
FROM node:22-bookworm
```

> ⚠️ **Alpine y musl**: Alpine usa `musl` en lugar de `glibc`. Algunas librerías nativas pueden tener problemas. Prueba siempre.

---

## 📦 Optimización del Orden de Capas

### Principio: Lo que cambia menos, primero

```dockerfile
# ❌ Mal orden - invalida caché frecuentemente
FROM node:22-alpine
WORKDIR /app
COPY . .                    # ← Cualquier cambio invalida todo
RUN corepack enable && pnpm install
CMD ["node", "server.js"]
```

```dockerfile
# ✅ Buen orden - maximiza uso de caché
FROM node:22-alpine
WORKDIR /app

# 1. Dependencias (cambian poco)
COPY package.json pnpm-lock.yaml ./
RUN corepack enable && pnpm install

# 2. Código fuente (cambia frecuentemente)
COPY . .

CMD ["node", "server.js"]
```

### Orden Recomendado

| Prioridad | Tipo de Instrucción                       | Frecuencia de Cambio |
| --------- | ----------------------------------------- | -------------------- |
| 1         | `FROM`, `ARG` base                        | Rara vez             |
| 2         | `RUN` instalación de paquetes del sistema | Ocasional            |
| 3         | `COPY` de archivos de dependencias        | Ocasional            |
| 4         | `RUN` instalación de dependencias         | Ocasional            |
| 5         | `COPY` de código fuente                   | Frecuente            |
| 6         | `RUN` de build/compilación                | Frecuente            |
| 7         | `CMD`, `EXPOSE`, etc.                     | Rara vez             |

---

## 🧹 Reducir Tamaño de Capas

### Limpiar en la misma capa

```dockerfile
# ❌ Malo - caché de apt persiste
RUN apt-get update
RUN apt-get install -y curl
RUN apt-get clean

# ✅ Bueno - todo en una capa, limpieza incluida
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
```

### Para diferentes gestores de paquetes

```dockerfile
# Alpine (apk)
RUN apk add --no-cache curl git

# Node.js (pnpm)
RUN corepack enable && \
    pnpm install --prod --frozen-lockfile

# Python (uv)
RUN uv pip install --system --no-cache -r requirements.txt

# Go
RUN go build -ldflags="-s -w" -o /app/server
```

---

## 🔒 Optimización de Seguridad

### Usuario No-Root

```dockerfile
FROM node:22-alpine

# Crear usuario y grupo
RUN addgroup -S appgroup && \
    adduser -S appuser -G appgroup

WORKDIR /app

# Copiar con permisos correctos
COPY --chown=appuser:appgroup . .

# Cambiar a usuario no-root ANTES de CMD
USER appuser

CMD ["node", "server.js"]
```

### Imagen Distroless (Máxima Seguridad)

```dockerfile
# Build
FROM golang:1.25 AS builder
WORKDIR /app
COPY . .
RUN CGO_ENABLED=0 go build -o /server

# Producción - sin shell, sin paquetes
FROM gcr.io/distroless/static-debian12
COPY --from=builder /server /server
USER nonroot:nonroot
ENTRYPOINT ["/server"]
```

### Imagen Scratch (Binarios Estáticos)

```dockerfile
# Para binarios Go completamente estáticos
FROM golang:1.25 AS builder
WORKDIR /app
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -a -ldflags='-s -w' -o /server

# Imagen vacía - solo tu binario
FROM scratch
COPY --from=builder /server /server
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
ENTRYPOINT ["/server"]
```

---

## 📋 Dockerfile Optimizado Completo

```dockerfile
# ============================================
# Multi-stage build optimizado para Node.js
# ============================================

# --- Etapa 1: Dependencias ---
FROM node:22-alpine AS deps
WORKDIR /app
COPY package.json pnpm-lock.yaml ./
RUN corepack enable && pnpm install --prod --frozen-lockfile

# --- Etapa 2: Build ---
FROM node:22-alpine AS builder
WORKDIR /app
COPY package.json pnpm-lock.yaml ./
RUN corepack enable && pnpm install --frozen-lockfile
COPY . .
RUN pnpm run build && \
    pnpm prune --prod

# --- Etapa 3: Producción ---
FROM node:22-alpine AS production

# Metadatos
LABEL maintainer="dev@example.com" \
      version="1.0.0"

# Variables de entorno
ENV NODE_ENV=production \
    PORT=3000

# Usuario no-root
RUN addgroup -S app && adduser -S app -G app

WORKDIR /app

# Solo archivos necesarios
COPY --from=builder --chown=app:app /app/dist ./dist
COPY --from=deps --chown=app:app /app/node_modules ./node_modules
COPY --from=builder --chown=app:app /app/package.json ./

# Seguridad
USER app

# Healthcheck
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:${PORT}/health || exit 1

EXPOSE ${PORT}

CMD ["node", "dist/server.js"]
```

---

## 📊 Comparativa de Optimizaciones

| Técnica           | Antes           | Después | Reducción |
| ----------------- | --------------- | ------- | --------- |
| Multi-stage       | 1.2 GB          | 150 MB  | 87%       |
| Alpine base       | 900 MB          | 140 MB  | 84%       |
| .dockerignore     | 600 MB contexto | 1 MB    | 99%       |
| Limpieza de caché | 50 MB extra     | 0 MB    | 100%      |
| Distroless        | 150 MB          | 20 MB   | 86%       |

---

## 🔍 Herramientas de Análisis

```bash
# Ver historial y tamaño de capas
docker history --human miimagen:latest

# Análisis detallado con dive
docker run --rm -it \
    -v /var/run/docker.sock:/var/run/docker.sock \
    wagoodman/dive:latest miimagen:latest

# Escanear vulnerabilidades
docker scout cves miimagen:latest

# Comparar tamaños
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" | sort -k3 -h
```

---

## ✅ Checklist de Optimización

- [ ] Usar multi-stage build
- [ ] Elegir imagen base mínima (alpine/slim)
- [ ] Configurar .dockerignore
- [ ] Ordenar instrucciones para maximizar caché
- [ ] Combinar RUN y limpiar en la misma capa
- [ ] Usar usuario no-root
- [ ] Implementar HEALTHCHECK
- [ ] Verificar con `docker history`
- [ ] Escanear vulnerabilidades

---

## ✅ Verificación de Aprendizaje

1. ¿Qué es un multi-stage build y cuándo lo usarías?
2. ¿Por qué el orden de las instrucciones afecta el tiempo de build?
3. ¿Cuál es la diferencia entre `node:22` y `node:22-alpine`?
4. ¿Por qué debemos limpiar cachés en la misma instrucción RUN?
5. ¿Qué beneficios tiene usar un usuario no-root?

---

## 🔗 Navegación

| ← Anterior                                | Inicio                           |
| ----------------------------------------- | -------------------------------- |
| [04 - Build Context](04-build-context.md) | [Volver al índice](../README.md) |
