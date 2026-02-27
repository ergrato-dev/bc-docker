# 🚀 Proyecto Semana 07: Plataforma E-Learning con Compose Avanzado

## 📋 Información del Proyecto

| Atributo         | Valor                                               |
| ---------------- | --------------------------------------------------- |
| **Nombre**       | EduStack — Plataforma E-Learning Multi-Entorno      |
| **Duración**     | 1.5 horas                                           |
| **Nivel**        | Avanzado                                            |
| **Stack**        | FastAPI + PostgreSQL + Redis + Nginx + Workers      |

---

## 🎯 Objetivos

Al completar este proyecto:

- ✅ Implementarás profiles para activar herramientas por entorno
- ✅ Habrás gestionado credenciales con `secrets:`
- ✅ Tendrás healthchecks en todos los servicios con `condition: service_healthy`
- ✅ Usarás anchors YAML para eliminar repetición
- ✅ Tendrás un stack que escala workers en la línea de comando

---

## 📖 Descripción

EduStack es una plataforma de cursos online. Los servicios son:

| Servicio      | Rol                                              |
| ------------- | ------------------------------------------------ |
| `nginx`       | Reverse proxy + archivos estáticos               |
| `api`         | API REST (FastAPI) — endpoints de cursos y auth  |
| `worker`      | Procesador de tareas asíncronas (correos, certs) |
| `db`          | PostgreSQL principal                             |
| `cache`       | Redis (sesiones + cola de tareas)                |
| `adminer`     | Admin de BD (profile: tools)                     |
| `prometheus`  | Métricas (profile: monitoring)                   |
| `grafana`     | Dashboards (profile: monitoring)                 |

---

## 📋 Requisitos Técnicos

### 1. Anchors YAML (obligatorio)

Usa al menos un anchor `x-` para evitar repetición de `restart`, `logging` o environment común:

```yaml
x-base-service: &base
  restart: unless-stopped
  logging:
    driver: json-file
    options:
      max-size: "5m"
```

### 2. Profiles (obligatorio)

- Servicios core (sin profile): `nginx`, `api`, `worker`, `db`, `cache`
- Profile `tools`: `adminer`
- Profile `monitoring`: `prometheus`, `grafana`

### 3. Secrets (obligatorio)

- Crear `secrets/db_password.txt` y `secrets/jwt_secret.txt`
- Referencias en el compose con `file:` 
- No hardcodear credenciales

### 4. Healthchecks (obligatorio)

- `db`: healthcheck con `pg_isready`
- `cache`: healthcheck con `redis-cli ping`  
- `api`: healthcheck con endpoint `/health`
- `api` y `worker` con `depends_on: condition: service_healthy`

### 5. Scaling

- El servicio `worker` debe poder escalarse: `docker compose up -d --scale worker=3`
- El worker **no debe tener puertos de host**

### 6. Archivos .env

- `.env` con variables no sensibles
- `.env.example` para documentar variables requeridas
- `secrets/README.md` indicando qué archivos crear

---

## 🗂️ Estructura Esperada

```
edustack/
├── docker-compose.yml
├── .env
├── .env.example
├── .gitignore
├── secrets/
│   ├── README.md       # Instrucciones (commitable)
│   ├── db_password.txt # NO commitable (.gitignore)
│   └── jwt_secret.txt  # NO commitable (.gitignore)
├── nginx/
│   └── nginx.conf
└── api/
    ├── Dockerfile
    ├── requirements.txt
    └── main.py
```

---

## 📦 Starter Code

### `starter/docker-compose.yml` (esqueleto)

```yaml
# x-: Anchors reutilizables
x-base: &base
  # TODO: agregar restart y logging

services:
  nginx:
    <<: *base
    image: nginx:alpine
    ports:
      - "80:80"
    # TODO: volumes, depends_on, healthcheck

  api:
    <<: *base
    build: ./api
    # TODO: environment, secrets, depends_on con condition: service_healthy, healthcheck

  worker:
    <<: *base
    build: ./api
    command: python worker.py
    # TODO: environment, secrets, depends_on, SIN puertos
    # Los workers se escalan: docker compose up -d --scale worker=2

  db:
    <<: *base
    image: postgres:16-alpine
    # TODO: environment referenciando secrets, volumes, healthcheck

  cache:
    <<: *base
    image: redis:7-alpine
    # TODO: healthcheck

  # --- TOOLS ---
  adminer:
    image: adminer:latest
    # TODO: profiles, ports, depends_on

  # --- MONITORING ---
  prometheus:
    image: prom/prometheus:latest
    # TODO: profiles, ports

  grafana:
    image: grafana/grafana:latest
    # TODO: profiles, ports, depends_on, volumes

secrets:
  # TODO: definir db_password y jwt_secret

volumes:
  # TODO: definir volúmenes necesarios

networks:
  # TODO: public-net e internal-net
```

### `starter/secrets/README.md`

```markdown
# Secrets del Proyecto

Crear los siguientes archivos (NO commitear):

## db_password.txt
echo "tu_password_seguro" > secrets/db_password.txt

## jwt_secret.txt  
openssl rand -hex 32 > secrets/jwt_secret.txt
```

---

## 🏁 Criterios de Aceptación

1. `docker compose up -d --build` funciona sin errores
2. `docker compose ps` muestra todos los servicios core como `Up (healthy)`
3. `docker compose --profile tools up -d` agrega Adminer
4. `docker compose --profile monitoring up -d` agrega Prometheus y Grafana
5. `docker compose up -d --scale worker=3` escala a 3 workers
6. `docker compose exec db cat /run/secrets/db_password` muestra el secret
7. `docker compose exec api env` NO muestra el valor del secret (solo la ruta)
8. Los archivos de secrets están en `.gitignore`
9. El `docker-compose.yml` usa al menos un anchor YAML `x-`

---

## 📊 Evaluación

| Criterio                      | Puntos |
| ----------------------------- | ------ |
| Anchors YAML implementados    | 15     |
| Profiles correctos            | 20     |
| Secrets correctamente usados  | 25     |
| Healthchecks en todos         | 25     |
| Worker escalable              | 15     |
| **Total**                     | **100**|
