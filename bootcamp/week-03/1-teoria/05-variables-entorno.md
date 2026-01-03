# 📚 Variables de Entorno y Configuración

## 🎯 Objetivos de Aprendizaje

Al finalizar esta sección, serás capaz de:

- Configurar variables de entorno en contenedores
- Usar archivos .env con Docker
- Entender la precedencia de variables
- Implementar configuración dinámica
- Gestionar secretos básicos

---

## 🌍 Variables de Entorno en Docker

![Variables de Entorno](../0-assets/05-variables-entorno.svg)

Las variables de entorno son el método recomendado para configurar contenedores, siguiendo los principios de [12-Factor App](https://12factor.net/config).

### Métodos de configuración

| Método           | Scope            | Precedencia |
| ---------------- | ---------------- | ----------- |
| `docker run -e`  | Contenedor       | Alta        |
| `--env-file`     | Contenedor       | Alta        |
| `ENV` Dockerfile | Imagen           | Baja        |
| `.env` Compose   | Compose file     | Media       |
| `environment:`   | Servicio Compose | Alta        |

---

## 🔧 Variables en docker run

### Flag -e / --env

```bash
# Variable única
docker run -e MYSQL_ROOT_PASSWORD=secreto mysql

# Múltiples variables
docker run -e DB_HOST=localhost -e DB_PORT=3306 -e DB_NAME=myapp myimage

# Usar valor de variable del host
export MY_SECRET=abc123
docker run -e MY_SECRET myimage  # Pasa MY_SECRET=abc123

# Con comillas para valores con espacios
docker run -e "MESSAGE=Hello World" myimage
```

### Verificar variables configuradas

```bash
# Ver todas las variables
docker exec mi-app env
docker exec mi-app printenv

# Ver variable específica
docker exec mi-app printenv DB_HOST
docker exec mi-app sh -c 'echo $DB_HOST'

# Desde inspect
docker inspect -f '{{.Config.Env}}' mi-app
docker inspect -f '{{range .Config.Env}}{{println .}}{{end}}' mi-app
```

---

## 📄 Archivos de Entorno

### Flag --env-file

```bash
# Crear archivo .env
cat > app.env << EOF
# Configuración de base de datos
DB_HOST=mysql
DB_PORT=3306
DB_NAME=production
DB_USER=appuser
DB_PASS=secretpassword

# Configuración de aplicación
APP_ENV=production
DEBUG=false
LOG_LEVEL=info
EOF

# Usar archivo
docker run --env-file app.env myimage

# Múltiples archivos
docker run --env-file base.env --env-file secrets.env myimage

# Combinar con -e (tienen precedencia)
docker run --env-file base.env -e DEBUG=true myimage
```

### Formato del archivo .env

```bash
# Variables simples
KEY=value

# Con comillas (opcionales)
KEY="value with spaces"
KEY='single quotes'

# Comentarios
# Este es un comentario

# Líneas vacías se ignoran

# Sin valor (usa valor del host)
EXISTING_VAR

# Valores multilínea NO soportados directamente
```

---

## 🏗️ Variables en Dockerfile

### Instrucción ENV

```dockerfile
# Variable simple
ENV APP_HOME=/app

# Múltiples variables (forma antigua)
ENV APP_HOME=/app \
    APP_USER=appuser \
    APP_PORT=8080

# Múltiples variables (forma moderna)
ENV APP_HOME=/app
ENV APP_USER=appuser
ENV APP_PORT=8080

# Usar en otras instrucciones
WORKDIR ${APP_HOME}
USER ${APP_USER}
EXPOSE ${APP_PORT}
```

### ARG vs ENV

```dockerfile
# ARG: solo durante build
ARG VERSION=1.0
ARG BUILD_DATE

# ENV: persiste en runtime
ENV APP_VERSION=${VERSION}

# ARG desde línea de comandos
# docker build --build-arg VERSION=2.0 .
```

| Característica | ARG                | ENV             |
| -------------- | ------------------ | --------------- |
| Disponible en  | Build time         | Build + Runtime |
| Sobrescribir   | `--build-arg`      | `-e` en run     |
| Capas          | No crea capa extra | Crea capa       |
| En imagen      | No persiste        | Persiste        |

### Ejemplo completo

```dockerfile
# Args de build
ARG NODE_VERSION=20
ARG BUILD_ENV=production

# Imagen base paramétrica
FROM node:${NODE_VERSION}-alpine

# Variables de runtime
ENV NODE_ENV=${BUILD_ENV} \
    APP_HOME=/app \
    PORT=3000

WORKDIR ${APP_HOME}
COPY . .
RUN npm ci --only=production

EXPOSE ${PORT}
CMD ["node", "server.js"]
```

```bash
# Build con args personalizados
docker build --build-arg NODE_VERSION=18 --build-arg BUILD_ENV=development -t myapp .

# Run con env personalizado
docker run -e PORT=8080 myapp
```

---

## 🔄 Precedencia de Variables

### Orden de precedencia (mayor a menor)

1. `docker run -e VAR=value` (línea de comandos)
2. `--env-file` (archivo .env)
3. `ENV` en Dockerfile

```bash
# Dockerfile tiene: ENV DEBUG=false
# app.env tiene: DEBUG=maybe
# Comando: docker run --env-file app.env -e DEBUG=true myimage

# Resultado: DEBUG=true (línea de comandos gana)
```

### Ejemplo de precedencia

```dockerfile
# Dockerfile
ENV APP_MODE=dockerfile
ENV LOG_LEVEL=info
```

```bash
# override.env
APP_MODE=envfile
```

```bash
# Ejecutar
docker run --env-file override.env -e LOG_LEVEL=debug myimage

# Resultado:
# APP_MODE=envfile (de --env-file, sobrescribe Dockerfile)
# LOG_LEVEL=debug (de -e, sobrescribe todo)
```

---

## 🔐 Gestión de Secretos

### ⚠️ Malas prácticas

```dockerfile
# ❌ NUNCA hacer esto
ENV DB_PASSWORD=supersecretpassword
ENV API_KEY=abc123xyz

# ❌ Secretos visibles en imagen
docker history myimage  # Muestra el secreto
```

### ✅ Buenas prácticas

```bash
# ✅ Variables en runtime
docker run -e DB_PASSWORD="$(cat /secure/db_pass)" myimage

# ✅ Archivo de secretos (no versionado)
echo "supersecret" > .secrets/db_pass
docker run --env-file .secrets/db_pass myimage

# ✅ Docker secrets (Swarm)
echo "supersecret" | docker secret create db_password -
docker service create --secret db_password myimage

# ✅ Herramientas externas
# - HashiCorp Vault
# - AWS Secrets Manager
# - Azure Key Vault
```

### Archivos .env y Git

```bash
# .gitignore
.env
.env.local
.env.*.local
*.secrets
secrets/

# Proveer template
# .env.example (versionado)
DB_HOST=localhost
DB_USER=
DB_PASS=
API_KEY=
```

---

## 📦 Variables en Docker Compose

### environment: vs env_file:

```yaml
services:
  app:
    image: myapp
    # Variables inline
    environment:
      - NODE_ENV=production
      - DEBUG=false
      - DB_HOST=db
    # O formato mapa
    environment:
      NODE_ENV: production
      DEBUG: "false"
      DB_HOST: db

  db:
    image: mysql
    # Desde archivo
    env_file:
      - ./db.env
      - ./secrets.env
    # Combinar con inline
    environment:
      - MYSQL_DATABASE=app
```

### Interpolación de variables

```yaml
# docker-compose.yml
services:
  app:
    image: myapp:${APP_VERSION:-latest}
    environment:
      - DB_HOST=${DB_HOST:-localhost}
      - DB_PORT=${DB_PORT:-3306}
```

```bash
# Archivo .env (cargado automáticamente)
APP_VERSION=2.0
DB_HOST=production-db

# O desde shell
export APP_VERSION=2.0
docker compose up
```

### Sintaxis de interpolación

| Sintaxis          | Descripción                           |
| ----------------- | ------------------------------------- |
| `${VAR}`          | Valor de VAR                          |
| `${VAR:-default}` | Default si VAR no existe o está vacía |
| `${VAR-default}`  | Default solo si VAR no existe         |
| `${VAR:?error}`   | Error si VAR no existe o está vacía   |
| `${VAR?error}`    | Error solo si VAR no existe           |

---

## 🎯 Patrones Comunes

### Configuración por entorno

```bash
# development.env
NODE_ENV=development
DEBUG=true
LOG_LEVEL=debug
DB_HOST=localhost

# production.env
NODE_ENV=production
DEBUG=false
LOG_LEVEL=warn
DB_HOST=prod-db.cluster.local
```

```bash
# Desarrollo
docker run --env-file development.env myapp

# Producción
docker run --env-file production.env myapp
```

### Feature flags

```bash
docker run \
    -e FEATURE_NEW_UI=true \
    -e FEATURE_BETA_API=false \
    -e FEATURE_ANALYTICS=true \
    myapp
```

### Configuración de conexiones

```bash
# Base de datos
docker run \
    -e DB_HOST=mysql \
    -e DB_PORT=3306 \
    -e DB_NAME=myapp \
    -e DB_USER=admin \
    -e DB_PASS=secret \
    myapp

# O connection string
docker run \
    -e DATABASE_URL="mysql://admin:secret@mysql:3306/myapp" \
    myapp
```

---

## 🔍 Debugging de Variables

```bash
# Ver todas las variables
docker exec mi-app env | sort

# Buscar variable específica
docker exec mi-app printenv | grep DB

# Ver cómo se configuró
docker inspect mi-app | jq '.[0].Config.Env'

# Ver en compose
docker compose config  # Muestra configuración interpolada

# Test de interpolación
echo "DB_HOST=${DB_HOST:-localhost}" | docker compose config --format=yaml
```

---

## ✅ Verificación de Aprendizaje

1. ¿Cuál es la diferencia entre ARG y ENV?
2. ¿Qué método tiene mayor precedencia: `-e` o `--env-file`?
3. ¿Por qué no debes poner secretos en el Dockerfile?
4. ¿Qué significa `${VAR:-default}`?
5. ¿Cómo verificarías qué variables tiene un contenedor?

---

## 🔗 Navegación

| ← Anterior                                  | Siguiente →                                       |
| ------------------------------------------- | ------------------------------------------------- |
| [04 - Exec y Comandos](04-exec-comandos.md) | [06 - Recursos y Límites](06-recursos-limites.md) |
