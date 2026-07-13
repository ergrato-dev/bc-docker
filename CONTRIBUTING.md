# 🤝 Guía de Contribución

¡Gracias por tu interés en contribuir al **Bootcamp Docker Zero to Hero**! 🐳

Este documento proporciona las pautas para contribuir al proyecto.

---

## 📋 Tabla de Contenidos

- [Código de Conducta](#código-de-conducta)
- [¿Cómo Puedo Contribuir?](#cómo-puedo-contribuir)
- [Configuración del Entorno](#configuración-del-entorno)
- [Estilo y Convenciones](#estilo-y-convenciones)
- [Proceso de Pull Request](#proceso-de-pull-request)
- [Estructura del Proyecto](#estructura-del-proyecto)

---

## 📜 Código de Conducta

Este proyecto adopta el [Código de Conducta](CODE_OF_CONDUCT.md). Al participar, se espera que respetes este código.

---

## 🎯 ¿Cómo Puedo Contribuir?

### 🐛 Reportando Bugs

- Usa la plantilla de [Bug Report](.github/ISSUE_TEMPLATE/bug_report.md)
- Incluye pasos para reproducir el problema
- Especifica tu entorno (OS, versión de Docker)

### ✨ Sugiriendo Mejoras

- Usa la plantilla de [Feature Request](.github/ISSUE_TEMPLATE/feature_request.md)
- Explica el beneficio para los estudiantes
- Proporciona ejemplos si es posible

### 📝 Mejorando Documentación

- Correcciones de typos y gramática
- Mejoras en explicaciones
- Nuevos ejemplos o diagramas
- Traducción de contenido

### 💻 Contribuyendo Código/Contenido

- Nuevos ejercicios
- Mejoras en Dockerfiles de ejemplo
- Nuevos recursos o referencias
- Mejoras en proyectos semanales

---

## ⚙️ Configuración del Entorno

### Requisitos

```bash
# Verificar Docker
docker --version  # 27+

# Verificar Docker Compose
docker compose version  # 2.31+

# Verificar Git
git --version  # 2.40+
```

### Fork y Clone

```bash
# 1. Fork el repositorio en GitHub

# 2. Clone tu fork
git clone https://github.com/TU_USUARIO/bc-docker.git
cd bc-docker

# 3. Añade el upstream
git remote add upstream https://github.com/ergrato-dev/bc-docker.git

# 4. Crea una rama para tu contribución
git checkout -b feature/mi-contribucion
```

---

## 🎨 Estilo y Convenciones

### Markdown

````markdown
# Título Principal (solo uno por archivo)

## Sección

### Subsección

- Lista con guiones
- Usar emojis con moderación 🐳

**Negrita** para énfasis
`código inline` para comandos

​```dockerfile

# Bloques de código con syntax highlighting

FROM alpine:3.21
​```
````

### Dockerfiles

```dockerfile
# ✅ Correcto
FROM alpine:3.21
LABEL maintainer="email@example.com"

# Comentarios en español
RUN apk add --no-cache curl

USER appuser
```

```dockerfile
# ❌ Incorrecto
FROM alpine  # Sin tag específico
RUN apt-get update  # Comando incorrecto para Alpine
```

### Docker Compose

```yaml
# ✅ Usar la especificación actual (sin version)
services:
  app:
    image: nginx:alpine
    container_name: my-app
```

### Commits

Usa [Conventional Commits](https://www.conventionalcommits.org/):

```bash
# Formato
<tipo>(<alcance>): <descripción>

# Ejemplos
feat(week-03): añadir ejercicio de logs
fix(week-02): corregir typo en dockerfile
docs(readme): actualizar requisitos
style(week-05): mejorar formato de tablas
```

**Tipos permitidos:**

- `feat`: Nueva característica o contenido
- `fix`: Corrección de error
- `docs`: Documentación
- `style`: Formato (sin cambio de contenido)
- `refactor`: Reestructuración de contenido
- `chore`: Tareas de mantenimiento

---

## 🔄 Proceso de Pull Request

### 1. Antes de Empezar

```bash
# Sincroniza con upstream
git fetch upstream
git checkout main
git merge upstream/main
```

### 2. Crea tu Rama

```bash
git checkout -b tipo/descripcion-corta
# Ejemplos:
# feat/week-04-ejercicio-redes
# fix/week-02-dockerfile-typo
# docs/readme-badges
```

### 3. Realiza tus Cambios

- Sigue las convenciones de estilo
- Prueba los comandos Docker incluidos
- Actualiza documentación si es necesario

### 4. Commit y Push

```bash
git add .
git commit -m "feat(week-04): añadir ejercicio de bridge network"
git push origin feat/week-04-ejercicio-redes
```

### 5. Crea el Pull Request

- Usa la plantilla de PR
- Enlaza el issue relacionado
- Espera la revisión

### 6. Revisión

- Responde a los comentarios
- Realiza los cambios solicitados
- El PR será mergeado cuando esté aprobado

---

## 📁 Estructura del Proyecto

```
bc-docker/
├── .github/
│   ├── ISSUE_TEMPLATE/
│   ├── PULL_REQUEST_TEMPLATE.md
│   └── copilot-instructions.md
├── .vscode/
├── assets/                     # Assets globales
├── docs/                       # Documentación general
├── scripts/                    # Scripts de utilidad
├── bootcamp/
│   └── week-XX/
│       ├── README.md           # Descripción de la semana
│       ├── rubrica-evaluacion.md
│       ├── 0-assets/           # SVGs y diagramas
│       ├── 1-teoria/           # Material teórico (.md)
│       ├── 2-ejercicios/       # Ejercicios guiados
│       ├── 3-proyecto/         # Proyecto semanal
│       │   ├── README.md
│       │   ├── starter/        # Código inicial (opcional, cuando el proyecto lo requiera)
│       │   └── solution/       # Solución (opcional, no versionada — ver .gitignore)
│       ├── 4-recursos/         # Curados por semana; puede estar vacío si aún no hay contenido
│       │   ├── ebooks-free/
│       │   ├── videografia/
│       │   └── webgrafia/
│       └── 5-glosario/
├── CONTRIBUTING.md
├── CODE_OF_CONDUCT.md
├── LICENSE
├── README.md
└── README-EN.md
```

---

## ❓ ¿Preguntas?

- 💬 Abre una [Discussion](https://github.com/ergrato-dev/bc-docker/discussions)
- 🐛 Reporta un [Issue](https://github.com/ergrato-dev/bc-docker/issues)

---

¡Gracias por contribuir! 🐳❤️
