# 🌐 Ejercicio 01: Redes Básicas

## 📋 Información del Ejercicio

| Atributo          | Valor                                        |
| ----------------- | -------------------------------------------- |
| **Duración**      | 45 minutos                                   |
| **Nivel**         | Básico                                       |
| **Objetivos**     | Crear, listar, inspeccionar y eliminar redes |
| **Prerequisitos** | Docker instalado y funcionando               |

---

## 🎯 Objetivos de Aprendizaje

Al finalizar este ejercicio serás capaz de:

- ✅ Listar las redes existentes en Docker
- ✅ Crear redes bridge personalizadas
- ✅ Ejecutar contenedores en redes específicas
- ✅ Inspeccionar configuración de redes
- ✅ Eliminar redes no utilizadas

---

## 📝 Parte 1: Explorar Redes Existentes

### Paso 1.1: Listar Redes por Defecto

Docker crea tres redes automáticamente al instalarse.

```bash
# Listar todas las redes
docker network ls
```

**Resultado esperado:**

```
NETWORK ID     NAME      DRIVER    SCOPE
xxxxxxxxxxxx   bridge    bridge    local
xxxxxxxxxxxx   host      host      local
xxxxxxxxxxxx   none      null      local
```

### Paso 1.2: Inspeccionar Red Bridge Default

```bash
# Ver detalles de la red bridge
docker network inspect bridge
```

**Preguntas de verificación:**

1. ¿Cuál es el subnet de la red bridge default?
2. ¿Cuál es la gateway?
3. ¿Hay contenedores conectados actualmente?

### Paso 1.3: Ver Información Específica

```bash
# Solo el subnet
docker network inspect bridge -f '{{range .IPAM.Config}}{{.Subnet}}{{end}}'

# Solo la gateway
docker network inspect bridge -f '{{range .IPAM.Config}}{{.Gateway}}{{end}}'
```

---

## 📝 Parte 2: Crear Redes Personalizadas

### Paso 2.1: Crear Red Simple

```bash
# Crear red bridge personalizada
docker network create mi-primera-red

# Verificar creación
docker network ls | grep mi-primera-red
```

### Paso 2.2: Crear Red con Configuración Específica

```bash
# Red con subnet personalizado
docker network create \
  --subnet=10.10.0.0/24 \
  --gateway=10.10.0.1 \
  red-personalizada

# Verificar configuración
docker network inspect red-personalizada -f '{{range .IPAM.Config}}Subnet: {{.Subnet}}, Gateway: {{.Gateway}}{{end}}'
```

### Paso 2.3: Crear Red con IP Range Limitado

```bash
# Red donde los contenedores solo usan parte del subnet
docker network create \
  --subnet=192.168.100.0/24 \
  --ip-range=192.168.100.128/25 \
  --gateway=192.168.100.1 \
  red-limitada

# El rango 192.168.100.128-255 para contenedores
# El rango 192.168.100.1-127 queda libre
```

---

## 📝 Parte 3: Usar Redes con Contenedores

### Paso 3.1: Ejecutar Contenedor en Red Específica

```bash
# Ejecutar en red personalizada
docker run -d \
  --name web-server \
  --network mi-primera-red \
  nginx:alpine

# Verificar
docker inspect web-server -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}'
```

### Paso 3.2: Ejecutar Múltiples Contenedores

```bash
# Contenedor 1
docker run -d \
  --name app-1 \
  --network mi-primera-red \
  alpine sleep 3600

# Contenedor 2
docker run -d \
  --name app-2 \
  --network mi-primera-red \
  alpine sleep 3600

# Ver contenedores en la red
docker network inspect mi-primera-red -f '{{range .Containers}}{{.Name}} {{end}}'
```

### Paso 3.3: Verificar Conectividad entre Contenedores

```bash
# Desde app-1, hacer ping a app-2 por nombre
docker exec app-1 ping -c 3 app-2

# Desde app-2, hacer ping a web-server
docker exec app-2 ping -c 3 web-server
```

**¿Funciona?** ✅ Sí, porque están en la misma red personalizada y tienen DNS interno.

---

## 📝 Parte 4: Conectar y Desconectar Redes

### Paso 4.1: Crear Contenedor sin Red Específica

```bash
# Contenedor en red bridge default
docker run -d --name standalone alpine sleep 3600

# Verificar red actual
docker inspect standalone -f '{{range $k, $v := .NetworkSettings.Networks}}{{$k}}{{end}}'
# Resultado: bridge
```

### Paso 4.2: Conectar a Red Adicional

```bash
# Conectar a mi-primera-red
docker network connect mi-primera-red standalone

# Verificar que tiene dos redes
docker inspect standalone -f '{{range $k, $v := .NetworkSettings.Networks}}{{$k}} {{end}}'
# Resultado: bridge mi-primera-red
```

### Paso 4.3: Desconectar de Red

```bash
# Desconectar de la red bridge default
docker network disconnect bridge standalone

# Verificar
docker inspect standalone -f '{{range $k, $v := .NetworkSettings.Networks}}{{$k}}{{end}}'
# Resultado: mi-primera-red
```

### Paso 4.4: Probar Conectividad

```bash
# Ahora standalone puede comunicarse con app-1 y app-2
docker exec standalone ping -c 2 app-1
docker exec standalone ping -c 2 app-2
```

---

## 📝 Parte 5: Eliminar Redes

### Paso 5.1: Intentar Eliminar Red en Uso

```bash
# Esto fallará porque hay contenedores conectados
docker network rm mi-primera-red
# Error: network has active endpoints
```

### Paso 5.2: Desconectar Contenedores Primero

```bash
# Eliminar contenedores
docker rm -f web-server app-1 app-2 standalone

# Ahora sí se puede eliminar
docker network rm mi-primera-red
```

### Paso 5.3: Eliminar Redes No Utilizadas

```bash
# Eliminar TODAS las redes no utilizadas
docker network prune

# Confirmar con -f para no preguntar
docker network prune -f
```

### Paso 5.4: Verificar Limpieza

```bash
# Solo deberían quedar las redes default
docker network ls
```

---

## ✅ Checklist de Verificación

Marca cada ítem que hayas completado correctamente:

| Tarea                                           | Completado |
| ----------------------------------------------- | ---------- |
| Listar redes existentes con `docker network ls` | ☐          |
| Inspeccionar la red bridge default              | ☐          |
| Crear red simple con `docker network create`    | ☐          |
| Crear red con subnet personalizado              | ☐          |
| Ejecutar contenedor en red específica           | ☐          |
| Verificar conectividad entre contenedores       | ☐          |
| Conectar contenedor existente a nueva red       | ☐          |
| Desconectar contenedor de una red               | ☐          |
| Eliminar red no utilizada                       | ☐          |
| Usar `docker network prune` para limpieza       | ☐          |

---

## 🧪 Desafío Extra

Intenta crear esta configuración:

1. Una red llamada `dev-network` con subnet `172.25.0.0/16`
2. Tres contenedores: `frontend`, `backend`, `database`
3. Verifica que todos pueden comunicarse entre sí por nombre
4. Obtén la IP de cada contenedor
5. Limpia todo al finalizar

```bash
# Tu solución aquí
# ...
```

---

## 🔍 Comandos Utilizados

| Comando                     | Descripción               |
| --------------------------- | ------------------------- |
| `docker network ls`         | Listar redes              |
| `docker network create`     | Crear red                 |
| `docker network inspect`    | Ver detalles de red       |
| `docker network connect`    | Conectar contenedor a red |
| `docker network disconnect` | Desconectar contenedor    |
| `docker network rm`         | Eliminar red              |
| `docker network prune`      | Eliminar redes no usadas  |

---

## 🧹 Limpieza Final

```bash
# Eliminar todos los contenedores
docker rm -f $(docker ps -aq) 2>/dev/null

# Eliminar redes personalizadas
docker network prune -f

# Verificar estado limpio
docker ps -a
docker network ls
```

---

<div align="center">

⬅️ [Volver al Índice](../README.md) | [Siguiente: Comunicación →](../02-comunicacion/README.md)

</div>
