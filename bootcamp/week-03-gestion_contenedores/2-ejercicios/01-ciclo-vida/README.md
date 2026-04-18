# 💻 Ejercicio 01: Ciclo de Vida del Contenedor

## 🎯 Objetivos

- Practicar la creación de contenedores con `create` y `run`
- Gestionar estados: start, stop, pause, restart
- Entender políticas de reinicio
- Limpiar contenedores correctamente

---

## ⏱️ Duración Estimada

30 minutos

---

## 📋 Requisitos Previos

- Docker instalado y funcionando
- Lectura de [01-ciclo-vida.md](../../1-teoria/01-ciclo-vida.md)

---

## 🏋️ Parte 1: Crear vs Run

### Paso 1.1: Crear sin iniciar

```bash
# TODO: Crear un contenedor nginx sin iniciarlo
docker create --name nginx-created nginx:alpine

# TODO: Verificar que existe pero NO está corriendo
docker ps -a --filter name=nginx-created

# Observa: STATUS debe ser "Created"
```

### Paso 1.2: Iniciar el contenedor

```bash
# TODO: Iniciar el contenedor creado
docker start nginx-created

# TODO: Verificar que ahora está corriendo
docker ps --filter name=nginx-created

# Observa: STATUS debe ser "Up X seconds"
```

### Paso 1.3: Comparar con run

```bash
# TODO: Crear e iniciar en un solo comando
docker run -d --name nginx-running nginx:alpine

# TODO: Listar ambos contenedores
docker ps --filter name=nginx

# Pregunta: ¿Cuál es la diferencia práctica entre create y run?
```

---

## 🏋️ Parte 2: Estados del Contenedor

### Paso 2.1: Pausar y reanudar

```bash
# TODO: Pausar nginx-running
docker pause nginx-running

# TODO: Verificar estado pausado
docker ps --filter name=nginx-running

# Observa: STATUS debe mostrar "(Paused)"

# TODO: Intentar acceder al contenedor pausado
docker exec nginx-running ls
# ¿Qué sucede?

# TODO: Reanudar el contenedor
docker unpause nginx-running

# TODO: Verificar que funciona de nuevo
docker exec nginx-running ls
```

### Paso 2.2: Detener contenedores

```bash
# TODO: Detener con señal graceful (SIGTERM)
time docker stop nginx-running

# Observa el tiempo que tarda (hasta 10 segundos)

# TODO: Iniciar de nuevo
docker start nginx-running

# TODO: Detener con timeout personalizado (2 segundos)
time docker stop -t 2 nginx-running

# TODO: Iniciar y usar kill (SIGKILL inmediato)
docker start nginx-running
time docker kill nginx-running

# Pregunta: ¿Cuál es más rápido? ¿Cuándo usarías cada uno?
```

### Paso 2.3: Reiniciar contenedores

```bash
# TODO: Iniciar nginx-running si está detenido
docker start nginx-running

# TODO: Reiniciar el contenedor
docker restart nginx-running

# TODO: Verificar que el contenedor se reinició
docker ps --filter name=nginx-running

# TODO: Ver el tiempo de uptime (debe ser segundos)
```

---

## 🏋️ Parte 3: Políticas de Reinicio

### Paso 3.1: Contenedor sin política

```bash
# TODO: Crear contenedor que termina inmediatamente
docker run -d --name exit-normal alpine echo "Hola y adiós"

# TODO: Verificar estado
docker ps -a --filter name=exit-normal

# Observa: STATUS "Exited (0)" - no se reinicia
```

### Paso 3.2: Política always

```bash
# TODO: Crear contenedor con restart=always
docker run -d --name restart-always --restart=always alpine sh -c "sleep 5 && exit 1"

# TODO: Esperar 10 segundos y verificar
sleep 10
docker ps --filter name=restart-always

# Observa: El contenedor sigue reiniciándose

# TODO: Ver cuántas veces se ha reiniciado
docker inspect -f '{{.RestartCount}}' restart-always
```

### Paso 3.3: Política on-failure

```bash
# TODO: Crear contenedor con restart=on-failure:3
docker run -d --name restart-limited --restart=on-failure:3 alpine sh -c "exit 1"

# TODO: Esperar y verificar
sleep 15
docker ps -a --filter name=restart-limited

# TODO: Ver intentos de reinicio
docker inspect -f '{{.RestartCount}}' restart-limited

# Observa: Máximo 3 reintentos, luego se detiene
```

### Paso 3.4: Actualizar política existente

```bash
# TODO: Cambiar política de restart-always a unless-stopped
docker update --restart=unless-stopped restart-always

# TODO: Verificar el cambio
docker inspect -f '{{.HostConfig.RestartPolicy.Name}}' restart-always
```

---

## 🏋️ Parte 4: Eliminar Contenedores

### Paso 4.1: Eliminar contenedores detenidos

```bash
# TODO: Listar todos los contenedores
docker ps -a

# TODO: Intentar eliminar un contenedor corriendo
docker rm restart-always
# ¿Qué error aparece?

# TODO: Detener primero, luego eliminar
docker stop restart-always
docker rm restart-always

# TODO: O forzar eliminación
docker rm -f nginx-running
```

### Paso 4.2: Limpieza masiva

```bash
# TODO: Eliminar todos los contenedores detenidos de este ejercicio
docker rm exit-normal restart-limited nginx-created

# TODO: Verificar que se eliminaron
docker ps -a

# TODO: Limpiar contenedores detenidos con prune
docker container prune -f
```

---

## ✅ Checklist de Verificación

Marca cada item completado:

- [ ] Creé un contenedor con `docker create`
- [ ] Inicié el contenedor con `docker start`
- [ ] Creé e inicié con `docker run`
- [ ] Pausé y reanudé un contenedor
- [ ] Usé `docker stop` y `docker kill`
- [ ] Configuré política `--restart=always`
- [ ] Configuré política `--restart=on-failure:N`
- [ ] Actualicé política con `docker update`
- [ ] Eliminé contenedores con `docker rm`
- [ ] Limpié con `docker container prune`

---

## 🧹 Limpieza

```bash
# Asegúrate de eliminar todos los contenedores del ejercicio
docker rm -f nginx-created nginx-running exit-normal restart-always restart-limited 2>/dev/null

# Verificar que no quedan contenedores
docker ps -a
```

---

## 🤔 Preguntas de Reflexión

1. ¿En qué escenario usarías `docker create` en lugar de `docker run`?
2. ¿Cuál es la diferencia entre exit code 0 y exit code 1 para la política `on-failure`?
3. ¿Qué política de reinicio usarías para un servidor web en producción?
4. ¿Por qué `docker kill` es más rápido que `docker stop`?

---

## 🔗 Navegación

| ← Anterior                           | Siguiente →                                             |
| ------------------------------------ | ------------------------------------------------------- |
| [Índice de Ejercicios](../README.md) | [02 - Logs y Debugging](../02-logs-debugging/README.md) |
