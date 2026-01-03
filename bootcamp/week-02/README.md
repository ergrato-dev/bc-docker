# 🐳 Semana 02: Imágenes Docker

<p align="center">
  <img src="0-assets/week-02-header.svg" alt="Semana 02 - Imágenes Docker" width="600">
</p>

## 🎯 Objetivos de Aprendizaje

Al finalizar esta semana, serás capaz de:

- ✅ Comprender la estructura y capas de una imagen Docker
- ✅ Escribir Dockerfiles eficientes y optimizados
- ✅ Aplicar multi-stage builds para reducir tamaño
- ✅ Gestionar tags y versiones de imágenes
- ✅ Publicar imágenes en Docker Hub
- ✅ Usar .dockerignore correctamente

---

## 📚 Requisitos Previos

Antes de comenzar esta semana, debes:

- ✅ Completar la Semana 01 (Fundamentos)
- ✅ Tener Docker instalado y funcionando
- ✅ Conocer los comandos básicos de Docker

---

## 🗂️ Estructura de la Semana

```
week-02/
├── README.md                    # Este archivo
├── rubrica-evaluacion.md        # Criterios de evaluación
├── 0-assets/                    # Recursos visuales
│   └── week-02-header.svg
├── 1-teoria/                    # Material teórico
│   ├── 01-anatomia-imagen.md
│   ├── 02-dockerfile-basico.md
│   ├── 03-instrucciones-dockerfile.md
│   ├── 04-multi-stage-builds.md
│   └── 05-optimizacion-capas.md
├── 2-ejercicios/                # Ejercicios guiados
│   ├── 01-primer-dockerfile/
│   ├── 02-multi-stage/
│   └── 03-optimizacion/
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

| #   | Tema                     | Duración | Archivo                                                                   |
| --- | ------------------------ | -------- | ------------------------------------------------------------------------- |
| 1   | Anatomía de una Imagen   | 20 min   | [01-anatomia-imagen.md](1-teoria/01-anatomia-imagen.md)                   |
| 2   | Dockerfile Básico        | 25 min   | [02-dockerfile-basico.md](1-teoria/02-dockerfile-basico.md)               |
| 3   | Instrucciones Dockerfile | 30 min   | [03-instrucciones-dockerfile.md](1-teoria/03-instrucciones-dockerfile.md) |
| 4   | Multi-Stage Builds       | 25 min   | [04-multi-stage-builds.md](1-teoria/04-multi-stage-builds.md)             |
| 5   | Optimización de Capas    | 20 min   | [05-optimizacion-capas.md](1-teoria/05-optimizacion-capas.md)             |

### 💻 Ejercicios Guiados

| #   | Ejercicio                | Duración | Carpeta                                                     |
| --- | ------------------------ | -------- | ----------------------------------------------------------- |
| 1   | Mi Primer Dockerfile     | 45 min   | [01-primer-dockerfile/](2-ejercicios/01-primer-dockerfile/) |
| 2   | Multi-Stage Build        | 50 min   | [02-multi-stage/](2-ejercicios/02-multi-stage/)             |
| 3   | Optimización de Imágenes | 45 min   | [03-optimizacion/](2-ejercicios/03-optimizacion/)           |

### 🚀 Proyecto Semanal

**Aplicación Web Containerizada**

Crear una imagen Docker optimizada para una aplicación web, aplicando multi-stage builds y buenas prácticas.

📁 [Ver instrucciones del proyecto](3-proyecto/README.md)

---

## ⏱️ Distribución del Tiempo

| Actividad     | Tiempo      |
| ------------- | ----------- |
| 📖 Teoría     | 2 horas     |
| 💻 Ejercicios | 2.5 horas   |
| 🚀 Proyecto   | 1.5 horas   |
| **Total**     | **6 horas** |

---

## 📌 Entregables

- [ ] Ejercicios 01, 02 y 03 completados
- [ ] Proyecto semanal funcional
- [ ] Imagen publicada en Docker Hub (opcional)
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

- **Imagen**: Plantilla inmutable para crear contenedores
- **Capa (Layer)**: Cada instrucción del Dockerfile crea una capa
- **Build Context**: Archivos enviados al daemon durante build
- **Multi-Stage Build**: Múltiples FROM para optimizar imagen final
- **Tag**: Identificador de versión de una imagen
- **.dockerignore**: Archivos excluidos del build context

---

## 🔗 Navegación

| ⬅️ Anterior                       | 🏠 Inicio                   | Siguiente ➡️                      |
| --------------------------------- | --------------------------- | --------------------------------- |
| [Semana 01](../week-01/README.md) | [Bootcamp](../../README.md) | [Semana 03](../week-03/README.md) |

---

## 📚 Recursos Adicionales

- [Dockerfile Reference](https://docs.docker.com/engine/reference/dockerfile/)
- [Best practices for writing Dockerfiles](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- [Multi-stage builds](https://docs.docker.com/build/building/multi-stage/)
