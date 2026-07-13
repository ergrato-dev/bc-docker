# 🔍 Escaneo de Vulnerabilidades en Imágenes Docker

## ¿Por qué Escanear Imágenes?

Una imagen Docker contiene cientos de paquetes del sistema operativo y librerías. Cada uno puede tener vulnerabilidades conocidas (CVEs). El escaneo automatizado te permite:

1. **Detectar** CVEs conocidas antes de desplegar a producción
2. **Priorizar** correcciones por criticidad (CRITICAL, HIGH, MEDIUM, LOW)
3. **Bloquear** imágenes vulnerables en CI/CD
4. **Cumplir** con políticas de seguridad corporativas

---

## Herramientas Principales

| Herramienta        | Tipo          | Destacado                          |
| ------------------ | ------------- | ---------------------------------- |
| **Trivy**          | CLI / CI      | El más completo y fácil de usar    |
| **Docker Scout**   | CLI / Hub     | Integrado en Docker Desktop y Hub  |
| **Grype**          | CLI / CI      | Alternativa a Trivy                |
| **Snyk**           | SaaS / CLI    | Integración con repositorios       |

---

## Trivy: Herramienta Principal

Trivy (Aqua Security) es el escáner de código abierto más popular. Detecta:
- Vulnerabilidades en paquetes del SO
- Dependencias de lenguajes (pip, npm, gem, etc.)
- Misconfiguraciones en Dockerfiles e IaC
- Secretos hardcodeados

### Instalación

```bash
# Linux (Debian/Ubuntu)
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin

# macOS
brew install trivy

# Con Docker (sin instalación)
docker run --rm aquasec/trivy:latest image nginx:alpine
```

### Escanear una Imagen

```bash
# Escaneo básico
trivy image nginx:alpine

# Output de ejemplo:
# nginx:alpine (alpine 3.19.1)
# Total: 3 (UNKNOWN: 0, LOW: 0, MEDIUM: 2, HIGH: 1, CRITICAL: 0)
# ┌───────────┬───────────────┬──────────┬─────────────────────┬─────────────────┐
# │  Library  │ Vulnerability │ Severity │ Installed Version   │ Fixed Version   │
# ├───────────┼───────────────┼──────────┼─────────────────────┼─────────────────┤
# │ libssl3   │ CVE-2023-XXXX │ HIGH     │ 3.1.4-r2            │ 3.1.4-r3        │

# Solo vulnerabilidades HIGH y CRITICAL
trivy image --severity HIGH,CRITICAL nginx:alpine

# Formato JSON para integrar en scripts
trivy image --format json --output report.json nginx:alpine

# Escanear imagen local construida
trivy image mi-app:latest

# Escanear Dockerfile (antes de construir)
trivy config --file-patterns Dockerfile .
```

---

## Docker Scout

Integrado con Docker Hub, Scout ofrece análisis visual y en CLI:

```bash
# Instalar el plugin
docker extension install docker/scout-extension

# o usar el CLI directamente si tienes Docker Desktop
docker scout quickview nginx:alpine

# Comparar con otro tag
docker scout compare nginx:latest --to nginx:alpine

# Ver CVEs detalladas
docker scout cves nginx:alpine

# Ver recomendaciones de actualización
docker scout recommendations mi-app:latest

# Política de seguridad
docker scout policy mi-app:latest
```

---

## Grype: Alternativa a Trivy

```bash
# Instalación
curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh -s -- -b /usr/local/bin

# Escanear imagen
grype nginx:alpine

# Solo HIGH y CRITICAL y salir con código de error si hay alguna
grype nginx:alpine --fail-on high
```

---

## Estrategias para Reducir Vulnerabilidades

### 1. Usar Imágenes Mínimas

```dockerfile
# ❌ Muchos paquetes = muchos CVEs potenciales
FROM ubuntu:22.04

# ✅ Alpine: minimalista
FROM alpine:3.21

# ✅ Distroless: sin shell, sin utilidades del sistema
FROM gcr.io/distroless/python3-debian12

# ✅✅ scratch (binarios Go): absolutamente mínimo
FROM scratch
```

```bash
# Comparar superficie de ataque
trivy image ubuntu:22.04 --severity HIGH,CRITICAL
# Total: 25 (HIGH: 18, CRITICAL: 7)

trivy image alpine:3.21 --severity HIGH,CRITICAL
# Total: 0
```

### 2. Actualizar Dependencias Regularmente

```dockerfile
# ✅ Actualizar paquetes del SO en el build
FROM python:3.12-slim

RUN apt-get update && \
    apt-get upgrade -y && \    # Aplicar parches de seguridad
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# ✅ Fijar versiones de paquetes Python para control
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
```

### 3. Multi-Stage para Reducir la Imagen Final

```dockerfile
# El stage de build puede tener herramientas de compilación
FROM golang:1.25-alpine AS builder
RUN apk add --no-cache gcc musl-dev
WORKDIR /build
COPY . .
RUN go build -o app .

# La imagen final NO tiene el compilador ni sus vulnerabilidades
FROM alpine:3.21
COPY --from=builder /build/app /app
USER 65534
CMD ["/app"]
```

---

## Integrar en CI/CD

### GitHub Actions

```yaml
# .github/workflows/security.yml
name: Security Scan

on: [push, pull_request]

jobs:
  scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Build image
        run: docker build -t my-app:${{ github.sha }} .

      - name: Run Trivy
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: 'my-app:${{ github.sha }}'
          format: 'sarif'
          output: 'trivy-results.sarif'
          severity: 'CRITICAL,HIGH'
          exit-code: '1'          # Falla el pipeline si hay CVEs altas

      - name: Upload to GitHub Security
        uses: github/codeql-action/upload-sarif@v3
        if: always()
        with:
          sarif_file: 'trivy-results.sarif'
```

### docker-compose.yml con Trivy (scan local antes de up)

```bash
# Script: scan-before-up.sh
#!/bin/bash
set -e

echo "🔍 Escaneando imágenes antes de levantar..."

# Construir primero
docker compose build

# Escanear cada servicio
for service in $(docker compose config --services); do
  image=$(docker compose config | grep -A5 "$service:" | grep "image:" | awk '{print $2}')
  if [ ! -z "$image" ]; then
    echo "Escaneando $service ($image)..."
    trivy image --exit-code 1 --severity CRITICAL "$image" || {
      echo "❌ Vulnerabilidades CRÍTICAS en $service"
      exit 1
    }
  fi
done

echo "✅ Sin vulnerabilidades críticas. Iniciando stack..."
docker compose up -d
```

---

## Interpretar los Resultados

```
CVE-2024-12345   CRITICAL   libssl3   1.1.1q-r0   → 1.1.1t-r0
```

| Campo        | Descripción                                              |
| ------------ | -------------------------------------------------------- |
| CVE-ID       | Identificador único de la vulnerabilidad                 |
| Severity     | CRITICAL > HIGH > MEDIUM > LOW > UNKNOWN                 |
| Package      | Paquete afectado                                         |
| Installed    | Versión actualmente en la imagen                         |
| Fixed in     | Versión donde está corregido (si existe fix)             |

**Prioridad de corrección**:
- 🔴 CRITICAL → Corregir inmediatamente
- 🟠 HIGH → Corregir en el próximo ciclo
- 🟡 MEDIUM → Planificar corrección
- 🟢 LOW → Monitorear

---

## ✅ Buenas Prácticas

1. **Escanear en CI/CD** antes de push al registry
2. **Usar tags específicos** de imágenes base con fecha conocida
3. **Actualizar imágenes base** regularmente (semana/mes)
4. **Preferir Alpine o Distroless** para imágenes de producción
5. **No ignorar CRITICAL** sin documentar el reason y workaround
6. **Separar build de runtime** con multi-stage

---

## 📚 Siguiente Tema

[→ 04. Buenas Prácticas de Producción](./04-buenas-practicas.md)
