<p align="center">
  <img src="assets/docker-bootcamp-banner.svg" alt="Bootcamp Docker Zero to Hero" width="100%">
</p>

<p align="center">
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="License MIT"></a>
  <a href="#"><img src="https://img.shields.io/badge/semanas-8-yellow.svg" alt="8 Semanas"></a>
  <a href="#"><img src="https://img.shields.io/badge/horas-48-orange.svg" alt="48 Horas"></a>
  <a href="#"><img src="https://img.shields.io/badge/Docker-27+-2496ED?logo=docker&logoColor=white" alt="Docker 27+"></a>
  <a href="CONTRIBUTING.md"><img src="https://img.shields.io/badge/PRs-Welcome-brightgreen?style=flat-square" alt="PRs Welcome"></a>
</p>

<p align="center">
  <a href="README-EN.md"><img src="https://img.shields.io/badge/🇺🇸_English-0969DA?style=for-the-badge&logoColor=white" alt="English Version"></a>
</p>

---

## 📋 Descripción

**Bootcamp Docker Zero to Hero** es un programa de formación intensiva de **8 semanas** diseñado para llevarte desde los conceptos básicos de contenedores hasta el despliegue de aplicaciones en producción con Docker.

Este bootcamp es parte de la serie **Zero to Hero** y sirve como preparación ideal para el siguiente nivel: **Kubernetes**.

### 🎯 Objetivos

Al finalizar el bootcamp, los estudiantes serán capaces de:

- ✅ Comprender la diferencia entre contenedores y máquinas virtuales
- ✅ Crear y optimizar imágenes Docker con Dockerfile
- ✅ Gestionar el ciclo de vida completo de contenedores
- ✅ Configurar redes para comunicación entre contenedores
- ✅ Implementar persistencia de datos con volúmenes
- ✅ Orquestar aplicaciones multi-contenedor con Docker Compose
- ✅ Aplicar buenas prácticas de seguridad en contenedores
- ✅ Preparar aplicaciones para entornos de producción
- ✅ Integrar Docker en flujos de CI/CD básicos

---

## 🗓️ Estructura del Bootcamp

|      Etapa       | Semanas | Horas | Temas Principales                                    |
| :--------------: | :-----: | :---: | ---------------------------------------------------- |
| **Fundamentos**  |   1-2   |  12h  | Conceptos básicos, instalación, Dockerfile, imágenes |
|   **Gestión**    |   3-4   |  12h  | Contenedores, ciclo de vida, redes, comunicación     |
| **Persistencia** |    5    |  6h   | Volúmenes, bind mounts, backups                      |
| **Orquestación** |   6-7   |  12h  | Docker Compose básico y avanzado                     |
|  **Producción**  |    8    |  6h   | Seguridad, buenas prácticas, CI/CD                   |

**Total: 8 semanas** | **48 horas** de formación intensiva

---

## 📚 Contenido por Semana

Cada semana incluye:

```
bootcamp/week-XX/
├── README.md                 # Descripción y objetivos
├── rubrica-evaluacion.md     # Criterios de evaluación
├── 0-assets/                 # Imágenes y diagramas
├── 1-teoria/                 # Material teórico
├── 2-ejercicios/             # Ejercicios guiados
├── 3-proyecto/               # Proyecto semanal
├── 4-recursos/               # Recursos adicionales
│   ├── ebooks-free/
│   ├── videografia/
│   └── webgrafia/
└── 5-glosario/               # Términos clave
```

### 🔑 Componentes Clave

| Semana | Tema                         | Descripción                                                       |
| ------ | ---------------------------- | ----------------------------------------------------------------- |
| 01     | **Fundamentos de Docker**    | Conceptos básicos, arquitectura, instalación, comandos esenciales |
| 02     | **Imágenes Docker**          | Dockerfile, capas, construcción, optimización, multi-stage builds |
| 03     | **Gestión de Contenedores**  | Ciclo de vida, logs, exec, variables de entorno, recursos         |
| 04     | **Redes en Docker**          | Bridge, host, overlay, DNS interno, port mapping                  |
| 05     | **Volúmenes y Persistencia** | Named volumes, bind mounts, tmpfs, backups y restore              |
| 06     | **Docker Compose Básico**    | Servicios múltiples, dependencias, override files                 |
| 07     | **Docker Compose Avanzado**  | Profiles, extends, healthchecks, secrets, configs                 |
| 08     | **Seguridad y Producción**   | Usuarios no-root, escaneo de vulnerabilidades, CI/CD básico       |

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

## 🚀 Inicio Rápido

### Prerrequisitos

- **Docker** y **Docker Compose** instalados
- **Git** para control de versiones
- **VS Code** (recomendado) con extensiones incluidas
- Navegador moderno (Chrome, Firefox, Edge)

### 1. Clonar el Repositorio

```bash
git clone https://github.com/epti-dev/bc-docker.git
cd bc-docker
```

### 2. Instalar Extensiones de VS Code

```bash
# Abrir en VS Code
code .

# Las extensiones recomendadas aparecerán automáticamente
# O ejecutar: Ctrl+Shift+P → "Extensions: Show Recommended Extensions"
```

### 3. Verificar Instalación de Docker

```bash
# Verificar Docker
docker --version
docker compose version

# Ejecutar contenedor de prueba
docker run hello-world
```

### 4. Navegar a la Semana Actual

```bash
cd bootcamp/week-01-fundamentos_docker
```

### 5. Seguir las Instrucciones

Cada semana contiene un `README.md` con instrucciones detalladas.

---

## 📊 Metodología de Aprendizaje

### ⏱️ Distribución del Tiempo Semanal (6 horas)

| Actividad     | Tiempo | Descripción                 |
| ------------- | ------ | --------------------------- |
| 📖 Teoría     | 1.5h   | Conceptos y fundamentos     |
| 💻 Ejercicios | 2.5h   | Práctica guiada             |
| 🚀 Proyecto   | 1.5h   | Aplicación de conocimientos |
| 📚 Recursos   | 0.5h   | Material complementario     |

### 🏆 Sistema de Evaluación

| Evidencia       | Peso | Descripción                              |
| --------------- | ---- | ---------------------------------------- |
| 🧠 Conocimiento | 30%  | Quiz teórico (≥70% para aprobar)         |
| 💪 Desempeño    | 40%  | Ejercicios completados correctamente     |
| 📦 Producto     | 30%  | Proyecto semanal funcional y documentado |

---

## 🤝 Contribuir

¡Las contribuciones son bienvenidas! Este es un proyecto educativo de código abierto.

### Cómo Contribuir

1. Lee la [Guía de Contribución](CONTRIBUTING.md)
2. Revisa el [Código de Conducta](CODE_OF_CONDUCT.md)
3. Fork del repositorio
4. Crea tu rama (`git checkout -b feature/nueva-funcionalidad`)
5. Commit con [Conventional Commits](https://www.conventionalcommits.org/) (`git commit -m 'feat: add new exercise'`)
6. Push a la rama (`git push origin feature/nueva-funcionalidad`)
7. Abre un Pull Request

### 📋 Áreas de Contribución

- ✨ Ejercicios adicionales
- 📚 Mejoras en documentación
- 🐛 Corrección de errores
- 🎨 Recursos visuales (diagramas SVG)
- 🌐 Traducciones
- 📹 Videos tutoriales

---

## 📞 Soporte

- 💬 **Discussions**: [GitHub Discussions](https://github.com/epti-dev/bc-docker/discussions)
- 🐛 **Issues**: [GitHub Issues](https://github.com/epti-dev/bc-docker/issues)

---

## 📄 Licencia

Este proyecto está licenciado bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para más detalles.

---

## 🏆 Agradecimientos

- [Docker](https://docker.com/) - Por revolucionar el despliegue de aplicaciones
- [Docker Hub](https://hub.docker.com/) - Por el registro de imágenes
- [Play with Docker](https://labs.play-with-docker.com/) - Por el entorno de práctica online
- Comunidad Docker - Por recursos y ejemplos
- Todos los contribuidores

---

## 📚 Documentación Adicional

- [🤖 Instrucciones de Copilot](.github/copilot-instructions.md)
- [🤝 Guía de Contribución](CONTRIBUTING.md)
- [📜 Código de Conducta](CODE_OF_CONDUCT.md)
- [🔒 Política de Seguridad](SECURITY.md)

---

## 🚀 ¿Qué sigue?

Después de completar este bootcamp, estarás preparado para:

- 🎓 **Bootcamp Kubernetes** - Orquestación de contenedores a escala
- ☁️ Despliegue en cloud (AWS, GCP, Azure)
- 🔄 Pipelines de CI/CD avanzados

---

<p align="center">
  <strong>🐳 Bootcamp Docker - Zero to Hero</strong><br>
  <em>De cero a experto en contenedores en 2 meses</em>
</p>

<p align="center">
  <a href="bootcamp/week-01-fundamentos_docker">Comenzar Semana 1</a> •
  <a href="docs">Ver Documentación</a> •
  <a href="https://github.com/epti-dev/bc-docker/issues">Reportar Issue</a> •
  <a href="CONTRIBUTING.md">Contribuir</a>
</p>

<p align="center">
  Hecho con ❤️ para la comunidad de desarrolladores
</p>
