# 💻 Ejercicio 02: Bind Mounts para Desarrollo

## 📋 Información del Ejercicio

| Atributo          | Valor                                              |
| ----------------- | -------------------------------------------------- |
| **Duración**      | 50 minutos                                         |
| **Nivel**         | Básico-Intermedio                                  |
| **Objetivos**     | Configurar entorno de desarrollo con bind mounts   |
| **Prerequisitos** | Ejercicio 01 completado                            |

---

## 🎯 Objetivos de Aprendizaje

Al finalizar este ejercicio serás capaz de:

- ✅ Montar código fuente en un contenedor con bind mount
- ✅ Configurar hot reload para desarrollo
- ✅ Manejar diferencias de permisos entre host y contenedor
- ✅ Montar archivos de configuración de forma segura (`:ro`)
- ✅ Usar Docker Compose con bind mounts para desarrollo

---

## 📖 Contexto

Configurarás un entorno de desarrollo completo donde puedes **editar código** en tu editor local (VS Code, etc.) y ver los cambios reflejados **instantáneamente** en el contenedor, sin reconstruir la imagen.

---

## 🗂️ Estructura de Archivos

Antes de empezar, crea la siguiente estructura en tu directorio de trabajo:

```bash
mkdir -p ejercicio-bind/src ejercicio-bind/config
cd ejercicio-bind
```

---

## 📝 Instrucciones

### Parte 1: Servidor Web con Hot Reload (20 min)

**Paso 1**: Crear archivos del proyecto

```bash
# Crear página HTML
cat > src/index.html << 'EOF'
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>Docker Bind Mount - Demo</title>
  <link rel="stylesheet" href="style.css">
</head>
<body>
  <h1>🐳 Semana 05 - Bind Mounts</h1>
  <p>Este archivo se sirve desde el HOST a través de un bind mount.</p>
  <p>¡Edítame y recarga la página!</p>
  <ul>
    <li>Versión: 1.0</li>
    <li>Fecha: <span id="fecha"></span></li>
  </ul>
  <script>
    document.getElementById('fecha').textContent = new Date().toLocaleString('es');
  </script>
</body>
</html>
EOF

# Crear CSS
cat > src/style.css << 'EOF'
body {
  font-family: Arial, sans-serif;
  max-width: 800px;
  margin: 50px auto;
  background: #1a1a2e;
  color: #e0e0e0;
  padding: 20px;
}
h1 { color: #2496ED; }
li { margin: 8px 0; }
EOF
```

**Paso 2**: Crear configuración de Nginx

```bash
cat > config/nginx.conf << 'EOF'
server {
    listen 80;
    server_name localhost;
    root /usr/share/nginx/html;
    index index.html;

    # Deshabilitar caché para ver cambios al instante
    add_header Cache-Control "no-cache, no-store";
    
    location / {
        try_files $uri $uri/ =404;
    }
}
EOF
```

**Paso 3**: Lanzar Nginx con bind mounts

```bash
docker run -d \
  --name web-dev \
  -v $(pwd)/src:/usr/share/nginx/html:ro \
  -v $(pwd)/config/nginx.conf:/etc/nginx/conf.d/default.conf:ro \
  -p 8080:80 \
  nginx:alpine
```

**Paso 4**: Verificar que funciona

```bash
curl http://localhost:8080
# Abre tu navegador en http://localhost:8080
```

**Paso 5**: ¡Usar el hot reload!

Abre `src/index.html` en tu editor y cambia algo (por ejemplo, el texto o el color en el CSS). Luego recarga la página en el navegador — ¡verás los cambios instantáneamente sin reiniciar nada!

---

### Parte 2: Archivo de Configuración Seguro (15 min)

**Paso 6**: Crear configuración de aplicación

```bash
cat > config/app.env << 'EOF'
# Configuración de la aplicación
APP_NAME=mi-app-dev
APP_ENV=development
LOG_LEVEL=debug
MAX_CONNECTIONS=10
EOF
```

**Paso 7**: Montar configuración como solo lectura

```bash
# Contenedor que lee configuración del host
docker run --rm \
  --name lector-config \
  -v $(pwd)/config/app.env:/etc/app/config.env:ro \
  alpine \
  sh -c "echo '=== Configuración ===' && cat /etc/app/config.env"

# Intentar escribir (¡debe fallar!)
docker run --rm \
  -v $(pwd)/config/app.env:/etc/app/config.env:ro \
  alpine \
  sh -c "echo 'HACK=true' >> /etc/app/config.env"
# Debe aparecer: Read-only file system
```

---

### Parte 3: Entorno de Desarrollo Completo con Compose (15 min)

**Paso 8**: Crear `docker-compose.dev.yml`

```bash
cat > docker-compose.dev.yml << 'EOF'
services:
  web:
    image: nginx:alpine
    ports:
      - "8080:80"
    volumes:
      # Código fuente: lectura (nginx no necesita escribir)
      - ./src:/usr/share/nginx/html:ro
      # Configuración personalizada de nginx
      - ./config/nginx.conf:/etc/nginx/conf.d/default.conf:ro
    restart: unless-stopped

  # Watcher: muestra cambios en los archivos
  watcher:
    image: alpine
    volumes:
      - ./src:/watch:ro
    command: sh -c "apk add inotify-tools && inotifywait -m -r /watch --format '%T %w%f %e' --timefmt '%H:%M:%S'"
    restart: unless-stopped
EOF
```

**Paso 9**: Levantar el entorno de desarrollo

```bash
docker compose -f docker-compose.dev.yml up -d

# Ver los logs para confirmar que funciona
docker compose -f docker-compose.dev.yml logs

# Hacer un cambio en src/index.html y ver la notificación del watcher
echo "" >> src/index.html  # o edita con tu editor
docker compose -f docker-compose.dev.yml logs watcher
```

---

### Limpieza

```bash
# Detener todo
docker stop web-dev 2>/dev/null; true
docker rm web-dev 2>/dev/null; true
docker compose -f docker-compose.dev.yml down

# Limpiar archivos del ejercicio (opcional)
# cd .. && rm -rf ejercicio-bind
```

---

## ✅ Checklist de Verificación

- [ ] Lancé Nginx con código HTML montado como bind mount
- [ ] Edité un archivo en el host y vi el cambio en el navegador sin reiniciar
- [ ] Monté un archivo de configuración con `:ro` y verifiqué que no se puede escribir
- [ ] Intenté modificar un archivo de solo lectura y obtuve error
- [ ] Usé Docker Compose con bind mounts para un entorno de desarrollo

---

## 🤔 Preguntas de Reflexión

1. ¿Por qué usamos `:ro` para los archivos de configuración y código fuente en este caso?
2. ¿Qué ventaja tiene bind mount sobre copiar los archivos a la imagen para desarrollo?
3. Si tienes un proyecto Node.js, ¿qué directorios **no** deberías montar con bind mount? ¿Por qué?

---

## 🔗 Siguiente Ejercicio

[→ Ejercicio 03: Backup y Restore](../03-backup-restore/README.md)
