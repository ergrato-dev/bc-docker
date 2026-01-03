# 🔗 Ejercicio 02: Comunicación entre Contenedores

## 📋 Información del Ejercicio

| Atributo          | Valor                              |
| ----------------- | ---------------------------------- |
| **Duración**      | 50 minutos                         |
| **Nivel**         | Intermedio                         |
| **Objetivos**     | DNS interno, aliases, port mapping |
| **Prerequisitos** | Ejercicio 01 completado            |

---

## 🎯 Objetivos de Aprendizaje

Al finalizar este ejercicio serás capaz de:

- ✅ Usar DNS interno para resolver nombres de contenedores
- ✅ Configurar network aliases
- ✅ Implementar port mapping correctamente
- ✅ Comunicar servicios entre contenedores
- ✅ Diagnosticar problemas de conectividad

---

## 📝 Parte 1: DNS Interno en Acción

### Paso 1.1: Preparar el Entorno

```bash
# Crear red para el ejercicio
docker network create app-network

# Verificar creación
docker network ls | grep app-network
```

### Paso 1.2: Crear Contenedores con Nombres

```bash
# Servidor web
docker run -d \
  --name webserver \
  --network app-network \
  nginx:alpine

# Cliente para pruebas
docker run -d \
  --name client \
  --network app-network \
  alpine sleep 3600
```

### Paso 1.3: Probar Resolución DNS

```bash
# Resolver nombre del webserver
docker exec client nslookup webserver

# Hacer ping por nombre
docker exec client ping -c 3 webserver

# Obtener página web por nombre
docker exec client wget -qO- http://webserver
```

**Resultado esperado:** La resolución DNS funciona y puedes acceder al servidor web por nombre.

### Paso 1.4: Comparar con Red Bridge Default

```bash
# Crear contenedores en red default (sin especificar --network)
docker run -d --name default-web nginx:alpine
docker run -d --name default-client alpine sleep 3600

# Intentar resolver DNS
docker exec default-client nslookup default-web
# FALLA: bad address 'default-web'

# Solo funciona por IP
WEB_IP=$(docker inspect default-web -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}')
docker exec default-client ping -c 2 $WEB_IP
```

**Lección:** El DNS interno SOLO funciona en redes personalizadas.

---

## 📝 Parte 2: Network Aliases

### Paso 2.1: Crear Contenedor con Alias

```bash
# Servidor de base de datos con múltiples nombres
docker run -d \
  --name postgres-main \
  --network app-network \
  --network-alias db \
  --network-alias database \
  --network-alias postgres \
  -e POSTGRES_PASSWORD=secret \
  postgres:15-alpine
```

### Paso 2.2: Verificar Aliases

```bash
# Todos estos nombres resuelven al mismo contenedor
docker exec client nslookup db
docker exec client nslookup database
docker exec client nslookup postgres
docker exec client nslookup postgres-main

# Todos deberían mostrar la misma IP
```

### Paso 2.3: Simular Balanceo de Carga con Aliases

```bash
# Crear múltiples instancias con el mismo alias
docker run -d --name web1 --network app-network --network-alias webapp nginx:alpine
docker run -d --name web2 --network app-network --network-alias webapp nginx:alpine
docker run -d --name web3 --network app-network --network-alias webapp nginx:alpine

# Resolver el alias múltiples veces
for i in 1 2 3 4 5; do
  docker exec client nslookup webapp | grep "Address" | tail -1
done
```

**Observación:** El DNS de Docker realiza round-robin entre las IPs.

### Paso 2.4: Verificar IPs Individuales

```bash
# Ver IP de cada contenedor
docker inspect web1 -f '{{range .NetworkSettings.Networks}}web1: {{.IPAddress}}{{end}}'
docker inspect web2 -f '{{range .NetworkSettings.Networks}}web2: {{.IPAddress}}{{end}}'
docker inspect web3 -f '{{range .NetworkSettings.Networks}}web3: {{.IPAddress}}{{end}}'
```

---

## 📝 Parte 3: Port Mapping

### Paso 3.1: Limpiar y Preparar

```bash
# Limpiar contenedores anteriores
docker rm -f $(docker ps -aq)

# Recrear red
docker network create web-network
```

### Paso 3.2: Publicar Puerto Específico

```bash
# Puerto fijo: host:8080 -> container:80
docker run -d \
  --name nginx-fixed \
  --network web-network \
  -p 8080:80 \
  nginx:alpine

# Verificar
docker ps --format "{{.Names}}: {{.Ports}}"

# Probar acceso desde el host
curl http://localhost:8080
```

### Paso 3.3: Puerto Aleatorio

```bash
# Docker asigna puerto disponible
docker run -d \
  --name nginx-random \
  --network web-network \
  -p 80 \
  nginx:alpine

# Ver puerto asignado
docker port nginx-random
# 80/tcp -> 0.0.0.0:XXXXX

# Probar con el puerto asignado
PORT=$(docker port nginx-random 80 | cut -d: -f2)
curl http://localhost:$PORT
```

### Paso 3.4: Binding a Localhost Solamente

```bash
# Solo accesible desde localhost
docker run -d \
  --name nginx-local \
  --network web-network \
  -p 127.0.0.1:8081:80 \
  nginx:alpine

# Funciona desde localhost
curl http://localhost:8081

# NO funcionaría desde otra máquina en la red
# curl http://192.168.x.x:8081 (desde otro host)
```

### Paso 3.5: Múltiples Puertos

```bash
# Crear imagen simple que escucha en múltiples puertos
docker run -d \
  --name multi-port \
  --network web-network \
  -p 8082:80 \
  -p 8083:443 \
  nginx:alpine

# Verificar ambos puertos publicados
docker port multi-port
```

---

## 📝 Parte 4: Comunicación de Servicios

### Paso 4.1: Escenario Real - App + Database

```bash
# Limpiar
docker rm -f $(docker ps -aq)
docker network create myapp-network

# 1. Base de datos (sin puerto publicado - solo interno)
docker run -d \
  --name myapp-db \
  --network myapp-network \
  --network-alias db \
  -e POSTGRES_USER=app \
  -e POSTGRES_PASSWORD=secret123 \
  -e POSTGRES_DB=myapp \
  postgres:15-alpine

# 2. Esperar a que inicie
sleep 5

# 3. Aplicación que conecta a la DB
docker run -d \
  --name myapp-api \
  --network myapp-network \
  -p 3000:3000 \
  -e DATABASE_URL=postgres://app:secret123@db:5432/myapp \
  alpine sleep 3600
```

### Paso 4.2: Verificar Conectividad Interna

```bash
# La API puede resolver y conectar a la DB
docker exec myapp-api nslookup db
docker exec myapp-api ping -c 2 db

# Instalar cliente postgres para probar conexión
docker exec myapp-api apk add --no-cache postgresql-client

# Conectar a la base de datos
docker exec myapp-api psql postgres://app:secret123@db:5432/myapp -c '\l'
```

### Paso 4.3: Verificar que DB no es Accesible Externamente

```bash
# La base de datos NO tiene puerto publicado
docker port myapp-db
# (vacío)

# No se puede acceder desde el host
# psql -h localhost -p 5432 -U app myapp
# Error: connection refused (o timeout)
```

**Seguridad:** La base de datos solo es accesible desde dentro de la red Docker.

---

## 📝 Parte 5: Diagnóstico de Conectividad

### Paso 5.1: Herramientas de Diagnóstico

```bash
# Crear contenedor con herramientas de red
docker run -d \
  --name nettools \
  --network myapp-network \
  nicolaka/netshoot sleep 3600
```

### Paso 5.2: Diagnósticos Comunes

```bash
# Ver configuración de red
docker exec nettools ip addr
docker exec nettools ip route

# Ver DNS configurado
docker exec nettools cat /etc/resolv.conf

# Resolver nombres
docker exec nettools nslookup myapp-db
docker exec nettools nslookup myapp-api

# Probar puertos específicos
docker exec nettools nc -zv myapp-db 5432
docker exec nettools nc -zv myapp-api 3000
```

### Paso 5.3: Traceroute y Diagnóstico Avanzado

```bash
# Ver ruta de red
docker exec nettools traceroute myapp-db

# Ver conexiones activas
docker exec nettools netstat -an | grep ESTABLISHED

# Capturar tráfico (breve)
docker exec nettools timeout 5 tcpdump -i eth0 -c 10
```

---

## ✅ Checklist de Verificación

| Tarea                                           | Completado |
| ----------------------------------------------- | ---------- |
| Resolver contenedor por nombre DNS              | ☐          |
| Verificar que DNS no funciona en red default    | ☐          |
| Crear contenedor con network aliases            | ☐          |
| Verificar round-robin DNS con múltiples aliases | ☐          |
| Publicar puerto específico (-p 8080:80)         | ☐          |
| Publicar puerto aleatorio (-p 80)               | ☐          |
| Binding solo a localhost (127.0.0.1)            | ☐          |
| Comunicar aplicación con base de datos por DNS  | ☐          |
| Verificar que DB no es accesible externamente   | ☐          |
| Usar herramientas de diagnóstico de red         | ☐          |

---

## 🧪 Desafío Extra

Implementa el siguiente escenario:

1. Red `frontend-net` con contenedor `nginx` publicando puerto 80
2. Red `backend-net` con contenedor `postgres` (sin puerto público)
3. Contenedor `api` conectado a AMBAS redes
4. Verifica que:
   - `nginx` puede comunicarse con `api`
   - `api` puede comunicarse con `postgres`
   - `nginx` NO puede comunicarse con `postgres`

---

## 🧹 Limpieza Final

```bash
# Eliminar todos los contenedores
docker rm -f $(docker ps -aq)

# Eliminar redes personalizadas
docker network prune -f

# Verificar
docker ps -a
docker network ls
```

---

<div align="center">

⬅️ [Anterior: Redes Básicas](../01-redes-basicas/README.md) | [Siguiente: Aislamiento →](../03-aislamiento/README.md)

</div>
