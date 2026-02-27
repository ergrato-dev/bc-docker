# 🔐 Secrets y Configs en Docker Compose

## El Problema de las Credenciales

Gestionar credenciales es uno de los desafíos más importantes en producción. Los enfoques incorrectos:

```yaml
# ❌ Credenciales en el compose.yml (commiteado en git)
services:
  db:
    image: postgres:16
    environment:
      POSTGRES_PASSWORD: mi_clave_super_secreta_123

# ❌ Credenciales en el Dockerfile
ENV DB_PASS=produccion_password
```

La solución correcta depende del entorno:

| Entorno        | Solución recomendada                         |
| -------------- | -------------------------------------------- |
| Desarrollo     | Variables de entorno con `.env` (no commited)|
| Docker Compose | `secrets:` con archivos fuera del repo       |
| Docker Swarm   | `docker secret create`                       |
| Kubernetes     | Kubernetes Secrets / Vault                   |

---

## Secrets en Docker Compose

Los secrets en Compose se montan como archivos en `/run/secrets/<nombre>` dentro del contenedor. El contenido del archivo es el secreto.

### Definir y usar un Secret (archivo)

```bash
# Crear el archivo con el secreto (FUERA del repositorio)
echo "mi_password_seguro_prod" > /run/secrets/db_password
# o
echo "mi_password_seguro_prod" > secrets/db_password.txt
```

```yaml
# docker-compose.yml
services:
  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_USER: appuser
      POSTGRES_DB: appdb
      # Le decimos a postgres que lea la password desde archivo
      POSTGRES_PASSWORD_FILE: /run/secrets/db_password
    secrets:
      - db_password

  api:
    build: ./api
    environment:
      DB_HOST: db
      DB_USER: appuser
      DB_NAME: appdb
      # La API leerá el secreto desde el archivo
      DB_PASS_FILE: /run/secrets/db_password
    secrets:
      - db_password

# Definición de secrets a nivel global
secrets:
  db_password:
    file: ./secrets/db_password.txt    # Ruta al archivo en el host
```

> El archivo en `/run/secrets/db_password` dentro del contenedor tendrá el contenido `mi_password_seguro_prod`

---

## Leer Secrets en Código

La aplicación debe leer el secreto desde el archivo (no de una variable de entorno):

```python
# api/main.py (Python)
import os

def get_db_password():
    # Primero intenta leer del archivo (secrets)
    secret_file = os.getenv("DB_PASS_FILE")
    if secret_file and os.path.exists(secret_file):
        with open(secret_file) as f:
            return f.read().strip()
    # Fallback a variable de entorno (desarrollo sin secrets)
    return os.getenv("DB_PASS", "")
```

```javascript
// api/config.js (Node.js)
const fs = require('fs');

function getDbPassword() {
  const secretFile = process.env.DB_PASS_FILE;
  if (secretFile && fs.existsSync(secretFile)) {
    return fs.readFileSync(secretFile, 'utf8').trim();
  }
  return process.env.DB_PASS || '';
}
```

---

## Múltiples Secrets

```yaml
services:
  api:
    build: ./api
    secrets:
      - db_password
      - jwt_secret
      - api_key_stripe

secrets:
  db_password:
    file: ./secrets/db_password.txt

  jwt_secret:
    file: ./secrets/jwt_secret.txt

  api_key_stripe:
    file: ./secrets/stripe_key.txt
```

---

## Configs

Los **configs** son similares a los secrets pero para **configuración no sensible** que necesita ser diferente por entorno. Se montan como archivos de solo lectura:

```yaml
services:
  nginx:
    image: nginx:alpine
    configs:
      - source: nginx_config
        target: /etc/nginx/conf.d/default.conf
        mode: 0444      # Solo lectura

  prometheus:
    image: prom/prometheus
    configs:
      - source: prometheus_config
        target: /etc/prometheus/prometheus.yml

configs:
  nginx_config:
    file: ./config/nginx.conf

  prometheus_config:
    file: ./config/prometheus.yml
```

---

## Secrets vs Variables de Entorno vs Configs

| Característica        | Env Vars (`environment`)   | Secrets                    | Configs                   |
| --------------------- | -------------------------- | -------------------------- | ------------------------- |
| **Visibilidad**       | `docker inspect` las expone| Solo dentro del contenedor | Solo dentro del contenedor|
| **Uso típico**        | Config no sensible, URLs   | Contraseñas, tokens, claves| Archivos de configuración |
| **En logs**           | Puede aparecer             | No aparece                 | No aparece                |
| **Formato**           | Key=Value                  | Archivo en `/run/secrets/` | Archivo en ruta custom    |
| **Compatible con**    | Todos los entornos         | Compose + Swarm            | Compose + Swarm           |

---

## .gitignore para Secrets

```gitignore
# .gitignore

# Nunca versionar secrets
secrets/
*.secret
*.key
.env
.env.local
.env.production
.env.staging

# Sí versionar (plantillas sin valores)
.env.example
secrets/.gitkeep  # Para mantener la carpeta
```

---

## Flujo de Trabajo Seguro

```
1. Crear archivos de secretos (FUERA del repo):
   echo "pass_segura" > secrets/db_password.txt
   
2. Asegurarse de que secrets/ está en .gitignore

3. En docker-compose.yml referenciar los archivos:
   secrets:
     db_password:
       file: ./secrets/db_password.txt

4. Proveer .env.example y secrets/README.md
   indicando qué archivos crear y su formato

5. En CI/CD: crear los archivos desde variables
   seguras del sistema de CI
```

---

## Ejemplo Completo: Stack con Secrets

```yaml
# docker-compose.yml
services:
  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_USER: appuser
      POSTGRES_DB: appdb
      POSTGRES_PASSWORD_FILE: /run/secrets/db_password
    secrets:
      - db_password
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U appuser"]
      interval: 10s
      retries: 5
      start_period: 30s

  api:
    build: ./api
    environment:
      DB_HOST: db
      DB_USER: appuser
      DB_NAME: appdb
      DB_PASS_FILE: /run/secrets/db_password
      JWT_SECRET_FILE: /run/secrets/jwt_secret
    secrets:
      - db_password
      - jwt_secret
    depends_on:
      db:
        condition: service_healthy

  nginx:
    image: nginx:alpine
    configs:
      - source: nginx_config
        target: /etc/nginx/conf.d/default.conf
    ports:
      - "80:80"
    depends_on:
      - api

secrets:
  db_password:
    file: ./secrets/db_password.txt
  jwt_secret:
    file: ./secrets/jwt_secret.txt

configs:
  nginx_config:
    file: ./config/nginx.conf
```

---

## ✅ Buenas Prácticas

1. **Nunca** commites archivos con credenciales reales
2. Provee siempre `secrets/README.md` o `.env.example`
3. Los secrets se limpian automáticamente cuando el contenedor para
4. Usa variables `_FILE` para imágenes que las soporten (postgres, mysql, etc.)
5. En desarrollo sin Swarm, `file:` es suficiente; en producción usa Swarm secrets

---

## 📚 Siguiente Tema

[→ 04. Extends y Anchors YAML](./04-extends-anchors.md)
