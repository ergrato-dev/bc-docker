# 🐳 Semana 04: Redes en Docker

<p align="center">
  <img src="0-assets/week-04-header.svg" alt="Semana 04 - Redes en Docker" width="600">
</p>

## 🎯 Objetivos de Aprendizaje

Al finalizar esta semana, serás capaz de:

- ✅ Comprender los tipos de redes en Docker
- ✅ Crear y gestionar redes personalizadas
- ✅ Conectar contenedores entre sí
- ✅ Usar DNS interno de Docker
- ✅ Configurar port mapping correctamente
- ✅ Aislar contenedores por red

---

## 📚 Requisitos Previos

Antes de comenzar esta semana, debes:

- ✅ Completar la Semana 03 (Gestión de Contenedores)
- ✅ Entender el ciclo de vida de contenedores
- ✅ Saber usar docker exec

---

## 🗂️ Estructura de la Semana

```
week-04/
├── README.md                    # Este archivo
├── rubrica-evaluacion.md        # Criterios de evaluación
├── 0-assets/                    # Recursos visuales
│   └── week-04-header.svg
├── 1-teoria/                    # Material teórico
│   ├── 01-tipos-redes.md
│   ├── 02-bridge-network.md
│   ├── 03-host-none.md
│   ├── 04-dns-interno.md
│   └── 05-port-mapping.md
├── 2-ejercicios/                # Ejercicios guiados
│   ├── 01-redes-basicas/
│   ├── 02-comunicacion/
│   └── 03-aislamiento/
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

| #   | Tema                  | Duración | Archivo                                               |
| --- | --------------------- | -------- | ----------------------------------------------------- |
| 1   | Tipos de Redes Docker | 25 min   | [01-tipos-redes.md](1-teoria/01-tipos-redes.md)       |
| 2   | Bridge Network        | 25 min   | [02-bridge-network.md](1-teoria/02-bridge-network.md) |
| 3   | Host y None           | 15 min   | [03-host-none.md](1-teoria/03-host-none.md)           |
| 4   | DNS Interno           | 20 min   | [04-dns-interno.md](1-teoria/04-dns-interno.md)       |
| 5   | Port Mapping          | 20 min   | [05-port-mapping.md](1-teoria/05-port-mapping.md)     |

### 💻 Ejercicios Guiados

| #   | Ejercicio                       | Duración | Carpeta                                             |
| --- | ------------------------------- | -------- | --------------------------------------------------- |
| 1   | Redes Básicas                   | 45 min   | [01-redes-basicas/](2-ejercicios/01-redes-basicas/) |
| 2   | Comunicación entre Contenedores | 50 min   | [02-comunicacion/](2-ejercicios/02-comunicacion/)   |
| 3   | Aislamiento de Redes            | 45 min   | [03-aislamiento/](2-ejercicios/03-aislamiento/)     |

### 🚀 Proyecto Semanal

**Arquitectura Multi-Tier**

Crear una arquitectura de aplicación con frontend, backend y base de datos en redes separadas y comunicación controlada.

📁 [Ver instrucciones del proyecto](3-proyecto/README.md)

---

## ⏱️ Distribución del Tiempo

| Actividad     | Tiempo      |
| ------------- | ----------- |
| 📖 Teoría     | 1.75 horas  |
| 💻 Ejercicios | 2.5 horas   |
| 🚀 Proyecto   | 1.5 horas   |
| **Total**     | **6 horas** |

---

## 📌 Entregables

- [ ] Ejercicios 01, 02 y 03 completados
- [ ] Proyecto con arquitectura multi-tier
- [ ] Diagrama de red del proyecto
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

- **Bridge**: Red por defecto, aislada del host
- **Host**: Comparte red del host (sin aislamiento)
- **None**: Sin red (aislamiento total)
- **DNS interno**: Resolución por nombre de contenedor
- **Port mapping**: `-p host:container`
- **Network alias**: Nombres alternativos en la red

---

## 🔗 Navegación

| ⬅️ Anterior                       | 🏠 Inicio                   | Siguiente ➡️                      |
| --------------------------------- | --------------------------- | --------------------------------- |
| [Semana 03](../week-03/README.md) | [Bootcamp](../../README.md) | [Semana 05](../week-05/README.md) |

---

## 📚 Recursos Adicionales

- [Docker networking overview](https://docs.docker.com/network/)
- [Bridge network tutorial](https://docs.docker.com/network/network-tutorial-standalone/)
- [Container networking](https://docs.docker.com/config/containers/container-networking/)
