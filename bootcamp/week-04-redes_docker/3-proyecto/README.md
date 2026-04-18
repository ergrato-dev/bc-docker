# 🚀 Proyecto Semana 04: Microservicios con Redes Docker

## 📋 Descripción del Proyecto

En este proyecto construirás una **arquitectura de microservicios** completa utilizando redes Docker para implementar comunicación segura y aislamiento entre componentes.

### Escenario

Eres el DevOps de una startup que necesita desplegar una aplicación web con:

- **Frontend**: Nginx sirviendo contenido estático
- **API Gateway**: Punto de entrada para APIs
- **Servicios Backend**: Usuarios y Productos
- **Base de Datos**: PostgreSQL
- **Cache**: Redis

---

## 🎯 Objetivos

Al completar este proyecto serás capaz de:

- ✅ Diseñar topología de redes para microservicios
- ✅ Implementar aislamiento de seguridad por capas
- ✅ Configurar DNS interno para service discovery
- ✅ Publicar solo los servicios necesarios al exterior
- ✅ Verificar conectividad entre servicios

---

## 📐 Arquitectura

```
                         INTERNET
                            │
                        ┌───┴───┐
                        │ :8080 │
                        └───┬───┘
┌───────────────────────────┼───────────────────────────┐
│                      DMZ NETWORK                       │
│  ┌─────────────────────────────────────────────────┐  │
│  │                    nginx                         │  │
│  │              (frontend + proxy)                  │  │
│  └─────────────────────┬───────────────────────────┘  │
└────────────────────────┼──────────────────────────────┘
                         │
┌────────────────────────┼──────────────────────────────┐
│                   APP NETWORK                          │
│  ┌─────────────────────┴───────────────────────────┐  │
│  │                 api-gateway                      │  │
│  └────────────┬─────────────────────┬──────────────┘  │
│               │                     │                  │
│  ┌────────────┴──────┐  ┌──────────┴────────────┐    │
│  │   users-service   │  │   products-service    │    │
│  └────────────┬──────┘  └──────────┬────────────┘    │
└───────────────┼─────────────────────┼─────────────────┘
                │                     │
┌───────────────┼─────────────────────┼─────────────────┐
│               │    DATA NETWORK     │                  │
│  ┌────────────┴──────┐  ┌──────────┴────────────┐    │
│  │     postgres      │  │        redis          │    │
│  └───────────────────┘  └───────────────────────┘    │
└───────────────────────────────────────────────────────┘
```

---

## 📁 Estructura del Proyecto

```
3-proyecto/
├── README.md              # Este archivo
├── starter/               # Archivos iniciales (con TODOs)
│   ├── README.md
│   ├── scripts/
│   │   ├── setup-networks.sh
│   │   ├── deploy.sh
│   │   ├── test-connectivity.sh
│   │   └── cleanup.sh
│   └── nginx/
│       └── nginx.conf
└── solution/              # Solución completa
    ├── README.md
    ├── scripts/
    │   ├── setup-networks.sh
    │   ├── deploy.sh
    │   ├── test-connectivity.sh
    │   └── cleanup.sh
    └── nginx/
        └── nginx.conf
```

---

## 🔧 Requisitos

### Redes a Crear

| Red        | Propósito                  | Contenedores                                          |
| ---------- | -------------------------- | ----------------------------------------------------- |
| `dmz-net`  | Exposición pública         | nginx                                                 |
| `app-net`  | Comunicación de aplicación | nginx, api-gateway, users-svc, products-svc           |
| `data-net` | Acceso a datos             | api-gateway, users-svc, products-svc, postgres, redis |

### Contenedores

| Nombre           | Imagen             | Redes             | Puerto Publicado |
| ---------------- | ------------------ | ----------------- | ---------------- |
| nginx            | nginx:alpine       | dmz-net, app-net  | 8080:80          |
| api-gateway      | alpine             | app-net, data-net | -                |
| users-service    | alpine             | app-net, data-net | -                |
| products-service | alpine             | app-net, data-net | -                |
| postgres         | postgres:15-alpine | data-net          | -                |
| redis            | redis:alpine       | data-net          | -                |

### Matriz de Comunicación Esperada

| Origen → Destino | nginx | api-gw | users | products | postgres | redis |
| ---------------- | ----- | ------ | ----- | -------- | -------- | ----- |
| **nginx**        | -     | ✅     | ✅    | ✅       | ❌       | ❌    |
| **api-gateway**  | ✅    | -      | ✅    | ✅       | ✅       | ✅    |
| **users-svc**    | ✅    | ✅     | -     | ✅       | ✅       | ✅    |
| **products-svc** | ✅    | ✅     | ✅    | -        | ✅       | ✅    |
| **postgres**     | ❌    | ❌     | ❌    | ❌       | -        | ✅    |
| **redis**        | ❌    | ❌     | ❌    | ❌       | ✅       | -     |

---

## 📝 Entregables

1. **Scripts funcionales** que crean la infraestructura
2. **Test de conectividad** que verifica la matriz de comunicación
3. **Documentación** de decisiones de diseño

---

## ⏱️ Tiempo Estimado

| Fase                       | Tiempo     |
| -------------------------- | ---------- |
| Lectura y planificación    | 15 min     |
| Implementación de redes    | 20 min     |
| Despliegue de contenedores | 25 min     |
| Testing y verificación     | 20 min     |
| Documentación              | 10 min     |
| **Total**                  | **90 min** |

---

## 🏁 Criterios de Éxito

- [ ] Las 3 redes están creadas correctamente
- [ ] Los 6 contenedores están ejecutándose
- [ ] Nginx es accesible desde localhost:8080
- [ ] La matriz de comunicación se cumple al 100%
- [ ] postgres y redis NO son accesibles desde nginx

---

## 💡 Consejos

1. **Empieza simple**: Primero crea las redes, luego los contenedores
2. **Verifica paso a paso**: No avances sin confirmar que funciona
3. **Usa aliases**: Facilitan el testing de conectividad
4. **Documenta errores**: Aprende de los problemas encontrados

---

<div align="center">

[📂 Ir a Starter](starter/README.md) | [📂 Ver Solución](solution/README.md)

</div>
