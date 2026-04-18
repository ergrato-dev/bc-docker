# 💻 Ejercicio 05: Gestión Avanzada de Contenedores

## 🎯 Objetivos

- Combinar todos los conceptos de la semana
- Practicar exec y attach para debugging
- Usar docker cp para transferir archivos
- Implementar workflow de diagnóstico completo

---

## ⏱️ Duración Estimada

40 minutos

---

## 📋 Requisitos Previos

- Completar ejercicios 01-04
- Lecturas de teoría de la semana

---

## 🏋️ Parte 1: Exec Interactivo

### Paso 1.1: Shell en contenedores

```bash
# TODO: Crear contenedor de aplicación
docker run -d --name app-debug \
    -e APP_ENV=development \
    -e DEBUG=true \
    nginx:alpine

# TODO: Abrir shell interactivo
docker exec -it app-debug /bin/sh

# Dentro del contenedor, ejecuta:
# $ whoami
# $ pwd
# $ ls -la /etc/nginx/
# $ cat /etc/nginx/nginx.conf
# $ exit
```

### Paso 1.2: Ejecutar como diferente usuario

```bash
# TODO: Ejecutar como root
docker exec -it -u root app-debug /bin/sh

# Dentro del contenedor:
# $ id
# $ whoami
# $ cat /etc/shadow  # Solo root puede leer esto
# $ exit

# TODO: Ejecutar como nginx
docker exec -it -u nginx app-debug /bin/sh

# Dentro del contenedor:
# $ id
# $ whoami
# $ cat /etc/shadow  # Debería fallar
# $ exit
```

### Paso 1.3: Ejecutar en directorio específico

```bash
# TODO: Exec con directorio de trabajo
docker exec -w /usr/share/nginx/html app-debug ls -la

# TODO: Crear archivo desde exec
docker exec -w /usr/share/nginx/html app-debug sh -c 'echo "Hola desde exec" > test.html'

# TODO: Verificar
docker exec app-debug cat /usr/share/nginx/html/test.html
```

---

## 🏋️ Parte 2: Attach y Detach

### Paso 2.1: Proceso interactivo

```bash
# TODO: Crear contenedor interactivo
docker run -d --name interactive-app \
    alpine sh -c '
        i=1
        while true; do
            echo "[$(date +%H:%M:%S)] Tick $i"
            read -t 5 input
            if [ -n "$input" ]; then
                echo "Recibido: $input"
            fi
            i=$((i + 1))
        done
    '

# TODO: Conectar al proceso principal
docker attach interactive-app

# Observa los mensajes que aparecen
# Escribe algo y presiona Enter
# Para desconectar SIN detener: Ctrl+P, Ctrl+Q
```

### Paso 2.2: Diferencia con exec

```bash
# TODO: Con attach conectado (en otra terminal si es posible)
docker exec interactive-app ps aux

# Observa: exec crea nuevo proceso, attach conecta al existente

# TODO: Ver logs mientras está corriendo
docker logs -f --tail 5 interactive-app
# Ctrl+C para salir de logs (no detiene el contenedor)
```

---

## 🏋️ Parte 3: Transferencia de Archivos

### Paso 3.1: Copiar desde contenedor

```bash
# TODO: Crear directorio local
mkdir -p /tmp/docker-files

# TODO: Copiar archivo de configuración
docker cp app-debug:/etc/nginx/nginx.conf /tmp/docker-files/

# TODO: Copiar directorio completo
docker cp app-debug:/usr/share/nginx/html /tmp/docker-files/html-backup

# TODO: Verificar
ls -la /tmp/docker-files/
cat /tmp/docker-files/nginx.conf | head -20
```

### Paso 3.2: Copiar hacia contenedor

```bash
# TODO: Crear archivo HTML personalizado
cat > /tmp/docker-files/custom.html << 'EOF'
<!DOCTYPE html>
<html>
<head><title>Custom Page</title></head>
<body>
    <h1>Página personalizada</h1>
    <p>Creada con docker cp</p>
</body>
</html>
EOF

# TODO: Copiar al contenedor
docker cp /tmp/docker-files/custom.html app-debug:/usr/share/nginx/html/

# TODO: Verificar que se copió
docker exec app-debug cat /usr/share/nginx/html/custom.html
```

### Paso 3.3: Modificar configuración sin rebuild

```bash
# TODO: Modificar nginx.conf localmente
cat > /tmp/docker-files/nginx-custom.conf << 'EOF'
events {
    worker_connections 1024;
}

http {
    server {
        listen 80;
        server_name localhost;

        location / {
            root /usr/share/nginx/html;
            index custom.html index.html;
        }

        location /health {
            return 200 'OK';
            add_header Content-Type text/plain;
        }
    }
}
EOF

# TODO: Copiar al contenedor
docker cp /tmp/docker-files/nginx-custom.conf app-debug:/etc/nginx/nginx.conf

# TODO: Recargar nginx sin reiniciar contenedor
docker exec app-debug nginx -s reload

# TODO: Probar la nueva configuración
docker exec app-debug curl -s localhost/health
```

---

## 🏋️ Parte 4: Diagnóstico Completo

### Paso 4.1: Crear escenario problemático

```bash
# TODO: Crear aplicación que tiene problemas
docker run -d --name problematic-app \
    --memory=64m \
    -e DB_HOST=db-server \
    -e DB_PORT=3306 \
    alpine sh -c '
        echo "Iniciando aplicación..."

        # Simular intento de conexión a DB
        for i in $(seq 1 5); do
            echo "Intento $i: Conectando a $DB_HOST:$DB_PORT..."
            sleep 2
            echo "ERROR: No se puede conectar a la base de datos" >&2
        done

        echo "FATAL: Aplicación terminando por falta de conexión DB" >&2
        exit 1
    '

# TODO: Esperar a que falle
sleep 15
```

### Paso 4.2: Proceso de diagnóstico

```bash
# TODO: Paso 1 - Verificar estado
echo "=== Estado del contenedor ==="
docker ps -a --filter name=problematic-app

# TODO: Paso 2 - Ver exit code
echo -e "\n=== Exit Code ==="
docker inspect -f '{{.State.ExitCode}}' problematic-app

# TODO: Paso 3 - Ver si fue OOM
echo -e "\n=== OOM Killed ==="
docker inspect -f '{{.State.OOMKilled}}' problematic-app

# TODO: Paso 4 - Ver logs
echo -e "\n=== Logs ==="
docker logs problematic-app

# TODO: Paso 5 - Ver configuración
echo -e "\n=== Variables de Entorno ==="
docker inspect -f '{{range .Config.Env}}{{println .}}{{end}}' problematic-app | grep -E "^DB_"

# TODO: Paso 6 - Ver límites de recursos
echo -e "\n=== Límites de Recursos ==="
docker inspect -f 'Memory: {{.HostConfig.Memory}}' problematic-app
```

### Paso 4.3: Documentar diagnóstico

```bash
# TODO: Crear reporte de diagnóstico
cat > /tmp/docker-files/diagnostic-report.txt << EOF
=== REPORTE DE DIAGNÓSTICO ===
Fecha: $(date)
Contenedor: problematic-app

ESTADO:
$(docker inspect -f 'Status: {{.State.Status}}, ExitCode: {{.State.ExitCode}}, OOMKilled: {{.State.OOMKilled}}' problematic-app)

CONFIGURACIÓN:
$(docker inspect -f '{{range .Config.Env}}{{println .}}{{end}}' problematic-app)

LOGS (últimas 20 líneas):
$(docker logs --tail 20 problematic-app 2>&1)

CONCLUSIÓN:
La aplicación falló porque no pudo conectar a la base de datos.
El host 'db-server' no existe o no es accesible.

RECOMENDACIÓN:
1. Verificar que el servicio de base de datos está corriendo
2. Verificar la conectividad de red
3. Usar docker network para comunicación entre contenedores
EOF

cat /tmp/docker-files/diagnostic-report.txt
```

---

## 🏋️ Parte 5: Workflow de Debugging

### Paso 5.1: Contenedor de debugging

```bash
# TODO: Crear contenedor con herramientas de debugging
docker run -d --name debug-tools \
    --network host \
    alpine sh -c '
        apk add --no-cache curl netcat-openbsd bind-tools
        sleep 3600
    '

# TODO: Esperar instalación
sleep 10

# TODO: Usar para diagnóstico de red
docker exec debug-tools nslookup google.com
docker exec debug-tools curl -I https://google.com
```

### Paso 5.2: Inspeccionar desde debug container

```bash
# TODO: Ver procesos del sistema (con --pid=host)
docker run --rm --pid=host alpine ps aux | head -20

# TODO: Ver red del host
docker run --rm --network=host alpine ip addr
```

---

## 🏋️ Parte 6: Commit y Export

### Paso 6.1: Guardar estado del contenedor

```bash
# TODO: Hacer commit del contenedor modificado
docker commit -m "Nginx con página personalizada" app-debug my-nginx:custom

# TODO: Verificar la imagen
docker images my-nginx

# TODO: Crear contenedor desde la imagen guardada
docker run -d --name nginx-from-commit -p 8081:80 my-nginx:custom

# TODO: Verificar que tiene los cambios
docker exec nginx-from-commit cat /usr/share/nginx/html/custom.html
```

### Paso 6.2: Exportar contenedor

```bash
# TODO: Exportar filesystem del contenedor
docker export app-debug > /tmp/docker-files/app-debug-export.tar

# TODO: Ver tamaño
ls -lh /tmp/docker-files/app-debug-export.tar

# TODO: Ver contenido (sin extraer)
tar -tvf /tmp/docker-files/app-debug-export.tar | head -30
```

---

## ✅ Checklist de Verificación

Marca cada item completado:

- [ ] Abrí shell interactivo con exec
- [ ] Ejecuté comandos como diferentes usuarios
- [ ] Usé attach para conectar al proceso principal
- [ ] Desconecté sin detener con Ctrl+P, Ctrl+Q
- [ ] Copié archivos desde el contenedor
- [ ] Copié archivos hacia el contenedor
- [ ] Modifiqué configuración sin rebuild
- [ ] Realicé diagnóstico completo de contenedor fallido
- [ ] Creé reporte de diagnóstico
- [ ] Hice commit de contenedor modificado
- [ ] Exporté contenedor a archivo tar

---

## 🧹 Limpieza

```bash
# Eliminar contenedores
docker rm -f app-debug interactive-app problematic-app debug-tools nginx-from-commit 2>/dev/null

# Eliminar imagen creada
docker rmi my-nginx:custom 2>/dev/null

# Limpiar archivos
rm -rf /tmp/docker-files

# Verificar
docker ps -a
docker images | grep my-nginx
```

---

## 🤔 Preguntas de Reflexión

1. ¿Cuándo preferirías usar `docker cp` sobre volúmenes?
2. ¿Por qué es importante poder diagnosticar contenedores que ya fallaron?
3. ¿Qué información es más útil en un reporte de diagnóstico?
4. ¿Cuáles son las limitaciones de `docker commit`?

---

## 🔗 Navegación

| ← Anterior                                        | Proyecto →                          |
| ------------------------------------------------- | ----------------------------------- |
| [04 - Recursos](../04-recursos-limites/README.md) | [Ir al Proyecto](../../3-proyecto/) |
