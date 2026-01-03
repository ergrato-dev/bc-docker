# 🚀 Proyecto Semana 03: Sistema de Monitoreo de Contenedores

## 📋 Descripción

En este proyecto construirás un **Sistema de Monitoreo de Contenedores** que permite supervisar múltiples servicios, gestionar su ciclo de vida, y diagnosticar problemas. Aplicarás todos los conceptos aprendidos durante la semana.

---

## 🎯 Objetivos del Proyecto

Al completar este proyecto serás capaz de:

- ✅ Gestionar el ciclo de vida de múltiples contenedores
- ✅ Configurar aplicaciones mediante variables de entorno
- ✅ Establecer límites de recursos apropiados
- ✅ Implementar sistema de logging y monitoreo
- ✅ Diagnosticar y resolver problemas en contenedores

---

## 📊 Escenario

Eres el administrador de sistemas de una startup. Tu equipo necesita un entorno local de desarrollo con varios servicios:

1. **Web Server** - Nginx sirviendo una página de estado
2. **API Backend** - Simulado con Alpine + scripts
3. **Base de Datos** - MySQL con datos de prueba
4. **Cache** - Redis para mejorar rendimiento

Tu tarea es desplegar, configurar, monitorear y mantener estos servicios.

---

## ⏱️ Duración Estimada

90 minutos

---

## 📁 Estructura del Proyecto

```
3-proyecto/
├── README.md           # Este archivo
├── starter/            # Archivos iniciales para comenzar
│   ├── config/
│   │   ├── app.env
│   │   └── db.env
│   ├── scripts/
│   │   ├── health-check.sh
│   │   └── monitor.sh
│   └── web/
│       └── index.html
└── solution/           # Solución completa de referencia
    ├── config/
    ├── scripts/
    └── web/
```

---

## 🏗️ Requisitos del Sistema

### Servicios a desplegar

| Servicio | Imagen       | Puerto | Memoria | CPU  |
| -------- | ------------ | ------ | ------- | ---- |
| web      | nginx:alpine | 8080   | 128MB   | 0.5  |
| api      | alpine:3.19  | 3000   | 256MB   | 1.0  |
| db       | mysql:8.0    | 3306   | 512MB   | 1.0  |
| cache    | redis:alpine | 6379   | 128MB   | 0.25 |

### Configuración requerida

- Todos los contenedores deben tener nombres descriptivos
- Usar archivos `.env` para configuración
- Establecer límites de recursos
- Configurar política de reinicio `unless-stopped`
- Implementar health checks manuales

---

## 📝 Tareas

### Tarea 1: Preparación del Entorno (10 min)

1. Crea el directorio del proyecto
2. Copia los archivos de `starter/`
3. Revisa los archivos de configuración
4. Personaliza las variables según necesites

### Tarea 2: Despliegue de Servicios (25 min)

1. Despliega cada servicio con los recursos especificados
2. Usa los archivos `.env` proporcionados
3. Configura los puertos correctamente
4. Verifica que cada servicio esté corriendo

### Tarea 3: Configuración de Monitoreo (20 min)

1. Implementa el script `monitor.sh`
2. Configura alertas básicas por uso de recursos
3. Prueba el sistema de monitoreo
4. Genera un reporte de estado

### Tarea 4: Pruebas de Ciclo de Vida (15 min)

1. Prueba stop/start de servicios
2. Verifica comportamiento de restart policies
3. Simula fallo de un servicio
4. Documenta los tiempos de recuperación

### Tarea 5: Diagnóstico y Troubleshooting (20 min)

1. Introduce un problema intencionalmente
2. Usa las técnicas aprendidas para diagnosticar
3. Documenta el proceso de resolución
4. Crea un runbook básico

---

## 📋 Criterios de Evaluación

| Criterio                     | Puntos  |
| ---------------------------- | ------- |
| Servicios desplegados        | 20      |
| Configuración correcta       | 20      |
| Límites de recursos          | 15      |
| Sistema de monitoreo         | 20      |
| Documentación de diagnóstico | 15      |
| Limpieza y organización      | 10      |
| **Total**                    | **100** |

---

## 🚀 Comenzar

```bash
# 1. Ir al directorio del proyecto
cd bootcamp/week-03/3-proyecto/starter

# 2. Revisar los archivos disponibles
ls -la

# 3. Seguir las instrucciones en cada tarea
```

---

## 💡 Consejos

- Ejecuta los comandos uno por uno
- Verifica el estado después de cada paso
- Usa `docker stats` frecuentemente
- Guarda los logs importantes
- Documenta los problemas que encuentres

---

## 🔗 Navegación

| Ejercicios                                | Recursos                          |
| ----------------------------------------- | --------------------------------- |
| [← Volver a Ejercicios](../2-ejercicios/) | [Ir a Recursos →](../4-recursos/) |
