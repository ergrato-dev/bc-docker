# 📂 Starter - Proyecto Semana 04

## 🎯 Tu Misión

Completa los scripts y configuraciones para desplegar la arquitectura de microservicios.

---

## 📁 Archivos a Completar

| Archivo                        | Estado      | Descripción                      |
| ------------------------------ | ----------- | -------------------------------- |
| `scripts/setup-networks.sh`    | 🔧 TODO     | Crear las 3 redes                |
| `scripts/deploy.sh`            | 🔧 TODO     | Desplegar los 6 contenedores     |
| `scripts/test-connectivity.sh` | ✅ Completo | Verificar matriz de comunicación |
| `scripts/cleanup.sh`           | 🔧 TODO     | Limpiar recursos                 |
| `nginx/nginx.conf`             | 🔧 TODO     | Configuración de proxy           |

---

## 📝 Instrucciones

### Paso 1: Crear Redes

Edita `scripts/setup-networks.sh` para crear:

- `dmz-net` - Red para exposición pública
- `app-net` - Red para comunicación de aplicación
- `data-net` - Red para acceso a datos

### Paso 2: Desplegar Contenedores

Edita `scripts/deploy.sh` para crear los contenedores con las redes correctas:

1. **nginx**: dmz-net + app-net, puerto 8080:80
2. **api-gateway**: app-net + data-net
3. **users-service**: app-net + data-net
4. **products-service**: app-net + data-net
5. **postgres**: data-net (con password)
6. **redis**: data-net

### Paso 3: Configurar Nginx

Edita `nginx/nginx.conf` para proxy a los servicios internos.

### Paso 4: Verificar

Ejecuta `scripts/test-connectivity.sh` para validar la matriz.

### Paso 5: Documentar

Anota cualquier decisión de diseño o problema encontrado.

---

## 🚀 Ejecución

```bash
# 1. Dar permisos de ejecución
chmod +x scripts/*.sh

# 2. Crear redes
./scripts/setup-networks.sh

# 3. Desplegar contenedores
./scripts/deploy.sh

# 4. Verificar conectividad
./scripts/test-connectivity.sh

# 5. Limpiar (al finalizar)
./scripts/cleanup.sh
```

---

## ✅ Checklist

- [ ] `setup-networks.sh` crea las 3 redes
- [ ] `deploy.sh` despliega los 6 contenedores
- [ ] nginx accesible en localhost:8080
- [ ] Test de conectividad pasa al 100%
- [ ] `cleanup.sh` elimina todo correctamente

---

<div align="center">

[← Volver al Proyecto](../README.md)

</div>
