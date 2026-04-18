# 📖 Glosario — Semana 07: Docker Compose Avanzado

Términos clave de esta semana, ordenados alfabéticamente.

---

## A

**Anchor YAML (`&nombre`)**
Marca un bloque YAML para su reutilización posterior con `*nombre`. Se usa en Compose dentro de extensiones `x-` para evitar repetición de configuración común entre servicios.

**`<<:` (Merge Key)**
Operador YAML de fusión. Permite incorporar el contenido de un anchor en el contexto actual. Compatible con la especificación YAML 1.1 y mayoría de parsers:
```yaml
<<: *base-config    # Fusiona todas las claves del anchor
```

---

## C

**`condition: service_completed_successfully`**
Opción de `depends_on` que hace que un servicio espere a que su dependencia haya terminado con exit code 0. Útil para servicios de migración o seeding de BD.

**`condition: service_healthy`**
Opción de `depends_on` que hace que el servicio espere hasta que el healthcheck de la dependencia reporte `healthy`. Garantiza que la dependencia esté lista para aceptar conexiones.

**`configs:`** (top-level)
Sección de Compose para definir archivos de configuración que se montan en los contenedores. Similar a secrets pero para contenido no sensible. Se montan en la ruta especificada como archivos de solo lectura.

---

## D

**`deploy.replicas`**
Número de instancias idénticas de un servicio a ejecutar. En Compose standalone, controla cuántos contenedores del mismo servicio se crean. En Swarm, gestiona la distribución entre nodos.

**`deploy.restart_policy`**
Política avanzada de reinicio con control de `condition`, `delay` (espera entre reintentos), `max_attempts` y `window`. Más granular que la opción `restart:` a nivel de servicio.

---

## E

**`extends`**
Directiva de Compose que permite a un servicio heredar la configuración completa de otro servicio, en el mismo archivo o en uno externo. **No hereda** `volumes:`, `networks:` ni `depends_on:` — estos deben definirse explícitamente.

---

## F

**`file:` (en secrets)**
Especifica la ruta en el host donde se encuentra el archivo de secreto. El contenido de ese archivo se monta en `/run/secrets/<nombre>` dentro del contenedor.

---

## H

**Historial de Healthchecks**
Docker mantiene un log de los últimos chequeos de salud. Accesible con `docker inspect <container>` en el campo `State.Health.Log`. Muestra el exit code y output de cada intento.

---

## M

**`max_attempts`** (restart_policy)
Número máximo de reintentos antes de rendir. Previene loops infinitos en servicios que fallan permanentemente.

**Merge Key** → ver `<<:`

---

## O

**`on-failure`** (restart policy)
El contenedor se reinicia solo cuando termina con un código de error (exit code ≠ 0). Ideal para workers que procesan tareas: si fallan procesando un mensaje, reinician; si se detienen normalmente, no.

---

## P

**Profile**
Etiqueta asignada a servicios opcionales en Compose. Los servicios con `profiles:` solo se inician cuando el profile se activa explícitamente. Los servicios sin `profiles:` **siempre** se inician.

**`COMPOSE_PROFILES`**
Variable de entorno que activa uno o más profiles en Compose. Equivalente a usar `--profile` en la línea de comandos. Acepta múltiples valores separados por coma.

---

## R

**`restart_policy`** → ver `deploy.restart_policy`

**`/run/secrets/<nombre>`**
Ruta estándar donde Docker monta los archivos de secretos dentro del contenedor. Los secretos son archivos de solo lectura, visibles únicamente dentro del contenedor al que se le asignan.

---

## S

**Secret**
En Docker Compose, datos sensibles (contraseñas, tokens) que se montan como archivos en `/run/secrets/<nombre>`. A diferencia de las variables de entorno, no aparecen en `docker inspect` ni en los logs del proceso de arranque.

**`service_completed_successfully`** → ver condition

**`service_healthy`** → ver condition

**`start_period`** (healthcheck)
Período inicial de gracia tras el arranque del contenedor. Los fallos durante este período no cuentan hacia `retries`. Permite que servicios lentos en arrancar (como PostgreSQL inicializando) no sean marcados como unhealthy prematuramente.

---

## U

**`unless-stopped`** (restart policy)
El contenedor se reinicia automáticamente en todos los casos, **excepto** si fue detenido explícitamente por el usuario con `docker stop` o `docker compose stop`. Es la política recomendada para servicios de producción.

---

## W

**`window`** (restart_policy)
Ventana de tiempo para evaluar los reintentos. Si `max_attempts` falla dentro de esta ventana, el contenedor se marca como fallido. Evita que fallos esporádicos acumulen el contador de reintentos indefinidamente.

---

## X

**`x-<nombre>:`** (extensiones Compose)
Claves personalizadas a nivel top-level de docker-compose.yml que Compose ignora. Convención para definir bloques YAML reutilizables con anchors. Docker Compose no procesa ni valida estas secciones.

---

## 📚 Términos Relacionados de Semanas Anteriores

| Término            | Semana | Descripción breve                              |
| ------------------ | ------ | ---------------------------------------------- |
| Healthcheck        | 03, 06 | Sonda periódica de salud del contenedor        |
| depends_on         | 06     | Orden de arranque entre servicios              |
| Override File      | 06     | Fusión de múltiples archivos compose           |
| Internal Network   | 06     | Red sin acceso externo                         |
| Named Volume       | 05     | Volumen persistente gestionado por Docker      |

---

*Este glosario complementa la teoría en [1-teoria/](../1-teoria/).*
