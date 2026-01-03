# 🤖 Instrucciones para GitHub Copilot

Este archivo configura el comportamiento de GitHub Copilot al trabajar en el **Bootcamp Docker Zero to Hero**.

---

## 📋 Información del Proyecto

| Atributo               | Valor                        |
| ---------------------- | ---------------------------- |
| **Nombre**             | Bootcamp Docker Zero to Hero |
| **Duración**           | 8 semanas                    |
| **Horas totales**      | 48 horas (6 horas/semana)    |
| **Nivel**              | Principiante a Intermedio    |
| **Idioma principal**   | Español                      |
| **Siguiente bootcamp** | Kubernetes                   |

---

## 🗓️ Estructura del Bootcamp

| Semana | Tema                     | Objetivos                                           |
| ------ | ------------------------ | --------------------------------------------------- |
| 1      | Fundamentos de Docker    | Conceptos básicos, instalación, comandos esenciales |
| 2      | Imágenes Docker          | Dockerfile, capas, construcción y optimización      |
| 3      | Gestión de Contenedores  | Ciclo de vida, logs, exec, variables de entorno     |
| 4      | Redes en Docker          | Bridge, host, comunicación entre contenedores       |
| 5      | Volúmenes y Persistencia | Bind mounts, named volumes, backups                 |
| 6      | Docker Compose Básico    | Multi-contenedor, servicios, dependencias           |
| 7      | Docker Compose Avanzado  | Profiles, extends, healthchecks, secrets            |
| 8      | Seguridad y Producción   | Buenas prácticas, usuarios no-root, CI/CD básico    |

---

## 📁 Estructura de Archivos

```
bc-docker/
├── .github/
│   ├── ISSUE_TEMPLATE/
│   ├── PULL_REQUEST_TEMPLATE.md
│   └── copilot-instructions.md     # Este archivo
├── .vscode/
│   └── extensions.json
├── _assets/                         # Assets globales del proyecto
├── _docs/                           # Documentación general
├── _scripts/                        # Scripts de utilidad
├── bootcamp/
│   └── week-XX/
│       ├── README.md                # Descripción y objetivos
│       ├── rubrica-evaluacion.md    # Criterios de evaluación
│       ├── 0-assets/                # Imágenes y diagramas SVG
│       ├── 1-teoria/                # Material teórico
│       ├── 2-ejercicios/            # Ejercicios guiados
│       ├── 3-proyecto/              # Proyecto semanal
│       ├── 4-recursos/              # Recursos adicionales
│       │   ├── ebooks-free/
│       │   ├── videografia/
│       │   └── webgrafia/
│       └── 5-glosario/              # Términos clave
├── CONTRIBUTING.md
├── CODE_OF_CONDUCT.md
├── LICENSE
├── README.md
└── README-EN.md
```

---

## 🛠️ Stack Tecnológico

| Tecnología     | Versión    | Uso                   |
| -------------- | ---------- | --------------------- |
| Docker         | **27+**    | Motor de contenedores |
| Docker Compose | **2.31+**  | Orquestación local    |
| Git            | **2.40+**  | Control de versiones  |
| VS Code        | **Latest** | Editor recomendado    |

**Entorno de desarrollo**: Docker Desktop (Windows/macOS) o Docker Engine (Linux)

---

## 📝 Reglas de Estilo

### Dockerfile

```dockerfile
# ✅ Correcto
FROM alpine:3.19

LABEL maintainer="email@example.com"
LABEL version="1.0"

ENV APP_HOME=/app \
    APP_USER=appuser

RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR ${APP_HOME}

COPY --chown=appuser:appgroup . .

USER appuser

EXPOSE 8080

CMD ["./app"]
```

```dockerfile
# ❌ Incorrecto
FROM alpine
RUN apt-get update
RUN apt-get install -y curl
RUN apt-get install -y vim
COPY . .
```

### Convenciones

- **Imágenes base**: Usar tags específicos, preferir `-slim` o `-alpine`
- **Multi-stage builds**: Usar para reducir tamaño de imagen final
- **Capas**: Combinar comandos RUN relacionados con `&&`
- **Usuario**: Nunca ejecutar como root en producción
- **Variables**: Usar ARG para build-time, ENV para runtime
- **Labels**: Incluir metadata del proyecto

### Docker Compose

```yaml
# ✅ Correcto - docker-compose.yml
services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: my-app
    environment:
      - NODE_ENV=production
    ports:
      - '3000:3000'
    volumes:
      - app-data:/app/data
    networks:
      - app-network
    healthcheck:
      test: ['CMD', 'curl', '-f', 'http://localhost:3000/health']
      interval: 30s
      timeout: 10s
      retries: 3
    restart: unless-stopped

volumes:
  app-data:

networks:
  app-network:
    driver: bridge
```

### Markdown

- Usar encabezados jerárquicos (`#`, `##`, `###`)
- Incluir emojis para mejorar legibilidad (con moderación)
- Código con syntax highlighting (`dockerfile`, `yaml`, `bash`)
- Enlaces relativos para archivos internos
- Tablas para información estructurada

### Git Commits

Los commits deben seguir **Conventional Commits** en **inglés**.

#### Formato

```
<type>(<scope>): <description>

[body: what? for? impact?]

[footer]
```

#### Tipos permitidos

| Tipo       | Descripción                                |
| ---------- | ------------------------------------------ |
| `feat`     | Nueva característica o contenido           |
| `fix`      | Corrección de error                        |
| `docs`     | Cambios en documentación                   |
| `style`    | Formato (sin cambio de lógica/contenido)   |
| `refactor` | Reestructuración sin cambiar funcionalidad |
| `test`     | Añadir o corregir tests                    |
| `chore`    | Tareas de mantenimiento, configuración     |
| `perf`     | Mejoras de rendimiento                     |
| `ci`       | Cambios en CI/CD                           |

#### Body: What? For? Impact?

| Pregunta    | Descripción                                  |
| ----------- | -------------------------------------------- |
| **What?**   | ¿Qué cambios se realizaron?                  |
| **For?**    | ¿Por qué se hicieron estos cambios?          |
| **Impact?** | ¿Qué impacto tienen en el proyecto/usuarios? |

#### Ejemplos

```bash
# ✅ Correcto - Simple
feat(week-03): add container lifecycle exercise

# ✅ Correcto - Con body
feat(week-04): add bridge network tutorial

What: Added comprehensive tutorial for Docker bridge networks
For: Students need hands-on practice with container networking
Impact: Enables completion of week-04 networking objectives

# ✅ Correcto - Con breaking change
feat(week-06)!: restructure compose exercises

BREAKING CHANGE: Exercise folder structure changed from flat to nested

# ✅ Correcto - Fix
fix(week-02): correct typo in Dockerfile example

What: Fixed incorrect base image tag in multi-stage example
For: Students were getting build errors with the wrong tag
Impact: Exercise now builds successfully

# ❌ Incorrecto
added stuff
fix bug
Update README.md
```

#### Reglas

1. **Idioma**: Siempre en inglés
2. **Descripción**: Imperativo, presente ("add" no "added")
3. **Longitud**: Primera línea máximo 72 caracteres
4. **Scope**: Usar `week-XX`, `docs`, `config`, `assets`, etc.
5. **Body**: Usar What/For/Impact para cambios significativos

---

## 🎯 Directrices para Copilot

### Al generar Dockerfiles

1. **Siempre** usar versiones específicas de imágenes base
2. **Incluir** comentarios explicativos en español
3. **Aplicar** multi-stage builds cuando sea apropiado
4. **Configurar** usuario no-root
5. **Optimizar** el orden de capas para caché
6. **Incluir** HEALTHCHECK cuando sea aplicable

### Al generar docker-compose.yml

1. **Usar** la versión más reciente de la especificación
2. **Definir** redes y volúmenes explícitamente
3. **Incluir** healthchecks para servicios críticos
4. **Documentar** variables de entorno
5. **Usar** depends_on con condiciones cuando sea necesario

### Al generar ejercicios

1. **Estructurar** con objetivos claros
2. **Incluir** pasos numerados
3. **Proporcionar** código starter con TODOs
4. **Agregar** checklist de verificación
5. **Estimar** tiempo de realización

### Al generar teoría

1. **Explicar** conceptos progresivamente
2. **Usar** diagramas y visualizaciones cuando sea posible
3. **Incluir** ejemplos prácticos
4. **Agregar** tips y buenas prácticas
5. **Referenciar** documentación oficial

---

## 📚 Comandos Docker Comunes

### Imágenes

```bash
# Construir imagen
docker build -t nombre:tag .

# Listar imágenes
docker images

# Eliminar imagen
docker rmi nombre:tag

# Inspeccionar imagen
docker inspect nombre:tag
```

### Contenedores

```bash
# Ejecutar contenedor
docker run -d --name mi-contenedor -p 8080:80 imagen:tag

# Listar contenedores
docker ps -a

# Logs
docker logs -f mi-contenedor

# Ejecutar comando
docker exec -it mi-contenedor /bin/sh

# Detener y eliminar
docker stop mi-contenedor && docker rm mi-contenedor
```

### Volúmenes

```bash
# Crear volumen
docker volume create mi-volumen

# Montar volumen
docker run -v mi-volumen:/data imagen:tag

# Bind mount
docker run -v $(pwd):/app imagen:tag
```

### Redes

```bash
# Crear red
docker network create mi-red

# Conectar contenedor
docker network connect mi-red mi-contenedor

# Inspeccionar red
docker network inspect mi-red
```

### Docker Compose

```bash
# Levantar servicios
docker compose up -d

# Ver logs
docker compose logs -f

# Detener servicios
docker compose down

# Reconstruir
docker compose up -d --build
```

---

## 🔑 Conceptos Clave por Semana

### Semana 1: Fundamentos

- Contenedor vs Máquina Virtual
- Docker Engine y Docker Desktop
- Imagen vs Contenedor
- Registry (Docker Hub)

### Semana 2: Imágenes

- Dockerfile
- Capas (layers)
- Build context
- Tags y versionado

### Semana 3: Contenedores

- Ciclo de vida
- Logs y debugging
- Variables de entorno
- Recursos y límites

### Semana 4: Redes

- Bridge network
- Host network
- DNS interno
- Port mapping

### Semana 5: Volúmenes

- Tipos de volúmenes
- Persistencia de datos
- Backup y restore
- tmpfs mounts

### Semana 6: Compose Básico

- docker-compose.yml
- Servicios múltiples
- Dependencias
- Override files

### Semana 7: Compose Avanzado

- Profiles
- Extends y anchors
- Healthchecks
- Secrets y configs

### Semana 8: Seguridad y Producción

- Usuarios no-root
- Escaneo de vulnerabilidades
- Buenas prácticas de seguridad
- Introducción a CI/CD

---

## ⏱️ Distribución del Tiempo Semanal

| Actividad     | Tiempo      |
| ------------- | ----------- |
| 📖 Teoría     | 1.5 horas   |
| 💻 Ejercicios | 2.5 horas   |
| 🚀 Proyecto   | 1.5 horas   |
| 📚 Recursos   | 0.5 horas   |
| **Total**     | **6 horas** |

---

## 🏆 Sistema de Evaluación

| Evidencia       | Peso | Descripción                              |
| --------------- | ---- | ---------------------------------------- |
| 🧠 Conocimiento | 30%  | Quiz teórico (≥70% para aprobar)         |
| 💪 Desempeño    | 40%  | Ejercicios completados correctamente     |
| 📦 Producto     | 30%  | Proyecto semanal funcional y documentado |

---

## 💡 Tips para Copilot

- Cuando generes código, **siempre** incluir comentarios en español
- Para Dockerfiles, **priorizar** seguridad y optimización
- En ejercicios, **incluir** código starter con `# TODO:` markers
- Para proyectos, **proporcionar** estructura `starter/` y `solution/`
- En teoría, **usar** analogías para conceptos complejos
- **Evitar** usar `latest` como tag de imagen
- **Preferir** Alpine o Slim como imágenes base
- **Incluir** `.dockerignore` en todos los ejemplos de build

---

## � Cheat Sheet

### Dockerfile - Instrucciones Principales

| Instrucción   | Descripción              | Ejemplo                                     |
| ------------- | ------------------------ | ------------------------------------------- |
| `FROM`        | Imagen base              | `FROM node:20-alpine`                       |
| `WORKDIR`     | Directorio de trabajo    | `WORKDIR /app`                              |
| `COPY`        | Copiar archivos          | `COPY package*.json ./`                     |
| `ADD`         | Copiar + extraer/URL     | `ADD app.tar.gz /app`                       |
| `RUN`         | Ejecutar comando (build) | `RUN npm install`                           |
| `CMD`         | Comando por defecto      | `CMD ["node", "app.js"]`                    |
| `ENTRYPOINT`  | Ejecutable principal     | `ENTRYPOINT ["python"]`                     |
| `ENV`         | Variable de entorno      | `ENV NODE_ENV=production`                   |
| `ARG`         | Argumento de build       | `ARG VERSION=1.0`                           |
| `EXPOSE`      | Puerto expuesto          | `EXPOSE 3000`                               |
| `VOLUME`      | Punto de montaje         | `VOLUME /data`                              |
| `USER`        | Usuario de ejecución     | `USER appuser`                              |
| `LABEL`       | Metadata                 | `LABEL version="1.0"`                       |
| `HEALTHCHECK` | Verificación de salud    | `HEALTHCHECK CMD curl -f http://localhost/` |

### Docker CLI - Comandos Esenciales

| Comando                                    | Descripción                    |
| ------------------------------------------ | ------------------------------ |
| `docker run -d --name c1 -p 8080:80 nginx` | Ejecutar contenedor            |
| `docker ps -a`                             | Listar todos los contenedores  |
| `docker images`                            | Listar imágenes                |
| `docker build -t app:v1 .`                 | Construir imagen               |
| `docker exec -it c1 /bin/sh`               | Ejecutar comando en contenedor |
| `docker logs -f c1`                        | Ver logs en tiempo real        |
| `docker stop c1 && docker rm c1`           | Detener y eliminar             |
| `docker system prune -a`                   | Limpiar recursos no usados     |

### Docker Compose - Comandos

| Comando                           | Descripción                     |
| --------------------------------- | ------------------------------- |
| `docker compose up -d`            | Iniciar servicios               |
| `docker compose down -v`          | Detener y eliminar volúmenes    |
| `docker compose logs -f`          | Ver logs de todos los servicios |
| `docker compose ps`               | Estado de servicios             |
| `docker compose exec app sh`      | Shell en servicio               |
| `docker compose build --no-cache` | Reconstruir sin caché           |

### Volúmenes y Redes

| Comando                          | Descripción               |
| -------------------------------- | ------------------------- |
| `docker volume create vol1`      | Crear volumen             |
| `docker volume ls`               | Listar volúmenes          |
| `docker network create net1`     | Crear red                 |
| `docker network connect net1 c1` | Conectar contenedor a red |
| `-v $(pwd):/app`                 | Bind mount                |
| `-v vol1:/data`                  | Named volume              |

### Flags Comunes

| Flag           | Descripción                     |
| -------------- | ------------------------------- |
| `-d`           | Modo detached (background)      |
| `-it`          | Interactivo + TTY               |
| `-p 8080:80`   | Mapeo de puertos host:container |
| `-v`           | Montar volumen                  |
| `-e VAR=value` | Variable de entorno             |
| `--name`       | Nombre del contenedor           |
| `--rm`         | Eliminar al detener             |
| `--network`    | Red a usar                      |
| `-f`           | Especificar archivo             |

---

## �🔗 Referencias

- [Docker Documentation](https://docs.docker.com/)
- [Docker Hub](https://hub.docker.com/)
- [Dockerfile Best Practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- [Docker Compose Specification](https://docs.docker.com/compose/compose-file/)
- [Docker Security](https://docs.docker.com/engine/security/)

---

## 📞 Soporte

- 💬 **Discussions**: GitHub Discussions
- 🐛 **Issues**: GitHub Issues

---

> **Nota**: Este archivo es leído por GitHub Copilot para contextualizar sus respuestas. Mantenerlo actualizado mejora la calidad de las sugerencias.
