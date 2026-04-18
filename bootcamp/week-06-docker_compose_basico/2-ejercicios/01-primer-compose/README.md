# 💻 Ejercicio 01: Primer docker-compose.yml

## 📋 Información del Ejercicio

| Atributo          | Valor                                              |
| ----------------- | -------------------------------------------------- |
| **Duración**      | 45 minutos                                         |
| **Nivel**         | Básico                                             |
| **Objetivos**     | Crear y gestionar un Compose básico                |
| **Prerequisitos** | Semanas 01-05 completadas                          |

---

## 🎯 Objetivos de Aprendizaje

- ✅ Crear un `docker-compose.yml` válido desde cero
- ✅ Usar los comandos principales de `docker compose`
- ✅ Entender la diferencia entre `up`, `stop` y `down`
- ✅ Leer y entender el output de `docker compose ps` y `logs`
- ✅ Modificar un servicio sin recrear toda la stack

---

## 📝 Instrucciones

### Parte 1: Compose Mínimo (10 min)

**Paso 1**: Crear directorio de trabajo

```bash
mkdir compose-lab && cd compose-lab
```

**Paso 2**: Crear tu primer `docker-compose.yml`

```bash
cat > docker-compose.yml << 'EOF'
services:
  web:
    image: nginx:alpine
    ports:
      - "8080:80"
EOF
```

**Paso 3**: Levantar, inspeccionar y gestionar

```bash
# Levantar en segundo plano
docker compose up -d

# Verificar estado
docker compose ps

# Ver logs
docker compose logs web

# Acceder al servicio
curl http://localhost:8080

# Ver la configuración resuelta
docker compose config

# Detener (sin eliminar)
docker compose stop

# Verificar que los contenedores existen pero están parados
docker compose ps -a

# Volver a iniciar
docker compose start

# Eliminar todo
docker compose down
```

> Observa que `docker compose down` elimina contenedores Y las redes creadas por Compose pero **NO los volúmenes**.

---

### Parte 2: Compose con Dos Servicios (20 min)

**Paso 4**: Aplicación WordPress + MySQL

```bash
cat > docker-compose.yml << 'EOF'
services:
  db:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: rootpass
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wpuser
      MYSQL_PASSWORD: wppass
    volumes:
      - db-data:/var/lib/mysql

  wordpress:
    image: wordpress:latest
    ports:
      - "8080:80"
    environment:
      WORDPRESS_DB_HOST: db
      WORDPRESS_DB_USER: wpuser
      WORDPRESS_DB_PASSWORD: wppass
      WORDPRESS_DB_NAME: wordpress
    depends_on:
      - db

volumes:
  db-data:
EOF
```

**Paso 5**: Levantar y observar el orden de inicio

```bash
# Levantar y ver todo en tiempo real (sin -d para ver el output)
docker compose up

# En otra terminal, observar el estado
docker compose ps
```

Observa:
- `db` se inicia primero (por `depends_on`)
- `wordpress` espera a que `db` esté corriendo
- Las redes se crean automáticamente

**Paso 6**: Abrir WordPress en el navegador

```bash
# Abrir http://localhost:8080 en el navegador
# Completar la instalación de WordPress

# Ver qué red creó Compose
docker network ls | grep compose-lab
docker network inspect compose-lab_default
```

**Paso 7**: Probar la persistencia

```bash
# Completar la instalación, crear un post en WordPress
# Luego detener y recrear los contenedores

docker compose down      # Elimina contenedores, NO el volumen
docker compose up -d
# WordPress debería mantener la instalación
```

```bash
# DIFERENCIA IMPORTANTE:
docker compose down      # Mantiene db-data
docker compose down -v   # ELIMINA db-data ← pierde WordPress
```

---

### Parte 3: Comandos de Gestión (15 min)

**Paso 8**: Practicar los comandos esenciales

```bash
# Ver logs de db en tiempo real
docker compose logs -f db

# Ejecutar MySQL CLI dentro del contenedor
docker compose exec db mysql -u wpuser -pwppass wordpress

# En MySQL, mostrar tablas:
SHOW TABLES;
EXIT;

# Reiniciar solo un servicio
docker compose restart wordpress

# Ver estadísticas de uso de recursos
docker compose top

# Escalar (para servicios sin puertos fijos)
# ⚠️ Wordpress tiene puerto fijo, no se puede escalar directamente
```

**Paso 9**: Modificar y aplicar cambios

```bash
# Agregar un servicio Adminer para gestionar MySQL visualmente
cat >> docker-compose.yml << 'EOF'

  adminer:
    image: adminer:latest
    ports:
      - "8081:8080"
    depends_on:
      - db
EOF

# Aplicar el cambio (solo crea el nuevo contenedor)
docker compose up -d

# Verificar
docker compose ps
# Abrir http://localhost:8081
# Sistema: MySQL, Servidor: db, Usuario: wpuser, Contraseña: wppass
```

---

### Limpieza

```bash
docker compose down -v   # Eliminar todo incluyendo volúmenes
cd .. && rm -rf compose-lab
```

---

## ✅ Checklist de Verificación

- [ ] Creé un `docker-compose.yml` desde cero y lo levanté
- [ ] Diferencio `stop` vs `down` vs `down -v`
- [ ] Usé `docker compose exec` para entrar a un contenedor  
- [ ] Verifiqué que los datos persisten tras `docker compose down && up`
- [ ] Agregué un nuevo servicio sin recrear los existentes
- [ ] Entiendo qué red y nombre de contenedor crea Compose automáticamente

---

## 🔗 Siguiente Ejercicio

[→ Ejercicio 02: Aplicación Multi-Servicio](../02-multi-servicio/README.md)
