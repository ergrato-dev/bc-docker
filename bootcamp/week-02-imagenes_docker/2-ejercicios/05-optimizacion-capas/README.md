# 💻 Ejercicio 05: Optimización de Capas

## 🎯 Objetivo

Dominar las técnicas de optimización de capas para maximizar el uso de caché y reducir tiempos de build.

---

## 📋 Descripción

Tomarás un Dockerfile mal optimizado y lo mejorarás aplicando buenas prácticas de ordenamiento de capas, limpieza y caché.

---

## ⏱️ Tiempo Estimado

30 minutos

---

## 📚 Conceptos Aplicados

- Orden óptimo de instrucciones
- Combinación de comandos RUN
- Limpieza de caché en la misma capa
- Análisis de capas con `docker history`
- Uso eficiente del build cache

---

## 📝 Instrucciones

### Paso 1: Preparar el Entorno

```bash
cd bootcamp/week-02-imagenes_docker/2-ejercicios/05-optimizacion-capas
```

### Paso 2: Crear la Aplicación Python

Crea `requirements.txt`:

```text
flask==3.0.0
gunicorn==21.2.0
requests==2.31.0
```

Crea `app.py`:

```python
from flask import Flask, jsonify
import requests
import os

app = Flask(__name__)

@app.route('/')
def home():
    return jsonify({
        'message': '¡Optimización de capas exitosa!',
        'exercise': '05-optimizacion-capas',
        'environment': os.getenv('FLASK_ENV', 'development')
    })

@app.route('/health')
def health():
    return jsonify({'status': 'healthy'})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
```

### Paso 3: Crear Dockerfile NO Optimizado

Crea `Dockerfile.bad`:

```dockerfile
# ❌ DOCKERFILE MAL OPTIMIZADO
# Este archivo demuestra malas prácticas

FROM python:3.12

# ❌ Copia TODO primero (invalida caché con cualquier cambio)
COPY . /app

WORKDIR /app

# ❌ Múltiples RUN separados (más capas)
RUN apt-get update
RUN apt-get install -y curl
RUN apt-get install -y vim
RUN apt-get clean

# ❌ Instala dependencias DESPUÉS de copiar código
COPY --from=ghcr.io/astral-sh/uv:latest /uv /bin/uv
RUN uv pip install --system -r requirements.txt

# ❌ No limpia caché de uv
# ❌ No usa --no-cache

EXPOSE 5000

CMD ["python", "app.py"]
```

### Paso 4: Analizar el Dockerfile Malo

```bash
# Construir versión no optimizada
docker build -f Dockerfile.bad -t capas:bad .

# Ver capas y tamaños
docker history capas:bad

# Ver tamaño total
docker images capas:bad
```

### Paso 5: Crear Dockerfile OPTIMIZADO

Crea `Dockerfile`:

```dockerfile
# ============================================
# ✅ DOCKERFILE OPTIMIZADO
# Aplicando buenas prácticas de capas
# ============================================

# Usar imagen slim (más pequeña que la completa)
FROM python:3.12-slim

# Metadatos
LABEL maintainer="bootcamp@docker.com" \
      version="1.0.0"

# Variables de entorno
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    FLASK_ENV=production

# ✅ Instalar dependencias del sistema en UNA sola capa
# ✅ Limpiar caché en la MISMA instrucción RUN
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Directorio de trabajo
WORKDIR /app

# ✅ Instalar uv (gestor de paquetes recomendado, más rápido que pip)
COPY --from=ghcr.io/astral-sh/uv:latest /uv /bin/uv

# ✅ Copiar SOLO requirements primero (mejor caché)
COPY requirements.txt .

# ✅ Instalar dependencias Python con --no-cache
RUN uv pip install --system --no-cache -r requirements.txt

# ✅ Copiar código fuente AL FINAL (cambia más frecuentemente)
COPY app.py .

# Puerto
EXPOSE 5000

# ✅ Usar gunicorn para producción
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]
```

### Paso 6: Construir y Comparar

```bash
# Construir versión optimizada
docker build -t capas:optimized .

# Comparar tamaños
docker images | grep capas

# Comparar número de capas
echo "=== Capas versión BAD ==="
docker history capas:bad --no-trunc | wc -l

echo "=== Capas versión OPTIMIZED ==="
docker history capas:optimized --no-trunc | wc -l
```

### Paso 7: Probar el Caché

```bash
# Modificar SOLO app.py
echo "# Comentario de prueba" >> app.py

# Reconstruir - observa qué capas se reutilizan
docker build -t capas:optimized-v2 .

# Deberías ver "Using cache" en las capas de uv pip install
```

### Paso 8: Ejecutar y Verificar

```bash
# Ejecutar
docker run -d --name flask-app -p 5000:5000 capas:optimized

# Probar endpoints
curl http://localhost:5000/
curl http://localhost:5000/health

# Limpiar
docker stop flask-app && docker rm flask-app
```

---

## ✅ Checklist de Verificación

- [ ] El Dockerfile usa `python:3.12-slim` como base
- [ ] Los comandos `apt-get` están en UNA sola instrucción RUN
- [ ] La limpieza de apt se hace en la MISMA capa
- [ ] `requirements.txt` se copia ANTES que el código
- [ ] `uv pip install` usa `--no-cache`
- [ ] El código fuente se copia AL FINAL
- [ ] La imagen optimizada es significativamente más pequeña
- [ ] Al cambiar solo `app.py`, las capas de uv pip se reutilizan del caché

---

## 💡 Hints

<details>
<summary>Hint 1: Combinar comandos RUN</summary>

```dockerfile
# ❌ Malo - 4 capas
RUN apt-get update
RUN apt-get install -y curl
RUN apt-get clean

# ✅ Bueno - 1 capa
RUN apt-get update && \
    apt-get install -y curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
```

</details>

<details>
<summary>Hint 2: Orden para maximizar caché</summary>

```dockerfile
# 1. Cosas que casi nunca cambian
FROM python:3.12-slim
RUN apt-get update && apt-get install -y curl && ...

# 2. Dependencias (cambian ocasionalmente)
COPY requirements.txt .
RUN uv pip install --system -r requirements.txt

# 3. Código fuente (cambia frecuentemente)
COPY . .
```

</details>

<details>
<summary>Hint 3: Verificar uso de caché</summary>

```bash
# Al reconstruir, busca estas líneas:
# ---> Using cache
# Si aparece después de uv pip install, ¡está funcionando!
```

</details>

---

## 🔍 Análisis Detallado

```bash
# Ver capas con tamaños
docker history capas:optimized --format "table {{.Size}}\t{{.CreatedBy}}"

# Analizar con dive (herramienta avanzada)
docker run --rm -it \
    -v /var/run/docker.sock:/var/run/docker.sock \
    wagoodman/dive:latest capas:optimized
```

---

## 📊 Comparativa Esperada

| Aspecto                     | Dockerfile.bad     | Dockerfile optimizado     |
| --------------------------- | ------------------ | ------------------------- |
| **Imagen base**             | python:3.12 (~1GB) | python:3.12-slim (~150MB) |
| **Capas RUN apt**           | 4 capas            | 1 capa                    |
| **Caché de uv**             | No                 | Sí                        |
| **Limpieza apt**            | Capa separada      | Misma capa                |
| **Tamaño final**            | ~1.2 GB            | ~200 MB                   |
| **Rebuild (cambio código)** | Reinstala todo     | Reutiliza caché           |

---

## 📂 Estructura de Archivos

```
05-optimizacion-capas/
├── README.md           # Este archivo
├── Dockerfile          # Optimizado (lo crearás tú)
├── Dockerfile.bad      # No optimizado (comparación)
├── requirements.txt    # Lo crearás tú
└── app.py              # Lo crearás tú
```

---

## 🔗 Navegación

| ← Anterior                             | Índice                              |
| -------------------------------------- | ----------------------------------- |
| [04 - Multi-stage](../04-multi-stage/) | [Volver a Ejercicios](../README.md) |
