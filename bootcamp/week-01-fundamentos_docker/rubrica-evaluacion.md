# 📋 Rúbrica de Evaluación - Semana 01

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

| Tema              | Puntos | Descripción                       |
| ----------------- | ------ | --------------------------------- |
| Contenedorización | 6      | Concepto, beneficios, historia    |
| Docker vs VMs     | 6      | Diferencias, cuándo usar cada uno |
| Arquitectura      | 6      | Cliente, daemon, registry         |
| Comandos básicos  | 6      | run, ps, stop, rm, images         |
| Conceptos clave   | 6      | Imagen, contenedor, volumen, red  |

**Puntos Conocimiento: \_\_\_ / 30**

---

## 💪 Desempeño (40 pts)

### Ejercicio 01: Primer Contenedor (12 pts)

| Criterio                        | Puntos | Logrado |
| ------------------------------- | ------ | ------- |
| Ejecutar hello-world            | 3      | ☐       |
| Contenedor interactivo (Ubuntu) | 3      | ☐       |
| Nginx en segundo plano          | 3      | ☐       |
| Ver logs y ejecutar comandos    | 3      | ☐       |

### Ejercicio 02: Explorando Imágenes (14 pts)

| Criterio                     | Puntos | Logrado |
| ---------------------------- | ------ | ------- |
| Buscar y descargar imágenes  | 3      | ☐       |
| Entender y usar tags         | 3      | ☐       |
| Comparar tamaños de imágenes | 3      | ☐       |
| Inspeccionar imagen          | 3      | ☐       |
| Ver historial de capas       | 2      | ☐       |

### Ejercicio 03: Gestionando Contenedores (14 pts)

| Criterio                      | Puntos | Logrado |
| ----------------------------- | ------ | ------- |
| Crear red personalizada       | 3      | ☐       |
| Múltiples contenedores en red | 3      | ☐       |
| Verificar conectividad        | 3      | ☐       |
| Monitorear recursos (stats)   | 2      | ☐       |
| Copiar archivos (cp)          | 3      | ☐       |

**Puntos Desempeño: \_\_\_ / 40**

---

## 📦 Producto (30 pts)

### Proyecto: Entorno Multi-Servicio

| Criterio                     | Puntos | Descripción                    |
| ---------------------------- | ------ | ------------------------------ |
| **Infraestructura**          | 12     |                                |
| Red dev-network creada       | 3      | Red bridge funcional           |
| PostgreSQL configurado       | 3      | Variables de entorno correctas |
| Redis funcionando            | 3      | Responde PONG                  |
| Nginx accesible              | 3      | Puerto 8080                    |
| **Funcionalidad**            | 10     |                                |
| Adminer conecta a PostgreSQL | 4      | Login exitoso                  |
| Contenedores se comunican    | 3      | Ping por nombre                |
| Política de reinicio         | 3      | unless-stopped                 |
| **Documentación**            | 8      |                                |
| Capturas de pantalla         | 4      | docker ps, navegador           |
| Script de limpieza           | 4      | Funcional y documentado        |

**Puntos Producto: \_\_\_ / 30**

---

## 📝 Niveles de Desempeño

| Nivel            | Puntos | Descripción                                                      |
| ---------------- | ------ | ---------------------------------------------------------------- |
| 🌟 Excelente     | 90-100 | Domina todos los conceptos, proyecto completo y bien documentado |
| ✅ Competente    | 70-89  | Cumple con los requisitos, algunos detalles por mejorar          |
| ⚠️ En desarrollo | 50-69  | Necesita refuerzo en algunos temas                               |
| ❌ Insuficiente  | 0-49   | No cumple con los objetivos mínimos                              |

---

## 📌 Checklist de Entrega

- [ ] Docker instalado y funcionando (`docker --version`)
- [ ] Ejercicio 01 completado
- [ ] Ejercicio 02 completado
- [ ] Ejercicio 03 completado
- [ ] Proyecto con 4 contenedores funcionando
- [ ] Capturas de pantalla adjuntas
- [ ] Script de limpieza funcional
- [ ] Quiz teórico completado (≥70%)

---

## 🔗 Navegación

| README Semana          | Siguiente Rúbrica →                                 |
| ---------------------- | --------------------------------------------------- |
| [Semana 01](README.md) | [Rúbrica Week-02](../week-02-imagenes_docker/rubrica-evaluacion.md) |
