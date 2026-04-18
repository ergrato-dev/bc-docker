# 📖 Glosario — Semana 08: Seguridad y Producción

Términos clave de esta semana y del bootcamp completo, ordenados alfabéticamente.

---

## A

**Attack Surface (Superficie de Ataque)**
El conjunto total de puntos de entrada que un atacante puede explotar en un sistema. En Docker: incluye paquetes del SO en la imagen, puertos expuestos, capacidades Linux concedidas, y procesos que corren como root.

---

## C

**`cap_add` / `cap_drop`**
Opciones de Compose/Docker para añadir o eliminar capacidades de Linux de un contenedor. La práctica recomendada es `cap_drop: [ALL]` y añadir solo las capacidades mínimas necesarias.

**Capacidades Linux (Linux Capabilities)**
Subdivisiones del privilegio de root. En lugar de ser root total, un proceso puede tener capacidades específicas: `NET_BIND_SERVICE` (puertos <1024), `SYS_ADMIN` (administración del sistema), etc. Los contenedores reciben ~14 por defecto.

**CD (Continuous Delivery / Deployment)**
Automatización del proceso de entrega o despliegue de software. En Docker: automatizar el push de imágenes al registry y el despliegue en servidores tras pasar el pipeline.

**CI (Continuous Integration)**
Automatización de la integración de cambios de código: construir, testear y validar cada push al repositorio. En Docker: `docker build` + tests + security scan en cada PR.

**CVE (Common Vulnerabilities and Exposures)**
Sistema de identificadores únicos para vulnerabilidades de seguridad conocidas. Ejemplos: `CVE-2024-12345`. Las herramientas de escaneo detectan CVEs en paquetes instalados.

---

## D

**Distroless**
Imágenes de contenedor de Google que no contienen shell, gestor de paquetes ni utilidades del SO. Solo el runtime de la aplicación. Mínima superficie de ataque. Ejemplo: `gcr.io/distroless/python3`.

**Docker Bench for Security**
Herramienta oficial de Docker que audita la configuración del daemon y los contenedores contra el benchmark CIS Docker. Disponible como imagen oficial: `docker/docker-bench-security`.

**`.dockerignore`**
Archivo que lista patrones de archivos y directorios a **excluir** del build context. Crítico para seguridad: evita que `.env`, `secrets/`, `.git` y otras cosas sensibles entren en la imagen.

---

## G

**GitHub Container Registry (GHCR)**
Registry de contenedores integrado en GitHub. Permite almacenar imágenes como `ghcr.io/usuario/repo:tag`. Autenticación con `GITHUB_TOKEN` en GitHub Actions.

**Grype**
Escáner de vulnerabilidades para imágenes y SBOMs de Anchore. Alternativa a Trivy, integrable en CI/CD.

---

## H

**Hardening**
Proceso de fortalecer un sistema reduciendo su superficie de ataque. En Docker: usuario no-root, `read_only`, `cap_drop`, `no-new-privileges`, imágenes mínimas.

---

## L

**Layers (Capas)**
Cada instrucción en un Dockerfile crea una capa inmutable. El orden importa para el cache: lo que cambia frecuentemente va al final. Las capas innecesarias aumentan el tamaño y la superficie de ataque.

---

## M

**Multi-Stage Build**
Técnica de Dockerfile con múltiples `FROM`. Permite separar el stage de build (con compiladores y herramientas) del stage de producción (solo el binario/artifact). Reduce drásticamente el tamaño y las CVEs.

---

## N

**`no-new-privileges`**
Opción `security_opt` que impide que un proceso dentro del contenedor obtenga privilegios adicionales mediante `setuid`, `setgid` o file capabilities. Previene un vector común de escalada de privilegios.

---

## P

**Principio de Mínimo Privilegio**
Conceder a cada proceso, usuario o componente solo los permisos estrictamente necesarios para su función. Base de toda la seguridad en Docker.

---

## R

**`read_only: true`**
Opción de Compose que monta el filesystem del contenedor como solo lectura. Si el contenedor es comprometido, el atacante no puede escribir archivos persistentes en el container layer. Combinado con `tmpfs` para directorios que necesitan escritura.

**Registry (Container Registry)**
Servicio de almacenamiento de imágenes Docker. Ejemplos: Docker Hub, GHCR, AWS ECR, GCR de Google. Las imágenes se identifican como `registry/usuario/nombre:tag`.

---

## S

**SARIF (Static Analysis Results Interchange Format)**
Formato estándar (JSON) para reportar resultados de análisis de seguridad. GitHub Security acepta SARIF para mostrar vulnerabilidades en la pestaña Security del repositorio.

**`scratch`**
Imagen base vacía de Docker. Solo contiene el binario que copias. Usado para aplicaciones Go o C compiladas estáticamente. Superficie de ataque: cero paquetes del SO.

**Severidad (Trivy)**
Clasificación de vulnerabilidades: CRITICAL (explotación remota, datos comprometidos) > HIGH (difícil explotar pero impacto alto) > MEDIUM > LOW > UNKNOWN.

**Docker Scout**
Herramienta de Docker Inc. para análisis de vulnerabilidades. Integrado en Docker Desktop. Ofrece recomendaciones de imágenes base alternativas con menos CVEs.

---

## T

**Tag (de imagen)**
Identificador de versión de una imagen Docker. `latest` es el default pero no recomendado en producción. Usar tags específicos como `3.12.7-slim` o SHA (`@sha256:abc...`) garantiza reproducibilidad.

**Trivy**
Escáner de vulnerabilidades open-source de Aqua Security. Detecta CVEs en paquetes del SO, dependencias de lenguajes, misconfiguraciones en Dockerfiles y secretos hardcodeados.

---

## U

**UID / GID**
User ID y Group ID en sistemas Linux. Los usuarios no-root tienen UID ≥ 1000. En Docker es práctica estándar usar UID 1001 para usuarios de aplicación.

---

## W

**Workflow (GitHub Actions)**
Archivo YAML en `.github/workflows/` que define el pipeline de CI/CD. Se activa por eventos (push, PR, schedule). Contiene jobs con steps que ejecutan acciones.

---

## 📚 Resumen de Herramientas del Bootcamp

| Herramienta          | Semana | Uso                                       |
| -------------------- | ------ | ----------------------------------------- |
| Docker Engine        | 1      | Motor de contenedores                     |
| Dockerfile           | 2      | Definir imágenes                          |
| docker compose       | 6-7    | Orquestar multi-servicio                  |
| Trivy / Docker Scout | 8      | Escaneo de vulnerabilidades               |
| GitHub Actions       | 8      | Pipeline CI/CD                            |
| GHCR                 | 8      | Registry de imágenes                      |

---

*Este glosario complementa la teoría en [1-teoria/](../1-teoria/).*
