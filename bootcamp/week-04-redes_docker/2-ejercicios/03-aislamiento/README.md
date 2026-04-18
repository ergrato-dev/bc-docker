# 🔒 Ejercicio 03: Aislamiento de Redes

## 📋 Información del Ejercicio

| Atributo          | Valor                              |
| ----------------- | ---------------------------------- |
| **Duración**      | 45 minutos                         |
| **Nivel**         | Intermedio                         |
| **Objetivos**     | Segmentación, seguridad, multi-red |
| **Prerequisitos** | Ejercicios 01 y 02 completados     |

---

## 🎯 Objetivos de Aprendizaje

Al finalizar este ejercicio serás capaz de:

- ✅ Aislar contenedores en diferentes redes
- ✅ Implementar arquitectura de seguridad por capas
- ✅ Conectar contenedores a múltiples redes
- ✅ Entender la matriz de comunicación entre redes
- ✅ Aplicar principio de mínimo privilegio en redes

---

## 📝 Parte 1: Concepto de Aislamiento

### Arquitectura de Ejemplo

```
┌─────────────────────────────────────────────────────────────┐
│                        INTERNET                              │
│                            │                                 │
│                        ┌───┴───┐                            │
│                        │ :8080 │                            │
│                        └───┬───┘                            │
│  ┌─────────────────────────┼─────────────────────────────┐  │
│  │      FRONTEND NETWORK   │                             │  │
│  │  ┌──────────┐      ┌────┴─────┐                      │  │
│  │  │  nginx   │◄────►│   api    │                      │  │
│  │  └──────────┘      └────┬─────┘                      │  │
│  └─────────────────────────┼─────────────────────────────┘  │
│                            │                                 │
│  ┌─────────────────────────┼─────────────────────────────┐  │
│  │      BACKEND NETWORK    │                             │  │
│  │                    ┌────┴─────┐                       │  │
│  │                    │   api    │                       │  │
│  │                    └────┬─────┘                       │  │
│  │           ┌─────────────┼─────────────┐              │  │
│  │      ┌────┴─────┐  ┌────┴─────┐                      │  │
│  │      │ postgres │  │  redis   │                      │  │
│  │      └──────────┘  └──────────┘                      │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                              │
│  nginx ↔ api ✅     api ↔ postgres ✅                       │
│  nginx ↔ postgres ❌  (aislamiento)                         │
└─────────────────────────────────────────────────────────────┘
```

---

## 📝 Parte 2: Crear Redes Aisladas

### Paso 2.1: Limpiar Entorno

```bash
# Limpiar todo
docker rm -f $(docker ps -aq) 2>/dev/null
docker network prune -f
```

### Paso 2.2: Crear Redes Separadas

```bash
# Red para frontend (web, load balancer)
docker network create frontend-network

# Red para backend (APIs, bases de datos)
docker network create backend-network

# Verificar
docker network ls | grep -E "frontend|backend"
```

### Paso 2.3: Verificar Aislamiento por Defecto

```bash
# Contenedor en frontend
docker run -d --name frontend-app --network frontend-network alpine sleep 3600

# Contenedor en backend
docker run -d --name backend-db --network backend-network alpine sleep 3600

# Verificar que NO pueden comunicarse
docker exec frontend-app ping -c 2 -W 2 backend-db 2>&1 || echo "❌ No puede resolver backend-db"
docker exec backend-db ping -c 2 -W 2 frontend-app 2>&1 || echo "❌ No puede resolver frontend-app"
```

**Resultado:** Los contenedores en diferentes redes NO pueden comunicarse.

---

## 📝 Parte 3: Contenedor Puente (Multi-Red)

### Paso 3.1: Crear Contenedor con Acceso a Ambas Redes

```bash
# Crear API que conecta ambas redes
docker run -d \
  --name api-gateway \
  --network frontend-network \
  alpine sleep 3600

# Conectar también a backend
docker network connect backend-network api-gateway

# Verificar redes del contenedor
docker inspect api-gateway -f '{{range $k, $v := .NetworkSettings.Networks}}{{$k}} {{end}}'
# Output: frontend-network backend-network
```

### Paso 3.2: Verificar IPs en Cada Red

```bash
# Ver IPs asignadas
docker inspect api-gateway -f '
Frontend: {{.NetworkSettings.Networks.frontend-network.IPAddress}}
Backend: {{.NetworkSettings.Networks.backend-network.IPAddress}}'
```

### Paso 3.3: Probar Conectividad

```bash
# api-gateway puede hablar con frontend-app
docker exec api-gateway ping -c 2 frontend-app

# api-gateway puede hablar con backend-db
docker exec api-gateway ping -c 2 backend-db

# frontend-app SIGUE sin poder hablar con backend-db
docker exec frontend-app ping -c 2 -W 2 backend-db 2>&1 || echo "❌ Correcto: sigue aislado"
```

---

## 📝 Parte 4: Arquitectura Completa de 3 Capas

### Paso 4.1: Limpiar y Crear Estructura

```bash
# Limpiar
docker rm -f $(docker ps -aq) 2>/dev/null
docker network rm frontend-network backend-network 2>/dev/null

# Crear redes
docker network create dmz-network      # Para nginx (expuesto)
docker network create app-network      # Para aplicación
docker network create data-network     # Para bases de datos
```

### Paso 4.2: Crear Contenedores por Capa

```bash
# CAPA 1: DMZ - nginx (único expuesto al exterior)
docker run -d \
  --name nginx \
  --network dmz-network \
  -p 8080:80 \
  nginx:alpine

# CAPA 2: Aplicación - API
docker run -d \
  --name api \
  --network app-network \
  alpine sleep 3600

# CAPA 3: Datos - PostgreSQL y Redis
docker run -d \
  --name postgres \
  --network data-network \
  -e POSTGRES_PASSWORD=secret \
  postgres:15-alpine

docker run -d \
  --name redis \
  --network data-network \
  redis:alpine
```

### Paso 4.3: Conectar Capas Adyacentes

```bash
# nginx necesita hablar con api (conectar a app-network)
docker network connect app-network nginx

# api necesita hablar con postgres/redis (conectar a data-network)
docker network connect data-network api
```

### Paso 4.4: Verificar Matriz de Comunicación

```bash
echo "=== Verificando comunicación ==="

# nginx → api (debería funcionar)
echo -n "nginx → api: "
docker exec nginx ping -c 1 -W 2 api &>/dev/null && echo "✅" || echo "❌"

# nginx → postgres (NO debería funcionar)
echo -n "nginx → postgres: "
docker exec nginx ping -c 1 -W 2 postgres &>/dev/null && echo "✅ (MAL)" || echo "❌ (Correcto)"

# nginx → redis (NO debería funcionar)
echo -n "nginx → redis: "
docker exec nginx ping -c 1 -W 2 redis &>/dev/null && echo "✅ (MAL)" || echo "❌ (Correcto)"

# api → postgres (debería funcionar)
echo -n "api → postgres: "
docker exec api ping -c 1 -W 2 postgres &>/dev/null && echo "✅" || echo "❌"

# api → redis (debería funcionar)
echo -n "api → redis: "
docker exec api ping -c 1 -W 2 redis &>/dev/null && echo "✅" || echo "❌"

# api → nginx (debería funcionar)
echo -n "api → nginx: "
docker exec api ping -c 1 -W 2 nginx &>/dev/null && echo "✅" || echo "❌"

# postgres → nginx (NO debería funcionar)
echo -n "postgres → nginx: "
docker exec postgres ping -c 1 -W 2 nginx &>/dev/null && echo "✅ (MAL)" || echo "❌ (Correcto)"
```

**Resultado esperado:**

```
nginx → api: ✅
nginx → postgres: ❌ (Correcto)
nginx → redis: ❌ (Correcto)
api → postgres: ✅
api → redis: ✅
api → nginx: ✅
postgres → nginx: ❌ (Correcto)
```

---

## 📝 Parte 5: Visualizar Topología de Red

### Paso 5.1: Ver Contenedores por Red

```bash
echo "=== DMZ Network ==="
docker network inspect dmz-network -f '{{range .Containers}}  - {{.Name}}{{"\n"}}{{end}}'

echo "=== App Network ==="
docker network inspect app-network -f '{{range .Containers}}  - {{.Name}}{{"\n"}}{{end}}'

echo "=== Data Network ==="
docker network inspect data-network -f '{{range .Containers}}  - {{.Name}}{{"\n"}}{{end}}'
```

### Paso 5.2: Generar Resumen de Redes

```bash
# Script para mostrar topología
for net in dmz-network app-network data-network; do
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Red: $net"
  echo "Subnet: $(docker network inspect $net -f '{{range .IPAM.Config}}{{.Subnet}}{{end}}')"
  echo "Contenedores:"
  docker network inspect $net -f '{{range .Containers}}  {{.Name}}: {{.IPv4Address}}{{"\n"}}{{end}}'
done
```

---

## 📝 Parte 6: Escenario de Seguridad

### Paso 6.1: Simular Ataque desde DMZ

```bash
# Si un atacante compromete nginx, ¿qué puede alcanzar?
echo "=== Alcance desde nginx (DMZ comprometida) ==="

# Puede alcanzar api
docker exec nginx ping -c 1 -W 1 api &>/dev/null && echo "api: Alcanzable ⚠️" || echo "api: Aislado ✅"

# NO puede alcanzar datos directamente
docker exec nginx ping -c 1 -W 1 postgres &>/dev/null && echo "postgres: Alcanzable ❌ RIESGO" || echo "postgres: Aislado ✅"
docker exec nginx ping -c 1 -W 1 redis &>/dev/null && echo "redis: Alcanzable ❌ RIESGO" || echo "redis: Aislado ✅"
```

### Paso 6.2: Principio de Mínimo Privilegio

```bash
# Verificar que cada contenedor solo tiene acceso a lo necesario

# nginx: solo dmz + app
echo "Redes de nginx:"
docker inspect nginx -f '{{range $k, $v := .NetworkSettings.Networks}}  - {{$k}}{{"\n"}}{{end}}'

# api: app + data (pero no dmz directamente)
echo "Redes de api:"
docker inspect api -f '{{range $k, $v := .NetworkSettings.Networks}}  - {{$k}}{{"\n"}}{{end}}'

# postgres: solo data
echo "Redes de postgres:"
docker inspect postgres -f '{{range $k, $v := .NetworkSettings.Networks}}  - {{$k}}{{"\n"}}{{end}}'
```

---

## ✅ Checklist de Verificación

| Tarea                                                          | Completado |
| -------------------------------------------------------------- | ---------- |
| Crear redes separadas para aislamiento                         | ☐          |
| Verificar que contenedores en diferentes redes no se comunican | ☐          |
| Conectar contenedor a múltiples redes                          | ☐          |
| Implementar arquitectura de 3 capas                            | ☐          |
| Verificar matriz de comunicación correcta                      | ☐          |
| Nginx NO puede alcanzar base de datos                          | ☐          |
| API puede alcanzar nginx Y base de datos                       | ☐          |
| Base de datos NO puede alcanzar nginx                          | ☐          |

---

## 🧪 Desafío Extra

Implementa una arquitectura con estas reglas:

1. **DMZ**: contenedor `haproxy` (puerto 80 publicado)
2. **Web Tier**: contenedores `web1`, `web2`, `web3`
3. **App Tier**: contenedor `api`
4. **Data Tier**: contenedores `mysql`, `redis`

Reglas de comunicación:

- `haproxy` solo habla con `web1/2/3`
- `web1/2/3` solo hablan con `api`
- `api` solo habla con `mysql` y `redis`
- `mysql` y `redis` no hablan con nadie más

---

## 🧹 Limpieza Final

```bash
# Eliminar todos los contenedores
docker rm -f nginx api postgres redis 2>/dev/null
docker rm -f $(docker ps -aq) 2>/dev/null

# Eliminar redes personalizadas
docker network rm dmz-network app-network data-network 2>/dev/null
docker network prune -f

# Verificar estado limpio
docker ps -a
docker network ls
```

---

<div align="center">

⬅️ [Anterior: Comunicación](../02-comunicacion/README.md) | [Volver al Índice](../README.md)

</div>
