# 💻 Ejercicio 03: Variables de Entorno y Configuración

## 🎯 Objetivos

- Configurar contenedores con variables de entorno
- Usar archivos .env
- Entender la precedencia de variables
- Implementar configuración dinámica

---

## ⏱️ Duración Estimada

30 minutos

---

## 📋 Requisitos Previos

- Docker instalado y funcionando
- Lectura de [05-variables-entorno.md](../../1-teoria/05-variables-entorno.md)

---

## 🏋️ Parte 1: Variables con -e

### Paso 1.1: Variables simples

```bash
# TODO: Crear contenedor con variable de entorno
docker run -d --name app-env -e APP_NAME=MiAplicacion alpine sleep 3600

# TODO: Verificar la variable
docker exec app-env printenv APP_NAME

# TODO: Ver todas las variables
docker exec app-env env | sort
```

### Paso 1.2: Múltiples variables

```bash
# TODO: Crear contenedor con múltiples variables
docker run -d --name db-config \
    -e DB_HOST=localhost \
    -e DB_PORT=3306 \
    -e DB_NAME=produccion \
    -e DB_USER=admin \
    alpine sleep 3600

# TODO: Verificar las variables de DB
docker exec db-config printenv | grep DB_

# TODO: Usar variable en comando
docker exec db-config sh -c 'echo "Conectando a $DB_HOST:$DB_PORT/$DB_NAME"'
```

### Paso 1.3: Variables desde el host

```bash
# TODO: Exportar variable en el host
export MI_SECRETO="valor-desde-host"

# TODO: Pasar variable al contenedor (sin valor, usa el del host)
docker run --rm -e MI_SECRETO alpine printenv MI_SECRETO

# TODO: Sobrescribir variable del host
docker run --rm -e MI_SECRETO=otro-valor alpine printenv MI_SECRETO
```

---

## 🏋️ Parte 2: Archivos de Entorno

### Paso 2.1: Crear archivo .env

```bash
# TODO: Crear directorio de trabajo
mkdir -p /tmp/docker-env-exercise
cd /tmp/docker-env-exercise

# TODO: Crear archivo de configuración
cat > app.env << 'EOF'
# Configuración de la aplicación
APP_ENV=production
APP_DEBUG=false
APP_PORT=8080

# Base de datos
DB_HOST=mysql-server
DB_PORT=3306
DB_NAME=myapp_prod
DB_USER=appuser
DB_PASS=secretpassword123
EOF

# TODO: Ver el contenido
cat app.env
```

### Paso 2.2: Usar archivo .env

```bash
# TODO: Crear contenedor con archivo de entorno
docker run -d --name app-from-file \
    --env-file app.env \
    alpine sleep 3600

# TODO: Verificar que se cargaron las variables
docker exec app-from-file printenv | grep -E "^(APP_|DB_)"

# TODO: Verificar variable específica
docker exec app-from-file printenv APP_ENV
```

### Paso 2.3: Combinar archivo y línea de comandos

```bash
# TODO: Crear con archivo + override
docker run -d --name app-override \
    --env-file app.env \
    -e APP_DEBUG=true \
    -e APP_ENV=development \
    alpine sleep 3600

# TODO: Verificar qué valores tienen las variables
docker exec app-override printenv APP_DEBUG
docker exec app-override printenv APP_ENV

# Pregunta: ¿Qué valor ganó? ¿Por qué?
```

---

## 🏋️ Parte 3: Configuración de MySQL

### Paso 3.1: Variables oficiales de MySQL

```bash
# TODO: Crear archivo de configuración para MySQL
cat > mysql.env << 'EOF'
MYSQL_ROOT_PASSWORD=rootsecret123
MYSQL_DATABASE=testdb
MYSQL_USER=testuser
MYSQL_PASSWORD=testpass456
EOF

# TODO: Iniciar MySQL con las variables
docker run -d --name mysql-test \
    --env-file mysql.env \
    mysql:8.0

# TODO: Esperar a que MySQL inicie (puede tardar 30-60 segundos)
sleep 30

# TODO: Verificar que la base de datos se creó
docker exec mysql-test mysql -uroot -prootsecret123 -e "SHOW DATABASES;"
```

### Paso 3.2: Verificar usuario creado

```bash
# TODO: Conectar como el usuario creado
docker exec mysql-test mysql -utestuser -ptestpass456 -e "SELECT CURRENT_USER();"

# TODO: Verificar acceso a la base de datos
docker exec mysql-test mysql -utestuser -ptestpass456 testdb -e "SHOW TABLES;"
```

---

## 🏋️ Parte 4: Precedencia de Variables

### Paso 4.1: Crear imagen con ENV

```bash
# TODO: Crear Dockerfile con variables
cat > Dockerfile << 'EOF'
FROM alpine:3.19
ENV APP_MODE=dockerfile
ENV LOG_LEVEL=info
ENV VERSION=1.0
CMD ["sh", "-c", "echo Mode=$APP_MODE Log=$LOG_LEVEL Version=$VERSION && sleep 3600"]
EOF

# TODO: Construir la imagen
docker build -t env-test:v1 .
```

### Paso 4.2: Probar precedencia

```bash
# TODO: Ejecutar solo con valores del Dockerfile
docker run -d --name test1 env-test:v1
sleep 2
docker logs test1

# TODO: Sobrescribir con -e
docker run -d --name test2 -e APP_MODE=comandoline env-test:v1
sleep 2
docker logs test2

# TODO: Crear archivo de override
cat > override.env << 'EOF'
APP_MODE=envfile
LOG_LEVEL=debug
EOF

# TODO: Probar con archivo
docker run -d --name test3 --env-file override.env env-test:v1
sleep 2
docker logs test3

# TODO: Archivo + línea de comandos
docker run -d --name test4 --env-file override.env -e LOG_LEVEL=warning env-test:v1
sleep 2
docker logs test4

# Pregunta: Ordena los métodos de mayor a menor precedencia
```

---

## 🏋️ Parte 5: Inspect de Variables

### Paso 5.1: Ver variables con inspect

```bash
# TODO: Ver todas las variables de un contenedor
docker inspect -f '{{range .Config.Env}}{{println .}}{{end}}' app-from-file

# TODO: Buscar variable específica
docker inspect -f '{{range .Config.Env}}{{println .}}{{end}}' app-from-file | grep DB_HOST

# TODO: Formato JSON
docker inspect app-from-file | jq '.[0].Config.Env'
```

### Paso 5.2: Comparar configuraciones

```bash
# TODO: Script para comparar variables entre contenedores
echo "=== test1 (solo Dockerfile) ==="
docker inspect -f '{{range .Config.Env}}{{println .}}{{end}}' test1 | grep -E "^(APP_|LOG_|VERSION)"

echo "=== test4 (Dockerfile + envfile + -e) ==="
docker inspect -f '{{range .Config.Env}}{{println .}}{{end}}' test4 | grep -E "^(APP_|LOG_|VERSION)"
```

---

## 🏋️ Parte 6: Buenas Prácticas

### Paso 6.1: Template de configuración

```bash
# TODO: Crear archivo .env.example (para versionar)
cat > .env.example << 'EOF'
# Configuración de la aplicación
# Copiar a .env y completar valores
APP_ENV=development
APP_DEBUG=true
APP_PORT=3000

# Base de datos (REQUERIDO)
DB_HOST=
DB_PORT=3306
DB_NAME=
DB_USER=
DB_PASS=
EOF

# TODO: Crear .gitignore
cat > .gitignore << 'EOF'
.env
.env.local
*.env.local
secrets/
EOF

echo "Archivos creados: .env.example y .gitignore"
```

### Paso 6.2: Validar variables requeridas

```bash
# TODO: Script de validación
cat > validate-env.sh << 'EOF'
#!/bin/sh
REQUIRED_VARS="DB_HOST DB_NAME DB_USER DB_PASS"

for var in $REQUIRED_VARS; do
    value=$(printenv $var)
    if [ -z "$value" ]; then
        echo "ERROR: Variable $var no está definida"
        exit 1
    fi
done

echo "OK: Todas las variables requeridas están definidas"
EOF

chmod +x validate-env.sh

# TODO: Probar validación (debería fallar)
docker run --rm -v $(pwd)/validate-env.sh:/validate.sh alpine sh /validate.sh

# TODO: Probar con variables definidas
docker run --rm \
    -e DB_HOST=localhost \
    -e DB_NAME=test \
    -e DB_USER=user \
    -e DB_PASS=pass \
    -v $(pwd)/validate-env.sh:/validate.sh \
    alpine sh /validate.sh
```

---

## ✅ Checklist de Verificación

Marca cada item completado:

- [ ] Configuré variables con `-e`
- [ ] Usé múltiples variables en un contenedor
- [ ] Pasé variables desde el host
- [ ] Creé y usé archivo `.env`
- [ ] Combiné `--env-file` con `-e`
- [ ] Configuré MySQL con variables de entorno
- [ ] Entendí la precedencia de variables
- [ ] Inspeccioné variables con `docker inspect`
- [ ] Creé template `.env.example`
- [ ] Implementé validación de variables

---

## 🧹 Limpieza

```bash
# Eliminar contenedores
docker rm -f app-env db-config app-from-file app-override mysql-test test1 test2 test3 test4 2>/dev/null

# Limpiar archivos temporales
cd ~
rm -rf /tmp/docker-env-exercise

# Verificar
docker ps -a
```

---

## 🤔 Preguntas de Reflexión

1. ¿Por qué no deberías poner secretos directamente en el Dockerfile?
2. ¿Cuál es el orden de precedencia de las variables?
3. ¿Cómo manejarías diferentes configuraciones para dev/staging/prod?
4. ¿Qué ventajas tiene usar archivos .env sobre múltiples `-e`?

---

## 🔗 Navegación

| ← Anterior                                  | Siguiente →                                       |
| ------------------------------------------- | ------------------------------------------------- |
| [02 - Logs](../02-logs-debugging/README.md) | [04 - Recursos](../04-recursos-limites/README.md) |
