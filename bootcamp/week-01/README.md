# 🐳 Semana 01: Fundamentos de Docker

<p align="center">
  <img src="0-assets/week-01-header.svg" alt="Semana 01 - Fundamentos de Docker" width="600">
</p>

## 🎯 Objetivos de Aprendizaje

Al finalizar esta semana, serás capaz de:

- ✅ Comprender qué es la contenedorización y sus beneficios
- ✅ Diferenciar contenedores de máquinas virtuales
- ✅ Entender la arquitectura de Docker
- ✅ Instalar y configurar Docker en tu sistema
- ✅ Ejecutar comandos esenciales de Docker
- ✅ Gestionar contenedores e imágenes básicas

---

## 📚 Requisitos Previos

Antes de comenzar esta semana, asegúrate de tener:

- ✅ Conocimientos básicos de línea de comandos (terminal)
- ✅ Un computador con Windows 10+, macOS 12+ o Linux
- ✅ Mínimo 4 GB de RAM disponible
- ✅ Conexión a internet

---

## 🗂️ Estructura de la Semana

```
week-01/
├── README.md                    # Este archivo
├── rubrica-evaluacion.md        # Criterios de evaluación
├── 0-assets/                    # Recursos visuales
│   └── week-01-header.svg
├── 1-teoria/                    # Material teórico
│   ├── 01-introduccion-contenedores.md
│   ├── 02-docker-vs-vm.md
│   ├── 03-arquitectura-docker.md
│   ├── 04-instalacion.md
│   └── 05-comandos-esenciales.md
├── 2-ejercicios/                # Ejercicios guiados
│   ├── 01-primer-contenedor/
│   ├── 02-explorando-imagenes/
│   └── 03-gestionando-contenedores/
├── 3-proyecto/                  # Proyecto semanal
│   ├── README.md
│   ├── starter/
│   └── solution/
├── 4-recursos/                  # Material adicional
│   ├── ebooks-free/
│   ├── videografia/
│   └── webgrafia/
└── 5-glosario/                  # Términos clave
    └── README.md
```

---

## 📝 Contenidos

### 📚 Teoría

| #   | Tema                                | Duración | Archivo                                                                     |
| --- | ----------------------------------- | -------- | --------------------------------------------------------------------------- |
| 1   | Introducción a la Contenedorización | 20 min   | [01-introduccion-contenedores.md](1-teoria/01-introduccion-contenedores.md) |
| 2   | Docker vs Máquinas Virtuales        | 25 min   | [02-docker-vs-vm.md](1-teoria/02-docker-vs-vm.md)                           |
| 3   | Arquitectura de Docker              | 25 min   | [03-arquitectura-docker.md](1-teoria/03-arquitectura-docker.md)             |
| 4   | Instalación de Docker               | 20 min   | [04-instalacion.md](1-teoria/04-instalacion.md)                             |
| 5   | Comandos Esenciales                 | 30 min   | [05-comandos-esenciales.md](1-teoria/05-comandos-esenciales.md)             |

### 💻 Ejercicios Guiados

| #   | Ejercicio                | Duración | Carpeta                                                                   |
| --- | ------------------------ | -------- | ------------------------------------------------------------------------- |
| 1   | Primer Contenedor        | 30 min   | [01-primer-contenedor/](2-ejercicios/01-primer-contenedor/)               |
| 2   | Explorando Imágenes      | 35 min   | [02-explorando-imagenes/](2-ejercicios/02-explorando-imagenes/)           |
| 3   | Gestionando Contenedores | 40 min   | [03-gestionando-contenedores/](2-ejercicios/03-gestionando-contenedores/) |

### 🚀 Proyecto Semanal

**Entorno de Desarrollo Multi-Servicio**

Crear un entorno de desarrollo local con nginx, PostgreSQL, Redis y Adminer comunicándose en una red Docker.

📁 [Ver instrucciones del proyecto](3-proyecto/README.md)

---

## ⏱️ Distribución del Tiempo

| Actividad     | Tiempo      |
| ------------- | ----------- |
| 📖 Teoría     | 2 horas     |
| 💻 Ejercicios | 1.75 horas  |
| 🚀 Proyecto   | 1.5 horas   |
| 📚 Recursos   | 0.75 horas  |
| **Total**     | **6 horas** |

---

## 📌 Entregables

- [ ] Docker instalado y funcionando
- [ ] Ejercicios 01, 02 y 03 completados
- [ ] Proyecto con 4 contenedores funcionando
- [ ] Capturas de pantalla del proyecto
- [ ] Quiz teórico aprobado (≥70%)

---

## 🧪 Criterios de Evaluación

| Evidencia       | Peso | Criterio                             |
| --------------- | ---- | ------------------------------------ |
| 🧠 Conocimiento | 30%  | Quiz teórico aprobado (≥70%)         |
| 💪 Desempeño    | 40%  | Ejercicios completados correctamente |
| 📦 Producto     | 30%  | Proyecto funcional y documentado     |

📋 [Ver rúbrica detallada](rubrica-evaluacion.md)

---

## 💡 Conceptos Clave

- **Contenedor**: Proceso aislado con su propio filesystem
- **Imagen**: Plantilla de solo lectura para crear contenedores
- **Docker Engine**: Motor que ejecuta los contenedores
- **Docker Hub**: Registry público de imágenes
- **Namespaces**: Aislamiento de procesos, red, filesystem
- **cgroups**: Control de recursos (CPU, memoria)

---

## 🔗 Navegación

| 🏠 Inicio                   | Siguiente ➡️                      |
| --------------------------- | --------------------------------- |
| [Bootcamp](../../README.md) | [Semana 02](../week-02/README.md) |

---

## 📚 Recursos Adicionales

- [Docker Documentation](https://docs.docker.com/)
- [Docker Get Started](https://docs.docker.com/get-started/)
- [Play with Docker](https://labs.play-with-docker.com/)
- [Docker Hub](https://hub.docker.com/)
