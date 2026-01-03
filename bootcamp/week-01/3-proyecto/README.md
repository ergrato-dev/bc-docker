# 🚀 Proyecto Semana 01: Entorno de Desarrollo Multi-Servicio

## 📋 Descripción

En este proyecto crearás un entorno de desarrollo local utilizando contenedores Docker. Configurarás múltiples servicios que se comunican entre sí, simulando una arquitectura de aplicación real.

## 🎯 Objetivos del Proyecto

- Aplicar todos los conocimientos de la semana
- Gestionar múltiples contenedores simultáneamente
- Configurar comunicación entre contenedores
- Practicar el flujo de trabajo con Docker

## ⏱️ Tiempo Estimado

1.5 horas

---

## 📦 Arquitectura

Crearás la siguiente arquitectura:

```
┌─────────────────────────────────────────────────────────────────┐
│                         RED: dev-network                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   ┌──────────────┐    ┌──────────────┐    ┌──────────────┐     │
│   │              │    │              │    │              │     │
│   │    nginx     │    │   adminer    │    │    redis     │     │
│   │   (proxy)    │    │  (DB admin)  │    │   (cache)    │     │
│   │              │    │              │    │              │     │
│   │   :8080      │    │   :8081      │    │   :6379      │     │
│   └──────────────┘    └──────────────┘    └──────────────┘     │
│          │                   │                   │              │
│          └───────────────────┼───────────────────┘              │
│                              │                                  │
│                    ┌─────────▼────────┐                        │
│                    │                  │                        │
│                    │    postgres      │                        │
│                    │   (database)     │                        │
│                    │                  │                        │
│                    │    :5432         │                        │
│                    └──────────────────┘                        │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📁 Estructura del Proyecto

```
3-proyecto/
├── README.md           # Este archivo
├── starter/            # Archivos iniciales
│   └── README.md       # Instrucciones paso a paso
└── solution/           # Solución completa
    ├── README.md       # Documentación de la solución
    └── commands.sh     # Script con todos los comandos
```

---

## 🎯 Requisitos Funcionales

### Servicios a crear:

| Servicio  | Imagen             | Puerto Host | Propósito           |
| --------- | ------------------ | ----------- | ------------------- |
| `web`     | nginx:alpine       | 8080        | Servidor web/proxy  |
| `db`      | postgres:16-alpine | 5432        | Base de datos       |
| `cache`   | redis:alpine       | 6379        | Sistema de caché    |
| `dbadmin` | adminer            | 8081        | Administrador de BD |

### Configuración requerida:

1. **Red personalizada**: `dev-network`
2. **Variables de entorno para PostgreSQL**:
   - `POSTGRES_USER=devuser`
   - `POSTGRES_PASSWORD=devpass`
   - `POSTGRES_DB=devdb`
3. **Nombres de contenedor** claros y descriptivos
4. **Política de reinicio**: `unless-stopped` para todos

---

## 📝 Entregables

1. **Documentación** de los comandos ejecutados
2. **Capturas de pantalla** de:
   - `docker ps` con todos los contenedores corriendo
   - Adminer conectado a PostgreSQL
   - Página de nginx en el navegador
3. **Script de limpieza** para eliminar todos los recursos

---

## 🧪 Criterios de Evaluación

| Criterio                             | Puntos  |
| ------------------------------------ | ------- |
| Red creada correctamente             | 10      |
| PostgreSQL funcionando con variables | 20      |
| Redis funcionando                    | 15      |
| Nginx accesible en :8080             | 15      |
| Adminer conecta a PostgreSQL         | 20      |
| Documentación completa               | 10      |
| Script de limpieza                   | 10      |
| **Total**                            | **100** |

---

## 🚀 Comenzar

1. Ve a la carpeta [starter/](starter/) para las instrucciones paso a paso
2. Intenta completar el proyecto por tu cuenta
3. Si te atascas, consulta [solution/](solution/) para ver la solución

---

## 💡 Tips

- Crea primero la red antes que los contenedores
- Inicia PostgreSQL antes que Adminer (Adminer lo necesita)
- Usa `docker logs` si un contenedor no inicia correctamente
- Verifica conectividad con `docker exec` y `ping`

---

## 🔗 Navegación

| ← Ejercicios                                                                           | README Semana             |
| -------------------------------------------------------------------------------------- | ------------------------- |
| [03 - Gestionando Contenedores](../2-ejercicios/03-gestionando-contenedores/README.md) | [Semana 01](../README.md) |
