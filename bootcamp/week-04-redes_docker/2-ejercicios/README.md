# 💻 Ejercicios - Semana 04: Redes en Docker

## 📋 Índice de Ejercicios

| #   | Ejercicio                                                    | Duración | Nivel      | Tema Principal           |
| --- | ------------------------------------------------------------ | -------- | ---------- | ------------------------ |
| 1   | [Redes Básicas](01-redes-basicas/README.md)                  | 45 min   | Básico     | Crear y gestionar redes  |
| 2   | [Comunicación entre Contenedores](02-comunicacion/README.md) | 50 min   | Intermedio | DNS y conectividad       |
| 3   | [Aislamiento de Redes](03-aislamiento/README.md)             | 45 min   | Intermedio | Segmentación y seguridad |

---

## 🎯 Objetivos de los Ejercicios

Al completar estos ejercicios serás capaz de:

- ✅ Crear y eliminar redes Docker
- ✅ Conectar contenedores a redes personalizadas
- ✅ Usar DNS interno para comunicación
- ✅ Configurar port mapping correctamente
- ✅ Implementar aislamiento entre redes
- ✅ Diagnosticar problemas de conectividad

---

## 📝 Instrucciones Generales

### Antes de Comenzar

```bash
# Verificar que Docker está funcionando
docker --version
docker network ls

# Limpiar contenedores/redes de sesiones anteriores
docker rm -f $(docker ps -aq) 2>/dev/null
docker network prune -f
```

### Durante los Ejercicios

1. **Lee** las instrucciones completas antes de empezar
2. **Ejecuta** los comandos paso a paso
3. **Verifica** cada resultado antes de continuar
4. **Anota** cualquier error o comportamiento inesperado

### Después de Cada Ejercicio

```bash
# Limpiar recursos creados
docker rm -f $(docker ps -aq) 2>/dev/null
docker network prune -f
```

---

## ⏱️ Distribución del Tiempo

| Ejercicio          | Lectura    | Práctica   | Verificación |
| ------------------ | ---------- | ---------- | ------------ |
| 01 - Redes Básicas | 10 min     | 25 min     | 10 min       |
| 02 - Comunicación  | 10 min     | 30 min     | 10 min       |
| 03 - Aislamiento   | 10 min     | 25 min     | 10 min       |
| **Total**          | **30 min** | **80 min** | **30 min**   |

---

## 🔧 Herramientas Útiles

### Comandos de Red Esenciales

```bash
# Listar redes
docker network ls

# Crear red
docker network create <nombre>

# Inspeccionar red
docker network inspect <nombre>

# Conectar contenedor
docker network connect <red> <contenedor>

# Desconectar contenedor
docker network disconnect <red> <contenedor>

# Eliminar red
docker network rm <nombre>
```

### Comandos de Diagnóstico

```bash
# Ver IP de contenedor
docker inspect <contenedor> -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}'

# Ver redes de contenedor
docker inspect <contenedor> -f '{{json .NetworkSettings.Networks}}' | jq

# Probar conectividad
docker exec <contenedor> ping -c 3 <destino>

# Resolver DNS
docker exec <contenedor> nslookup <nombre>
```

---

## 📊 Autoevaluación

Después de completar todos los ejercicios, verifica que puedes:

| Competencia                                | ✅  |
| ------------------------------------------ | --- |
| Crear una red bridge personalizada         | ☐   |
| Ejecutar contenedores en redes específicas | ☐   |
| Comunicar contenedores por nombre DNS      | ☐   |
| Publicar puertos correctamente             | ☐   |
| Aislar contenedores en redes separadas     | ☐   |
| Conectar un contenedor a múltiples redes   | ☐   |
| Diagnosticar problemas de conectividad     | ☐   |

---

## 🆘 Solución de Problemas Comunes

### "Network not found"

```bash
# Verificar que la red existe
docker network ls | grep <nombre-red>

# Crear si no existe
docker network create <nombre-red>
```

### "Cannot connect to container"

```bash
# Verificar que están en la misma red
docker network inspect <red> | grep -A5 Containers
```

### "Name resolution failed"

```bash
# Solo funciona en redes personalizadas, NO en bridge default
docker network create mi-red
docker run --network mi-red ...
```

---

<div align="center">

[Comenzar Ejercicio 1 →](01-redes-basicas/README.md)

</div>
