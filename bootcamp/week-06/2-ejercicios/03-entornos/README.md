# 💻 Ejercicio 03: Múltiples Entornos con Override Files

## 📋 Información del Ejercicio

| Atributo          | Valor                                                  |
| ----------------- | ------------------------------------------------------ |
| **Duración**      | 50 minutos                                             |
| **Nivel**         | Intermedio                                             |
| **Objetivos**     | Configurar dev, staging y prod con override files      |
| **Prerequisitos** | Ejercicio 02 completado                                |

---

## 🎯 Objetivos de Aprendizaje

- ✅ Crear y usar `docker-compose.override.yml` para desarrollo
- ✅ Entender cómo se fusionan múltiples archivos Compose
- ✅ Gestionar variables con múltiples archivos `.env`
- ✅ Activar/desactivar servicios por entorno
- ✅ Observar diferencias de configuración entre entornos

---

## 🗂️ Estructura Final

```
entornos-lab/
├── docker-compose.yml          # Base (producción)
├── docker-compose.override.yml # Dev (carga automática)
├── docker-compose.staging.yml  # Staging
├── .env                        # Variables de desarrollo
├── .env.staging                # Variables de staging
├── .env.example                # Plantilla (commitable)
└── app/
    ├── Dockerfile
    └── index.html
```

---

## 📝 Instrucciones

### Parte 1: Archivo Base y Override Dev (20 min)

```bash
mkdir -p entornos-lab/app && cd entornos-lab

cat > app/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head><title>Bootcamp Docker - Entornos</title></head>
<body style="background:#1a1a2e; color:white; font-family:monospace; padding:40px">
  <h1>🐳 Ambiente: ENVIRONMENT_PLACEHOLDER</h1>
  <p>Servidor: HOSTNAME_PLACEHOLDER</p>
</body>
</html>
EOF

cat > app/Dockerfile << 'EOF'
FROM nginx:alpine
COPY index.html /usr/share/nginx/html/index.html
ENV ENVIRONMENT=production
RUN apk add --no-cache bash
CMD ["sh", "-c", "sed -i s/ENVIRONMENT_PLACEHOLDER/$ENVIRONMENT/ /usr/share/nginx/html/index.html && sed -i s/HOSTNAME_PLACEHOLDER/$(hostname)/ /usr/share/nginx/html/index.html && nginx -g 'daemon off;'"]
EOF
```

**`docker-compose.yml`** (base — producción):

```yaml
# docker-compose.yml
services:
  app:
    build: ./app
    environment:
      ENVIRONMENT: ${ENVIRONMENT:-production}
    restart: unless-stopped
    # Sin puertos: en producción el tráfico pasa por reverse proxy

  proxy:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./nginx-proxy.conf:/etc/nginx/conf.d/default.conf:ro
    depends_on:
      - app
    restart: unless-stopped
```

Crear `nginx-proxy.conf`:

```bash
cat > nginx-proxy.conf << 'EOF'
server {
    listen 80;
    location / {
        proxy_pass http://app:80;
    }
}
EOF
```

**`docker-compose.override.yml`** (desarrollo — carga automática):

```yaml
# docker-compose.override.yml
services:
  app:
    build:
      context: ./app
      dockerfile: Dockerfile
    ports:
      - "8080:80"          # Acceso directo para debugging
    environment:
      ENVIRONMENT: development
    volumes:
      - ./app/index.html:/usr/share/nginx/html/index.html:ro  # Hot reload
    restart: "no"          # En dev no queremos auto-restart

  proxy:
    ports:
      - "8081:80"          # Puerto diferente para el proxy en dev

  # Servicio EXTRA solo en desarrolloo
  mailhog:
    image: mailhog/mailhog:latest
    ports:
      - "8025:8025"        # UI web de emails de prueba
      - "1025:1025"        # SMTP
```

**`.env`** (desarrollo):

```bash
cat > .env << 'EOF'
ENVIRONMENT=development
EOF
```

---

### Parte 2: Verificar Fusión de Archivos (10 min)

```bash
# Ver la configuración FUSIONADA (dev)
docker compose config

# Observar:
# - app tiene ports: [8080:80] (del override)
# - app tiene volumes (del override)
# - proxy tiene ports: [8081:80] (del override)
# - mailhog está presente (del override)

# Levantar en modo dev
docker compose up -d --build
docker compose ps

# Acceso directo a la app (sin proxy)
curl http://localhost:8080    # Muestra "development"

# A través del proxy
curl http://localhost:8081    # También "development"
```

---

### Parte 3: Configurar Staging (20 min)

**`docker-compose.staging.yml`**:

```yaml
# docker-compose.staging.yml
services:
  app:
    image: mi-app:staging    # Imagen pre-construida, no build local
    deploy:
      replicas: 2            # 2 instancias en staging
    environment:
      ENVIRONMENT: staging

  proxy:
    ports:
      - "80:80"

  # Sin mailhog en staging
  # Sin puertos directos a app
```

**`.env.staging`**:

```bash
cat > .env.staging << 'EOF'
ENVIRONMENT=staging
EOF
```

```bash
# Detener el stack de dev
docker compose down

# Ver la config de staging (sin levantar)
docker compose -f docker-compose.yml -f docker-compose.staging.yml \
  --env-file .env.staging config

# Observar diferencias:
# - No hay ports directos en app
# - No hay mailhog
# - No hay volumes de hot-reload
```

```bash
# Para comparar, ver la diff de configuraciones
echo "=== DESARROLLO ===" 
docker compose config --services

echo "=== STAGING ==="
docker compose -f docker-compose.yml -f docker-compose.staging.yml config --services
```

---

### Limpieza

```bash
docker compose down -v
cd .. && rm -rf entornos-lab
```

---

## ✅ Checklist de Verificación

- [ ] `docker-compose.override.yml` se carga automáticamente en dev
- [ ] La configuración fusionada en dev tiene `mailhog` y puertos directos
- [ ] La configuración de staging NO tiene `mailhog` ni hot-reload
- [ ] Entiendo cómo `docker compose config` muestra la config resuelta
- [ ] Sé cómo usar `-f` para elegir archivos manualmente

---

## 🔗 Ir al Proyecto

[→ Proyecto Semanal: Aplicación Full-Stack](../../3-proyecto/README.md)
