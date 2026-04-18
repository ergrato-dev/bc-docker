# 📋 Rúbrica de Evaluación - Semana 02

## 📊 Resumen de Evaluación

| Evidencia       | Peso     | Puntos Máximos |
| --------------- | -------- | -------------- |
| 🧠 Conocimiento | 30%      | 30 pts         |
| 💪 Desempeño    | 40%      | 40 pts         |
| 📦 Producto     | 30%      | 30 pts         |
| **Total**       | **100%** | **100 pts**    |

**Nota mínima aprobatoria**: 70 puntos

---

## 🧠 Conocimiento (30 pts)

### Quiz Teórico

| Tema                     | Puntos | Descripción                           |
| ------------------------ | ------ | ------------------------------------- |
| Anatomía de imágenes     | 6      | Capas, caché, inmutabilidad           |
| Instrucciones Dockerfile | 8      | FROM, RUN, COPY, CMD, ENTRYPOINT      |
| Multi-stage builds       | 8      | Concepto, sintaxis, casos de uso      |
| Optimización             | 8      | Orden de capas, .dockerignore, tamaño |

**Puntos Conocimiento: \_\_\_ / 30**

---

## 💪 Desempeño (40 pts)

### Ejercicio 01: Primer Dockerfile (12 pts)

| Criterio                       | Puntos | Logrado |
| ------------------------------ | ------ | ------- |
| Dockerfile válido y funcional  | 4      | ☐       |
| Imagen base con tag específico | 3      | ☐       |
| WORKDIR configurado            | 2      | ☐       |
| CMD o ENTRYPOINT correcto      | 3      | ☐       |

### Ejercicio 02: Multi-Stage Build (15 pts)

| Criterio                       | Puntos | Logrado |
| ------------------------------ | ------ | ------- |
| Etapa de build correcta        | 5      | ☐       |
| Etapa de producción optimizada | 5      | ☐       |
| Imagen final < 100MB           | 3      | ☐       |
| Sin archivos innecesarios      | 2      | ☐       |

### Ejercicio 03: Optimización (13 pts)

| Criterio                      | Puntos | Logrado |
| ----------------------------- | ------ | ------- |
| .dockerignore configurado     | 3      | ☐       |
| Capas optimizadas             | 4      | ☐       |
| Aprovecha caché correctamente | 3      | ☐       |
| Usuario no-root               | 3      | ☐       |

**Puntos Desempeño: \_\_\_ / 40**

---

## 📦 Producto (30 pts)

### Proyecto: Aplicación Web Containerizada

| Criterio                         | Puntos | Descripción                        |
| -------------------------------- | ------ | ---------------------------------- |
| **Funcionalidad**                | 12     |                                    |
| Dockerfile funcional             | 4      | La imagen se construye sin errores |
| Multi-stage implementado         | 4      | Build y producción separados       |
| Aplicación ejecuta correctamente | 4      | El contenedor funciona             |
| **Optimización**                 | 10     |                                    |
| Imagen < 150MB                   | 3      | Tamaño optimizado                  |
| .dockerignore completo           | 3      | Excluye archivos innecesarios      |
| Usuario no-root                  | 4      | No ejecuta como root               |
| **Documentación**                | 8      |                                    |
| README con instrucciones         | 4      | Cómo construir y ejecutar          |
| Comentarios en Dockerfile        | 4      | Explica cada sección               |

**Puntos Producto: \_\_\_ / 30**

---

## 📝 Niveles de Desempeño

| Nivel            | Puntos | Descripción                                       |
| ---------------- | ------ | ------------------------------------------------- |
| 🌟 Excelente     | 90-100 | Domina todos los conceptos, imagen muy optimizada |
| ✅ Competente    | 70-89  | Dockerfile funcional con optimizaciones básicas   |
| ⚠️ En desarrollo | 50-69  | Dockerfile funcional pero sin optimizar           |
| ❌ Insuficiente  | 0-49   | Dockerfile incompleto o no funcional              |

---

## 🔗 Navegación

| ← Anterior                                          | Actual              | Siguiente →                                         |
| --------------------------------------------------- | ------------------- | --------------------------------------------------- |
| [Rúbrica Week-01](../week-01-fundamentos_docker/rubrica-evaluacion.md) | **Rúbrica Week-02** | [Rúbrica Week-03](../week-03-gestion_contenedores/rubrica-evaluacion.md) |
