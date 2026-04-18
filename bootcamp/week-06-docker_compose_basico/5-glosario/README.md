# 📖 Glosario — Semana 06: Docker Compose Básico

Términos clave de esta semana, ordenados alfabéticamente.

---

## A

**Anchor YAML (`&` y `*`)**
Mecanismo de YAML para reutilizar bloques de configuración. Con `&nombre` se define el ancla y con `*nombre` se referencia. Permite evitar repetición en docker-compose.yml.

```yaml
x-common: &common
  restart: unless-stopped

services:
  web:
    <<: *common      # Hereda restart: unless-stopped
```

---

## B

**Build Context**
Directorio que Docker envía al daemon para construir una imagen. En Compose se especifica bajo `build: context:`. Solo los archivos dentro del contexto son accesibles durante el build.

---

## C

**`condition: service_healthy`**
Opción de `depends_on` que hace que un servicio espere no solo a que su dependencia *arranque*, sino a que su *healthcheck reporte success*. Evita errores de conexión durante el inicio.

```yaml
depends_on:
  db:
    condition: service_healthy
```

**`config`** (subcomando)
`docker compose config` resuelve y muestra la configuración final después de fusionar todos los archivos y sustituir variables. Útil para depurar configuraciones complejas.

---

## D

**Default Network**
Red bridge que Docker Compose crea automáticamente para cada proyecto. Su nombre sigue el patrón `{directorio}_{nombre-red}`. Todos los servicios se conectan a ella si no se especifica otra red.

**`depends_on`**
Instrucción que define dependencias entre servicios. Controla el orden de arranque. Sin `condition`, solo garantiza que el contenedor dependiente *esté corriendo*, no que esté *listo para aceptar conexiones*.

**DNS Interno**
En una red Compose, los servicios se resuelven por su nombre. Si defines un servicio llamado `db`, los demás servicios pueden conectarse usando `db` como hostname. Docker gestiona automáticamente este DNS.

---

## E

**`env_file`**
Opción de servicio que carga variables de entorno desde un archivo en disco. A diferencia de `environment:`, no embebe los valores en el compose.yml:

```yaml
services:
  app:
    env_file:
      - .env
      - .env.local
```

**`environment`**
Sección de un servicio Compose para definir variables de entorno. Puede usar valores literales o interpolación desde `.env`:

```yaml
environment:
  DB_PASS: ${DB_PASS}         # Del .env
  NODE_ENV: production         # Valor literal
```

---

## H

**Healthcheck**
Configuración que define cómo sondear la salud de un contenedor. Docker ejecuta el comando periódicamente y reporta el estado: `starting`, `healthy` o `unhealthy`. Esencial para `condition: service_healthy`.

---

## I

**`image`**
Imagen Docker a usar para un servicio. Si se especifica junto con `build:`, la imagen construida recibirá ese nombre y tag. Si no se especifica `build:`, Compose descarga la imagen del registry.

**`internal: true`** (en redes)
Opción de red que impide que los contenedores en esa red accedan a internet o a otras redes externas. Útil para aislar servicios de base de datos.

**Interpolación**
Sustitución de variables en docker-compose.yml usando la sintaxis `${VAR}`. Los valores vienen del archivo `.env`, del entorno del sistema, o de defaults definidos con `${VAR:-default}`.

---

## M

**Merge de archivos**
Proceso por el que compose fusiona múltiples archivos (`-f file1 -f file2`). Los valores del segundo archivo sobreescriben o complementan los del primero. Las listas como `ports` y `volumes` se concatenan.

---

## N

**Named Volume** (en Compose)
Volumen declarado en la sección top-level `volumes:` de docker-compose.yml. Docker lo gestiona con ciclo de vida independiente. Persiste entre `docker compose down && up`. Solo se elimina con `down -v`.

---

## O

**Override File**
Archivo docker-compose que extiende o modifica el base. `docker-compose.override.yml` se carga automáticamente. Otros archivos requieren `-f explícito`. Patrón estándar para gestionar entornos.

---

## P

**Project Name**
Nombre del proyecto Compose, por defecto el nombre del directorio. Se puede cambiar con `-p nombre` o la variable `COMPOSE_PROJECT_NAME`. Prefija nombres de contenedores, redes y volúmenes.

**`ports`**
Mapeo de puertos entre el host y el contenedor. Formato: `"host:container"`. Solo los servicios con `ports` son accesibles desde fuera de Docker. Los servicios sin `ports` son accesibles solo por nombre dentro de la red Compose.

---

## R

**`restart`**
Política de reinicio automático del contenedor. Valores comunes:
- `no` (default): no reiniciar
- `always`: siempre reiniciar
- `unless-stopped`: reiniciar excepto si el usuario lo detuvo
- `on-failure`: reiniciar solo si terminó con error

---

## S

**Service**
Unidad básica de Docker Compose. Define la configuración para uno o más contenedores idénticos (cuando se usa `deploy: replicas`). Equivale a un patrón de `docker run` con sus flags.

---

## V

**`volumes`** (en servicio)
Lista de montajes para el contenedor. Puede ser binding de bind mount (`./local:/container`) o volumen nombrado (`nombre-volumen:/container`). La forma larga (`type/source/target`) es más explícita.

**`volumes`** (top-level)
Sección global donde se declaran volúmenes nombrados. Un volumen sin opciones (`db-data:`) usa el driver local por defecto. Se puede marcar como `external: true` para usar volúmenes creados fuera de Compose.

---

## X

**`x-` extensiones**
Campos personalizados en docker-compose.yml que Compose ignora. Útiles para definir bloques YAML reutilizables con anclas. La especificación permite cualquier campo que empiece con `x-`.

```yaml
x-logging: &logging
  driver: json-file
  options:
    max-size: "10m"
```

---

## 📚 Términos Relacionados de Semanas Anteriores

| Término          | Semana | Descripción breve                         |
| ---------------- | ------ | ----------------------------------------- |
| Bridge Network   | 04     | Red virtual aislada para contenedores     |
| Named Volume     | 05     | Volumen gestionado por Docker             |
| Bind Mount       | 05     | Directorio del host montado en contenedor |
| Healthcheck      | 03     | Sonda de salud del contenedor             |
| Environment Vars | 03     | Variables de entorno en contenedores      |

---

*Este glosario complementa la teoría en [1-teoria/](../1-teoria/).*
