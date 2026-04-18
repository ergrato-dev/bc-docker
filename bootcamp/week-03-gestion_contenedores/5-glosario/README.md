# 📖 Glosario - Semana 03

## Gestión de Contenedores

Términos clave y definiciones para la Semana 03 del Bootcamp Docker.

---

## A

### Attach

Comando que conecta la terminal al proceso principal (PID 1) de un contenedor en ejecución. A diferencia de `exec`, no crea un nuevo proceso.

```bash
docker attach mi-contenedor
```

### ARG

Instrucción de Dockerfile que define variables disponibles solo durante el proceso de build. No persisten en la imagen final.

```dockerfile
ARG VERSION=1.0
```

---

## C

### cgroups (Control Groups)

Característica del kernel de Linux que permite limitar, contabilizar y aislar el uso de recursos (CPU, memoria, I/O) de procesos. Docker usa cgroups para implementar límites de recursos.

### Container Lifecycle

Ciclo de vida del contenedor que incluye los estados: Created, Running, Paused, Stopped, y Removed.

### CPU Shares

Peso relativo de CPU asignado a un contenedor. El valor por defecto es 1024. Un contenedor con 2048 shares recibe el doble de CPU que uno con 1024 cuando compiten por recursos.

```bash
docker run --cpu-shares=512 nginx
```

---

## D

### Daemon (Docker Daemon)

Proceso en segundo plano (`dockerd`) que gestiona objetos Docker como imágenes, contenedores, redes y volúmenes. Escucha solicitudes de la API de Docker.

### Detach

Modo de ejecución en segundo plano. Se activa con `-d` en `docker run`. Para desconectarse de un contenedor sin detenerlo: `Ctrl+P, Ctrl+Q`.

### docker diff

Comando que muestra los cambios realizados en el filesystem de un contenedor respecto a su imagen base.

```bash
docker diff mi-contenedor
# A = Added, C = Changed, D = Deleted
```

---

## E

### ENV

Instrucción de Dockerfile y flag de `docker run` para definir variables de entorno que persisten en runtime.

```dockerfile
ENV NODE_ENV=production
```

```bash
docker run -e NODE_ENV=production node
```

### Exec

Comando que ejecuta un nuevo proceso dentro de un contenedor en ejecución. A diferencia de `attach`, crea un proceso independiente.

```bash
docker exec -it mi-contenedor /bin/sh
```

### Exit Code

Código numérico que indica cómo terminó un proceso. 0 indica éxito, otros valores indican error. Códigos comunes: 137 (SIGKILL), 143 (SIGTERM).

---

## H

### Healthcheck

Mecanismo para verificar si un contenedor está funcionando correctamente. Puede definirse en Dockerfile o docker run.

```dockerfile
HEALTHCHECK CMD curl -f http://localhost/ || exit 1
```

---

## I

### Inspect

Comando que devuelve información detallada en formato JSON sobre objetos Docker (contenedores, imágenes, volúmenes, redes).

```bash
docker inspect mi-contenedor
docker inspect -f '{{.State.Status}}' mi-contenedor
```

---

## K

### Kill

Comando que envía la señal SIGKILL a un contenedor, terminándolo inmediatamente sin oportunidad de cleanup.

```bash
docker kill mi-contenedor
```

---

## L

### Logging Driver

Mecanismo que determina cómo Docker gestiona los logs de contenedores. Drivers disponibles: json-file, syslog, journald, fluentd, awslogs, etc.

```bash
docker run --log-driver=json-file --log-opt max-size=10m nginx
```

### Logs

Comando para ver la salida estándar (stdout) y error estándar (stderr) del proceso principal de un contenedor.

```bash
docker logs -f --tail 100 mi-contenedor
```

---

## M

### Memory Limit

Límite máximo de memoria RAM que un contenedor puede usar. Si se excede, el contenedor puede ser terminado por OOM Killer.

```bash
docker run --memory=512m nginx
```

### Memory Reservation

Límite suave de memoria (soft limit). Docker intenta mantener el uso de memoria del contenedor bajo este valor, pero puede excederlo si hay recursos disponibles.

```bash
docker run --memory=1g --memory-reservation=512m nginx
```

---

## N

### Namespaces

Característica del kernel de Linux que proporciona aislamiento de recursos. Docker usa namespaces para aislar: PID, Network, Mount, UTS, IPC, User.

---

## O

### OOM (Out of Memory)

Condición que ocurre cuando un proceso intenta usar más memoria de la disponible. El OOM Killer de Linux termina procesos para liberar memoria.

### OOM Killer

Mecanismo del kernel de Linux que termina procesos cuando el sistema se queda sin memoria. Docker puede configurarse para proteger contenedores del OOM Killer.

```bash
docker run --oom-kill-disable --memory=512m nginx
```

---

## P

### Pause

Comando que suspende todos los procesos de un contenedor usando la señal SIGSTOP. El contenedor mantiene su estado pero no consume CPU.

```bash
docker pause mi-contenedor
docker unpause mi-contenedor
```

### PID 1

El proceso principal de un contenedor. Es el primer proceso que se ejecuta y es responsable de gestionar señales y procesos hijos.

### PIDs Limit

Límite máximo de procesos que un contenedor puede crear. Útil para prevenir fork bombs.

```bash
docker run --pids-limit=100 nginx
```

---

## R

### Restart Policy

Política que define cuándo Docker debe reiniciar automáticamente un contenedor. Opciones: `no`, `always`, `unless-stopped`, `on-failure[:max-retries]`.

```bash
docker run --restart=unless-stopped nginx
```

---

## S

### SIGKILL

Señal (9) que termina un proceso inmediatamente. No puede ser capturada ni ignorada. Usada por `docker kill`.

### SIGTERM

Señal (15) que solicita la terminación graceful de un proceso. Puede ser capturada para realizar cleanup. Usada por `docker stop`.

### Stats

Comando que muestra uso de recursos en tiempo real de uno o más contenedores.

```bash
docker stats --no-stream
```

### Stop

Comando que envía SIGTERM al proceso principal, espera un timeout (default 10s), y luego envía SIGKILL si el proceso no ha terminado.

```bash
docker stop -t 5 mi-contenedor
```

### stdout/stderr

Flujos de salida estándar (stdout) y error estándar (stderr). Docker captura ambos del PID 1 y los hace disponibles vía `docker logs`.

---

## T

### Top

Comando que muestra los procesos corriendo dentro de un contenedor.

```bash
docker top mi-contenedor
```

### TTY

Pseudo-terminal que permite interacción con el contenedor. Se activa con `-t` en `docker run` o `docker exec`.

---

## U

### Update

Comando que permite modificar la configuración de un contenedor en ejecución (memoria, CPU, restart policy).

```bash
docker update --memory=1g --cpus=2 mi-contenedor
```

### Unpause

Comando que reanuda un contenedor pausado.

```bash
docker unpause mi-contenedor
```

---

## Tabla de Referencia Rápida

| Término | Comando/Uso       | Descripción                 |
| ------- | ----------------- | --------------------------- |
| attach  | `docker attach`   | Conectar a PID 1            |
| exec    | `docker exec -it` | Nuevo proceso en contenedor |
| logs    | `docker logs -f`  | Ver salida del contenedor   |
| stats   | `docker stats`    | Monitoreo de recursos       |
| inspect | `docker inspect`  | Información detallada       |
| stop    | `docker stop`     | Detener gracefully          |
| kill    | `docker kill`     | Terminar inmediatamente     |
| pause   | `docker pause`    | Suspender procesos          |
| restart | `docker restart`  | Reiniciar contenedor        |
| update  | `docker update`   | Modificar configuración     |

---

## 🔗 Navegación

| Recursos                              | Índice de la Semana              |
| ------------------------------------- | -------------------------------- |
| [← Volver a Recursos](../4-recursos/) | [Volver al README](../README.md) |
