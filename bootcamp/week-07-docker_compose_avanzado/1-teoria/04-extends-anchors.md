# 🔗 Extends y Anchors YAML en Docker Compose

## El Problema de la Duplicación

Al escalar el uso de Compose aparece la repetición. Servicios con configuración similar generan mantenimiento costoso:

```yaml
# ❌ Repetición innecesaria
services:
  api-1:
    build: ./api
    restart: unless-stopped
    logging:
      driver: json-file
      options:
        max-size: "10m"
        max-file: "3"
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost/health"]
      interval: 15s
      retries: 3

  api-2:
    build: ./api-v2
    restart: unless-stopped       # ← duplicado
    logging:                       # ← duplicado
      driver: json-file
      options:
        max-size: "10m"
        max-file: "3"
    healthcheck:                   # ← duplicado
      test: ["CMD", "curl", "-f", "http://localhost/health"]
      interval: 15s
      retries: 3
```

Hay dos soluciones: **anchors YAML** y **extends**.

---

## Anchors YAML

Los anchors son una funcionalidad nativa de YAML (no específica de Compose) que permite reutilizar bloques.

### Sintaxis

```yaml
# Definir un anchor con &nombre
# Referenciarlo con *nombre
# Fusionar con <<: *nombre (merge key)

x-common-settings: &common   # El & define el anchor
  restart: unless-stopped
  logging:
    driver: json-file
    options:
      max-size: "10m"
      max-file: "3"

services:
  api:
    build: ./api
    <<: *common         # Fusiona el contenido de &common aquí
    ports:
      - "8000:8000"

  worker:
    build: ./worker
    <<: *common         # Reutiliza la misma configuración
    command: python worker.py
```

> El prefijo `x-` en las keys top-level le indica a Compose que las ignore (extensiones personalizadas).

---

## Anchors para Listas

```yaml
x-healthcheck: &healthcheck
  interval: 15s
  timeout: 5s
  retries: 3
  start_period: 20s

services:
  api:
    build: ./api
    healthcheck:
      test: ["CMD-SHELL", "curl -f http://localhost:8000/health || exit 1"]
      <<: *healthcheck    # Fusiona interval, timeout, retries, start_period

  frontend:
    build: ./frontend
    healthcheck:
      test: ["CMD-SHELL", "wget -qO- http://localhost:3000 || exit 1"]
      <<: *healthcheck    # Misma configuración de tiempos
```

---

## Múltiples Anchors

```yaml
x-logging: &logging
  logging:
    driver: json-file
    options:
      max-size: "10m"

x-restart: &restart
  restart: unless-stopped

x-networks: &networks
  networks:
    - app-net

services:
  api:
    build: ./api
    <<: [*logging, *restart, *networks]   # Fusión múltiple
    ports:
      - "8000:8000"

  worker:
    build: ./worker
    <<: [*logging, *restart, *networks]
    command: python worker.py
```

> ⚠️ La fusión múltiple `<<: [*a, *b]` es compatible con la mayoría de parsers YAML 1.2, pero algunos requieren dos líneas separadas `<<:` con el spec antiguo.

---

## extends (Herencia entre servicios)

`extends` permite que un servicio herede la configuración completa de otro servicio, ya sea en el mismo archivo o en uno externo.

### En el mismo archivo

```yaml
services:
  # Servicio base (no se levanta directamente si no se referencia)
  base-api:
    image: python:3.12-slim
    working_dir: /app
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "python -c \"import urllib.request; urllib.request.urlopen('http://localhost:8000/health')\""]
      interval: 30s
      retries: 3

  api-v1:
    extends:
      service: base-api    # Hereda TODA la config de base-api
    build: ./api-v1
    ports:
      - "8001:8000"

  api-v2:
    extends:
      service: base-api    # Hereda TODA la config de base-api
    build: ./api-v2
    ports:
      - "8002:8000"
    environment:
      VERSION: "2.0"       # Agrega/sobreescribe lo heredado
```

### Desde un archivo externo

```yaml
# common/base.yml
services:
  base-service:
    restart: unless-stopped
    logging:
      driver: json-file
      options:
        max-size: "10m"
    healthcheck:
      test: echo "ok"
      interval: 30s
```

```yaml
# docker-compose.yml
services:
  api:
    extends:
      file: common/base.yml    # Archivo externo
      service: base-service    # Servicio dentro de ese archivo
    build: ./api
    ports:
      - "8000:8000"

  worker:
    extends:
      file: common/base.yml
      service: base-service
    build: ./worker
```

---

## Diferencias: Anchors vs extends

| Característica           | Anchors YAML (`&`)          | `extends`                        |
| ------------------------ | --------------------------- | -------------------------------- |
| **Nivel**                | YAML nativo                 | Característica de Compose        |
| **Granularidad**         | Cualquier bloque YAML       | Servicio completo                |
| **Herencia de redes**    | Posible con fusión manual   | **No hereda** volumes ni networks|
| **Archivo externo**      | No                          | Sí (`file:`)                     |
| **Legibilidad**          | Puede ser confuso           | Muy explícito                    |
| **Recomendado para**     | Configuración repetitiva    | Servicios base compartidos       |

> `extends` NO hereda: `volumes:`, `networks:`, `depends_on:`. Estos deben definirse explícitamente en el servicio que extiende.

---

## Ejemplo Completo: Proyecto Real

```yaml
# x- extensiones (ignoradas por Compose, anclas YAML)
x-defaults: &defaults
  restart: unless-stopped
  logging:
    driver: json-file
    options:
      max-size: "5m"
      max-file: "2"

x-api-base: &api-base
  <<: *defaults
  build:
    context: ./src
    args:
      - NODE_ENV=${NODE_ENV:-production}
  environment:
    NODE_ENV: ${NODE_ENV:-production}
    DB_HOST: db
    REDIS_HOST: cache
  networks:
    - internal-net
  depends_on:
    db:
      condition: service_healthy
    cache:
      condition: service_healthy

services:
  nginx:
    image: nginx:alpine
    <<: *defaults
    ports:
      - "80:80"
    depends_on:
      - api
    networks:
      - public-net

  api:
    <<: *api-base
    ports:
      - "127.0.0.1:8000:8000"   # Solo localhost
    networks:
      - public-net
      - internal-net
    healthcheck:
      test: ["CMD-SHELL", "wget -qO- http://localhost:8000/health || exit 1"]
      interval: 30s
      retries: 3
      start_period: 20s

  worker:
    <<: *api-base
    command: python worker.py
    # Sin puertos, solo internal-net (heredada)

  db:
    image: postgres:16-alpine
    <<: *defaults
    environment:
      POSTGRES_USER: ${DB_USER}
      POSTGRES_PASSWORD_FILE: /run/secrets/db_password
    volumes:
      - db-data:/var/lib/postgresql/data
    secrets:
      - db_password
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${DB_USER}"]
      interval: 10s
      retries: 5
      start_period: 30s
    networks:
      - internal-net

  cache:
    image: redis:7-alpine
    <<: *defaults
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      retries: 3
    networks:
      - internal-net

volumes:
  db-data:

networks:
  public-net:
  internal-net:
    internal: true

secrets:
  db_password:
    file: ./secrets/db_password.txt
```

---

## ✅ Cuándo usar cada uno

| Situación                          | Solución                         |
| ---------------------------------- | -------------------------------- |
| Config repetida (logging, restart) | Anchor YAML (`x-key: &anchor`)   |
| Múltiples versiones de un servicio | `extends` con service base       |
| Config en archivo compartido       | `extends` con `file:`            |
| Healthcheck timing reutilizable    | Anchor YAML parcial              |

---

## 📚 Siguiente Tema

[→ 05. Scaling y Restart Policies](./05-scaling-restart.md)
