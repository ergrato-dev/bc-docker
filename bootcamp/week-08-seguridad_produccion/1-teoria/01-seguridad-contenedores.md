# 🛡️ Seguridad en Contenedores Docker

## El Modelo de Seguridad de Docker

Los contenedores Docker **comparten el kernel del host**. Un fallo de seguridad en el kernel afecta a todos. Por eso, a diferencia de las VMs, la seguridad por capas es fundamental:

```
┌─────────────────────────────┐
│   Aplicación (contenedor)   │  ← Tu código, dependencias
├─────────────────────────────┤
│   Docker Runtime            │  ← Docker Engine, containerd
├─────────────────────────────┤
│   Kernel del Host           │  ← COMPARTIDO entre contenedores
├─────────────────────────────┤
│   Hardware                  │
└─────────────────────────────┘
```

---

## Superficie de Ataque

| Vector de Ataque           | Riesgo                                          | Mitigación                        |
| -------------------------- | ----------------------------------------------- | --------------------------------- |
| Imagen con vulnerabilidades | CVEs explotables en tiempo de ejecución        | Escaneo + imágenes actualizadas   |
| Root en contenedor         | Escalada de privilegios si hay escape           | Usuario no-root                   |
| Puertos expuestos extras   | Mayor superficie de ataque de red               | Solo exponer lo necesario         |
| Secrets en env vars        | Visibles en `docker inspect`, logs              | Secrets como archivos             |
| Capacidades de Linux extra | Más permisos del necesario para la app          | `cap_drop: ALL` + añadir mínimas  |
| Imagen base grande         | Más software = más CVEs potenciales             | Imágenes mínimas (Alpine, Distroless)|
| Contenido writable         | Persistencia de malware si hay exploit          | `read_only: true` en filesystem   |

---

## Principio de Mínimo Privilegio

El principio fundamental es: **conceder solo los permisos estrictamente necesarios**.

### Limitar Capacidades de Linux

```dockerfile
# Por defecto Docker otorga ~14 capacidades de Linux
# Con cap_drop eliminamos todas y añadimos solo las necesarias

# En Dockerfile (limitar en tiempo de build no es posible,
# pero documentar las capacidades necesarias):
# NOTA: esta sería para net_bind_service (binding <1024)

EXPOSE 8080   # Usar puertos > 1024 evita necesitar net_bind_service
```

```yaml
# En docker-compose.yml
services:
  api:
    image: myapp:latest
    cap_drop:
      - ALL                 # Eliminar TODAS las capacidades
    cap_add:
      - NET_BIND_SERVICE    # Solo si necesita vincular puertos <1024
    # O para un servidor web en puerto > 1024: solo cap_drop: ALL
```

### Filesystem de Solo Lectura

```yaml
services:
  api:
    image: myapp:latest
    read_only: true          # Sistema de archivos de solo lectura
    tmpfs:
      - /tmp                 # Areas específicas donde sí se puede escribir
      - /var/run
```

### Sin Escalada de Privilegios

```yaml
services:
  api:
    image: myapp:latest
    security_opt:
      - no-new-privileges:true  # El proceso no puede escalar privilegios
```

---

## Namespaces y cgroups

Docker usa estas características del kernel para aislar contenedores:

| Mecanismo   | Qué aísla                                     |
| ----------- | --------------------------------------------- |
| `pid`       | Árbol de procesos                             |
| `net`       | Interfaces de red, rutas, puertos             |
| `mnt`       | Sistema de archivos                           |
| `uts`       | Hostname y dominio                            |
| `ipc`       | Colas de mensajes, semáforos                  |
| `user`      | UIDs y GIDs (user namespaces)                 |

Los **cgroups** limitan recursos (CPU, RAM, I/O) y previenen ataques DoS:

```yaml
services:
  api:
    image: myapp:latest
    deploy:
      resources:
        limits:
          cpus: '0.50'
          memory: 256M
```

---

## Opciones de Seguridad en Compose

```yaml
services:
  api:
    image: myapp:1.2.3          # Tag específico, NUNCA latest en prod
    read_only: true              # Filesystem read-only
    security_opt:
      - no-new-privileges:true   # No escalada de privilegios
    cap_drop:
      - ALL                      # Eliminar todas las capacidades
    tmpfs:
      - /tmp:size=50m,mode=1777  # /tmp con tamaño limitado
    user: "1001:1001"            # UID:GID no-root
    deploy:
      resources:
        limits:
          cpus: '1.0'
          memory: 512M
```

---

## Evitar Modo Privilegiado

```yaml
# ❌ NUNCA en producción
services:
  app:
    privileged: true    # Acceso total al host: equivalente a root en el host
```

```yaml
# ✅ Si necesitas acceso a dispositivos del host, sé específico
services:
  app:
    devices:
      - /dev/video0:/dev/video0    # Solo el dispositivo que necesitas
```

---

## Auditoría: Verificar Configuración Actual

```bash
# Ver capacidades del contenedor
docker inspect <container> | jq '.[0].HostConfig.CapAdd'
docker inspect <container> | jq '.[0].HostConfig.CapDrop'

# Ver si corre como root
docker exec <container> id

# Ver si el filesystem es read-only
docker inspect <container> | jq '.[0].HostConfig.ReadonlyRootfs'

# Benchmark de seguridad con Docker Bench
docker run --rm --net host --pid host --userns host --cap-add audit_control \
  -v /etc:/etc:ro -v /usr/bin/containerd:/usr/bin/containerd:ro \
  docker/docker-bench-security
```

---

## Resumen de Configuración Segura

```yaml
# Plantilla de servicio production-ready
services:
  app:
    image: myapp:1.2.3          # ← Tag específico
    user: "1001:1001"           # ← No root
    read_only: true             # ← No escritura en container layer
    tmpfs: [/tmp]               # ← /tmp en RAM si se necesita escritura
    cap_drop: [ALL]             # ← Sin capacidades
    security_opt:
      - no-new-privileges:true  # ← No escalada
    deploy:
      resources:
        limits:
          cpus: '1.0'           # ← Límite de CPU
          memory: 512M          # ← Límite de RAM
```

---

## 📚 Siguiente Tema

[→ 02. Usuarios No-Root en Dockerfiles](./02-usuarios-no-root.md)
