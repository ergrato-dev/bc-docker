# 💻 Ejercicio 04: Recursos y Límites

## 🎯 Objetivos

- Configurar límites de memoria en contenedores
- Establecer restricciones de CPU
- Monitorear uso de recursos
- Actualizar límites en caliente
- Entender comportamiento OOM

---

## ⏱️ Duración Estimada

35 minutos

---

## 📋 Requisitos Previos

- Docker instalado y funcionando
- Lectura de [06-recursos-limites.md](../../1-teoria/06-recursos-limites.md)

---

## 🏋️ Parte 1: Límites de Memoria

### Paso 1.1: Contenedor con límite de memoria

```bash
# TODO: Crear contenedor con límite de 100MB
docker run -d --name mem-limited \
    --memory=100m \
    nginx:alpine

# TODO: Verificar el límite configurado
docker inspect -f '{{.HostConfig.Memory}}' mem-limited
# Debería mostrar: 104857600 (bytes = 100MB)

# TODO: Ver el uso actual
docker stats --no-stream mem-limited
```

### Paso 1.2: Probar límite de memoria

```bash
# TODO: Crear contenedor que intenta usar más memoria de la permitida
docker run -d --name mem-test \
    --memory=50m \
    alpine sh -c '
        echo "Intentando asignar 100MB de memoria..."
        dd if=/dev/zero of=/dev/shm/testfile bs=1M count=100 2>&1 || echo "Falló la asignación"
        sleep 300
    '

# TODO: Esperar y verificar el estado
sleep 5
docker ps -a --filter name=mem-test

# TODO: Ver si fue matado por OOM
docker inspect -f '{{.State.OOMKilled}}' mem-test

# TODO: Ver logs para más información
docker logs mem-test
```

### Paso 1.3: Memory reservation (soft limit)

```bash
# TODO: Crear con límite duro y soft
docker run -d --name mem-soft \
    --memory=200m \
    --memory-reservation=100m \
    nginx:alpine

# TODO: Verificar configuración
docker inspect -f 'Hard: {{.HostConfig.Memory}}, Soft: {{.HostConfig.MemoryReservation}}' mem-soft
```

---

## 🏋️ Parte 2: Límites de CPU

### Paso 2.1: Limitar número de CPUs

```bash
# TODO: Crear contenedor limitado a 0.5 CPU
docker run -d --name cpu-half \
    --cpus=0.5 \
    alpine sh -c '
        while true; do
            echo "scale=5000; 4*a(1)" | bc -l > /dev/null 2>&1
        done
    '

# TODO: Crear contenedor sin límite
docker run -d --name cpu-unlimited \
    alpine sh -c '
        while true; do
            echo "scale=5000; 4*a(1)" | bc -l > /dev/null 2>&1
        done
    '

# TODO: Comparar uso de CPU
docker stats --no-stream cpu-half cpu-unlimited

# Observa: cpu-half debería estar cerca de 50%, cpu-unlimited puede llegar a 100%
```

### Paso 2.2: CPU shares (peso relativo)

```bash
# TODO: Detener contenedores anteriores
docker stop cpu-half cpu-unlimited

# TODO: Crear contenedores con diferentes pesos
docker run -d --name cpu-low \
    --cpu-shares=256 \
    alpine sh -c 'while true; do :; done'

docker run -d --name cpu-high \
    --cpu-shares=1024 \
    alpine sh -c 'while true; do :; done'

# TODO: Ver la diferencia cuando compiten por CPU
docker stats --no-stream cpu-low cpu-high

# cpu-high debería tener ~4x más CPU que cpu-low
# (1024/256 = 4)
```

### Paso 2.3: Fijar a CPUs específicas

```bash
# TODO: Ver cuántas CPUs tiene el sistema
nproc

# TODO: Crear contenedor fijado a CPU 0
docker run -d --name cpu-pinned \
    --cpuset-cpus=0 \
    alpine sh -c 'while true; do :; done'

# TODO: Verificar la configuración
docker inspect -f '{{.HostConfig.CpusetCpus}}' cpu-pinned

# TODO: Ver uso (solo CPU 0 debería estar al 100%)
docker stats --no-stream cpu-pinned
```

---

## 🏋️ Parte 3: Monitoreo de Recursos

### Paso 3.1: Docker stats avanzado

```bash
# TODO: Detener contenedores de CPU
docker stop cpu-low cpu-high cpu-pinned

# TODO: Crear contenedores de prueba
docker run -d --name web1 --memory=128m --cpus=0.5 nginx:alpine
docker run -d --name web2 --memory=128m --cpus=0.5 nginx:alpine
docker run -d --name cache --memory=256m --cpus=0.25 redis:alpine

# TODO: Ver stats de todos
docker stats --no-stream

# TODO: Formato personalizado para reportes
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}\t{{.NetIO}}"
```

### Paso 3.2: Generar carga y observar

```bash
# TODO: En una terminal, iniciar stats continuo
docker stats web1 web2 cache

# TODO: En otra terminal, generar carga a web1
for i in {1..100}; do
    curl -s http://localhost:8080 > /dev/null 2>&1 &
done

# Observa cómo cambia el uso de CPU y memoria

# TODO: Detener stats con Ctrl+C
```

### Paso 3.3: Script de monitoreo simple

```bash
# TODO: Crear script de alerta de recursos
cat > /tmp/monitor.sh << 'EOF'
#!/bin/bash
THRESHOLD_MEM=80
THRESHOLD_CPU=80

echo "Verificando recursos de contenedores..."
echo "======================================="

docker stats --no-stream --format "{{.Name}} {{.CPUPerc}} {{.MemPerc}}" | while read name cpu mem; do
    cpu_val=$(echo $cpu | tr -d '%')
    mem_val=$(echo $mem | tr -d '%')

    if (( $(echo "$cpu_val > $THRESHOLD_CPU" | bc -l 2>/dev/null || echo 0) )); then
        echo "⚠️  ALERTA: $name CPU alto: $cpu"
    fi

    if (( $(echo "$mem_val > $THRESHOLD_MEM" | bc -l 2>/dev/null || echo 0) )); then
        echo "⚠️  ALERTA: $name Memoria alta: $mem"
    fi
done

echo "======================================="
echo "Verificación completada"
EOF

chmod +x /tmp/monitor.sh

# TODO: Ejecutar el monitor
/tmp/monitor.sh
```

---

## 🏋️ Parte 4: Actualizar Límites en Caliente

### Paso 4.1: Actualizar memoria

```bash
# TODO: Ver límite actual de web1
docker inspect -f '{{.HostConfig.Memory}}' web1

# TODO: Aumentar memoria a 256MB
docker update --memory=256m web1

# TODO: Verificar el cambio
docker inspect -f '{{.HostConfig.Memory}}' web1
# Debería mostrar: 268435456 (256MB)

# TODO: Ver en stats
docker stats --no-stream web1
```

### Paso 4.2: Actualizar CPU

```bash
# TODO: Ver límite actual
docker inspect -f '{{.HostConfig.NanoCpus}}' web1

# TODO: Aumentar CPU a 1
docker update --cpus=1 web1

# TODO: Verificar
docker inspect -f '{{.HostConfig.NanoCpus}}' web1
# Debería mostrar: 1000000000 (1 CPU)
```

### Paso 4.3: Actualizar múltiples contenedores

```bash
# TODO: Actualizar web1 y web2 al mismo tiempo
docker update --memory=192m --cpus=0.75 web1 web2

# TODO: Verificar ambos
docker inspect -f '{{.Name}}: Mem={{.HostConfig.Memory}}, CPU={{.HostConfig.NanoCpus}}' web1 web2
```

---

## 🏋️ Parte 5: Límite de Procesos (PIDs)

### Paso 5.1: Configurar límite de PIDs

```bash
# TODO: Crear contenedor con límite de procesos
docker run -d --name pid-limited \
    --pids-limit=10 \
    alpine sh -c 'sleep 3600'

# TODO: Verificar límite
docker inspect -f '{{.HostConfig.PidsLimit}}' pid-limited

# TODO: Ver procesos actuales
docker top pid-limited
```

### Paso 5.2: Probar límite de PIDs

```bash
# TODO: Intentar crear más procesos de los permitidos
docker exec pid-limited sh -c '
    for i in $(seq 1 15); do
        sleep 100 &
        echo "Proceso $i creado"
    done
'

# Observa: Debería fallar después de ~10 procesos

# TODO: Ver cuántos procesos hay
docker top pid-limited | wc -l
```

---

## 🏋️ Parte 6: Escenario de Producción

### Paso 6.1: Configuración recomendada

```bash
# TODO: Crear contenedor con configuración de producción
docker run -d --name prod-app \
    --memory=512m \
    --memory-reservation=256m \
    --cpus=2 \
    --pids-limit=100 \
    --restart=unless-stopped \
    nginx:alpine

# TODO: Verificar toda la configuración
docker inspect prod-app | jq '.[0].HostConfig | {
    Memory: .Memory,
    MemoryReservation: .MemoryReservation,
    NanoCpus: .NanoCpus,
    PidsLimit: .PidsLimit,
    RestartPolicy: .RestartPolicy
}'
```

---

## ✅ Checklist de Verificación

Marca cada item completado:

- [ ] Configuré límite de memoria con `--memory`
- [ ] Probé el comportamiento OOM
- [ ] Configuré memory reservation
- [ ] Limité CPUs con `--cpus`
- [ ] Usé CPU shares para prioridad relativa
- [ ] Fijé contenedor a CPUs específicas
- [ ] Monitoré recursos con `docker stats`
- [ ] Actualicé límites con `docker update`
- [ ] Configuré límite de PIDs
- [ ] Creé configuración estilo producción

---

## 🧹 Limpieza

```bash
# Eliminar todos los contenedores del ejercicio
docker rm -f mem-limited mem-test mem-soft \
    cpu-half cpu-unlimited cpu-low cpu-high cpu-pinned \
    web1 web2 cache pid-limited prod-app 2>/dev/null

# Limpiar script de monitoreo
rm -f /tmp/monitor.sh

# Verificar
docker ps -a
```

---

## 🤔 Preguntas de Reflexión

1. ¿Por qué es importante establecer límites de recursos?
2. ¿Cuál es la diferencia entre `--memory` y `--memory-reservation`?
3. ¿Cuándo usarías `--cpus` vs `--cpu-shares`?
4. ¿Cómo calcularías los límites apropiados para tu aplicación?

---

## 🔗 Navegación

| ← Anterior                                         | Siguiente →                                               |
| -------------------------------------------------- | --------------------------------------------------------- |
| [03 - Variables](../03-variables-config/README.md) | [05 - Gestión Avanzada](../05-gestion-avanzada/README.md) |
