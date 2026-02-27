# 💻 Ejercicio 01: Contenedor No-Root en Práctica

## 📋 Información del Ejercicio

| Atributo          | Valor                                            |
| ----------------- | ------------------------------------------------ |
| **Duración**      | 45 minutos                                       |
| **Nivel**         | Básico                                           |
| **Objetivos**     | Construir imágenes producción-seguras            |
| **Prerequisitos** | Semana 07 completada                             |

---

## 🎯 Objetivos de Aprendizaje

- ✅ Crear usuario no-root en Alpine y Debian/Ubuntu
- ✅ Usar `COPY --chown` para permisos correctos
- ✅ Verificar que el contenedor no corre como root
- ✅ Aplicar `read_only`, `cap_drop` y `no-new-privileges`

---

## 📝 Instrucciones

### Parte 1: Imagen con Root vs Sin Root (15 min)

```bash
mkdir noroot-lab && cd noroot-lab
```

**`Dockerfile.inseguro`** (como punto de comparación):

```dockerfile
FROM python:3.12-slim
WORKDIR /app
COPY app.py .
EXPOSE 8000
CMD ["python", "app.py"]
```

**`app.py`**:

```bash
cat > app.py << 'EOF'
import os
from http.server import HTTPServer, BaseHTTPRequestHandler

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.end_headers()
        uid = os.getuid()
        username = os.popen("whoami").read().strip()
        self.wfile.write(f"Running as: uid={uid} ({username})\n".encode())
        self.wfile.write(f"PID: {os.getpid()}\n".encode())

HTTPServer(("", 8000), Handler).serve_forever()
EOF
```

```bash
# Construir y verificar la versión insegura
docker build -f Dockerfile.inseguro -t app:inseguro .
docker run --rm app:inseguro id
# uid=0(root) gid=0(root)  ← Peligroso

docker run --rm -p 8000:8000 -d --name app-inseguro app:inseguro
curl http://localhost:8000
# Running as: uid=0 (root)
docker stop app-inseguro
```

---

### Parte 2: Imagen No-Root (20 min)

**`Dockerfile.seguro`**:

```dockerfile
FROM python:3.12-slim

# 1. Crear usuario no-root
RUN groupadd --gid 1001 appgroup && \
    useradd --uid 1001 --gid appgroup \
            --shell /bin/false \
            --no-create-home appuser

# 2. Crear directorio con permisos correctos
RUN mkdir -p /app && chown appuser:appgroup /app
WORKDIR /app

# 3. Copiar código con el propietario correcto
COPY --chown=appuser:appgroup app.py .

# 4. Cambiar al usuario no-root
USER appuser

EXPOSE 8000
CMD ["python", "app.py"]
```

```bash
# Construir la versión segura
docker build -f Dockerfile.seguro -t app:seguro .

# Verificar usuario
docker run --rm app:seguro id
# uid=1001(appuser) gid=1001(appgroup)  ✅

# Probar la app
docker run --rm -p 8000:8000 -d --name app-seguro app:seguro
curl http://localhost:8000
# Running as: uid=1001 (appuser)  ✅

docker stop app-seguro
```

---

### Parte 3: Hardening con Compose (10 min)

```yaml
# docker-compose.yml
services:
  app:
    build:
      context: .
      dockerfile: Dockerfile.seguro
    ports:
      - "8000:8000"
    read_only: true              # Filesystem read-only
    tmpfs:
      - /tmp:size=10m            # /tmp writable en RAM
    cap_drop:
      - ALL                      # Sin capacidades Linux
    security_opt:
      - no-new-privileges:true   # No escalada de privilegios
    user: "1001:1001"            # Explícito en compose también
```

```bash
docker compose up -d --build
curl http://localhost:8000
# Running as: uid=1001 (appuser)

# Verificar que el filesystem es read-only
docker compose exec app touch /test-file
# touch: cannot touch '/test-file': Read-only file system  ✅

# /tmp sí debe ser writable
docker compose exec app touch /tmp/test-file
# OK ✅

docker compose down
```

---

## ✅ Checklist de Verificación

- [ ] `docker run app:inseguro id` muestra root
- [ ] `docker run app:seguro id` muestra uid=1001
- [ ] Con `read_only: true`, escribir en `/` falla
- [ ] Con `tmpfs`, escribir en `/tmp` funciona
- [ ] `curl http://localhost:8000` muestra "uid=1001"

---

## 🔗 Siguiente Ejercicio

[→ Ejercicio 02: Escaneo de Vulnerabilidades](../02-escaneo-imagenes/README.md)
