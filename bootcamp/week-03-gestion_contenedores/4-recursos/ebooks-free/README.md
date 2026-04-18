# 📖 eBooks y Documentación Gratuita

## Gestión de Contenedores Docker

Recursos de lectura gratuitos para complementar el aprendizaje de la semana.

---

## 📚 Documentación Oficial

### Docker Documentation

| Recurso                  | Descripción                               | Enlace                                                                                  |
| ------------------------ | ----------------------------------------- | --------------------------------------------------------------------------------------- |
| **Container Runtime**    | Documentación del runtime de contenedores | [docs.docker.com/engine](https://docs.docker.com/engine/)                               |
| **docker run reference** | Referencia completa del comando run       | [docker run](https://docs.docker.com/engine/reference/run/)                             |
| **Logging**              | Configuración de logging en Docker        | [Configure logging](https://docs.docker.com/config/containers/logging/)                 |
| **Resource constraints** | Límites de recursos para contenedores     | [Resource constraints](https://docs.docker.com/config/containers/resource_constraints/) |

---

## 📘 Guías y Manuales

### Container Management

| Título                  | Autor/Fuente     | Descripción                                                        |
| ----------------------- | ---------------- | ------------------------------------------------------------------ |
| **Docker Deep Dive**    | Nigel Poulton    | Capítulos sobre gestión de contenedores (versión gratuita parcial) |
| **The Docker Handbook** | freeCodeCamp     | Guía completa gratuita de Docker                                   |
| **Container Training**  | Jérôme Petazzoni | Materiales de entrenamiento open source                            |

### Enlaces de descarga

- [The Docker Handbook - freeCodeCamp](https://www.freecodecamp.org/news/the-docker-handbook/)
- [Container Training Materials](https://container.training/)
- [Docker Curriculum](https://docker-curriculum.com/)

---

## 📄 Cheat Sheets

### Comandos de Gestión

| Recurso                    | Descripción               | Enlace                                                                          |
| -------------------------- | ------------------------- | ------------------------------------------------------------------------------- |
| **Docker CLI Cheat Sheet** | Referencia rápida oficial | [Docker Cheat Sheet](https://docs.docker.com/get-started/docker_cheatsheet.pdf) |
| **Container Commands**     | Comandos de contenedores  | [devhints.io/docker](https://devhints.io/docker)                                |

---

## 📑 Especificaciones Técnicas

### Para lectores avanzados

| Documento            | Descripción                                |
| -------------------- | ------------------------------------------ |
| **OCI Runtime Spec** | Especificación del runtime de contenedores |
| **cgroups v2**       | Documentación de control groups en Linux   |
| **Linux namespaces** | Aislamiento de procesos en Linux           |

### Enlaces

- [OCI Runtime Specification](https://github.com/opencontainers/runtime-spec)
- [cgroups documentation](https://www.kernel.org/doc/Documentation/cgroup-v2.txt)
- [namespaces(7) man page](https://man7.org/linux/man-pages/man7/namespaces.7.html)

---

## 📋 Lecturas Recomendadas por Tema

### Ciclo de Vida de Contenedores

1. [Container lifecycle](https://docs.docker.com/engine/reference/run/#container-identification) - Docker Docs
2. [Understanding Docker container states](https://www.docker.com/blog/understanding-docker-container-states/)

### Logs y Debugging

1. [View container logs](https://docs.docker.com/engine/reference/commandline/logs/) - Docker Docs
2. [Configure logging drivers](https://docs.docker.com/config/containers/logging/configure/)
3. [Debug running containers](https://docs.docker.com/engine/reference/commandline/exec/)

### Variables de Entorno

1. [Environment variables in containers](https://docs.docker.com/engine/reference/run/#env-environment-variables)
2. [12-Factor App: Config](https://12factor.net/config)

### Recursos y Límites

1. [Runtime options with Memory, CPUs](https://docs.docker.com/config/containers/resource_constraints/)
2. [Understanding Docker container memory limits](https://www.docker.com/blog/understanding-docker-container-memory-limits/)

---

## 💾 Cómo Guardar para Lectura Offline

```bash
# Guardar página web como PDF (usando Chrome)
google-chrome --headless --print-to-pdf=docker-docs.pdf https://docs.docker.com/engine/

# O usar wget para descargar documentación
wget -r -l 2 -p -k https://docs.docker.com/engine/reference/run/
```

---

## 🔗 Navegación

| ← Índice de Recursos              | Siguiente →                             |
| --------------------------------- | --------------------------------------- |
| [Volver a Recursos](../README.md) | [Videografía](../videografia/README.md) |
