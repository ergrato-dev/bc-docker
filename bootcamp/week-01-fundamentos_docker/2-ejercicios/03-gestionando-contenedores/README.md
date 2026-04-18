# 💻 Ejercicio 03: Gestionando Contenedores

## 🎯 Objetivos

- Dominar el ciclo de vida de los contenedores
- Practicar comandos de gestión avanzados
- Entender estados de contenedores
- Trabajar con múltiples contenedores

## ⏱️ Duración Estimada

40 minutos

## 📋 Requisitos Previos

- Ejercicios 01 y 02 completados

---

## 📝 Instrucciones

### Paso 1: Estados de un Contenedor

Un contenedor puede estar en diferentes estados:

```
Created → Running → Paused → Running → Stopped → Removed
                ↓
            Restarting
```

Vamos a explorar cada estado:

```bash
# Crear contenedor sin iniciarlo
docker create --name estado-test nginx:alpine

# Ver estado (Created)
docker ps -a --filter name=estado-test

# Iniciar el contenedor
docker start estado-test

# Ver estado (Running)
docker ps --filter name=estado-test

# Pausar el contenedor
docker pause estado-test

# Ver estado (Paused)
docker ps --filter name=estado-test

# Reanudar el contenedor
docker unpause estado-test

# Detener el contenedor
docker stop estado-test

# Ver estado (Exited)
docker ps -a --filter name=estado-test

# Eliminar el contenedor
docker rm estado-test
```

---

### Paso 2: Trabajar con Múltiples Contenedores

Crearemos una mini infraestructura con varios contenedores:

```bash
# Crear red para comunicación
docker network create mi-red

# Contenedor 1: Servidor web
docker run -d \
  --name web \
  --network mi-red \
  -p 8080:80 \
  nginx:alpine

# Contenedor 2: Base de datos Redis
docker run -d \
  --name cache \
  --network mi-red \
  redis:alpine

# Contenedor 3: Herramienta de diagnóstico
docker run -d \
  --name tools \
  --network mi-red \
  alpine sleep infinity
```

---

### Paso 3: Verificar Conectividad

```bash
# Entrar al contenedor tools
docker exec -it tools sh

# Dentro del contenedor, probar conectividad:
# Ping al servidor web (por nombre)
ping -c 3 web

# Ping al cache (por nombre)
ping -c 3 cache

# Verificar que el servidor web responde
wget -qO- http://web

# Salir
exit
```

📌 **Observa**: Docker DNS resuelve automáticamente los nombres de contenedores en la misma red.

---

### Paso 4: Monitorear Recursos

```bash
# Ver estadísticas de todos los contenedores
docker stats --no-stream

# Ver solo nuestros contenedores
docker stats --no-stream web cache tools

# Estadísticas en formato personalizado
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}"
```

---

### Paso 5: Copiar Archivos

Puedes copiar archivos entre el host y los contenedores:

```bash
# Crear un archivo en el host
echo "<h1>Mi página personalizada</h1>" > mi-pagina.html

# Copiar al contenedor web
docker cp mi-pagina.html web:/usr/share/nginx/html/index.html

# Verificar el cambio
curl http://localhost:8080

# Copiar archivo DESDE el contenedor
docker cp web:/etc/nginx/nginx.conf ./nginx-backup.conf

# Verificar
cat nginx-backup.conf
```

---

### Paso 6: Ver Diferencias (diff)

```bash
# Ver cambios en el sistema de archivos del contenedor
docker diff web
```

📌 **Símbolos**:

- `A` = Added (archivo añadido)
- `C` = Changed (archivo modificado)
- `D` = Deleted (archivo eliminado)

---

### Paso 7: Reinicio Automático

```bash
# Crear contenedor con política de reinicio
docker run -d \
  --name auto-restart \
  --restart unless-stopped \
  nginx:alpine

# Ver la política de reinicio
docker inspect -f '{{.HostConfig.RestartPolicy.Name}}' auto-restart
```

**Políticas de reinicio:**

| Política         | Descripción                                  |
| ---------------- | -------------------------------------------- |
| `no`             | No reiniciar (predeterminado)                |
| `on-failure`     | Reiniciar solo si falla                      |
| `always`         | Reiniciar siempre                            |
| `unless-stopped` | Reiniciar a menos que se detenga manualmente |

---

### Paso 8: Límites de Recursos

```bash
# Crear contenedor con límites
docker run -d \
  --name limitado \
  --memory="128m" \
  --cpus="0.5" \
  nginx:alpine

# Ver límites aplicados
docker inspect -f 'Memory: {{.HostConfig.Memory}} CPUs: {{.HostConfig.NanoCpus}}' limitado

# Ver en stats
docker stats --no-stream limitado
```

---

### Paso 9: Renombrar y Actualizar

```bash
# Renombrar un contenedor
docker rename limitado nginx-limitado

# Actualizar configuración en caliente
docker update --memory="256m" nginx-limitado

# Verificar cambio
docker inspect -f '{{.HostConfig.Memory}}' nginx-limitado
```

---

### Paso 10: Limpieza Completa

```bash
# Detener todos nuestros contenedores
docker stop web cache tools auto-restart nginx-limitado

# Eliminar contenedores
docker rm web cache tools auto-restart nginx-limitado

# Eliminar la red
docker network rm mi-red

# Limpiar archivos locales
rm mi-pagina.html nginx-backup.conf

# Verificar limpieza
docker ps -a
docker network ls
```

---

## ✅ Checklist de Verificación

- [ ] Exploré los diferentes estados de un contenedor
- [ ] Creé múltiples contenedores en una red
- [ ] Verifiqué conectividad entre contenedores
- [ ] Monitoreé recursos con `docker stats`
- [ ] Copié archivos con `docker cp`
- [ ] Vi diferencias con `docker diff`
- [ ] Configuré política de reinicio
- [ ] Apliqué límites de recursos
- [ ] Limpié todos los recursos creados

---

## 🎯 Desafío Extra

Crea un escenario con:

1. Una red llamada `app-network`
2. Un contenedor nginx llamado `frontend` expuesto en puerto 3000
3. Un contenedor redis llamado `backend`
4. Límite de 256MB de RAM para cada contenedor
5. Política de reinicio `unless-stopped`

<details>
<summary>💡 Solución</summary>

```bash
# Crear red
docker network create app-network

# Frontend
docker run -d \
  --name frontend \
  --network app-network \
  -p 3000:80 \
  --memory="256m" \
  --restart unless-stopped \
  nginx:alpine

# Backend
docker run -d \
  --name backend \
  --network app-network \
  --memory="256m" \
  --restart unless-stopped \
  redis:alpine

# Verificar
docker ps
docker stats --no-stream frontend backend

# Limpieza
docker stop frontend backend
docker rm frontend backend
docker network rm app-network
```

</details>

---

## 🔗 Navegación

| ← Ejercicio Anterior                                            | Ir al Proyecto →                               |
| --------------------------------------------------------------- | ---------------------------------------------- |
| [02 - Explorando Imágenes](../02-explorando-imagenes/README.md) | [Proyecto Semanal](../../3-proyecto/README.md) |
