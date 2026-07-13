# 💻 Ejercicio 02: Explorando Imágenes

## 🎯 Objetivos

- Buscar y descargar imágenes de Docker Hub
- Entender tags y versiones
- Inspeccionar imágenes y sus capas
- Comparar tamaños de imágenes

## ⏱️ Duración Estimada

35 minutos

## 📋 Requisitos Previos

- Ejercicio 01 completado
- Conexión a internet (para descargar imágenes)

---

## 📝 Instrucciones

### Paso 1: Buscar Imágenes

Docker Hub es el registry público de imágenes. Puedes buscar desde la terminal:

```bash
# Buscar imágenes de python
docker search python

# Buscar con filtro de estrellas (popularidad)
docker search --filter=stars=100 python
```

📌 **Observa**: Las imágenes "OFFICIAL" son mantenidas por Docker o el proyecto oficial.

También puedes explorar en [hub.docker.com](https://hub.docker.com/)

---

### Paso 2: Entender los Tags

Los tags identifican versiones específicas de una imagen.

```bash
# Descargar diferentes versiones de Python
docker pull python:3.12
docker pull python:3.12-slim
docker pull python:3.12-alpine

# Ver las imágenes descargadas
docker images | grep python
```

📌 **Nomenclatura común de tags**:

| Tag             | Descripción                          |
| --------------- | ------------------------------------ |
| `latest`        | Última versión (predeterminada)      |
| `3.12`          | Versión específica                   |
| `3.12-slim`     | Versión reducida (Debian slim)       |
| `3.12-alpine`   | Basada en Alpine Linux (muy pequeña) |
| `3.12-bookworm` | Basada en Debian Bookworm            |

---

### Paso 3: Comparar Tamaños

```bash
# Ver tamaños de las imágenes Python
docker images python

# Salida esperada (aproximada):
# REPOSITORY   TAG           SIZE
# python       3.12          1.02GB
# python       3.12-slim     155MB
# python       3.12-alpine   51.8MB
```

📌 **Observa**: La versión Alpine es ~20 veces más pequeña que la versión completa.

---

### Paso 4: Inspeccionar una Imagen

```bash
# Ver información detallada
docker inspect python:3.12-alpine
```

Información útil que puedes extraer:

```bash
# Ver el comando por defecto
docker inspect -f '{{.Config.Cmd}}' python:3.12-alpine

# Ver las variables de entorno
docker inspect -f '{{.Config.Env}}' python:3.12-alpine

# Ver el punto de entrada
docker inspect -f '{{.Config.Entrypoint}}' python:3.12-alpine

# Ver arquitectura
docker inspect -f '{{.Architecture}}' python:3.12-alpine
```

---

### Paso 5: Ver Historial de Capas

```bash
# Ver las capas de una imagen
docker history python:3.12-alpine

# Con más detalle (sin truncar)
docker history --no-trunc python:3.12-alpine
```

📌 **Observa**: Cada línea representa una capa. Las capas más antiguas están abajo.

---

### Paso 6: Verificar Funcionamiento

Ejecuta Python en cada versión:

```bash
# Python completo
docker run --rm python:3.12 python --version

# Python slim
docker run --rm python:3.12-slim python --version

# Python alpine
docker run --rm python:3.12-alpine python --version
```

Prueba ejecutar un script simple:

```bash
# Ejecutar código Python directamente
docker run --rm python:3.12-alpine python -c "print('Hola desde Docker!')"

# Script más complejo
docker run --rm python:3.12-alpine python -c "
import sys
print(f'Python {sys.version}')
print(f'Plataforma: {sys.platform}')
"
```

---

### Paso 7: Explorar Otras Imágenes Populares

```bash
# Descargar imágenes populares
docker pull nginx:alpine
docker pull node:22-alpine
docker pull redis:alpine
docker pull postgres:16-alpine

# Comparar tamaños
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" | head -10
```

---

### Paso 8: Etiquetar Imágenes

Puedes crear tus propios tags (alias) para imágenes:

```bash
# Crear un tag personalizado
docker tag python:3.12-alpine mi-python:v1

# Ver el resultado
docker images | grep -E "python|mi-python"
```

📌 **Observa**: Ambos tags apuntan a la misma imagen (mismo IMAGE ID).

---

### Paso 9: Limpieza

```bash
# Eliminar la imagen con tag personalizado
docker rmi mi-python:v1

# Eliminar imágenes que no usaremos
docker rmi python:3.12 python:3.12-slim

# Eliminar imágenes "colgadas" (sin tag)
docker image prune

# Ver espacio liberado
docker system df
```

---

## ✅ Checklist de Verificación

- [ ] Busqué imágenes con `docker search`
- [ ] Descargué múltiples versiones de Python
- [ ] Comparé tamaños entre versiones
- [ ] Inspeccioné una imagen con `docker inspect`
- [ ] Vi el historial de capas con `docker history`
- [ ] Ejecuté Python en contenedores
- [ ] Creé un tag personalizado
- [ ] Limpié imágenes no necesarias

---

## 🎯 Desafío Extra

1. Encuentra la imagen oficial de Node.js más pequeña
2. Descarga MySQL y averigua qué puerto expone por defecto
3. Compara los tamaños de `ubuntu:22.04` vs `alpine:3.21`

<details>
<summary>💡 Soluciones</summary>

```bash
# 1. Node.js más pequeño
docker pull node:22-alpine
docker images node

# 2. Puerto de MySQL
docker pull mysql:8
docker inspect -f '{{.Config.ExposedPorts}}' mysql:8
# Respuesta: 3306/tcp, 33060/tcp

# 3. Comparar Ubuntu vs Alpine
docker pull ubuntu:22.04
docker pull alpine:3.21
docker images --format "{{.Repository}}:{{.Tag}}\t{{.Size}}" | grep -E "ubuntu|alpine"
# Ubuntu: ~77MB, Alpine: ~7MB
```

</details>

---

## 📊 Tabla de Referencia: Imágenes Base Comunes

| Imagen                 | Tamaño Aprox. | Uso Recomendado      |
| ---------------------- | ------------- | -------------------- |
| `alpine:3.21`          | 7 MB          | Producción, mínimo   |
| `debian:bookworm-slim` | 74 MB         | Compatibilidad       |
| `ubuntu:22.04`         | 77 MB         | Desarrollo           |
| `python:3.12-alpine`   | 52 MB         | Apps Python pequeñas |
| `node:22-alpine`       | 135 MB        | Apps Node.js         |
| `nginx:alpine`         | 43 MB         | Servidor web         |

---

## 🔗 Navegación

| ← Ejercicio Anterior                                        | Siguiente Ejercicio →                                                     |
| ----------------------------------------------------------- | ------------------------------------------------------------------------- |
| [01 - Primer Contenedor](../01-primer-contenedor/README.md) | [03 - Gestionando Contenedores](../03-gestionando-contenedores/README.md) |
