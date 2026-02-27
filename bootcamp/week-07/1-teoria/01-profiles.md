# 🎭 Profiles en Docker Compose

## ¿Qué es un Profile?

Un **profile** en Docker Compose es una etiqueta que asignas a servicios opcionales. Los servicios sin profile siempre arrancan; los servicios con profile **solo arrancan cuando los activas explícitamente**.

```yaml
services:
  app:                    # Sin profile → siempre arranca
    image: myapp:latest

  debug-tools:
    image: alpine:3.19
    profiles:             # Solo con --profile debug
      - debug

  mailhog:
    image: mailhog/mailhog
    profiles:             # Solo con --profile tools
      - tools
```

---

## ¿Por qué usar Profiles?

Sin profiles, tienes que mantener múltiples `docker-compose.yml`. Con profiles, un solo archivo sirve para todos los casos:

| Caso de uso                         | Sin profiles                | Con profiles             |
| ----------------------------------- | --------------------------- | ------------------------ |
| Dev con herramientas extra          | `docker-compose.dev.yml`    | `--profile dev`          |
| Tests con mocks                     | `docker-compose.test.yml`   | `--profile test`         |
| Debugging puntual                   | Editar el compose.yml       | `--profile debug`        |
| Servicios de administración (pgAdmin)| Tener compose separado     | `--profile admin`        |

---

## Sintaxis Completa

```yaml
# docker-compose.yml
services:

  # Servicio CORE (sin profile): siempre activo
  api:
    build: ./api
    ports:
      - "8000:8000"

  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: appdb
      POSTGRES_USER: user
      POSTGRES_PASSWORD: pass

  # Profile: tools (herramientas de administración)
  adminer:
    image: adminer:latest
    ports:
      - "8081:8080"
    profiles:
      - tools
    depends_on:
      - db

  # Profile: monitoring
  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    profiles:
      - monitoring

  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
    profiles:
      - monitoring

  # Profile: debug (herramientas de depuración)
  debug-shell:
    image: alpine:3.19
    command: sleep infinity
    profiles:
      - debug
    networks:
      - default
```

---

## Activar Profiles

```bash
# Modo básico: solo servicios sin profile
docker compose up -d

# Activar un profile específico
docker compose --profile tools up -d

# Activar múltiples profiles
docker compose --profile tools --profile monitoring up -d

# Variable de entorno (alternativa al flag)
export COMPOSE_PROFILES=tools,monitoring
docker compose up -d

# Ver qué servicios activa un profile
docker compose --profile monitoring config --services
```

---

## Profiles en Archivos .env

```bash
# .env.development
COMPOSE_PROFILES=tools,debug

# .env.production
COMPOSE_PROFILES=monitoring
```

```bash
# Usar con --env-file
docker compose --env-file .env.development up -d
```

---

## 🔧 Profile + depends_on

Cuando un servicio con profile tiene `depends_on`, la dependencia debe estar activa cuando el profile se activa:

```yaml
services:
  db:
    image: postgres:16-alpine

  pgadmin:
    image: dpage/pgadmin4:latest
    profiles:
      - admin
    depends_on:
      - db        # db está siempre activo, ok
    environment:
      PGADMIN_DEFAULT_EMAIL: admin@example.com
      PGADMIN_DEFAULT_PASSWORD: admin
    ports:
      - "5050:80"
```

> ⚠️ Si `db` también tuviera un profile, tendría que ser el mismo para que `depends_on` funcione.

---

## Casos de Uso Reales

### E-commerce Multi-Entorno

```yaml
services:
  frontend:
    image: frontend:latest

  api:
    build: ./api

  db:
    image: postgres:16-alpine
    volumes:
      - db-data:/var/lib/postgresql/data

  # Solo en desarrollo
  seed:
    build: ./scripts
    command: python seed_data.py
    profiles: [dev]
    depends_on: [db]

  # Solo en CI/test
  test-runner:
    build: ./tests
    profiles: [test]
    depends_on: [api, db]

  # Monitoreo (staging/prod)
  prometheus:
    image: prom/prometheus
    profiles: [monitoring]

  grafana:
    image: grafana/grafana
    profiles: [monitoring]
    depends_on: [prometheus]

volumes:
  db-data:
```

```bash
# Desarrollo
docker compose --profile dev up -d

# Testing en CI
docker compose --profile test run --rm test-runner

# Staging con monitoreo
docker compose --profile monitoring up -d
```

---

## ✅ Buenas Prácticas

```yaml
# 1. Nombres de profile en minúsculas, descriptivos
profiles: [tools]        # ✅
profiles: [TOOLS]        # ❌

# 2. Un servicio puede pertenecer a múltiples profiles
prometheus:
  profiles: [monitoring, debug]

# 3. Documenta qué hace cada profile en el README
# 4. Usa COMPOSE_PROFILES en .env por entorno
# 5. Los servicios core nunca llevan profile
```

---

## Resumen

| Concepto                | Descripción                                              |
| ----------------------- | -------------------------------------------------------- |
| `profiles: [nombre]`    | Asigna el servicio a un profile                         |
| `--profile nombre`      | Activa el profile al invocar compose                    |
| `COMPOSE_PROFILES`      | Variable de entorno para activar profiles               |
| Sin profile             | El servicio siempre se inicia                           |
| Con profile             | Solo se inicia cuando el profile está activo            |

---

## 📚 Siguiente Tema

[→ 02. Healthchecks Avanzados](./02-healthchecks.md)
