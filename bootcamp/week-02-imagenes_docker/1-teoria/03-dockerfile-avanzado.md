# 📚 Dockerfile: Instrucciones Avanzadas

## 🎯 Objetivos de Aprendizaje

Al finalizar esta sección, serás capaz de:

- Usar instrucciones avanzadas de Dockerfile
- Diferenciar entre ENTRYPOINT y CMD
- Trabajar con variables de entorno y argumentos de build
- Configurar metadatos con LABEL
- Implementar HEALTHCHECK para monitoreo

---

## 🚀 ENTRYPOINT vs CMD

### ENTRYPOINT

Define el **ejecutable principal** del contenedor. Es más difícil de sobreescribir.

```dockerfile
# Sintaxis exec (recomendada)
ENTRYPOINT ["ejecutable", "param1"]

# Sintaxis shell
ENTRYPOINT comando param1
```

### Diferencias Clave

| Aspecto         | CMD                          | ENTRYPOINT              |
| --------------- | ---------------------------- | ----------------------- |
| **Propósito**   | Argumentos por defecto       | Ejecutable principal    |
| **Override**    | Fácil (`docker run img cmd`) | Requiere `--entrypoint` |
| **Combinación** | Se pasa a ENTRYPOINT         | Recibe CMD como args    |

### Combinando ENTRYPOINT + CMD

```dockerfile
# ENTRYPOINT define el ejecutable
# CMD define argumentos por defecto
ENTRYPOINT ["python"]
CMD ["app.py"]

# Equivale a: python app.py
```

```bash
# Comportamiento
docker run miimagen                 # python app.py
docker run miimagen script.py       # python script.py (CMD sobreescrito)
docker run --entrypoint bash miimagen  # bash (ENTRYPOINT sobreescrito)
```

### Ejemplo Práctico: CLI Tool

```dockerfile
FROM alpine:3.21
RUN apk add --no-cache curl

# curl es el ejecutable fijo
ENTRYPOINT ["curl"]

# Argumentos por defecto
CMD ["--help"]
```

```bash
docker run micurl                           # curl --help
docker run micurl https://api.github.com    # curl https://api.github.com
docker run micurl -I https://google.com     # curl -I https://google.com
```

---

## 🌍 ENV - Variables de Entorno

Define variables de entorno disponibles en **build y runtime**.

```dockerfile
# Sintaxis
ENV <clave>=<valor>
ENV <clave1>=<valor1> <clave2>=<valor2>

# Ejemplos
ENV NODE_ENV=production
ENV APP_HOME=/app \
    APP_PORT=3000 \
    APP_USER=appuser
```

### Uso de Variables ENV

```dockerfile
FROM node:22-alpine

# Definir variables
ENV APP_DIR=/app \
    NODE_ENV=production

# Usar en instrucciones
WORKDIR ${APP_DIR}
RUN echo "Entorno: $NODE_ENV"

# También disponibles en runtime
CMD ["node", "server.js"]
```

```bash
# Sobreescribir en runtime
docker run -e NODE_ENV=development miimagen
docker run --env-file .env miimagen
```

---

## 🔧 ARG - Argumentos de Build

Define variables disponibles **solo durante el build**.

```dockerfile
# Sintaxis
ARG <nombre>[=<valor_defecto>]

# Ejemplos
ARG VERSION=1.0.0
ARG NODE_VERSION=20
ARG BUILD_DATE
```

### Diferencias ENV vs ARG

| Aspecto            | ENV                  | ARG                             |
| ------------------ | -------------------- | ------------------------------- |
| **Disponibilidad** | Build + Runtime      | Solo Build                      |
| **Persistencia**   | Sí, en imagen final  | No                              |
| **Override**       | `-e` en `docker run` | `--build-arg` en `docker build` |
| **Uso en FROM**    | No                   | Sí (antes de FROM)              |

### Ejemplo con ARG

```dockerfile
# ARG antes de FROM para versión dinámica
ARG NODE_VERSION=20

FROM node:${NODE_VERSION}-alpine

# ARG después de FROM necesita redefinirse
ARG APP_VERSION=1.0.0

ENV VERSION=${APP_VERSION}

LABEL version="${APP_VERSION}"
```

```bash
# Construir con argumentos
docker build --build-arg NODE_VERSION=18 --build-arg APP_VERSION=2.0.0 -t miapp .
```

---

## 🏷️ LABEL - Metadatos

Añade metadatos a la imagen en formato clave-valor.

```dockerfile
# Sintaxis
LABEL <clave>=<valor>

# Múltiples labels
LABEL maintainer="dev@example.com" \
      version="1.0.0" \
      description="Mi aplicación web"

# Labels OCI estándar
LABEL org.opencontainers.image.title="Mi App" \
      org.opencontainers.image.version="1.0.0" \
      org.opencontainers.image.authors="dev@example.com" \
      org.opencontainers.image.source="https://github.com/user/repo" \
      org.opencontainers.image.licenses="MIT"
```

```bash
# Ver labels de una imagen
docker inspect --format='{{json .Config.Labels}}' miimagen | jq
```

---

## 👤 USER - Usuario de Ejecución

Define el usuario (y opcionalmente grupo) para ejecutar instrucciones.

```dockerfile
# Sintaxis
USER <usuario>[:<grupo>]
USER <UID>[:<GID>]

# Ejemplo: Crear y usar usuario no-root
FROM node:22-alpine

# Crear usuario sin privilegios
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app
COPY --chown=appuser:appgroup . .

# Cambiar a usuario no-root
USER appuser

CMD ["node", "server.js"]
```

> ⚠️ **Seguridad**: Nunca ejecutes contenedores como root en producción.

---

## ❤️ HEALTHCHECK - Monitoreo de Salud

Define cómo verificar si el contenedor está funcionando correctamente.

```dockerfile
# Sintaxis
HEALTHCHECK [opciones] CMD <comando>
HEALTHCHECK NONE  # Deshabilitar

# Opciones
# --interval=30s     Frecuencia de verificación
# --timeout=10s      Tiempo máximo de espera
# --start-period=5s  Tiempo de gracia al inicio
# --retries=3        Intentos antes de marcar unhealthy
```

### Ejemplos de HEALTHCHECK

```dockerfile
# Para aplicación web
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3000/health || exit 1

# Para base de datos PostgreSQL
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
    CMD pg_isready -U postgres || exit 1

# Para Redis
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
    CMD redis-cli ping || exit 1

# Usando wget (si no hay curl)
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8080/ || exit 1
```

### Estados del Healthcheck

| Estado        | Descripción                                   |
| ------------- | --------------------------------------------- |
| **starting**  | Contenedor iniciando (dentro de start-period) |
| **healthy**   | Healthcheck pasó exitosamente                 |
| **unhealthy** | Healthcheck falló después de los retries      |

```bash
# Ver estado de salud
docker ps
# CONTAINER ID   IMAGE     STATUS
# abc123         miapp     Up 5 min (healthy)

# Ver historial de healthchecks
docker inspect --format='{{json .State.Health}}' mi-contenedor | jq
```

---

## 📁 ADD vs COPY

| Aspecto                      | COPY         | ADD                    |
| ---------------------------- | ------------ | ---------------------- |
| **Archivos locales**         | ✅           | ✅                     |
| **URLs remotas**             | ❌           | ✅ (no recomendado)    |
| **Descompresión automática** | ❌           | ✅ (.tar, .gz, .bz2)   |
| **Recomendación**            | ✅ Preferido | Solo para descomprimir |

```dockerfile
# ✅ Usar COPY para archivos locales
COPY package.json ./
COPY src/ ./src/

# ✅ ADD solo para descompresión automática
ADD app.tar.gz /app/

# ❌ No usar ADD para URLs (usar RUN + curl)
# ADD https://example.com/file.txt /app/  # No recomendado

# ✅ Mejor práctica para descargas
RUN curl -fsSL https://example.com/file.txt -o /app/file.txt
```

---

## 🛑 STOPSIGNAL

Define la señal del sistema para detener el contenedor.

```dockerfile
# Por defecto es SIGTERM
STOPSIGNAL SIGTERM

# Algunas aplicaciones necesitan SIGQUIT
STOPSIGNAL SIGQUIT

# O usar número de señal
STOPSIGNAL 9  # SIGKILL
```

---

## 📂 VOLUME

Crea un punto de montaje para volúmenes.

```dockerfile
# Sintaxis
VOLUME ["/ruta/datos"]
VOLUME /ruta/datos

# Ejemplos
VOLUME ["/var/lib/mysql"]
VOLUME ["/app/uploads", "/app/logs"]
```

> 💡 **Nota**: Esto crea un volumen anónimo. Es mejor definir volúmenes en `docker run -v` o Docker Compose.

---

## 📋 Dockerfile Completo de Ejemplo

```dockerfile
# ============================================
# Imagen de producción para aplicación Node.js
# ============================================

# Argumento para versión de Node
ARG NODE_VERSION=20

# Imagen base
FROM node:${NODE_VERSION}-alpine

# Metadatos
LABEL maintainer="equipo@example.com" \
      version="1.0.0" \
      description="API REST de ejemplo" \
      org.opencontainers.image.source="https://github.com/example/api"

# Variables de entorno
ENV NODE_ENV=production \
    APP_PORT=3000 \
    APP_USER=appuser

# Crear usuario no-root
RUN addgroup -S appgroup && \
    adduser -S ${APP_USER} -G appgroup

# Directorio de trabajo
WORKDIR /app

# Copiar dependencias primero (mejor cache)
COPY --chown=${APP_USER}:appgroup package*.json ./

# Instalar dependencias
RUN npm ci --only=production && \
    npm cache clean --force

# Copiar código fuente
COPY --chown=${APP_USER}:appgroup . .

# Cambiar a usuario no-root
USER ${APP_USER}

# Puerto de la aplicación
EXPOSE ${APP_PORT}

# Healthcheck
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:${APP_PORT}/health || exit 1

# Comando de inicio
ENTRYPOINT ["node"]
CMD ["server.js"]
```

---

## ✅ Verificación de Aprendizaje

1. ¿Cuándo usarías ENTRYPOINT en lugar de CMD?
2. ¿Cuál es la diferencia entre ENV y ARG?
3. ¿Por qué es importante usar USER para ejecutar como no-root?
4. ¿Qué información proporciona HEALTHCHECK?
5. ¿Cuándo es apropiado usar ADD en lugar de COPY?

---

## 🔗 Navegación

| ← Anterior                                        | Siguiente →                               |
| ------------------------------------------------- | ----------------------------------------- |
| [02 - Dockerfile Básico](02-dockerfile-basico.md) | [04 - Build Context](04-build-context.md) |
