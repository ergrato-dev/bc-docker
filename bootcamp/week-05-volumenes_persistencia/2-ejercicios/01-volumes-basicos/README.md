# 💻 Ejercicio 01: Volúmenes Básicos

## 📋 Información del Ejercicio

| Atributo          | Valor                                               |
| ----------------- | --------------------------------------------------- |
| **Duración**      | 45 minutos                                          |
| **Nivel**         | Básico                                              |
| **Objetivos**     | Crear, usar, inspeccionar y eliminar volúmenes      |
| **Prerequisitos** | Docker instalado y Semana 04 completada             |

---

## 🎯 Objetivos de Aprendizaje

Al finalizar este ejercicio serás capaz de:

- ✅ Crear volúmenes nombrados con `docker volume create`
- ✅ Montar volúmenes en contenedores
- ✅ Verificar persistencia de datos entre reinicios
- ✅ Inspeccionar y gestionar el ciclo de vida de volúmenes
- ✅ Compartir un volumen entre múltiples contenedores

---

## 📖 Contexto

Imagina que eres el ingeniero DevOps de una empresa y necesitas configurar una base de datos PostgreSQL que **no pierda datos** cuando el contenedor se reinicia. Usarás volúmenes nombrados para garantizar la persistencia.

---

## 📝 Instrucciones

### Parte 1: Tu Primer Volumen (10 min)

**Paso 1**: Listar los volúmenes existentes

```bash
docker volume ls
```

Deberías ver algo como:
```
DRIVER    VOLUME NAME
```
(posiblemente vacío o con volúmenes de ejercicios anteriores)

**Paso 2**: Crear un volumen nombrado

```bash
# Crear volumen para PostgreSQL
docker volume create datos-postgres

# Verificar que se creó
docker volume ls
```

**Paso 3**: Inspeccionar el volumen

```bash
docker volume inspect datos-postgres
```

Observa:
- `Mountpoint`: dónde Docker guarda los datos en el host
- `Driver`: tipo de driver (local por defecto)
- `CreatedAt`: cuándo se creó

---

### Parte 2: Persistencia Real (20 min)

**Paso 4**: Crear contenedor PostgreSQL con volumen

```bash
docker run -d \
  --name mi-postgres \
  -e POSTGRES_USER=admin \
  -e POSTGRES_PASSWORD=secreto123 \
  -e POSTGRES_DB=bootcamp \
  -v datos-postgres:/var/lib/postgresql/data \
  -p 5432:5432 \
  postgres:16-alpine
```

**Paso 5**: Esperar que PostgreSQL esté listo y crear datos de prueba

```bash
# Esperar ~5 segundos que PostgreSQL inicie
sleep 5

# Crear una tabla e insertar datos
docker exec -it mi-postgres psql -U admin -d bootcamp -c "
  CREATE TABLE estudiantes (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100),
    semana INT
  );
  INSERT INTO estudiantes (nombre, semana) VALUES 
    ('Ana García', 5),
    ('Carlos López', 5),
    ('María Rodríguez', 5);
"

# Verificar los datos
docker exec mi-postgres psql -U admin -d bootcamp -c "SELECT * FROM estudiantes;"
```

**Paso 6**: ¡La prueba de fuego! Destruir y recrear el contenedor

```bash
# Eliminar el contenedor (datos en el VOLUMEN, no en el contenedor)
docker stop mi-postgres
docker rm mi-postgres

# Crear NUEVO contenedor con EL MISMO VOLUMEN
docker run -d \
  --name mi-postgres-nuevo \
  -e POSTGRES_USER=admin \
  -e POSTGRES_PASSWORD=secreto123 \
  -e POSTGRES_DB=bootcamp \
  -v datos-postgres:/var/lib/postgresql/data \
  -p 5432:5432 \
  postgres:16-alpine

sleep 5

# ¿Siguen los datos?
docker exec mi-postgres-nuevo psql -U admin -d bootcamp -c "SELECT * FROM estudiantes;"
```

> 🎉 Si ves los 3 estudiantes, ¡la persistencia funciona correctamente!

---

### Parte 3: Compartir Volumen entre Contenedores (15 min)

**Paso 7**: Crear un volumen compartido con archivos

```bash
# Crear volumen compartido
docker volume create datos-compartidos

# Contenedor escritor: escribe un archivo
docker run --rm \
  -v datos-compartidos:/datos \
  alpine \
  sh -c "echo 'Hola desde el escritor!' > /datos/mensaje.txt && echo 'Fecha: '$(date) >> /datos/mensaje.txt"

# Contenedor lector: lee el archivo
docker run --rm \
  -v datos-compartidos:/datos:ro \
  alpine \
  cat /datos/mensaje.txt
```

**Paso 8**: Contenedores concurrentes

```bash
# Lanzar un "servidor de logs" que escribe continuamente
docker run -d \
  --name logger \
  -v datos-compartidos:/logs \
  alpine \
  sh -c "while true; do echo \$(date '+%H:%M:%S') - ping >> /logs/app.log; sleep 2; done"

# En otra terminal, leer los logs en tiempo real
docker run --rm \
  -v datos-compartidos:/logs:ro \
  alpine \
  tail -f /logs/app.log
```

Presiona `Ctrl+C` para detener el lector.

---

### Limpieza

```bash
# Detener y eliminar contenedores
docker stop mi-postgres-nuevo logger 2>/dev/null; true
docker rm mi-postgres-nuevo logger 2>/dev/null; true

# Los datos SÍ persisten — verificar
docker volume ls

# Eliminar volúmenes cuando hayas terminado
docker volume rm datos-postgres datos-compartidos
```

---

## ✅ Checklist de Verificación

- [ ] Creé un volumen con `docker volume create`
- [ ] Monté el volumen en un contenedor PostgreSQL
- [ ] Creé datos (tabla + registros) en la base de datos
- [ ] Destruí el contenedor y verifiqué que los datos persisten en el nuevo
- [ ] Compartí un volumen entre dos contenedores simultáneos
- [ ] Entiendo la diferencia entre eliminar un **contenedor** y un **volumen**

---

## 🤔 Preguntas de Reflexión

1. ¿Qué pasaría si ejecutas `docker run` **sin** `-v datos-postgres:/var/lib/postgresql/data`? ¿Seguirían los datos?
2. ¿Por qué es peligroso usar `docker volume prune` sin revisar antes?
3. ¿Cuándo preferirías un volumen anónimo sobre uno nombrado?

---

## 🔗 Siguiente Ejercicio

[→ Ejercicio 02: Bind Mounts para Desarrollo](../02-bind-mounts/README.md)
