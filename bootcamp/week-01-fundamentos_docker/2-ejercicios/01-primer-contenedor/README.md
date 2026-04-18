# 💻 Ejercicio 01: Primer Contenedor

## 🎯 Objetivos

- Ejecutar tu primer contenedor Docker
- Entender la diferencia entre primer plano y segundo plano
- Practicar comandos básicos de gestión de contenedores

## ⏱️ Duración Estimada

30 minutos

## 📋 Requisitos Previos

- Docker instalado y funcionando
- Terminal/PowerShell abierto

---

## 📝 Instrucciones

### Paso 1: Verificar Docker

Antes de comenzar, verifica que Docker está funcionando:

```bash
# Verificar versión
docker --version

# Verificar que el daemon está corriendo
docker info
```

✅ **Checkpoint**: Deberías ver la versión de Docker y la información del sistema.

---

### Paso 2: Hello World

Ejecuta el contenedor de prueba oficial:

```bash
docker run hello-world
```

📌 **Observa**:

- Docker descarga la imagen automáticamente
- El contenedor se ejecuta y muestra un mensaje
- El contenedor termina inmediatamente

---

### Paso 3: Contenedor Interactivo

Ejecuta un contenedor Ubuntu en modo interactivo:

```bash
docker run -it ubuntu bash
```

Dentro del contenedor, ejecuta:

```bash
# Ver información del sistema
cat /etc/os-release

# Listar archivos
ls -la

# Ver usuario actual
whoami

# Crear un archivo
echo "Hola desde Docker" > /tmp/mi-archivo.txt
cat /tmp/mi-archivo.txt

# Salir del contenedor
exit
```

📌 **Observa**:

- `-it` permite interacción (terminal interactivo)
- Estás "dentro" de un Ubuntu, aunque tu host sea diferente
- Al salir con `exit`, el contenedor se detiene

---

### Paso 4: Contenedor en Segundo Plano

Ejecuta un servidor web nginx:

```bash
# Ejecutar en modo detached (segundo plano)
docker run -d --name mi-nginx -p 8080:80 nginx
```

Verifica que está corriendo:

```bash
# Listar contenedores activos
docker ps
```

📌 **Observa**:

- `-d`: modo detached (segundo plano)
- `--name mi-nginx`: nombre personalizado
- `-p 8080:80`: puerto 8080 del host → puerto 80 del contenedor

---

### Paso 5: Acceder al Servidor Web

Abre tu navegador y ve a:

```
http://localhost:8080
```

O usa curl desde la terminal:

```bash
curl http://localhost:8080
```

✅ **Checkpoint**: Deberías ver la página de bienvenida de nginx.

---

### Paso 6: Ver Logs

```bash
# Ver logs del contenedor
docker logs mi-nginx

# Seguir logs en tiempo real (Ctrl+C para salir)
docker logs -f mi-nginx
```

Refresca la página web varias veces y observa cómo aparecen los logs.

---

### Paso 7: Ejecutar Comandos en el Contenedor

```bash
# Ver archivos de configuración de nginx
docker exec mi-nginx ls -la /etc/nginx/

# Abrir shell en el contenedor
docker exec -it mi-nginx /bin/bash

# Dentro del contenedor:
cat /etc/nginx/nginx.conf
exit
```

---

### Paso 8: Detener y Eliminar

```bash
# Detener el contenedor
docker stop mi-nginx

# Verificar que está detenido
docker ps

# Ver todos los contenedores (incluidos detenidos)
docker ps -a

# Eliminar el contenedor
docker rm mi-nginx

# Verificar eliminación
docker ps -a
```

---

### Paso 9: Limpieza

```bash
# Ver imágenes descargadas
docker images

# Eliminar contenedores detenidos
docker container prune

# Ver espacio usado
docker system df
```

---

## ✅ Checklist de Verificación

- [ ] Ejecuté `hello-world` exitosamente
- [ ] Accedí a un contenedor Ubuntu interactivamente
- [ ] Levanté nginx en segundo plano
- [ ] Accedí a nginx desde el navegador (localhost:8080)
- [ ] Vi los logs del contenedor
- [ ] Ejecuté comandos dentro del contenedor con `exec`
- [ ] Detuve y eliminé el contenedor

---

## 🎯 Desafío Extra

Intenta lo siguiente por tu cuenta:

1. Ejecuta un contenedor de `alpine` y explora su sistema de archivos
2. Ejecuta nginx en un puerto diferente (ej: 3000)
3. Ejecuta dos contenedores nginx simultáneamente con nombres diferentes

<details>
<summary>💡 Pistas</summary>

```bash
# 1. Alpine interactivo
docker run -it alpine sh

# 2. Nginx en puerto 3000
docker run -d --name nginx-3000 -p 3000:80 nginx

# 3. Dos nginx
docker run -d --name nginx-a -p 8081:80 nginx
docker run -d --name nginx-b -p 8082:80 nginx
```

</details>

---

## 🔗 Navegación

| 📚 Teoría                                                       | Siguiente Ejercicio →                                           |
| --------------------------------------------------------------- | --------------------------------------------------------------- |
| [Comandos Esenciales](../../1-teoria/05-comandos-esenciales.md) | [02 - Explorando Imágenes](../02-explorando-imagenes/README.md) |
