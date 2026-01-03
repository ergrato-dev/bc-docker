# 📚 Comandos de Gestión de Contenedores

## 🎯 Objetivos de Aprendizaje

Al finalizar esta sección, serás capaz de:

- Inspeccionar contenedores con `docker inspect`
- Ver procesos con `docker top`
- Detectar cambios con `docker diff`
- Renombrar y actualizar contenedores
- Copiar archivos entre host y contenedor

---

## 🔍 Inspeccionar Contenedores

### docker inspect

Obtiene información detallada en formato JSON:

```bash
# Inspeccionar contenedor completo
docker inspect mi-nginx

# Formato más legible con jq
docker inspect mi-nginx | jq

# Extraer información específica con --format
docker inspect -f '{{.State.Status}}' mi-nginx
# running

docker inspect -f '{{.NetworkSettings.IPAddress}}' mi-nginx
# 172.17.0.2

docker inspect -f '{{.Config.Env}}' mi-nginx
# [PATH=/usr/local/sbin:... NGINX_VERSION=1.25.0]
```

### Campos útiles de inspect

```bash
# Estado del contenedor
docker inspect -f '{{.State.Status}}' mi-nginx
docker inspect -f '{{.State.Running}}' mi-nginx
docker inspect -f '{{.State.Pid}}' mi-nginx
docker inspect -f '{{.State.ExitCode}}' mi-nginx
docker inspect -f '{{.State.StartedAt}}' mi-nginx

# Configuración de red
docker inspect -f '{{.NetworkSettings.IPAddress}}' mi-nginx
docker inspect -f '{{.NetworkSettings.Ports}}' mi-nginx
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' mi-nginx

# Montajes y volúmenes
docker inspect -f '{{.Mounts}}' mi-nginx
docker inspect -f '{{range .Mounts}}{{.Source}} -> {{.Destination}}{{"\n"}}{{end}}' mi-nginx

# Variables de entorno
docker inspect -f '{{.Config.Env}}' mi-nginx

# Comando de inicio
docker inspect -f '{{.Config.Cmd}}' mi-nginx
docker inspect -f '{{.Config.Entrypoint}}' mi-nginx

# Límites de recursos
docker inspect -f '{{.HostConfig.Memory}}' mi-nginx
docker inspect -f '{{.HostConfig.CpuShares}}' mi-nginx
```

### Tabla de plantillas útiles

| Información      | Template                             |
| ---------------- | ------------------------------------ |
| IP Address       | `{{.NetworkSettings.IPAddress}}`     |
| Estado           | `{{.State.Status}}`                  |
| PID del proceso  | `{{.State.Pid}}`                     |
| Exit Code        | `{{.State.ExitCode}}`                |
| Puertos          | `{{.NetworkSettings.Ports}}`         |
| Nombre de imagen | `{{.Config.Image}}`                  |
| Fecha de inicio  | `{{.State.StartedAt}}`               |
| Política restart | `{{.HostConfig.RestartPolicy.Name}}` |

---

## 📊 Ver Procesos del Contenedor

### docker top

Muestra los procesos corriendo dentro del contenedor:

```bash
# Ver procesos
docker top mi-nginx

# Salida ejemplo:
# UID    PID    PPID   C  STIME  TTY  TIME      CMD
# root   1234   1233   0  10:00  ?    00:00:00  nginx: master process
# nginx  1240   1234   0  10:00  ?    00:00:00  nginx: worker process

# Con opciones de ps
docker top mi-nginx -aux
docker top mi-nginx -eo pid,comm,rss
```

### docker stats

Monitoreo en tiempo real de recursos:

```bash
# Stats de todos los contenedores (en vivo)
docker stats

# Stats de contenedor específico
docker stats mi-nginx

# Una sola lectura (sin refresh)
docker stats --no-stream

# Formato personalizado
docker stats --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}"

# Solo IDs específicos
docker stats web1 web2 db
```

### Columnas de docker stats

| Columna      | Descripción                     |
| ------------ | ------------------------------- |
| CONTAINER ID | ID del contenedor               |
| NAME         | Nombre del contenedor           |
| CPU %        | Porcentaje de CPU usado         |
| MEM USAGE    | Memoria usada / Límite          |
| MEM %        | Porcentaje de memoria usada     |
| NET I/O      | Datos de red recibidos/enviados |
| BLOCK I/O    | Datos leídos/escritos a disco   |
| PIDS         | Número de procesos              |

---

## 📝 Detectar Cambios

### docker diff

Muestra archivos modificados respecto a la imagen original:

```bash
# Ver cambios en el filesystem
docker diff mi-nginx

# Salida ejemplo:
# A /run/nginx.pid          # A = Added (añadido)
# C /var                     # C = Changed (modificado)
# C /var/cache
# C /var/cache/nginx
# A /var/cache/nginx/client_temp
# D /tmp/old-file           # D = Deleted (eliminado)
```

| Símbolo | Significado | Descripción                   |
| ------- | ----------- | ----------------------------- |
| A       | Added       | Archivo/directorio añadido    |
| C       | Changed     | Archivo/directorio modificado |
| D       | Deleted     | Archivo/directorio eliminado  |

```bash
# Ejemplo práctico: ver qué cambió después de instalar algo
docker run -d --name test alpine sleep 3600
docker exec test apk add curl
docker diff test
# C /lib
# C /lib/apk
# A /lib/apk/db/...
# A /usr/bin/curl
# ...
```

---

## 🏷️ Renombrar Contenedores

### docker rename

```bash
# Renombrar contenedor
docker rename viejo-nombre nuevo-nombre

# Ejemplo
docker rename my-nginx produccion-nginx

# Verificar
docker ps -f name=produccion-nginx
```

> 💡 El contenedor puede estar corriendo o detenido al renombrarlo.

---

## 🔄 Actualizar Contenedores

### docker update

Modifica configuración de contenedores en ejecución:

```bash
# Actualizar límites de memoria
docker update --memory=512m mi-nginx
docker update --memory=1g --memory-swap=2g mi-nginx

# Actualizar límites de CPU
docker update --cpus=2 mi-nginx
docker update --cpu-shares=512 mi-nginx

# Actualizar política de reinicio
docker update --restart=always mi-nginx
docker update --restart=unless-stopped mi-nginx

# Actualizar múltiples contenedores
docker update --memory=256m web1 web2 web3
```

### Opciones actualizables

| Opción           | Descripción                |
| ---------------- | -------------------------- |
| `--memory`       | Límite de memoria          |
| `--memory-swap`  | Límite de swap             |
| `--cpus`         | Número de CPUs             |
| `--cpu-shares`   | CPU shares (peso relativo) |
| `--cpu-period`   | Período de CPU CFS         |
| `--cpu-quota`    | Cuota de CPU CFS           |
| `--restart`      | Política de reinicio       |
| `--blkio-weight` | Peso de I/O de bloque      |

---

## 📁 Copiar Archivos

### docker cp

Copia archivos entre contenedor y host:

```bash
# Sintaxis
docker cp [OPCIONES] CONTENEDOR:RUTA_ORIGEN RUTA_DESTINO
docker cp [OPCIONES] RUTA_ORIGEN CONTENEDOR:RUTA_DESTINO

# Copiar desde contenedor a host
docker cp mi-nginx:/etc/nginx/nginx.conf ./nginx.conf
docker cp mi-nginx:/var/log/nginx/ ./logs/

# Copiar desde host a contenedor
docker cp ./mi-config.conf mi-nginx:/etc/nginx/conf.d/
docker cp ./html/ mi-nginx:/usr/share/nginx/html/

# Copiar archivo específico
docker cp mi-nginx:/etc/hostname ./hostname-container

# Opciones
docker cp -a mi-nginx:/app ./backup  # -a: preservar permisos
docker cp -L mi-nginx:/symlink ./    # -L: seguir symlinks
```

### Ejemplos prácticos

```bash
# Extraer logs para análisis
docker cp mi-app:/var/log/app.log ./app.log

# Actualizar configuración sin rebuild
docker cp ./nginx.conf mi-nginx:/etc/nginx/nginx.conf
docker exec mi-nginx nginx -s reload

# Backup de datos
docker cp mi-db:/var/lib/mysql ./backup-mysql/

# Inyectar script y ejecutar
docker cp ./fix-script.sh mi-app:/tmp/
docker exec mi-app sh /tmp/fix-script.sh
```

---

## 📤 Exportar e Importar

### docker export / import

```bash
# Exportar filesystem del contenedor a tar
docker export mi-nginx > nginx-export.tar
docker export -o nginx-export.tar mi-nginx

# Importar como nueva imagen
docker import nginx-export.tar mi-nginx-importada:v1
cat nginx-export.tar | docker import - mi-nginx:imported

# Con mensaje de commit
docker import -m "Nginx customizado" nginx-export.tar custom/nginx:v1
```

> ⚠️ **Nota**: `export/import` pierde metadatos (CMD, ENV, etc.). Para preservarlos, usa `docker commit` o `docker save/load`.

---

## 💾 Crear Imagen desde Contenedor

### docker commit

Crea una imagen a partir del estado actual del contenedor:

```bash
# Sintaxis
docker commit [OPCIONES] CONTENEDOR IMAGEN[:TAG]

# Commit básico
docker commit mi-nginx mi-nginx-modificado:v1

# Con autor y mensaje
docker commit -a "dev@example.com" -m "Añadido curl" mi-nginx custom-nginx:v1

# Con cambios de configuración
docker commit --change='CMD ["nginx", "-g", "daemon off;"]' mi-nginx nginx-custom:v1
docker commit --change='ENV DEBUG=true' mi-nginx debug-nginx:v1
docker commit --change='EXPOSE 8080' mi-nginx nginx-8080:v1
```

### Opciones de commit

| Opción | Descripción                                |
| ------ | ------------------------------------------ |
| `-a`   | Autor de la imagen                         |
| `-m`   | Mensaje de commit                          |
| `-c`   | Aplicar instrucciones Dockerfile al commit |
| `-p`   | Pausar contenedor durante commit           |

---

## 📊 Resumen de Comandos

| Comando   | Propósito                             | Ejemplo                             |
| --------- | ------------------------------------- | ----------------------------------- |
| `inspect` | Información detallada JSON            | `docker inspect -f '{{.State}}' c1` |
| `top`     | Procesos del contenedor               | `docker top mi-nginx`               |
| `stats`   | Uso de recursos en tiempo real        | `docker stats --no-stream`          |
| `diff`    | Cambios en filesystem                 | `docker diff mi-nginx`              |
| `rename`  | Renombrar contenedor                  | `docker rename old new`             |
| `update`  | Actualizar config (recursos, restart) | `docker update --memory=1g c1`      |
| `cp`      | Copiar archivos host ↔ contenedor     | `docker cp c1:/logs ./`             |
| `export`  | Exportar filesystem a tar             | `docker export c1 > c1.tar`         |
| `commit`  | Crear imagen desde contenedor         | `docker commit c1 img:v1`           |

---

## ✅ Verificación de Aprendizaje

1. ¿Cómo obtendrías solo la IP de un contenedor con inspect?
2. ¿Qué significan A, C, D en `docker diff`?
3. ¿Cuál es la diferencia entre `export` y `commit`?
4. ¿Cómo actualizarías la memoria de un contenedor en ejecución?
5. ¿Cómo copiarías un directorio completo desde un contenedor?

---

## 🔗 Navegación

| ← Anterior                             | Siguiente →                                   |
| -------------------------------------- | --------------------------------------------- |
| [01 - Ciclo de Vida](01-ciclo-vida.md) | [03 - Logs y Monitoreo](03-logs-monitoreo.md) |
