# 📖 Glosario - Semana 05: Volúmenes y Persistencia

Términos y conceptos clave sobre almacenamiento persistente en Docker.

---

## 🔤 Índice Alfabético

[B](#b) | [C](#c) | [D](#d) | [E](#e) | [G](#g) | [I](#i) | [M](#m) | [N](#n) | [P](#p) | [R](#r) | [S](#s) | [T](#t) | [U](#u) | [V](#v)

---

## B

### Backup (Respaldo)

Copia de seguridad de datos en un momento determinado. En Docker, se realiza copiando el contenido de un volumen a un archivo comprimido.

```bash
# Backup de volumen con contenedor auxiliar
docker run --rm \
  --volumes-from mi-contenedor \
  -v $(pwd)/backups:/backup \
  alpine \
  tar czf /backup/datos-$(date +%Y%m%d).tar.gz /data
```

### Bind Mount

Tipo de montaje que enlaza directamente un directorio o archivo del **sistema host** con una ruta dentro del contenedor. Los cambios en ambos lados son inmediatos y bidireccionales.

```bash
# -v ruta_host:ruta_contenedor
docker run -v $(pwd)/src:/app/src node:20-alpine
```

**Diferencia clave**: A diferencia de los Named Volumes, Docker no gestiona la ubicación del bind mount; el usuario la especifica explícitamente.

---

## C

### Copy-on-Write (CoW)

Estrategia de gestión de memoria donde los datos no se copian hasta que se modifican. Docker usa CoW para las capas de imágenes: cuando un contenedor escribe en un archivo de la imagen base, Docker crea una copia de ese archivo en la capa de escritura del contenedor.

### Capa de Escritura (Writable Layer / Container Layer)

Capa superior y única del sistema de archivos de un contenedor que permite escritura. Es **efímera**: se destruye al eliminar el contenedor. Todo lo que se escribe aquí sin un volumen se pierde.

---

## D

### Dangling Volume

Volumen que no está siendo utilizado por ningún contenedor. Ocupa espacio en disco sin propósito activo.

```bash
# Listar volúmenes no usados
docker volume ls --filter dangling=true

# Eliminar todos los volúmenes no usados
docker volume prune
```

### Docker Volume Driver

Plugin que define cómo Docker almacena y gestiona los datos de un volumen. El driver por defecto es `local` (almacena en el sistema de archivos del host). Existen drivers para NFS, almacenamiento en la nube, etc.

---

## E

### Efimeralidad (Ephemeral)

Propiedad de los contenedores Docker de ser temporales. Los datos escritos en la **capa de escritura** del contenedor desaparecen al eliminarlo. Los volúmenes resuelven este problema.

---

## G

### `.gitignore` de Volúmenes

Es importante excluir directorios de datos de Git cuando se usan bind mounts en desarrollo.

```bash
# .gitignore
data/
backups/
*.dump
*.tar.gz
```

---

## I

### Init Script (Script de Inicialización)

Script SQL o Shell que se ejecuta automáticamente cuando se crea por primera vez un contenedor de base de datos. En PostgreSQL, se coloca en `/docker-entrypoint-initdb.d/`.

```yaml
# docker-compose.yml
services:
  postgres:
    image: postgres:16-alpine
    volumes:
      - ./init.sql:/docker-entrypoint-initdb.d/01-init.sql:ro
```

---

## M

### Mountpoint

Ruta física en el sistema host donde Docker almacena los datos de un volumen nombrado. Generalmente: `/var/lib/docker/volumes/<nombre>/_data`.

```bash
docker volume inspect mi-volumen --format '{{ .Mountpoint }}'
# /var/lib/docker/volumes/mi-volumen/_data
```

---

## N

### Named Volume (Volumen Nombrado)

Volumen de Docker identificado por un nombre legible, gestionado completamente por Docker. Es la **opción recomendada** para producción por su portabilidad y facilidad de gestión.

```bash
docker volume create mis-datos
docker run -v mis-datos:/app/data mi-imagen
```

### Node Modules Trick

Técnica para evitar que el `node_modules` del host sobreescriba el del contenedor en bind mounts:

```yaml
services:
  app:
    volumes:
      - ./src:/app/src           # Código fuente: bind mount
      - /app/node_modules         # node_modules: volumen anónimo (prioridad)
```

---

## P

### Persistencia

Capacidad de los datos de sobrevivir al ciclo de vida del contenedor. Se logra usando volúmenes (nombrados, bind mounts o tmpfs).

### `pg_dump`

Herramienta de PostgreSQL para exportar una base de datos a un archivo SQL o binario. Produce backups lógicos (portables entre versiones) en lugar de copias binarias del volumen.

```bash
# Backup lógico consistente
docker exec mi-postgres pg_dump -U admin mi_db > backup.sql

# Backup en formato custom (comprimido, más flexible)
docker exec mi-postgres pg_dump -U admin -Fc mi_db > backup.dump
```

---

## R

### Read-Only Mount (`:ro`)

Montaje que solo permite lectura desde el contenedor. El contenedor no puede modificar los archivos del host/volumen.

```bash
# Configuración como solo lectura
docker run -v $(pwd)/config:/config:ro alpine
```

### Restore (Restauración)

Proceso de recuperar datos desde un backup. Implica crear un nuevo volumen y descomprimir el backup, o usar `pg_restore` para bases de datos PostgreSQL.

---

## S

### Storage Driver

Driver del sistema de archivos que gestiona las capas de imágenes y la capa de escritura de los contenedores. Opciones comunes: `overlay2` (recomendado en Linux), `devicemapper`, `aufs`.

```bash
# Ver el storage driver activo
docker info | grep "Storage Driver"
```

### Sticky Bit (`mode=1777`)

Permiso especial en directorios que permite a cada usuario eliminar solo sus propios archivos. Común en `/tmp`. Se usa con tmpfs.

---

## T

### tmpfs

Sistema de archivos temporal en **memoria RAM**. Los datos son volátiles (desaparecen al detener el contenedor) pero extremadamente rápidos. Útil para datos sensibles y cache.

```bash
docker run --tmpfs /tmp:rw,size=100m,mode=1777 alpine
```

---

## U

### Union File System (UnionFS)

Sistema de archivos que superpone múltiples capas de solo lectura más una capa de escritura. Es la base del sistema de capas de Docker. Implementaciones: OverlayFS, AUFS, DeviceMapper.

---

## V

### Volumen Anónimo

Volumen creado automáticamente por Docker sin un nombre explícito. Docker le asigna un hash como nombre. Son difíciles de gestionar y generalmente se prefieren los volúmenes nombrados.

```bash
# Crea un volumen anónimo (hash como nombre)
docker run -v /app/data alpine

# Ver volúmenes anónimos
docker volume ls
# DRIVER    VOLUME NAME
# local     a3f8c9d1e2b4...  (hash)
```

### `--volumes-from`

Opción para montar todos los volúmenes de otro contenedor en el contenedor actual. Muy útil para operaciones de backup.

```bash
docker run --rm \
  --volumes-from mi-app \
  alpine \
  ls /app/data
```

---

## 📚 Comandos de Referencia Rápida

```bash
# Gestión de volúmenes
docker volume create nombre
docker volume ls
docker volume inspect nombre
docker volume rm nombre
docker volume prune

# Montar en contenedores
docker run -v nombre:/ruta imagen          # Named volume
docker run -v $(pwd)/dir:/ruta imagen      # Bind mount
docker run --tmpfs /tmp:rw,size=100m imagen # tmpfs

# Backup y restore
docker run --rm --volumes-from contenedor -v $(pwd):/backup alpine \
  tar czf /backup/backup.tar.gz /data

docker run --rm -v nombre:/restore -v $(pwd):/backup alpine \
  tar xzf /backup/backup.tar.gz -C /restore

# Información del sistema
docker system df -v   # Espacio usado por volúmenes
```

---

## 🔗 Navegación

[← Teoría Semana 05](../1-teoria/) | [Ejercicios →](../2-ejercicios/) | [Proyecto →](../3-proyecto/)
