# 🏆 Proyecto Final — Aplicación Production-Ready

## 📋 Información del Proyecto

| Atributo     | Valor                                           |
| ------------ | ----------------------------------------------- |
| **Nombre**   | SecureShop — E-Commerce Docker Production-Ready |
| **Duración** | 1.5 horas                                       |
| **Nivel**    | Avanzado                                        |
| **Semana**   | 08 — Proyecto Final del Bootcamp                |

---

## 🎯 Descripción

SecureShop es la culminación de todo lo aprendido en el bootcamp. Construirás un stack e-commerce completo que aplique **todas** las buenas prácticas de seguridad y producción:

| Servicio | Imagen            | Seguridad                         |
| -------- | ----------------- | --------------------------------- |
| `nginx`  | nginx:1.30-alpine | No-root, read_only, cap_drop      |
| `api`    | Dockerfile        | No-root, healthcheck, secrets     |
| `db`     | postgres:16       | Secrets, healthcheck, sin puertos |
| `cache`  | redis:7-alpine    | Healthcheck, sin puertos          |
| `worker` | Dockerfile        | No-root, sin puertos, escalable   |

---

## 📋 Requisitos de Seguridad (Obligatorios)

### Dockerfile (api y worker)

- [ ] Imagen base con **tag específico** (no `latest`)
- [ ] **Usuario no-root** creado con UID 1001
- [ ] `COPY --chown` para todos los archivos copiados
- [ ] `HEALTHCHECK` definido
- [ ] `.dockerignore` presente y completo
- [ ] Trivy scan sin vulnerabilidades **CRITICAL**

### docker-compose.yml

- [ ] `user: "1001:1001"` en todos los servicios con build
- [ ] `read_only: true` en api y worker
- [ ] `tmpfs: [/tmp]` donde se necesite escritura
- [ ] `cap_drop: [ALL]` en api, worker y nginx
- [ ] `security_opt: [no-new-privileges:true]` en todos
- [ ] `secrets:` para db_password y jwt_secret (NO en `environment:`)
- [ ] healthchecks con `condition: service_healthy`
- [ ] Redes separadas: `public-net` e `internal-net`
- [ ] `restart: unless-stopped` en todos
- [ ] `logging` con `max-size` y `max-file`
- [ ] `deploy.resources.limits` en api y worker

### CI/CD

- [ ] `.github/workflows/docker.yml` con build → test → scan
- [ ] `exit-code: 1` en Trivy para bloquear si hay CRITICAL

---

## 🗂️ Estructura Esperada

```
secureshop/
├── .github/
│   └── workflows/
│       └── docker.yml
├── docker-compose.yml
├── docker-compose.override.yml    # Desarrollo
├── .env
├── .env.example
├── .gitignore
├── secrets/
│   ├── README.md
│   ├── db_password.txt            # .gitignore
│   └── jwt_secret.txt             # .gitignore
├── nginx/
│   ├── nginx.conf
│   └── html/
│       └── index.html
├── api/
│   ├── Dockerfile
│   ├── .dockerignore
│   ├── requirements.txt
│   ├── main.py
│   └── tests/
│       └── test_api.py
└── worker/
    ├── Dockerfile
    ├── requirements.txt
    └── worker.py
```

---

## 📦 Starter Code

### `starter/api/Dockerfile` (con TODOs)

```dockerfile
# TODO: Usar tag específico de python:3.12-slim
FROM python:3.12-slim

# TODO: Crear grupo y usuario no-root (uid/gid 1001)

# TODO: Instalar dependencias como root
COPY --from=ghcr.io/astral-sh/uv:latest /uv /bin/uv
COPY requirements.txt .
RUN uv pip install --system --no-cache -r requirements.txt

# TODO: Copiar código con --chown correcto

# TODO: Cambiar al usuario no-root (USER)

EXPOSE 8000

# TODO: Agregar HEALTHCHECK

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### `starter/docker-compose.yml` (con TODOs)

```yaml
x-base: &base
  restart: unless-stopped
  logging:
    driver: json-file
    options:
      max-size: "10m"
      max-file: "3"
  # TODO: Agregar security_opt no-new-privileges

services:
  nginx:
    <<: *base
    image: nginx:1.30-alpine
    ports:
      - "80:80"
    # TODO: cap_drop, read_only, tmpfs, user

  api:
    <<: *base
    build: ./api
    # TODO: user, read_only, tmpfs, cap_drop, security_opt
    # TODO: secrets con los nombres correctos
    # TODO: depends_on con condition: service_healthy
    # TODO: healthcheck
    # TODO: deploy.resources.limits
    networks:
      - public-net
      - internal-net

  worker:
    <<: *base
    build: ./worker
    # TODO: mismo hardening que api
    # TODO: sin puertos (para poder escalar)
    networks:
      - internal-net

  db:
    <<: *base
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: ${DB_NAME:-shopdb}
      POSTGRES_USER: ${DB_USER:-shopuser}
      POSTGRES_PASSWORD_FILE: /run/secrets/db_password
    # TODO: secrets
    # TODO: healthcheck pg_isready
    # TODO: volumes para persistencia
    networks:
      - internal-net

  cache:
    <<: *base
    image: redis:7-alpine
    # TODO: healthcheck redis-cli ping
    networks:
      - internal-net

secrets:
  # TODO: Definir db_password y jwt_secret

volumes:
  # TODO: Definir volúmenes necesarios

networks:
  public-net:
  internal-net:
    internal: true
```

---

## 🏁 Criterios de Aceptación

1. `docker compose up -d --build` sin errores
2. `docker compose ps` → todos `Up (healthy)`
3. `docker compose exec api id` → NO muestra root
4. `docker compose exec api touch /evil` → Read-only file system (error)
5. `trivy image secureshop-api:latest --severity CRITICAL` → 0 CVEs O < 3
6. `docker compose exec nginx ping db` → falla (aislamiento de redes)
7. `docker compose exec api env | grep -i pass` → NO muestra contraseñas
8. `docker compose up -d --scale worker=3` funciona

---

## 📊 Evaluación Final del Bootcamp

| Semana               | Competencia                     | Peso    |
| -------------------- | ------------------------------- | ------- |
| 1-3: Fundamentos     | Contenedores, imágenes, gestión | 15%     |
| 4-5: Infraestructura | Redes y volúmenes               | 15%     |
| 6-7: Compose         | Multi-servicio, avanzado        | 30%     |
| **8: Seguridad**     | **Production-ready, CI/CD**     | **40%** |

### Rúbrica Proyecto Final

| Criterio                        | Puntos  |
| ------------------------------- | ------- |
| Dockerfile no-root + hardening  | 20      |
| Compose con secrets y seguridad | 25      |
| Healthchecks + depends_on       | 15      |
| Scan Trivy sin CRITICALs        | 20      |
| Pipeline CI/CD funcional        | 20      |
| **Total**                       | **100** |

---

## 🎓 ¡Felicidades!

Al completar este proyecto habrás dominado:

- ✅ Fundamentos de contenedores y Docker Engine
- ✅ Construcción y optimización de imágenes
- ✅ Redes y volúmenes
- ✅ Orquestación con Docker Compose
- ✅ Seguridad, secrets y CI/CD

**Siguiente paso**: [Bootcamp Kubernetes →](https://github.com/ergrato-dev/bc-kubernetes)

---

_"Un contenedor sin seguridad es solo un proceso con alias bonito." — Bootcamp Docker_
