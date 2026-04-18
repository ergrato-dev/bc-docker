# 💻 Ejercicio 02: Variables y Argumentos

## 🎯 Objetivo

Aprender a usar variables de entorno (`ENV`), argumentos de build (`ARG`) y metadatos (`LABEL`) en Dockerfiles.

---

## 📋 Descripción

Crearás una imagen configurable que muestre información dinámica según las variables definidas.

---

## ⏱️ Tiempo Estimado

25 minutos

---

## 📚 Conceptos Aplicados

- `ARG` - Argumentos de construcción
- `ENV` - Variables de entorno
- `LABEL` - Metadatos de imagen
- Paso de argumentos con `--build-arg`
- Sobrescritura de variables con `-e`

---

## 📝 Instrucciones

### Paso 1: Preparar el Entorno

```bash
cd bootcamp/week-02-imagenes_docker/2-ejercicios/02-variables-argumentos
```

### Paso 2: Crear el Script de la Aplicación

Crea un archivo `app.sh`:

```bash
#!/bin/sh

echo "=========================================="
echo "       🐳 INFORMACIÓN DEL CONTENEDOR"
echo "=========================================="
echo ""
echo "📦 Aplicación: ${APP_NAME:-Sin nombre}"
echo "🏷️  Versión:    ${APP_VERSION:-0.0.0}"
echo "🌍 Entorno:    ${ENVIRONMENT:-desarrollo}"
echo "👤 Usuario:    $(whoami)"
echo "📂 Directorio: $(pwd)"
echo "🕐 Hora:       $(date)"
echo ""
echo "=========================================="
echo "       Variables de Entorno Actuales"
echo "=========================================="
env | grep -E "^APP_|^ENVIRONMENT" | sort
echo "=========================================="
```

### Paso 3: Crear el Dockerfile

Crea un `Dockerfile` que cumpla con:

| Requisito        | Instrucción             | Descripción                              |
| ---------------- | ----------------------- | ---------------------------------------- |
| Versión dinámica | `ARG APP_VERSION=1.0.0` | Definir versión como argumento           |
| Nombre de app    | `ENV APP_NAME`          | Variable de entorno para nombre          |
| Entorno          | `ENV ENVIRONMENT`       | development/production                   |
| Metadatos        | `LABEL`                 | Incluir maintainer, version, description |

**Requisitos del Dockerfile:**

1. Usar `alpine:3.19` como base
2. Definir `ARG APP_VERSION` con valor por defecto `1.0.0`
3. Definir `ENV APP_NAME="Mi App Docker"`
4. Definir `ENV APP_VERSION=${APP_VERSION}` (pasar ARG a ENV)
5. Definir `ENV ENVIRONMENT="development"`
6. Añadir labels con información del proyecto
7. Copiar y hacer ejecutable el script
8. Ejecutar el script como CMD

### Paso 4: Construir con Valores por Defecto

```bash
# Construir con valores por defecto
docker build -t mi-app-config:v1 .

# Ejecutar
docker run --rm mi-app-config:v1
```

### Paso 5: Construir con Argumentos Personalizados

```bash
# Construir con versión personalizada
docker build \
    --build-arg APP_VERSION=2.5.0 \
    -t mi-app-config:v2.5 .

# Ejecutar
docker run --rm mi-app-config:v2.5
```

### Paso 6: Sobrescribir Variables en Runtime

```bash
# Cambiar nombre de la app
docker run --rm -e APP_NAME="Super App" mi-app-config:v1

# Cambiar entorno a producción
docker run --rm -e ENVIRONMENT="production" mi-app-config:v1

# Cambiar múltiples variables
docker run --rm \
    -e APP_NAME="API Gateway" \
    -e ENVIRONMENT="staging" \
    mi-app-config:v1
```

### Paso 7: Verificar Labels

```bash
# Ver labels de la imagen
docker inspect mi-app-config:v1 --format='{{json .Config.Labels}}' | jq

# O sin jq
docker inspect mi-app-config:v1 | grep -A 10 "Labels"
```

---

## ✅ Checklist de Verificación

- [ ] La imagen se construye correctamente
- [ ] `ARG APP_VERSION` permite cambiar la versión en build
- [ ] `ENV` variables se muestran correctamente
- [ ] Las variables se pueden sobrescribir con `-e`
- [ ] Los labels están presentes en la imagen
- [ ] El script muestra toda la información esperada

---

## 💡 Hints

<details>
<summary>Hint 1: Pasar ARG a ENV</summary>

```dockerfile
ARG APP_VERSION=1.0.0
ENV APP_VERSION=${APP_VERSION}
```

El ARG se evalúa en build-time y se asigna a ENV para runtime.

</details>

<details>
<summary>Hint 2: Labels múltiples</summary>

```dockerfile
LABEL maintainer="tu@email.com" \
      version="${APP_VERSION}" \
      description="Mi aplicación configurable"
```

</details>

<details>
<summary>Hint 3: Hacer script ejecutable</summary>

```dockerfile
COPY app.sh .
RUN chmod +x app.sh
CMD ["./app.sh"]
```

</details>

---

## 🔍 Experimentos Adicionales

```bash
# Ver diferencia entre builds
docker images | grep mi-app-config

# Ver variables de entorno definidas en la imagen
docker inspect mi-app-config:v1 --format='{{json .Config.Env}}'

# Ejecutar shell para explorar
docker run --rm -it mi-app-config:v1 /bin/sh
```

---

## 📂 Estructura de Archivos

```
02-variables-argumentos/
├── README.md       # Este archivo
├── Dockerfile      # Lo crearás tú
└── app.sh          # Lo crearás tú
```

---

## 🔗 Navegación

| ← Anterior                                   | Siguiente →                                        |
| -------------------------------------------- | -------------------------------------------------- |
| [01 - Primera Imagen](../01-primera-imagen/) | [03 - Copiando Archivos](../03-copiando-archivos/) |
