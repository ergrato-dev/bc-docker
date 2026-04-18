# 🚀 Introducción a CI/CD con Docker

## ¿Qué es CI/CD?

**CI (Continuous Integration)**: Automatizar la construcción y validación del código cada vez que hay un cambio.

**CD (Continuous Delivery/Deployment)**: Automatizar la entrega del software al entorno de destino.

```
Código → Push → CI (build + test + scan) → Registry → CD (deploy)
```

---

## Flujo CI/CD con Docker

```
1. Developer hace push a main/feature branch
        ↓
2. CI Pipeline se activa (GitHub Actions, GitLab CI, etc.)
        ↓
3. Build: docker build -t app:sha .
        ↓
4. Test: docker run --rm app:sha pytest
        ↓
5. Scan: trivy image app:sha --exit-code 1 --severity CRITICAL
        ↓
6. Push: docker push registry/app:sha
        ↓
7. Deploy: docker compose up -d (en servidor de staging/prod)
```

---

## GitHub Actions: Pipeline Básico

```yaml
# .github/workflows/docker-ci.yml
name: Docker CI/CD

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

env:
  REGISTRY: ghcr.io                    # GitHub Container Registry
  IMAGE_NAME: ${{ github.repository }} # owner/repo-name

jobs:
  # ─────────────── JOB 1: BUILD + TEST ───────────────
  build-test:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout código
        uses: actions/checkout@v4

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Construir imagen de test
        uses: docker/build-push-action@v5
        with:
          context: .
          push: false
          tags: test-image:${{ github.sha }}
          load: true     # Cargar en Docker local para tests
          cache-from: type=gha
          cache-to: type=gha,mode=max

      - name: Ejecutar tests
        run: |
          docker run --rm \
            -e TESTING=true \
            test-image:${{ github.sha }} \
            pytest tests/ -v

  # ─────────────── JOB 2: SECURITY SCAN ───────────────
  security-scan:
    runs-on: ubuntu-latest
    needs: build-test
    steps:
      - uses: actions/checkout@v4

      - name: Construir imagen para scan
        run: docker build -t scan-image:${{ github.sha }} .

      - name: Trivy vulnerability scan
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: scan-image:${{ github.sha }}
          format: sarif
          output: trivy-results.sarif
          severity: CRITICAL,HIGH
          exit-code: 1       # Falla si hay CVEs HIGH/CRITICAL

      - name: Upload scan results
        uses: github/codeql-action/upload-sarif@v3
        if: always()
        with:
          sarif_file: trivy-results.sarif

  # ─────────────── JOB 3: PUSH AL REGISTRY ───────────────
  push:
    runs-on: ubuntu-latest
    needs: [build-test, security-scan]
    if: github.ref == 'refs/heads/main'   # Solo en main
    permissions:
      contents: read
      packages: write
    steps:
      - uses: actions/checkout@v4

      - name: Login a GitHub Container Registry
        uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Extraer metadata (tags, labels)
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
          tags: |
            type=sha,prefix=,suffix=,format=short   # sha: abc1234
            type=ref,event=branch                    # main: latest
            type=semver,pattern={{version}}          # tag v1.0: 1.0

      - name: Build y push
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
```

---

## GitLab CI: Alternativa

```yaml
# .gitlab-ci.yml
stages:
  - build
  - test
  - scan
  - push

variables:
  DOCKER_IMAGE: $CI_REGISTRY_IMAGE:$CI_COMMIT_SHORT_SHA

build:
  stage: build
  script:
    - docker build -t $DOCKER_IMAGE .
    - docker save $DOCKER_IMAGE | gzip > image.tar.gz
  artifacts:
    paths: [image.tar.gz]

test:
  stage: test
  script:
    - docker load < image.tar.gz
    - docker run --rm $DOCKER_IMAGE pytest tests/ -v

scan:
  stage: scan
  script:
    - docker load < image.tar.gz
    - trivy image --exit-code 1 --severity CRITICAL $DOCKER_IMAGE

push:
  stage: push
  only:
    - main
  script:
    - docker load < image.tar.gz
    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
    - docker push $DOCKER_IMAGE
    - docker tag $DOCKER_IMAGE $CI_REGISTRY_IMAGE:latest
    - docker push $CI_REGISTRY_IMAGE:latest
```

---

## Dockerfile Optimizado para CI/CD

```dockerfile
# Multi-stage optimizado para fast builds en CI
FROM python:3.12-slim AS base
WORKDIR /app
RUN groupadd --gid 1001 appgroup && \
    useradd --uid 1001 --gid appgroup --no-create-home appuser

# Dependencias en stage separado → mejor cache en CI
FROM base AS deps
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Stage de test: tiene herramientas de testing
FROM deps AS test
COPY requirements-dev.txt .
RUN pip install --no-cache-dir -r requirements-dev.txt
COPY . .
# docker build --target test -t myapp:test .
# docker run myapp:test pytest

# Stage de producción: mínimo posible
FROM deps AS production
COPY --chown=appuser:appgroup src/ .
USER appuser
EXPOSE 8000
HEALTHCHECK --interval=30s --timeout=10s CMD wget -qO- http://localhost:8000/health
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

```bash
# En CI: construir y ejecutar el stage de test
docker build --target test -t myapp:test .
docker run --rm myapp:test pytest tests/

# Luego construir el stage de producción
docker build --target production -t myapp:$SHA .
```

---

## Gestión de Secrets en CI/CD

```yaml
# GitHub Actions: usar secrets del repositorio
# Configurar en: Settings → Secrets and variables → Actions

steps:
  - name: Deploy
    env:
      DB_PASSWORD: ${{ secrets.DB_PASSWORD }}
      SSH_KEY: ${{ secrets.DEPLOY_SSH_KEY }}
    run: |
      # Crear archivos de secrets para Compose
      echo "$DB_PASSWORD" > /tmp/db_password.txt
      # Usar en compose
      DB_PASS_FILE=/tmp/db_password.txt docker compose up -d
      # Limpiar
      rm -f /tmp/db_password.txt
```

---

## Estrategia de Tags de Imagen

```
myapp:latest          → siempre la última versión de main
myapp:main            → rama main
myapp:abc1234         → commit SHA (inmutable, para rollback)
myapp:v1.2.3          → versión semver (para releases)
myapp:1.2             → versión menor (semver)
```

```bash
# Para rollback rápido
docker compose set image api myapp:abc1234
docker compose up -d
```

---

## ✅ Buenas Prácticas de CI/CD con Docker

1. **Cachear capas** en CI (`cache-from: type=gha`)
2. **Nunca usar `latest`** como tag para deploy en producción
3. **Usar SHA** como identificador inmutable de la imagen
4. **Fallar el pipeline** si hay vulnerabilidades CRITICAL
5. **Separar staging y producción** con diferentes registries o tags
6. **Nunca manejar secrets** como env vars en CI — usar el gestor del CI

---

## 📚 Continúa con los Ejercicios

[→ 2-ejercicios/01-usuarios-no-root/README.md](../2-ejercicios/01-usuarios-no-root/README.md)
