# 💻 Ejercicio 03: Secrets y Configuración Segura

## 📋 Información del Ejercicio

| Atributo          | Valor                                              |
| ----------------- | -------------------------------------------------- |
| **Duración**      | 50 minutos                                         |
| **Nivel**         | Avanzado                                           |
| **Objetivos**     | Gestionar credenciales con Compose secrets         |
| **Prerequisitos** | Ejercicio 02 completado                            |

---

## 🎯 Objetivos de Aprendizaje

- ✅ Definir y usar `secrets:` en docker-compose.yml
- ✅ Leer secrets desde código (no de env vars)
- ✅ Aplicar `.gitignore` correcto para archivos sensibles
- ✅ Combinar secrets con `condition: service_healthy`

---

## 📝 Instrucciones

### Parte 1: Preparar la Estructura (10 min)

```bash
mkdir secrets-lab && cd secrets-lab
mkdir -p api secrets config

# IMPORTANTE: .gitignore ANTES de crear archivos sensibles
cat > .gitignore << 'EOF'
secrets/*.txt
.env
.env.local
.env.production
EOF

# Crear archivos de secretos (FUERA del versionado por el .gitignore)
echo "super_secure_db_pass_$(date +%s)" > secrets/db_password.txt
echo "jwt_token_$(openssl rand -hex 32 2>/dev/null || date +%s)" > secrets/jwt_secret.txt

# Verificar que .gitignore funciona
git init . -q
git status
# secrets/db_password.txt y jwt_secret.txt NO deben aparecer
```

---

### Parte 2: API que lee Secrets (20 min)

**`api/main.py`**:

```python
from fastapi import FastAPI, HTTPException
import os, datetime, jwt as pyjwt

app = FastAPI(title="Secrets Demo API")

def read_secret(env_var: str, fallback: str = "") -> str:
    """Lee un secret desde archivo o variable de entorno como fallback."""
    secret_file = os.getenv(env_var)
    if secret_file and os.path.exists(secret_file):
        with open(secret_file) as f:
            return f.read().strip()
    # Fallback para desarrollo sin secrets
    return os.getenv(env_var.replace("_FILE", ""), fallback)

@app.get("/")
def root():
    return {"app": "secrets-demo", "version": "1.0"}

@app.get("/health")
def health():
    return {"status": "healthy", "timestamp": datetime.datetime.now().isoformat()}

@app.get("/token/generate")
def generate_token(user_id: int = 1):
    """Genera un JWT usando el secret desde el archivo."""
    jwt_secret = read_secret("JWT_SECRET_FILE", "insecure_default")
    payload = {
        "user_id": user_id,
        "exp": datetime.datetime.utcnow() + datetime.timedelta(hours=1)
    }
    token = pyjwt.encode(payload, jwt_secret, algorithm="HS256")
    return {"token": token}

@app.get("/token/verify")
def verify_token(token: str):
    """Verifica un JWT usando el secret desde el archivo."""
    jwt_secret = read_secret("JWT_SECRET_FILE", "insecure_default")
    try:
        payload = pyjwt.decode(token, jwt_secret, algorithms=["HS256"])
        return {"valid": True, "payload": payload}
    except pyjwt.ExpiredSignatureError:
        raise HTTPException(status_code=401, detail="Token expirado")
    except pyjwt.InvalidTokenError:
        raise HTTPException(status_code=401, detail="Token inválido")
```

**`api/requirements.txt`**:

```
fastapi==0.115.0
uvicorn==0.30.0
PyJWT==2.9.0
```

**`api/Dockerfile`**:

```dockerfile
FROM python:3.12-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY main.py .
EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

---

### Parte 3: docker-compose.yml con Secrets (20 min)

**`docker-compose.yml`**:

```yaml
services:
  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_USER: appuser
      POSTGRES_DB: appdb
      POSTGRES_PASSWORD_FILE: /run/secrets/db_password
    secrets:
      - db_password
    volumes:
      - db-data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U appuser -d appdb"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s

  api:
    build: ./api
    ports:
      - "8000:8000"
    environment:
      JWT_SECRET_FILE: /run/secrets/jwt_secret
      DB_PASS_FILE: /run/secrets/db_password
    secrets:
      - jwt_secret
      - db_password
    depends_on:
      db:
        condition: service_healthy

secrets:
  db_password:
    file: ./secrets/db_password.txt
  jwt_secret:
    file: ./secrets/jwt_secret.txt

volumes:
  db-data:
```

**Levantar y verificar**:

```bash
# Construir y levantar
docker compose up -d --build

# Esperar a que estén healthy
docker compose ps

# Generar un token JWT (usando el secret)
curl http://localhost:8000/token/generate?user_id=42
# {"token": "eyJ..."}

TOKEN=$(curl -s http://localhost:8000/token/generate?user_id=42 | python3 -c "import json,sys; print(json.load(sys.stdin)['token'])")

# Verificar el token
curl "http://localhost:8000/token/verify?token=$TOKEN"
# {"valid": true, "payload": {"user_id": 42, ...}}

# Verificar que el secret NO está en las env vars del contenedor
docker compose exec api env | grep JWT
# No debe aparecer JWT_SECRET con el valor, solo JWT_SECRET_FILE con la ruta
```

**Verificar que el secret está montado como archivo**:

```bash
# Ver el archivo del secret dentro del contenedor
docker compose exec api cat /run/secrets/jwt_secret
# Muestra el contenido del archivo (el secret)

# IMPORTANTE: los secrets son archivos, no env vars
docker compose exec api env | grep SECRET
# Solo muestra la ruta del archivo, no el valor
```

---

## ✅ Checklist de Verificación

- [ ] `secrets/db_password.txt` está en `.gitignore`
- [ ] El compose.yml usa `secrets:` con `file:` 
- [ ] La API lee el secret desde `/run/secrets/<nombre>`, no env vars
- [ ] `docker compose exec api env` NO muestra el valor del secret
- [ ] La generación y verificación de tokens JWT funciona
- [ ] `POSTGRES_PASSWORD_FILE` permite a postgres leer la password desde archivo

---

## 🔗 Ir al Proyecto

[→ Proyecto Semanal](../../3-proyecto/README.md)
