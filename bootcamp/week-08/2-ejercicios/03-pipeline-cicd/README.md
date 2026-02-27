# 💻 Ejercicio 03: Pipeline CI/CD Local con GitHub Actions

## 📋 Información del Ejercicio

| Atributo          | Valor                                               |
| ----------------- | --------------------------------------------------- |
| **Duración**      | 50 minutos                                          |
| **Nivel**         | Avanzado                                            |
| **Objetivos**     | Crear un pipeline CI/CD real con GitHub Actions     |
| **Prerequisitos** | Ejercicios 01 y 02 completados, cuenta GitHub       |

---

## 🎯 Objetivos de Aprendizaje

- ✅ Crear un workflow de GitHub Actions para Docker
- ✅ Automatizar: build → test → scan → push
- ✅ Usar GitHub Container Registry (GHCR)
- ✅ Configurar variables y secrets en GitHub

---

## 📝 Instrucciones

### Parte 1: Preparar el Repositorio (10 min)

```bash
mkdir cicd-lab && cd cicd-lab
git init
mkdir -p .github/workflows src tests
```

**`src/app.py`**:

```python
from flask import Flask, jsonify
from datetime import datetime

app = Flask(__name__)

@app.get("/")
def root():
    return jsonify({"app": "cicd-demo", "version": "1.0"})

@app.get("/health")
def health():
    return jsonify({"status": "healthy", "time": datetime.now().isoformat()})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)
```

**`tests/test_app.py`**:

```python
import pytest
from src.app import app

@pytest.fixture
def client():
    app.config["TESTING"] = True
    with app.test_client() as c:
        yield c

def test_root(client):
    r = client.get("/")
    assert r.status_code == 200
    assert b"cicd-demo" in r.data

def test_health(client):
    r = client.get("/health")
    assert r.status_code == 200
    assert b"healthy" in r.data
```

**`requirements.txt`**:

```
flask==3.0.0
```

**`requirements-dev.txt`**:

```
flask==3.0.0
pytest==7.4.0
```

**`Dockerfile`**:

```dockerfile
FROM python:3.12-slim

RUN groupadd --gid 1001 appgroup && \
    useradd --uid 1001 --gid appgroup --no-create-home --shell /bin/false appuser

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY --chown=appuser:appgroup src/ ./src/

USER appuser
EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')"

CMD ["python", "src/app.py"]
```

---

### Parte 2: Crear el Workflow (20 min)

**`.github/workflows/docker.yml`**:

```yaml
name: Docker CI/CD

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Configurar Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.12'

      - name: Instalar dependencias de test
        run: pip install -r requirements-dev.txt

      - name: Ejecutar tests
        run: pytest tests/ -v

  build-scan-push:
    runs-on: ubuntu-latest
    needs: test
    permissions:
      contents: read
      packages: write
      security-events: write
    steps:
      - uses: actions/checkout@v4

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Construir imagen
        uses: docker/build-push-action@v5
        with:
          context: .
          push: false
          tags: ${{ env.IMAGE_NAME }}:${{ github.sha }}
          load: true
          cache-from: type=gha
          cache-to: type=gha,mode=max

      - name: Escaneo de seguridad con Trivy
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: ${{ env.IMAGE_NAME }}:${{ github.sha }}
          format: sarif
          output: trivy-results.sarif
          severity: CRITICAL,HIGH
          exit-code: 0            # No bloquea en este primer ejercicio (cámbialo a 1 en producción)

      - name: Upload resultados a GitHub Security
        uses: github/codeql-action/upload-sarif@v3
        if: always()
        with:
          sarif_file: trivy-results.sarif

      - name: Login GHCR
        if: github.ref == 'refs/heads/main'
        uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Extraer metadata
        if: github.ref == 'refs/heads/main'
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
          tags: |
            type=sha,format=short
            type=raw,value=latest,enable=${{ github.ref == 'refs/heads/main' }}

      - name: Push a GHCR
        if: github.ref == 'refs/heads/main'
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
```

---

### Parte 3: Activar y Monitorear (20 min)

```bash
# Crear .gitignore
cat > .gitignore << 'EOF'
__pycache__/
*.pyc
.pytest_cache/
.env
EOF

# Commit y push
git add .
git commit -m "feat(cicd): add docker ci/cd pipeline with trivy scan

What: Added GitHub Actions workflow with 2 jobs: test and build-scan-push
For: Automate Docker image building, security scanning and publishing
Impact: Images are scanned for vulnerabilities before publishing to GHCR"

# Crear repositorio en GitHub y hacer push
# git remote add origin https://github.com/TU_USUARIO/cicd-lab.git
# git push -u origin main
```

**Verificar en GitHub**:
1. Ir a `Actions` → ver el workflow ejecutándose
2. En el job `build-scan-push` → ver el output de Trivy
3. En `Security` → `Code scanning` → ver los resultados SARIF

---

## ✅ Checklist de Verificación

- [ ] Los tests de pytest pasan localmente
- [ ] El workflow de GitHub Actions corre sin errores de sintaxis
- [ ] El job `test` ejecuta los tests correctamente
- [ ] El job `build-scan-push` construye la imagen
- [ ] Los resultados de Trivy aparecen en la pestaña Security
- [ ] La imagen se publica en GHCR (si se hizo push a main)

---

## 🔗 Ir al Proyecto Final

[→ Proyecto Final: Aplicación Production-Ready](../../3-proyecto/README.md)
