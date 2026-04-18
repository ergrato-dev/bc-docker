# 🚀 Proyecto Semana 01: Starter

## 📋 Instrucciones Paso a Paso

Sigue estos pasos para completar el proyecto. Los comandos marcados con `# TODO` debes completarlos tú.

---

## Paso 1: Crear la Red

Crea una red bridge personalizada para que todos los contenedores se comuniquen.

```bash
# TODO: Crear la red llamada "dev-network"
docker network create ________
```

✅ **Verificación**:

```bash
docker network ls | grep dev
```

---

## Paso 2: Iniciar PostgreSQL

Crea el contenedor de base de datos con las variables de entorno necesarias.

```bash
# TODO: Completar el comando
docker run -d \
  --name db \
  --network ________ \
  -e POSTGRES_USER=________ \
  -e POSTGRES_PASSWORD=________ \
  -e POSTGRES_DB=________ \
  -p 5432:5432 \
  --restart unless-stopped \
  postgres:16-alpine
```

✅ **Verificación**:

```bash
docker logs db
# Deberías ver: "database system is ready to accept connections"
```

---

## Paso 3: Iniciar Redis

Crea el contenedor de caché.

```bash
# TODO: Completar el comando
docker run -d \
  --name ________ \
  --network dev-network \
  -p ________:6379 \
  --restart unless-stopped \
  redis:alpine
```

✅ **Verificación**:

```bash
docker exec cache redis-cli ping
# Debería responder: PONG
```

---

## Paso 4: Iniciar Nginx

Crea el servidor web.

```bash
# TODO: Completar el comando
docker run -d \
  --name ________ \
  --network ________ \
  -p 8080:________ \
  --restart unless-stopped \
  nginx:alpine
```

✅ **Verificación**:

```bash
curl http://localhost:8080
# O visita http://localhost:8080 en el navegador
```

---

## Paso 5: Iniciar Adminer

Crea el administrador de base de datos web.

```bash
# TODO: Completar el comando
docker run -d \
  --name dbadmin \
  --network ________ \
  -p ________:8080 \
  --restart unless-stopped \
  adminer
```

✅ **Verificación**:

- Visita `http://localhost:8081`
- Deberías ver la interfaz de Adminer

---

## Paso 6: Conectar Adminer a PostgreSQL

1. Abre `http://localhost:8081` en el navegador
2. Completa los campos:

| Campo         | Valor                                    |
| ------------- | ---------------------------------------- |
| Sistema       | PostgreSQL                               |
| Servidor      | `________` (nombre del contenedor de DB) |
| Usuario       | `________`                               |
| Contraseña    | `________`                               |
| Base de datos | `________`                               |

3. Clic en "Entrar"

✅ **Verificación**: Deberías ver la interfaz de administración de PostgreSQL.

---

## Paso 7: Verificar Conectividad

Entra al contenedor web y verifica que puede comunicarse con los demás:

```bash
# Entrar al contenedor nginx
docker exec -it web sh

# Dentro del contenedor:
# Instalar herramientas (alpine no tiene ping por defecto)
apk add --no-cache curl

# Verificar conectividad con PostgreSQL
# TODO: ¿Qué comando usarías para probar la conexión?


# Verificar conectividad con Redis
# TODO: ¿Qué comando usarías?


# Salir
exit
```

---

## Paso 8: Documentar

Crea un archivo con los comandos que usaste:

```bash
# Ver todos los contenedores corriendo
docker ps

# Guardar el estado actual
docker ps > mi-proyecto.txt
```

Toma capturas de pantalla de:

1. Terminal con `docker ps` mostrando los 4 contenedores
2. Navegador con nginx (localhost:8080)
3. Navegador con Adminer conectado a PostgreSQL (localhost:8081)

---

## Paso 9: Script de Limpieza

Crea un script para limpiar todos los recursos:

```bash
# TODO: Crea un archivo llamado cleanup.sh con los comandos necesarios
# Debe:
# 1. Detener todos los contenedores del proyecto
# 2. Eliminar los contenedores
# 3. Eliminar la red

# Pista: usa estos comandos
# docker stop ...
# docker rm ...
# docker network rm ...
```

---

## ✅ Checklist Final

- [ ] Red `dev-network` creada
- [ ] PostgreSQL corriendo con variables de entorno
- [ ] Redis corriendo y respondiendo PONG
- [ ] Nginx accesible en puerto 8080
- [ ] Adminer accesible en puerto 8081
- [ ] Adminer conecta exitosamente a PostgreSQL
- [ ] Captura de `docker ps` con los 4 contenedores
- [ ] Script de limpieza creado

---

## 🆘 ¿Necesitas Ayuda?

Si te atascas, revisa:

1. Los logs del contenedor: `docker logs <nombre>`
2. El estado de la red: `docker network inspect dev-network`
3. La solución completa en [../solution/](../solution/)

---

## 🔗 Navegación

| ← Proyecto                      | Solución →                            |
| ------------------------------- | ------------------------------------- |
| [README Proyecto](../README.md) | [Ver Solución](../solution/README.md) |
