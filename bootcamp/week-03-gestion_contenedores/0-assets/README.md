# 🎨 Assets - Semana 03

Diagramas y recursos visuales para la semana de **Gestión de Contenedores**.

---

## 📊 Catálogo de Diagramas

| #   | Archivo                                              | Descripción                           | Usado en           |
| --- | ---------------------------------------------------- | ------------------------------------- | ------------------ |
| 1   | [01-ciclo-vida.svg](01-ciclo-vida.svg)               | Estados y transiciones del contenedor | Teoría: Ciclo Vida |
| 2   | [02-logs-streams.svg](02-logs-streams.svg)           | Flujo de stdout/stderr hacia logs     | Teoría: Logs       |
| 3   | [03-exec-attach.svg](03-exec-attach.svg)             | Diferencias entre exec y attach       | Teoría: Exec       |
| 4   | [04-recursos-limites.svg](04-recursos-limites.svg)   | CPU, memoria y límites de recursos    | Teoría: Recursos   |
| 5   | [05-variables-entorno.svg](05-variables-entorno.svg) | Configuración con variables ENV       | Teoría: Variables  |

---

## 🖼️ Vista Previa

### 01 - Ciclo de Vida

Diagrama del ciclo de vida completo:

- Estados: Created → Running → Paused → Stopped → Removed
- Comandos de transición entre estados
- Códigos de color por estado

### 02 - Logs y Streams

Flujo de logs en Docker:

- stdout/stderr del proceso
- Logging driver
- Destinos (terminal, archivo, externo)

### 03 - Exec vs Attach

Comparativa visual:

- exec: Crea nuevo proceso
- attach: Conecta al existente
- Cuándo usar cada uno

### 04 - Recursos y Límites

Control de recursos:

- Límites de CPU y memoria
- Contenedores con y sin límites
- OOM Killer

### 05 - Variables de Entorno

Configuración externa:

- Métodos: -e, --env-file, Dockerfile
- Prioridad de sobrescritura
- Ejemplo de archivo .env

---

## 📐 Especificaciones Técnicas

| Propiedad   | Valor                                                           |
| ----------- | --------------------------------------------------------------- |
| **Formato** | SVG (vectorial)                                                 |
| **Ancho**   | 900px                                                           |
| **Tema**    | Oscuro (#1a1a2e)                                                |
| **Fuentes** | -apple-system, BlinkMacSystemFont, Segoe UI, Roboto, sans-serif |
| **Colores** | Sólidos (sin gradientes)                                        |

---

## 🎨 Paleta de Colores

| Color       | Hex       | Uso                            |
| ----------- | --------- | ------------------------------ |
| 🟢 Verde    | `#43e97b` | Running, éxito, exec           |
| 🔵 Azul     | `#667eea` | Created, información           |
| 🟡 Amarillo | `#ffd93d` | Paused, advertencia            |
| 🔴 Rojo     | `#f5576c` | Stopped, error, attach peligro |
| 🟣 Púrpura  | `#f093fb` | Dockerfile, configuración      |
| 🔷 Cyan     | `#00d4ff` | Docker daemon                  |

---

## 📝 Uso en Markdown

```markdown
![Ciclo de Vida](../0-assets/01-ciclo-vida.svg)

![Logs y Streams](../0-assets/02-logs-streams.svg)

![Exec vs Attach](../0-assets/03-exec-attach.svg)

![Recursos y Límites](../0-assets/04-recursos-limites.svg)

![Variables de Entorno](../0-assets/05-variables-entorno.svg)
```

---

> **Nota**: Todos los diagramas usan tema oscuro con colores sólidos y fuentes sans-serif según las especificaciones del proyecto.
