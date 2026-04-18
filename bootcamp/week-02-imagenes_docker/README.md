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
week-02-imagenes_docker/
├── README.md                    # Este archivo
├── rubrica-evaluacion.md        # Criterios de evaluación
├── 0-assets/                    # Recursos visuales (SVG)
│   ├── README.md
│   ├── 01-sistema-capas.svg
│   ├── 02-multi-stage-build.svg
│   ├── 03-dockerfile-flujo.svg
│   ├── 04-build-cache.svg
│   └── 05-build-context.svg
├── 1-teoria/                    # Material teórico
│   ├── 01-anatomia-imagen.md
│   ├── 02-dockerfile-basico.md
│   ├── 03-dockerfile-avanzado.md
│   ├── 04-build-context.md
│   └── 05-optimizacion.md
├── 2-ejercicios/                # Ejercicios guiados (sin solution)
│   ├── README.md
│   ├── 01-primera-imagen/
│   ├── 02-variables-argumentos/
│   ├── 03-copiando-archivos/
│   ├── 04-multi-stage/
│   └── 05-optimizacion-capas/
├── 3-proyecto/                  # Proyecto semanal
│   ├── README.md
│   ├── starter/
│   └── solution/
├── 4-recursos/                  # Material adicional
│   ├── README.md
│   ├── ebooks-free/
│   ├── videografia/
│   └── webgrafia/
└── 5-glosario/                  # Términos clave
    └── README.md
```

---

## 📝 Contenidos

### 📚 Teoría

| #   | Tema                   | Duración | Archivo                                                         |
| --- | ---------------------- | -------- | --------------------------------------------------------------- |
| 1   | Anatomía de una Imagen | 20 min   | [01-anatomia-imagen.md](1-teoria/01-anatomia-imagen.md)         |
| 2   | Dockerfile Básico      | 25 min   | [02-dockerfile-basico.md](1-teoria/02-dockerfile-basico.md)     |
| 3   | Dockerfile Avanzado    | 25 min   | [03-dockerfile-avanzado.md](1-teoria/03-dockerfile-avanzado.md) |
| 4   | Build Context          | 20 min   | [04-build-context.md](1-teoria/04-build-context.md)             |
| 5   | Optimización           | 30 min   | [05-optimizacion.md](1-teoria/05-optimizacion.md)               |

### 💻 Ejercicios Guiados

| #   | Ejercicio              | Duración | Carpeta                                                           |
| --- | ---------------------- | -------- | ----------------------------------------------------------------- |
| 1   | Primera Imagen         | 30 min   | [01-primera-imagen/](2-ejercicios/01-primera-imagen/)             |
| 2   | Variables y Argumentos | 30 min   | [02-variables-argumentos/](2-ejercicios/02-variables-argumentos/) |
| 3   | Copiando Archivos      | 30 min   | [03-copiando-archivos/](2-ejercicios/03-copiando-archivos/)       |
| 4   | Multi-Stage Build      | 40 min   | [04-multi-stage/](2-ejercicios/04-multi-stage/)                   |
| 5   | Optimización de Capas  | 30 min   | [05-optimizacion-capas/](2-ejercicios/05-optimizacion-capas/)     |

### 🚀 Proyecto Semanal

**API REST Optimizada**

Crear una imagen Docker optimizada para una API REST Node.js, aplicando multi-stage builds, usuario no-root y buenas prácticas.

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

- [ ] Quiz teórico aprobado (≥70%)
- [ ] 5 Ejercicios completados
- [ ] Proyecto semanal funcional (API en contenedor)
- [ ] Imagen optimizada (< 150MB)
- [ ] Imagen publicada en Docker Hub (opcional)

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
| [Semana 01](../week-01-fundamentos_docker/README.md) | [Bootcamp](../../README.md) | [Semana 03](../week-03-gestion_contenedores/README.md) |

---

## 📚 Recursos Adicionales

- [Dockerfile Reference](https://docs.docker.com/engine/reference/dockerfile/)
- [Best practices for writing Dockerfiles](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- [Multi-stage builds](https://docs.docker.com/build/building/multi-stage/)
