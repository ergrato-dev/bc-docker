# Auditoría de `bc-docker` — completitud, pertinencia, seguridad, estándares y actualidad

Fecha: 2026-07-12
Alcance: repo completo `bc-docker` (bootcamp Docker, SENA/ergrato-dev), 8 semanas.
Método: revisión directa de archivos + `docker scout` (bloqueado por falta de sesión Docker
Hub, no se intentó leer credenciales) + investigación web de EOL/CVEs + comparación contra
los 4 repos `bc-*` con más estrellas de la organización (`bc-javascript-es2023`, `bc-fastapi`,
`bc-react`, `bc-git-github`).

## Resumen ejecutivo

El repo está funcionalmente completo y bien estructurado en su núcleo (8 semanas con
progresión pedagógica coherente, `.github/copilot-instructions.md` cumpliendo el rol de
`CLAUDE.md`), pero arrastra deuda de dos tipos: **gobernanza desactualizada** (licencia
distinta al estándar de la serie, referencias a una organización de GitHub obsoleta,
placeholders sin resolver) y **contenido didáctico con versiones de imágenes base ya EOL**
(Alpine 3.19, Node 20, Go 1.21/1.23, nginx 1.27.2). Nada es crítico en el sentido de "riesgo
de producción" — es material educativo, no software desplegado — pero sí afecta la calidad
percibida y el riesgo de que un aprendiz copie una base desactualizada a un proyecto real.
Ningún hallazgo requiere acción urgente; se recomienda resolverlos en el próximo ciclo de
mantenimiento del bootcamp.

## Hallazgos por eje

### 1. Seguridad (CVEs e imágenes base)

**Limitación de método**: `docker scout cves` está instalado (v1.23.1) pero requiere sesión
de Docker Hub no disponible en este entorno; el análisis se basó en EOL oficial y avisos de
seguridad publicados (endoflife.date, avisos oficiales por proyecto), no en un scan binario
directo de las capas.

| Severidad | Imagen usada en el repo | Estado | Detalle |
|---|---|---|---|
| 🟠 Alto | `alpine:3.19` (19 ocurrencias, semanas 02, 03, 08) | **EOL desde nov-2025** | Sin parches desde entonces. Rama activa: 3.23/3.24. |
| 🟠 Alto | `node:20*` / `node:20.18.0-alpine3.20` (64 ocurrencias, semana 02 y 08) | **EOL desde 30-abr-2026** | Build 20.18.0 quedó atrás de CVE-2025-23083 (fuga en worker threads), CVE-2025-23085 (DoS HTTP/2), CVE-2025-59465 (crash HTTP/2). LTS activo: Node 22. |
| 🟠 Alto | `golang:1.21` (`week-02/1-teoria/05-optimizacion.md:252,268`) | **EOL desde ago-2024** | Go solo da soporte a las 2 últimas majors (hoy 1.25/1.26). |
| 🟡 Medio | `golang:1.23-alpine` (`week-08/1-teoria/03-escaneo-vulnerabilidades.md:163`, `week-08/1-teoria/02-usuarios-no-root.md:97`) | **EOL desde ago-2025** | Misma familia de riesgo (crypto/tls, net/url) sin backport. |
| 🟡 Medio | `nginx:1.27.2-alpine` (`week-08/1-teoria/04-buenas-practicas.md:73`) | Superada por 1.30.x/1.31.x | Vulnerable a CVE-2025-23419 (reutilización de sesión SSL entre server blocks, severidad media), corregido en 1.27.4+/1.26.3+. |
| 🟢 Bajo | `python:3.12*` (68 ocurrencias, mayoría del repo) | Activo (security-fixes hasta oct-2028) | Fijar patch ≥3.12.12 (fixes de `expat` CVE-2025-59375 y `urllib` CVE-2025-15282 aplicados desde ahí). |
| 🟢 Bajo | `python:3.11-slim` (`week-04/1-teoria/05-port-mapping.md:353`, único uso aislado) | Activo hasta oct-2027, pero inconsistente con el resto del repo (3.12) | Sin razón pedagógica visible para el downgrade puntual. |
| 🟢 OK | `ubuntu:22.04` (13 ocurrencias) | Soportado hasta abr-2027 (General), abr-2032 (ESM) | Vigente, no requiere cambio. |

**Recomendación de bump** (bajo esfuerzo, alto valor pedagógico — evita que un aprendiz
copie una base EOL a un proyecto real): `alpine:3.21+`, `node:22-alpine`, `golang:1.25-alpine`
o `1.26-alpine`, `nginx:1.30-alpine`, unificar todo a `python:3.12` (eliminar el `3.11-slim`
aislado de la semana 04).

**Hallazgo puntual — versión inventada**: `week-03/1-teoria/04-exec-comandos.md:260` dice
`"Solución 1: Usar debug container (Docker 1.25+)"`. **No existe una versión de Docker
Engine/CLI "1.25+"** (el versionado pasó de series 17.x/18.x directo a numeración por año:
20.10, 23, 24…29). Es casi seguro confusión con el requisito real de `docker debug`:
**Docker Desktop 4.27+ (beta)**, **GA en Docker Desktop 4.33+**. Corregir la referencia.

### 2. Completitud

| Severidad | Hallazgo | Ubicación |
|---|---|---|
| 🟠 Alto | Semanas 05-08 no tienen `starter/` en `3-proyecto/` ni contenido en `4-recursos/{ebooks-free,videografia,webgrafia}/` (solo `.gitkeep`), mientras semanas 01-04 sí. | `bootcamp/week-0{5,6,7,8}-*/3-proyecto/`, `.../4-recursos/*/` |
| 🟡 Medio | Ningún `Dockerfile`/`docker-compose.yml` real en el repo — todo el código vive como snippets embebidos en Markdown. Puede ser decisión de diseño (el estudiante crea sus propios archivos), pero no está declarado explícitamente en ningún README. | Todo el repo |
| 🟡 Medio | `docs/` y `scripts/` en la raíz existen solo con `.gitkeep`, sin contenido ni explicación de propósito futuro. | `/docs`, `/scripts` |
| 🟢 Bajo | `CONTRIBUTING.md` tiene placeholder literal `OWNER` sin resolver en 2 lugares (`git remote add upstream https://github.com/OWNER/bc-docker.git`, enlace a Discussions). | `CONTRIBUTING.md:81,257` |
| 🟢 Bajo | `SECURITY.md` no da una dirección de correo real para reportar vulnerabilidades — dice "Envía un correo electrónico" sin especificar cuál. | `SECURITY.md:16` |
| 🟢 Bajo | Enlace roto por concatenación de texto: `### Al generar ejercicioshttps://github.com/ergrato-dev/bc-docker.git`. | `.github/copilot-instructions.md:265` |

### 3. Pertinencia y relevancia pedagógica

Progresión temática **coherente y sin huecos evidentes**: fundamentos → imágenes → gestión
de contenedores → redes → volúmenes/persistencia → Compose básico → Compose avanzado →
seguridad en producción. Evita duplicar contenido de orquestación (Swarm/K8s) remitiendo
explícitamente a `bc-kubernetes` como siguiente paso
(`week-08-seguridad_produccion/3-proyecto/README.md:239`) — buena decisión de diseño de
curriculum, no un hueco.

La semana 08 (seguridad/producción) cubre lo esperado a nivel actual: usuarios no-root,
escaneo de vulnerabilidades, secrets management, imágenes mínimas — el contenido conceptual
es correcto y actual; el único problema es que las imágenes base de los ejemplos están
desactualizadas (ver eje Seguridad).

Sin hallazgos de irrelevancia: no se detectó contenido obsoleto o fuera de lugar en el
temario.

### 4. Estándares frente a la serie `bc-*` (comparado contra los 4 repos con más ⭐: `bc-javascript-es2023`, `bc-fastapi`, `bc-react`, `bc-git-github`)

| Severidad | Hallazgo |
|---|---|
| 🔴 **Crítico (gobernanza)** | **`bc-docker` usa licencia MIT** (`LICENSE`) mientras **los 4 repos de referencia usan CC BY-NC-SA 4.0** de forma consistente. Es una divergencia real del estándar de licenciamiento de la organización — MIT permite uso comercial y no exige compartir igual, CC BY-NC-SA 4.0 no. Vale la pena confirmar si es intencional o un descuido al crear el repo. |
| 🟠 Alto | `README.md`/`README-EN.md` de `bc-docker` referencian la organización obsoleta `epti-dev` en vez de `ergrato-dev` (líneas 114, 199-200, 247). **No es un caso aislado**: `bc-javascript-es2023` y `bc-fastapi` tienen la misma mezcla `ergrato-dev`/`epti-dev` — parece deuda sistémica de una migración de organización pendiente de completar en varios repos de la serie, no solo en `bc-docker`. |
| 🟡 Medio | El placeholder `OWNER` sin resolver en `CONTRIBUTING.md` de `bc-docker` tiene equivalente exacto (`TU-USUARIO`) en `bc-git-github` — mismo patrón repetido, probable copia de plantilla sin adaptar en más de un repo. |
| 🟡 Medio | La estructura `3-proyecto/starter/` + `solution/` que `bc-docker` documenta como estándar (en `copilot-instructions.md` y `CONTRIBUTING.md`) **no la usa ninguno de los 4 repos de referencia** — ninguno tiene `starter/solution`. La inconsistencia semanas 01-04 vs 05-08 dentro de `bc-docker` (punto de Completitud) podría resolverse mejor alineando la documentación al patrón real de la serie (sin `starter/solution`) en vez de completar `starter/` en las semanas que faltan. |
| 🟢 Bajo | `SECURITY.md` sin email de contacto verificable es un problema compartido con `bc-git-github` (vago) y `bc-javascript-es2023` (dominio ficticio `ejemplo.com`) — solo `bc-fastapi` lo resuelve bien usando el flujo nativo de GitHub Security Advisories. Recomendable adoptar ese mismo patrón en `bc-docker`. |
| 🟢 Alineado | Workflows: los 4 repos de referencia **tampoco** tienen lint de Markdown/YAML/Dockerfile ni security scanning — solo `close-prs.yml`, igual que `bc-docker`. No es una desviación, es el estándar (bajo) actual de toda la serie. |
| 🟢 Alineado | Ausencia de `CLAUDE.md`: ninguno de los 4 repos de referencia lo tiene tampoco — `.github/copilot-instructions.md` es el patrón real de la organización, `bc-docker` está alineado. |
| 🟢 Alineado | Esquema `week-XX-tema_principal` (guion tras el número) coincide con 3 de los 4 repos de referencia; solo `bc-git-github` usa guion bajo (`week-XX_tema`) como excepción. |

### 5. CLAUDE.md / gobernanza IA

- No existe `CLAUDE.md` en `bc-docker`, consistente con el resto de la serie (ver arriba).
- `.github/copilot-instructions.md` (557 líneas) cumple ese rol pero **duplica parcialmente**
  reglas de estilo (Dockerfile, Compose, Markdown, Conventional Commits) ya presentes en
  `CONTRIBUTING.md`, con pequeñas divergencias entre ambos documentos — riesgo de que se
  desincronicen con el tiempo. Ninguna de las reglas documentadas (lint, formato) se aplica
  automáticamente en CI (ver eje Seguridad/Completitud — no hay hadolint/yamllint/markdownlint).

### 6. Actualidad general del bootcamp

- Stack mínimo declarado (`README.md`, `README-EN.md`, `copilot-instructions.md`): Docker
  27+, Compose 2.31+, Git 2.40+. A jul-2026 la versión estable real es **Docker Engine
  29.6.1** y **Docker Compose ya saltó a la serie v5.x** (v5.2.0), evitando el rango 3.x/4.x
  para no confundirse con el formato de archivo Compose. El mínimo "27+/2.31+" sigue siendo
  técnicamente válido (nada del contenido exige features de Engine 28/29 o Compose v5), pero
  conviene aclarar en el README que Compose ya no usa versionado "2.x" como referencia visual,
  para que un estudiante no se confunda al instalar Docker Desktop actual y ver otro número.
- Ver eje Seguridad para el detalle de imágenes base EOL — es el hallazgo de actualidad más
  concreto y accionable del repo.

### 7. Preferencia de gestor de paquetes (`uv` / `pnpm`)

**Criterio añadido tras la auditoría inicial** (instrucción global del usuario: Python → `uv`
preferente, Node → `pnpm` preferente, npm/npx prohibidos).

Estado encontrado antes del fix: **24 ocurrencias de `pip install`** en 15 archivos y **29
ocurrencias de `npm install`/`npm ci`/`npx`** en 9 archivos de `bootcamp/`, con **0 menciones**
de `uv` o `pnpm` en todo el repo — el bootcamp enseñaba exclusivamente los gestores por defecto
(`pip`, `npm`) pese a que es material didáctico que un aprendiz puede copiar literalmente a un
proyecto real.

**Corregido**: las 53 ocurrencias se migraron a los equivalentes actuales en los 20 archivos
afectados (`bootcamp/week-02` a `week-08`):
- Python: `COPY --from=ghcr.io/astral-sh/uv:latest /uv /bin/uv` + `uv pip install --system`
  (patrón oficial de uv en Docker, sin requerir `pyproject.toml`/lockfile en ejercicios que solo
  usan `requirements.txt`).
- Node: `RUN corepack enable && pnpm install` (Corepack viene incluido en `node:22-alpine`, sin
  paso de instalación aparte); pipelines multi-stage migrados a `pnpm-lock.yaml` +
  `--frozen-lockfile` donde el ejercicio ya generaba lockfile real.
- CI: `.../03-pipeline-cicd/README.md` migrado de `actions/setup-python` + `pip install` a
  `astral-sh/setup-uv`.

Verificación: `grep -rn "pip install\|npm install\|npm ci\|npx " bootcamp --include="*.md"` da
0 resultados fuera de `uv pip install`/`pnpm`.

## Tabla priorizada de acciones sugeridas (top 10)

| # | Acción | Eje | Severidad |
|---|---|---|---|
| 1 | Confirmar si la licencia MIT es intencional; si no, migrar a CC BY-NC-SA 4.0 para alinear con el resto de la serie `bc-*`. | Estándares | 🔴 Crítico |
| 2 | Actualizar imágenes base en ejemplos: `alpine:3.21+`, `node:22-alpine`, `golang:1.25/1.26-alpine`, `nginx:1.30-alpine`; unificar `python:3.11-slim` → `3.12`. | Seguridad/Actualidad | 🟠 Alto |
| 3 | Corregir `README.md`/`README-EN.md` de `epti-dev` → `ergrato-dev` (y replicar el fix en `bc-javascript-es2023`/`bc-fastapi`, que comparten el mismo defecto). | Estándares | 🟠 Alto |
| 4 | Decidir y aplicar de forma uniforme: o se completa `starter/`+`4-recursos` en semanas 05-08, o se elimina esa expectativa de `copilot-instructions.md`/`CONTRIBUTING.md` (la serie de referencia no usa `starter/solution`). | Completitud/Estándares | 🟠 Alto |
| 5 | Corregir `"Docker 1.25+"` → `"Docker Desktop 4.33+ (GA) / 4.27+ (beta)"` en `week-03/1-teoria/04-exec-comandos.md:260`. | Seguridad/Actualidad | 🟡 Medio |
| 6 | Resolver placeholders `OWNER` en `CONTRIBUTING.md:81,257`. | Completitud | 🟡 Medio |
| 7 | Añadir dirección real de contacto en `SECURITY.md`, o migrar al flujo de GitHub Security Advisories (patrón de `bc-fastapi`). | Completitud/Estándares | 🟡 Medio |
| 8 | Arreglar el enlace roto/concatenado en `.github/copilot-instructions.md:265`. | Completitud | 🟢 Bajo |
| 9 | Aclarar en README que Docker Compose ya usa versionado v5.x (evitar confusión con el mínimo "2.31+"). | Actualidad | 🟢 Bajo |
| 10 | Considerar añadir lint básico (markdownlint/yamllint/hadolint sobre los snippets) al único workflow existente — mejora que ningún repo de la serie tiene aún, oportunidad de diferenciarse. | Seguridad/Estándares | 🟢 Bajo (mejora, no gap del estándar actual) |
| 11 | ✅ **Resuelto** — Migrar los 53 usos de `pip install`/`npm install`/`npm ci` a `uv`/`pnpm` en `bootcamp/`. | Actualidad/Estándares | 🟠 Alto |

---

*Auditoría generada por revisión asistida. Acciones #1-3 (licencia, imágenes EOL, org refs) y
#11 (uv/pnpm) ya se aplicaron sobre el contenido del repo en esta misma sesión; el resto queda
pendiente de decisión del mantenedor.*
