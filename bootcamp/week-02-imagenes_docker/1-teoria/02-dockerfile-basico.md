# 📚 Dockerfile: Instrucciones Básicas

## 🎯 Objetivos de Aprendizaje

Al finalizar esta sección, serás capaz de:

- Entender qué es un Dockerfile y su propósito
- Usar las instrucciones fundamentales
- Escribir tu primer Dockerfile funcional
- Construir imágenes con `docker build`

---

## 📝 ¿Qué es un Dockerfile?

Un **Dockerfile** es un archivo de texto que contiene todas las instrucciones necesarias para construir una imagen Docker.

```dockerfile
# Ejemplo básico de Dockerfile
FROM alpine:3.19
RUN apk add --no-cache curl
CMD ["curl", "--version"]
```

### Características

| Característica  | Descripción                                  |
| --------------- | -------------------------------------------- |
| **Nombre**      | `Dockerfile` (sin extensión, por convención) |
| **Formato**     | Texto plano, una instrucción por línea       |
| **Case**        | Instrucciones en MAYÚSCULAS (convención)     |
| **Orden**       | Se ejecutan de arriba hacia abajo            |
| **Comentarios** | Líneas que comienzan con `#`                 |

---

## 🏗️ Instrucciones Fundamentales

### FROM - Imagen Base

Define la imagen base sobre la cual se construirá tu imagen.

```dockerfile
# Sintaxis
FROM <imagen>:<tag>

# Ejemplos
FROM ubuntu:22.04
FROM node:20-alpine
FROM python:3.12-slim
FROM scratch              # Imagen vacía (para binarios estáticos)
```

> ⚠️ **Importante**: `FROM` debe ser la primera instrucción (excepto ARG).

#### Buenas Prácticas para FROM

| ✅ Hacer                     | ❌ Evitar               |
| ---------------------------- | ----------------------- |
| `FROM node:20-alpine`        | `FROM node:latest`      |
| `FROM python:3.12-slim`      | `FROM python`           |
| Usar tags específicos        | Usar `latest`           |
| Preferir `-alpine` o `-slim` | Usar imágenes completas |

---

### RUN - Ejecutar Comandos

Ejecuta comandos durante la **construcción** de la imagen.

```dockerfile
# Sintaxis shell (usa /bin/sh -c)
RUN <comando>

# Sintaxis exec (ejecuta directamente)
RUN ["ejecutable", "param1", "param2"]
```

```dockerfile
# Ejemplos
RUN apt-get update && apt-get install -y curl
RUN pip install flask
RUN npm install
RUN mkdir -p /app/data
```

#### Optimización de RUN

```dockerfile
# ❌ Malo - Crea múltiples capas
RUN apt-get update
RUN apt-get install -y curl
RUN apt-get install -y vim
RUN apt-get clean

# ✅ Bueno - Una sola capa, limpieza incluida
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        vim && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
```

---

### COPY - Copiar Archivos

Copia archivos desde el **build context** hacia la imagen.

```dockerfile
# Sintaxis
COPY <origen> <destino>
COPY ["<origen>", "<destino>"]  # Si hay espacios en rutas

# Ejemplos
COPY package.json /app/
COPY . /app/
COPY src/ /app/src/
COPY config/*.json /app/config/
```

```dockerfile
# Con --chown para establecer propietario (Linux)
COPY --chown=node:node package*.json ./
```

---

### WORKDIR - Directorio de Trabajo

Establece el directorio de trabajo para las instrucciones siguientes.

```dockerfile
# Sintaxis
WORKDIR /ruta/al/directorio

# Ejemplo
WORKDIR /app
COPY . .           # Copia al directorio /app
RUN npm install    # Se ejecuta en /app
```

> 💡 **Tip**: Usa `WORKDIR` en lugar de `RUN cd /directorio`. WORKDIR crea el directorio si no existe.

---

### CMD - Comando por Defecto

Define el comando que se ejecuta cuando el **contenedor inicia**.

```dockerfile
# Sintaxis exec (recomendada)
CMD ["ejecutable", "param1", "param2"]

# Sintaxis shell
CMD comando param1 param2

# Ejemplos
CMD ["node", "app.js"]
CMD ["python", "main.py"]
CMD ["nginx", "-g", "daemon off;"]
```

| Característica | Descripción                                |
| -------------- | ------------------------------------------ |
| **Cantidad**   | Solo puede haber UN `CMD` (el último gana) |
| **Override**   | Se puede sobreescribir en `docker run`     |
| **Ejecución**  | Se ejecuta al iniciar el contenedor        |

```bash
# El CMD se puede sobreescribir
docker run miimagen                    # Usa CMD del Dockerfile
docker run miimagen echo "Hola"        # Sobreescribe CMD
```

---

### EXPOSE - Documentar Puertos

Documenta qué puertos usa la aplicación (no los abre realmente).

```dockerfile
# Sintaxis
EXPOSE <puerto>
EXPOSE <puerto>/<protocolo>

# Ejemplos
EXPOSE 80
EXPOSE 443
EXPOSE 3000
EXPOSE 5432/tcp
EXPOSE 53/udp
```

> ⚠️ **Nota**: `EXPOSE` es documentación. Para publicar puertos usa `-p` en `docker run`.

---

## 🔨 Tu Primer Dockerfile

### Ejemplo: Aplicación Node.js

```dockerfile
# Dockerfile para aplicación Node.js
# Imagen base con Node.js sobre Alpine
FROM node:20-alpine

# Crear directorio de trabajo
WORKDIR /app

# Copiar archivos de dependencias
COPY package*.json ./

# Instalar dependencias
RUN npm install --production

# Copiar código fuente
COPY . .

# Documentar puerto
EXPOSE 3000

# Comando de inicio
CMD ["node", "server.js"]
```

### Ejemplo: Aplicación Python

```dockerfile
# Dockerfile para aplicación Python/Flask
FROM python:3.12-slim

# Variables de entorno para Python
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# Instalar dependencias
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copiar código
COPY . .

EXPOSE 5000

CMD ["python", "app.py"]
```

---

## 🏗️ Construir la Imagen

### Comando docker build

```bash
# Sintaxis básica
docker build [opciones] <contexto>

# Construir imagen en directorio actual
docker build -t miapp:v1 .

# Con Dockerfile en otra ubicación
docker build -t miapp:v1 -f docker/Dockerfile.prod .

# Sin cache
docker build --no-cache -t miapp:v1 .

# Ver progreso detallado
docker build --progress=plain -t miapp:v1 .
```

### Opciones Comunes

| Opción        | Descripción                    | Ejemplo                   |
| ------------- | ------------------------------ | ------------------------- |
| `-t, --tag`   | Nombre y tag de la imagen      | `-t miapp:v1`             |
| `-f, --file`  | Ruta al Dockerfile             | `-f Dockerfile.dev`       |
| `--no-cache`  | No usar cache de capas         | `--no-cache`              |
| `--build-arg` | Variables de build             | `--build-arg VERSION=1.0` |
| `--target`    | Stage específico (multi-stage) | `--target production`     |
| `--platform`  | Arquitectura destino           | `--platform linux/amd64`  |

---

## 📋 Ejemplo Completo: Build y Run

```bash
# 1. Crear estructura
mkdir mi-app && cd mi-app

# 2. Crear archivo de aplicación
cat > app.py << 'EOF'
from http.server import HTTPServer, SimpleHTTPRequestHandler
print("Servidor iniciando en puerto 8080...")
HTTPServer(('', 8080), SimpleHTTPRequestHandler).serve_forever()
EOF

# 3. Crear Dockerfile
cat > Dockerfile << 'EOF'
FROM python:3.12-alpine
WORKDIR /app
COPY app.py .
EXPOSE 8080
CMD ["python", "app.py"]
EOF

# 4. Construir imagen
docker build -t mi-servidor:v1 .

# 5. Ejecutar contenedor
docker run -d -p 8080:8080 --name servidor mi-servidor:v1

# 6. Verificar
curl http://localhost:8080

# 7. Limpiar
docker stop servidor && docker rm servidor
```

---

## ✅ Verificación de Aprendizaje

1. ¿Cuál es la diferencia entre RUN y CMD?
2. ¿Por qué debemos usar tags específicos en FROM?
3. ¿Qué hace realmente la instrucción EXPOSE?
4. ¿Cuál es el propósito de WORKDIR?
5. ¿Cómo se sobreescribe el CMD de una imagen?

---

## 🔗 Navegación

| ← Anterior                                       | Siguiente →                                           |
| ------------------------------------------------ | ----------------------------------------------------- |
| [01 - Anatomía de Imagen](01-anatomia-imagen.md) | [03 - Dockerfile Avanzado](03-dockerfile-avanzado.md) |
