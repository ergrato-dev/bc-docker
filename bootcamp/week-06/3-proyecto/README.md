# 🚀 Proyecto Semana 06: Stack Full-Stack con Docker Compose

## 📋 Información del Proyecto

| Atributo         | Valor                                               |
| ---------------- | --------------------------------------------------- |
| **Nombre**       | Task Manager — Aplicación Multi-Servicio Completa   |
| **Duración**     | 1.5 horas                                           |
| **Nivel**        | Intermedio                                          |
| **Stack**        | Nginx + FastAPI + PostgreSQL + Redis                |

---

## 🎯 Objetivos

Al completar este proyecto:

- ✅ Tendrás un stack multi-servicio funcional con Docker Compose
- ✅ Habrás implementado redes separadas para aislamiento
- ✅ Habrás configurado healthchecks en todos los servicios críticos
- ✅ Habrás gestionado variables de entorno con `.env`
- ✅ Tendrás configuraciones distintas para desarrollo y producción

---

## 📖 Descripción

Construirás una aplicación de gestión de tareas (*Task Manager*) con:

| Servicio      | Imagen/Build    | Puerto   | Rol                              |
| ------------- | --------------- | -------- | -------------------------------- |
| `nginx`       | nginx:alpine    | 8080:80  | Reverse proxy + archivos estáticos |
| `api`         | build local     | (interno)| API REST (FastAPI)               |
| `db`          | postgres:16     | (interno)| Base de datos principal          |
| `cache`       | redis:7-alpine  | (interno)| Cache de sesiones y contador     |

---

## 🗂️ Estructura del Proyecto

```
task-manager/
├── docker-compose.yml
├── docker-compose.override.yml    # Configuración de desarrollo
├── .env
├── .env.example
├── .gitignore
├── nginx/
│   ├── nginx.conf
│   └── html/
│       └── index.html
└── api/
    ├── Dockerfile
    ├── requirements.txt
    └── main.py
```

---

## 📋 Requisitos del Proyecto

### 1. Redes (Mínimo 2)

- **`public-net`**: Nginx ↔ API
- **`internal-net`**: API ↔ DB + Cache (marcada como `internal: true`)
- `db` y `cache` **NO** deben ser accesibles desde `nginx` directamente

### 2. Volúmenes

- Volumen nombrado para PostgreSQL: `pg-data`
- Los datos deben persistir entre `docker compose down && up`

### 3. Healthchecks

Todos los servicios deben tener `healthcheck`:
- **db**: `pg_isready` 
- **cache**: `redis-cli ping`
- **api**: endpoint `/health`
- **nginx**: `wget` o `curl` al status endpoint

### 4. Variables de entorno

- Usar un archivo `.env` para credenciales
- Nunca credenciales hardcodeadas en `docker-compose.yml`
- Proveer un `.env.example` con valores de ejemplo

### 5. Endpoints de la API

La API debe implementar al menos:

| Endpoint      | Método | Descripción                                  |
| ------------- | ------ | -------------------------------------------- |
| `/`           | GET    | Información de la aplicación                 |
| `/health`     | GET    | Estado del servicio                          |
| `/tasks`      | GET    | Listar tareas (puede ser mock)               |
| `/tasks`      | POST   | Crear tarea                                  |
| `/stats`      | GET    | Estadísticas usando Redis (`incr`)           |

### 6. Override para Desarrollo

El `docker-compose.override.yml` debe:
- Exponer la API directamente en puerto `8000`
- Agregar pgAdmin en puerto `5050` para inspeccionar la BD
- Montar el código fuente como volume para hot-reload

---

## 📦 Starter Code

El directorio `starter/` contiene la estructura básica con `# TODO:` markers.

### `starter/api/main.py`

```python
from fastapi import FastAPI
from datetime import datetime
import os

app = FastAPI(title="Task Manager API")

# TODO: Agregar conexión a Redis
# TODO: Agregar conexión a PostgreSQL

@app.get("/")
def root():
    return {"app": "Task Manager", "version": "1.0"}

@app.get("/health")
def health():
    # TODO: Verificar conexión a db y cache
    return {"status": "healthy", "timestamp": datetime.now().isoformat()}

@app.get("/tasks")
def list_tasks():
    # TODO: Obtener tareas de PostgreSQL
    # Por ahora retorna datos de ejemplo
    return [
        {"id": 1, "title": "Aprender Docker Compose", "done": True},
        {"id": 2, "title": "Crear stack multi-servicio", "done": False},
    ]

@app.post("/tasks")
def create_task(title: str):
    # TODO: Guardar tarea en PostgreSQL
    return {"message": "Task created", "title": title}

@app.get("/stats")
def get_stats():
    # TODO: Incrementar visitas en Redis y retornar
    return {"visits": 0, "source": "pending"}
```

### `starter/docker-compose.yml`

```yaml
services:
  
  nginx:
    image: nginx:alpine
    ports:
      - "8080:80"
    # TODO: agregar volumes para nginx.conf y html/
    # TODO: agregar depends_on con condition: service_healthy
    # TODO: agregar networks
    # TODO: agregar healthcheck

  api:
    build: ./api
    # TODO: agregar environment con variables de .env
    # TODO: agregar depends_on con healthchecks
    # TODO: agregar networks (tanto public como internal)
    # TODO: agregar healthcheck

  db:
    image: postgres:16-alpine
    # TODO: agregar environment
    # TODO: agregar volumes
    # TODO: agregar healthcheck con pg_isready
    # TODO: agregar networks (solo internal)

  cache:
    image: redis:7-alpine
    # TODO: agregar healthcheck con redis-cli ping
    # TODO: agregar networks (solo internal)

# TODO: Definir volúmenes nombrados

# TODO: Definir redes (public-net e internal-net con internal: true)
```

---

## 🏁 Criterios de Aceptación

Para que el proyecto se considere completo:

1. `docker compose up -d --build` levanta todos los servicios sin errores
2. `docker compose ps` muestra todos los servicios como `Up (healthy)`
3. `curl http://localhost:8080/tasks` retorna la lista de tareas
4. `curl http://localhost:8080/stats` retorna un contador que incrementa
5. `docker compose down && docker compose up -d` mantiene los datos de PostgreSQL
6. `docker compose exec nginx ping db` **falla** (aislamiento de redes)
7. `docker compose exec api ping db` **funciona** (misma red)
8. El archivo `.env.example` existe y no contiene contraseñas reales
9. `docker compose -f docker-compose.yml -f docker-compose.override.yml up -d` expone la API en puerto 8000

---

## 📊 Evaluación

| Criterio                    | Puntos |
| --------------------------- | ------ |
| Redes separadas correctas   | 20     |
| Healthchecks en todos       | 20     |
| Variables con `.env`        | 15     |
| Volúmenes y persistencia    | 15     |
| Override para desarrollo    | 15     |
| Código limpio y comentado   | 15     |
| **Total**                   | **100**|

---

## 🔗 Recursos

- [Docker Compose Specification](https://docs.docker.com/compose/compose-file/)
- [Teoría Semana 06](../1-teoria/)
- [FastAPI Documentación](https://fastapi.tiangolo.com/)
