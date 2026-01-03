# 🌐 Semana 04: Redes en Docker

![Header Semana 04](0-assets/week-04-header.svg)

## 📋 Información General

| Atributo          | Valor                             |
| ----------------- | --------------------------------- |
| **Duración**      | 6 horas                           |
| **Nivel**         | Principiante-Intermedio           |
| **Prerequisitos** | Semanas 01-03 completadas         |
| **Proyecto**      | Microservicios con redes aisladas |

---

## 🎯 Objetivos de Aprendizaje

Al finalizar esta semana, serás capaz de:

1. **Comprender** los diferentes tipos de redes en Docker
2. **Crear** y gestionar redes bridge personalizadas
3. **Configurar** comunicación entre contenedores usando DNS interno
4. **Implementar** port mapping para exponer servicios
5. **Diseñar** arquitecturas de red seguras con aislamiento
6. **Diagnosticar** problemas de conectividad entre contenedores

---

## 📚 Contenido

### 📖 Teoría (1.5 horas)

| Tema                            | Archivo                                               | Duración |
| ------------------------------- | ----------------------------------------------------- | -------- |
| Tipos de Redes Docker           | [01-tipos-redes.md](1-teoria/01-tipos-redes.md)       | 20 min   |
| Bridge Network en Profundidad   | [02-bridge-network.md](1-teoria/02-bridge-network.md) | 20 min   |
| Host y None Networks            | [03-host-none.md](1-teoria/03-host-none.md)           | 15 min   |
| DNS Interno y Service Discovery | [04-dns-interno.md](1-teoria/04-dns-interno.md)       | 20 min   |
| Port Mapping                    | [05-port-mapping.md](1-teoria/05-port-mapping.md)     | 15 min   |

### 💻 Ejercicios (2.5 horas)

| Ejercicio                            | Tema                            | Duración | Nivel      |
| ------------------------------------ | ------------------------------- | -------- | ---------- |
| [01](2-ejercicios/01-redes-basicas/) | Redes Básicas                   | 45 min   | Básico     |
| [02](2-ejercicios/02-comunicacion/)  | Comunicación entre Contenedores | 50 min   | Intermedio |
| [03](2-ejercicios/03-aislamiento/)   | Aislamiento y Segmentación      | 45 min   | Intermedio |

### 🚀 Proyecto (1.5 horas)

| Proyecto                                | Descripción                                        |
| --------------------------------------- | -------------------------------------------------- |
| [Microservicios con Redes](3-proyecto/) | Arquitectura de 6 contenedores en 3 redes aisladas |

### 📚 Recursos Adicionales (0.5 horas)

| Recurso                           | Descripción               |
| --------------------------------- | ------------------------- |
| [eBooks](4-recursos/ebooks-free/) | Libros gratuitos          |
| [Videos](4-recursos/videografia/) | Tutoriales en video       |
| [Web](4-recursos/webgrafia/)      | Artículos y documentación |

### 📖 Glosario

| Recurso                 | Descripción                  |
| ----------------------- | ---------------------------- |
| [Glosario](5-glosario/) | Términos clave de networking |

---

## 🗺️ Mapa de Conceptos

```
                    REDES EN DOCKER
                          │
          ┌───────────────┼───────────────┐
          │               │               │
      DRIVERS         DNS INTERNO     PORT MAPPING
          │               │               │
    ┌─────┼─────┐    Resolución      Publicación
    │     │     │    de nombres      de servicios
    │     │     │         │               │
 Bridge  Host  None   Aliases        -p / --publish
    │           │         │               │
 Default    Sin red   Service        TCP/UDP
 Custom              Discovery
    │
 Aislamiento
```

---

## ⏱️ Distribución del Tiempo

| Actividad     | Tiempo  | Porcentaje |
| ------------- | ------- | ---------- |
| 📖 Teoría     | 1.5 h   | 25%        |
| 💻 Ejercicios | 2.5 h   | 42%        |
| 🚀 Proyecto   | 1.5 h   | 25%        |
| 📚 Recursos   | 0.5 h   | 8%         |
| **Total**     | **6 h** | **100%**   |

---

## 🔑 Comandos Clave de la Semana

### Gestión de Redes

```bash
# Crear red
docker network create mi-red

# Crear red con subnet específico
docker network create --subnet 172.20.0.0/16 mi-red

# Listar redes
docker network ls

# Inspeccionar red
docker network inspect mi-red

# Eliminar red
docker network rm mi-red
```

### Conectar Contenedores

```bash
# Ejecutar en red específica
docker run --network mi-red --name app nginx

# Conectar contenedor existente
docker network connect mi-red contenedor

# Desconectar
docker network disconnect mi-red contenedor

# Usar alias de red
docker run --network mi-red --network-alias api nginx
```

### Port Mapping

```bash
# Mapeo básico
docker run -p 8080:80 nginx

# Solo localhost
docker run -p 127.0.0.1:8080:80 nginx

# Puerto aleatorio
docker run -p 80 nginx

# UDP
docker run -p 53:53/udp dns-server
```

---

## ✅ Checklist de la Semana

### Teoría

- [ ] Entender los 5 drivers de red (bridge, host, none, overlay, macvlan)
- [ ] Comprender la arquitectura bridge (veth, docker0, NAT)
- [ ] Conocer cómo funciona el DNS interno de Docker
- [ ] Dominar las opciones de port mapping

### Práctica

- [ ] Crear redes bridge personalizadas
- [ ] Configurar comunicación entre contenedores
- [ ] Usar aliases de red para service discovery
- [ ] Implementar aislamiento de redes
- [ ] Diagnosticar problemas de conectividad

### Proyecto

- [ ] Crear 3 redes (DMZ, APP, DATA)
- [ ] Desplegar 6 contenedores con conectividad correcta
- [ ] Verificar matriz de comunicación
- [ ] Documentar arquitectura de red

---

## 🔗 Conexión con Otras Semanas

| Semana    | Relación                                         |
| --------- | ------------------------------------------------ |
| Semana 03 | Usamos comandos de gestión de contenedores       |
| Semana 05 | Volúmenes complementan el aislamiento de redes   |
| Semana 06 | Docker Compose simplifica la definición de redes |
| Semana 08 | Seguridad de redes en producción                 |

---

## 📊 Criterios de Evaluación

Ver [rúbrica de evaluación](rubrica-evaluacion.md) para detalles completos.

| Componente   | Peso |
| ------------ | ---- |
| Quiz teórico | 30%  |
| Ejercicios   | 40%  |
| Proyecto     | 30%  |

---

## 🆘 Recursos de Ayuda

- **Documentación**: [Docker Networking](https://docs.docker.com/network/)
- **Troubleshooting**: `docker network inspect`, `docker exec ping`
- **Comunidad**: GitHub Discussions del bootcamp

---

## 🚀 Próxima Semana

**Semana 05: Volúmenes y Persistencia**

- Tipos de volúmenes
- Bind mounts vs Named volumes
- Backup y restore de datos
- Patrones de persistencia

---

> 💡 **Tip de la semana**: Las redes personalizadas son siempre preferibles a la red bridge por defecto. Proporcionan DNS automático y mejor aislamiento.
