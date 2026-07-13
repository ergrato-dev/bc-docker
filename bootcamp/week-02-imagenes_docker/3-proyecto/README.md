# 🚀 Proyecto Semana 02: API REST Optimizada

## 📋 Descripción

Construir una imagen Docker **optimizada** para una API REST en Node.js/Express aplicando todas las técnicas aprendidas durante la semana.

---

## 🎯 Objetivos

- Aplicar **multi-stage build** para separar build y producción
- Configurar **.dockerignore** correctamente
- Optimizar el **orden de capas** para máximo uso de caché
- Implementar **usuario no-root** para seguridad
- Añadir **HEALTHCHECK** para monitoreo
- Documentar con **LABEL** apropiados
- Lograr una **reducción de tamaño ≥ 80%** respecto a imagen base

---

## ⏱️ Tiempo Estimado

1.5 horas

---

## 📦 Requisitos del Proyecto

### Funcionales

| Requisito            | Descripción                        |
| -------------------- | ---------------------------------- |
| API REST             | Mínimo 3 endpoints funcionales     |
| Health endpoint      | `/health` que responda `200 OK`    |
| Info endpoint        | `/info` con datos de la aplicación |
| Variables de entorno | Configuración via ENV              |

### Técnicos del Dockerfile

| Requisito                 | Obligatorio |
| ------------------------- | ----------- |
| Multi-stage build         | ✅          |
| Imagen base Alpine        | ✅          |
| Usuario no-root           | ✅          |
| HEALTHCHECK               | ✅          |
| LABEL con metadata        | ✅          |
| .dockerignore             | ✅          |
| Orden optimizado de capas | ✅          |

### Métricas de Éxito

| Métrica                | Objetivo                    |
| ---------------------- | --------------------------- |
| Tamaño imagen final    | < 200 MB                    |
| Reducción vs `node:22` | ≥ 80%                       |
| Build cache hit        | Sí (al cambiar solo código) |
| Healthcheck            | Pasando                     |

---

## 📁 Estructura del Proyecto

```
3-proyecto/
├── README.md               # Este archivo
├── starter/                # Archivos iniciales
│   ├── package.json
│   ├── src/
│   │   └── index.js
│   └── .dockerignore.example
└── solution/               # Solución completa
    ├── Dockerfile
    ├── .dockerignore
    ├── package.json
    └── src/
        └── index.js
```

---

## 📝 Instrucciones

### Paso 1: Usar los Archivos Starter

```bash
cd bootcamp/week-02-imagenes_docker/3-proyecto/starter
```

Los archivos `starter/` contienen una aplicación Node.js básica. Tu tarea es crear:

1. `Dockerfile` optimizado con multi-stage
2. `.dockerignore` completo

### Paso 2: Crear el Dockerfile

Tu Dockerfile debe incluir:

```dockerfile
# Etapa 1: builder
# - Instalar TODAS las dependencias
# - (Si hubiera TypeScript, compilar aquí)

# Etapa 2: production
# - Imagen Alpine
# - Solo dependencias de producción
# - Usuario no-root
# - HEALTHCHECK
# - LABEL con metadata
```

### Paso 3: Crear .dockerignore

Excluir como mínimo:

- `node_modules/`
- `.git/`
- `*.md`
- `.env*`
- `Dockerfile*`
- `docker-compose*`

### Paso 4: Construir y Probar

```bash
# Construir
docker build -t api-optimizada:v1 .

# Verificar tamaño
docker images api-optimizada:v1

# Ejecutar
docker run -d --name api-test -p 3000:3000 api-optimizada:v1

# Probar endpoints
curl http://localhost:3000/
curl http://localhost:3000/health
curl http://localhost:3000/info

# Verificar healthcheck
docker ps  # Debe mostrar (healthy)

# Verificar usuario
docker exec api-test whoami  # NO debe ser root

# Limpiar
docker stop api-test && docker rm api-test
```

### Paso 5: Documentar

Crea un breve reporte con:

- Tamaño de imagen final
- Comparativa con `node:22` base
- Captura de `docker history`
- Verificación de healthcheck

---

## 🏆 Criterios de Evaluación

| Criterio              | Puntos  | Descripción                              |
| --------------------- | ------- | ---------------------------------------- |
| Multi-stage funcional | 20      | Dos etapas: builder y production         |
| Imagen Alpine         | 10      | Usar `node:22-alpine`                    |
| Usuario no-root       | 15      | Crear y usar usuario sin privilegios     |
| HEALTHCHECK           | 15      | Configurado y pasando                    |
| .dockerignore         | 10      | Excluye archivos correctos               |
| Orden de capas        | 15      | Maximiza uso de caché                    |
| LABEL metadata        | 5       | Incluye maintainer, version, description |
| Tamaño < 200MB        | 10      | Imagen final optimizada                  |
| **Total**             | **100** |                                          |

---

## 💡 Hints

<details>
<summary>Hint 1: Estructura Multi-stage</summary>

```dockerfile
FROM node:22-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
# Si hay build: RUN npm run build

FROM node:22-alpine AS production
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/src ./src
COPY --from=builder /app/package.json ./
# ... resto
```

</details>

<details>
<summary>Hint 2: Usuario no-root</summary>

```dockerfile
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser
```

</details>

<details>
<summary>Hint 3: HEALTHCHECK</summary>

```dockerfile
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1
```

</details>

---

## 🔗 Navegación

| Ejercicios                        | Recursos                      |
| --------------------------------- | ----------------------------- |
| [💻 Ejercicios](../2-ejercicios/) | [📚 Recursos](../4-recursos/) |
