# 💻 Ejercicio 01: Profiles en Acción

## 📋 Información del Ejercicio

| Atributo          | Valor                                              |
| ----------------- | -------------------------------------------------- |
| **Duración**      | 45 minutos                                         |
| **Nivel**         | Intermedio                                         |
| **Objetivos**     | Configurar y activar profiles en un stack real     |
| **Prerequisitos** | Semana 06 completada                               |

---

## 🎯 Objetivos de Aprendizaje

- ✅ Asignar servicios a profiles
- ✅ Activar profiles con `--profile` y `COMPOSE_PROFILES`
- ✅ Verificar qué servicios se inician con cada profile
- ✅ Combinar profiles para distintos escenarios de uso

---

## 📝 Instrucciones

### Parte 1: Stack Base con Profiles (20 min)

```bash
mkdir profiles-lab && cd profiles-lab
```

Crear `docker-compose.yml`:

```yaml
services:
  # CORE: siempre activo
  api:
    image: nginx:alpine
    ports:
      - "8080:80"
    volumes:
      - ./html:/usr/share/nginx/html:ro

  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: appdb
      POSTGRES_USER: user
      POSTGRES_PASSWORD: pass
    volumes:
      - db-data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U user -d appdb"]
      interval: 10s
      retries: 5
      start_period: 30s

  # PROFILE: tools (herramientas de admin)
  adminer:
    image: adminer:latest
    ports:
      - "8081:8080"
    profiles:
      - tools
    depends_on:
      db:
        condition: service_healthy

  # PROFILE: monitoring
  cadvisor:
    image: gcr.io/cadvisor/cadvisor:latest
    ports:
      - "8082:8080"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - /sys:/sys:ro
    profiles:
      - monitoring

  # PROFILE: debug (utilidades de red)
  debug:
    image: alpine:3.19
    command: sleep infinity
    profiles:
      - debug
    networks:
      - default

volumes:
  db-data:
```

```bash
mkdir html
echo "<h1>🐳 Docker Compose Profiles Lab</h1>" > html/index.html
```

---

### Parte 2: Experimentar con Profiles (15 min)

```bash
# 1. Ver qué servicios existen
docker compose config --services

# 2. Levantar solo los servicios CORE (sin profile)
docker compose up -d
docker compose ps
# Solo api y db deben estar corriendo

# 3. Activar el profile tools
docker compose --profile tools up -d
docker compose ps
# Ahora api, db y adminer están corriendo

# 4. Activar monitoring también
docker compose --profile tools --profile monitoring up -d
docker compose ps
# api, db, adminer y cadvisor corriendo

# 5. Ver la configuración de cada profile
docker compose --profile monitoring config --services

# 6. Usar variable de entorno
export COMPOSE_PROFILES=tools,monitoring
docker compose ps    # Ya no necesitas --profile

# 7. Detener todo
unset COMPOSE_PROFILES
docker compose --profile tools --profile monitoring down
```

---

### Parte 3: .env por Entorno (10 min)

```bash
# .env.development
cat > .env.development << 'EOF'
COMPOSE_PROFILES=tools,debug
EOF

# .env.production  
cat > .env.production << 'EOF'
COMPOSE_PROFILES=monitoring
EOF

# Levantar en modo desarrollo
docker compose --env-file .env.development up -d
docker compose ps
# Debe mostrar: api, db, adminer, debug

# Ver qué profile está activo
docker compose --env-file .env.development config --services
```

---

### Limpieza

```bash
docker compose --env-file .env.development down -v
cd .. && rm -rf profiles-lab
```

---

## ✅ Checklist de Verificación

- [ ] Sin `--profile`: solo servicios core arrancan
- [ ] Con `--profile tools`: adminer se agrega
- [ ] Con `--profile monitoring`: cadvisor se agrega
- [ ] `COMPOSE_PROFILES` funciona igual que `--profile`
- [ ] El perfil `debug` solo activa el contenedor de debug

---

## 🔗 Siguiente Ejercicio

[→ Ejercicio 02: Healthchecks Avanzados](../02-healthchecks/README.md)
