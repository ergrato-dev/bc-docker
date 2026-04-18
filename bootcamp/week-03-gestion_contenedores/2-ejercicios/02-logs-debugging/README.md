# 💻 Ejercicio 02: Logs y Debugging

## 🎯 Objetivos

- Visualizar y filtrar logs de contenedores
- Usar docker stats para monitoreo
- Diagnosticar problemas con inspect
- Seguir logs en tiempo real

---

## ⏱️ Duración Estimada

35 minutos

---

## 📋 Requisitos Previos

- Docker instalado y funcionando
- Lectura de [03-logs-monitoreo.md](../../1-teoria/03-logs-monitoreo.md)

---

## 🏋️ Parte 1: Visualizar Logs

### Paso 1.1: Generar logs

```bash
# TODO: Crear un contenedor nginx que genere logs
docker run -d --name web-logs -p 8080:80 nginx:alpine

# TODO: Generar tráfico para crear logs
curl http://localhost:8080
curl http://localhost:8080/index.html
curl http://localhost:8080/no-existe
```

### Paso 1.2: Ver logs básicos

```bash
# TODO: Ver todos los logs del contenedor
docker logs web-logs

# TODO: Ver logs con timestamps
docker logs -t web-logs

# TODO: Ver últimas 5 líneas
docker logs --tail 5 web-logs

# TODO: Combinar opciones
docker logs -t --tail 10 web-logs
```

### Paso 1.3: Seguir logs en tiempo real

```bash
# TODO: Seguir logs (Ctrl+C para salir)
docker logs -f web-logs

# En otra terminal, genera más tráfico:
# curl http://localhost:8080

# TODO: Seguir solo las nuevas líneas
docker logs -f --tail 0 web-logs
```

---

## 🏋️ Parte 2: Filtrar Logs por Tiempo

### Paso 2.1: Logs por período

```bash
# TODO: Generar más logs con timestamp
for i in {1..10}; do
    curl -s http://localhost:8080 > /dev/null
    sleep 1
done

# TODO: Ver logs de los últimos 30 segundos
docker logs --since 30s web-logs

# TODO: Ver logs de los últimos 2 minutos
docker logs --since 2m web-logs

# TODO: Ver logs hasta hace 1 minuto
docker logs --until 1m web-logs
```

### Paso 2.2: Buscar en logs

```bash
# TODO: Buscar errores 404
docker logs web-logs 2>&1 | grep 404

# TODO: Contar peticiones exitosas (código 200)
docker logs web-logs 2>&1 | grep -c "\" 200"

# TODO: Filtrar por IP específica
docker logs web-logs 2>&1 | grep "172.17"

# TODO: Guardar logs a archivo
docker logs web-logs > /tmp/nginx-logs.txt 2>&1
cat /tmp/nginx-logs.txt
```

---

## 🏋️ Parte 3: Debugging con Aplicación Problemática

### Paso 3.1: Crear aplicación que falla

```bash
# TODO: Crear contenedor que falla periódicamente
docker run -d --name app-buggy alpine sh -c '
    i=1
    while true; do
        if [ $((i % 5)) -eq 0 ]; then
            echo "ERROR: Operación fallida en iteración $i" >&2
        else
            echo "INFO: Procesando iteración $i"
        fi
        i=$((i + 1))
        sleep 2
    done
'

# TODO: Esperar unos segundos y ver logs
sleep 12
docker logs app-buggy
```

### Paso 3.2: Separar stdout y stderr

```bash
# TODO: Ver solo stdout (mensajes INFO)
docker logs app-buggy 2>/dev/null

# TODO: Ver solo stderr (mensajes ERROR)
docker logs app-buggy 2>&1 1>/dev/null

# TODO: Contar errores
docker logs app-buggy 2>&1 | grep -c ERROR
```

### Paso 3.3: Contenedor que crashea

```bash
# TODO: Crear contenedor que termina con error
docker run -d --name app-crash alpine sh -c '
    echo "Iniciando aplicación..."
    sleep 3
    echo "ERROR FATAL: No se puede conectar a la base de datos" >&2
    exit 1
'

# TODO: Esperar y verificar estado
sleep 5
docker ps -a --filter name=app-crash

# TODO: Ver logs para diagnosticar
docker logs app-crash

# TODO: Ver exit code
docker inspect -f '{{.State.ExitCode}}' app-crash

# Pregunta: ¿Cómo identificarías la causa del fallo?
```

---

## 🏋️ Parte 4: Monitoreo con Stats

### Paso 4.1: Ver uso de recursos

```bash
# TODO: Ver stats de todos los contenedores (Ctrl+C para salir)
docker stats

# TODO: Ver stats sin refresh continuo
docker stats --no-stream

# TODO: Stats de contenedor específico
docker stats --no-stream web-logs
```

### Paso 4.2: Formato personalizado

```bash
# TODO: Ver solo nombre, CPU y memoria
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}"

# TODO: Formato compacto
docker stats --no-stream --format "{{.Name}}: CPU={{.CPUPerc}}, MEM={{.MemPerc}}"
```

### Paso 4.3: Generar carga

```bash
# TODO: Crear contenedor que consume CPU
docker run -d --name cpu-hog alpine sh -c '
    while true; do
        dd if=/dev/zero of=/dev/null bs=1M count=100 2>/dev/null
    done
'

# TODO: Observar el uso de CPU
docker stats --no-stream cpu-hog

# TODO: Comparar con otros contenedores
docker stats --no-stream
```

---

## 🏋️ Parte 5: Inspect para Debugging

### Paso 5.1: Información del contenedor

```bash
# TODO: Ver toda la información del contenedor
docker inspect web-logs | head -50

# TODO: Extraer información específica
docker inspect -f '{{.State.Status}}' web-logs
docker inspect -f '{{.State.StartedAt}}' web-logs
docker inspect -f '{{.NetworkSettings.IPAddress}}' web-logs
```

### Paso 5.2: Verificar configuración

```bash
# TODO: Ver la imagen usada
docker inspect -f '{{.Config.Image}}' web-logs

# TODO: Ver puertos expuestos
docker inspect -f '{{.NetworkSettings.Ports}}' web-logs

# TODO: Ver comando de inicio
docker inspect -f '{{.Config.Cmd}}' web-logs
```

### Paso 5.3: Diagnóstico de contenedor fallido

```bash
# TODO: Inspeccionar el contenedor que crasheó
docker inspect -f '{{.State.Status}}' app-crash
docker inspect -f '{{.State.ExitCode}}' app-crash
docker inspect -f '{{.State.Error}}' app-crash
docker inspect -f '{{.State.FinishedAt}}' app-crash

# TODO: ¿Fue matado por OOM?
docker inspect -f '{{.State.OOMKilled}}' app-crash
```

---

## 🏋️ Parte 6: Docker Events

### Paso 6.1: Monitorear eventos

```bash
# TODO: En una terminal, escuchar eventos
docker events --filter type=container &

# TODO: En otra terminal, generar eventos
docker restart web-logs
docker pause web-logs
docker unpause web-logs
docker stop web-logs
docker start web-logs

# TODO: Detener el listener de eventos
# Presiona Enter y luego ejecuta:
kill %1
```

---

## ✅ Checklist de Verificación

Marca cada item completado:

- [ ] Visualicé logs con `docker logs`
- [ ] Usé timestamps con `-t`
- [ ] Filtré por tiempo con `--since` y `--until`
- [ ] Seguí logs en tiempo real con `-f`
- [ ] Busqué patrones con grep
- [ ] Separé stdout y stderr
- [ ] Diagnostiqué un contenedor que crasheó
- [ ] Usé `docker stats` para ver recursos
- [ ] Extraje información con `docker inspect`
- [ ] Monitoré eventos con `docker events`

---

## 🧹 Limpieza

```bash
# Eliminar todos los contenedores del ejercicio
docker rm -f web-logs app-buggy app-crash cpu-hog 2>/dev/null

# Limpiar archivo temporal
rm -f /tmp/nginx-logs.txt

# Verificar
docker ps -a
```

---

## 🤔 Preguntas de Reflexión

1. ¿Por qué es importante separar stdout y stderr en los logs?
2. ¿Cómo automatizarías la detección de errores en logs?
3. ¿Qué información de `docker inspect` es más útil para debugging?
4. ¿Cómo manejarías logs en un ambiente con muchos contenedores?

---

## 🔗 Navegación

| ← Anterior                                       | Siguiente →                                        |
| ------------------------------------------------ | -------------------------------------------------- |
| [01 - Ciclo de Vida](../01-ciclo-vida/README.md) | [03 - Variables](../03-variables-config/README.md) |
