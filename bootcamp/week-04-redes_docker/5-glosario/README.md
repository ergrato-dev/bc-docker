# 📖 Glosario - Semana 04: Redes en Docker

Términos y conceptos clave relacionados con networking en Docker.

---

## 🔤 Índice Alfabético

[A](#a) | [B](#b) | [C](#c) | [D](#d) | [E](#e) | [F](#f) | [G](#g) | [H](#h) | [I](#i) | [L](#l) | [M](#m) | [N](#n) | [O](#o) | [P](#p) | [R](#r) | [S](#s) | [T](#t) | [V](#v)

---

## A

### Alias (Network Alias)

Nombre alternativo para un contenedor dentro de una red Docker. Permite que un contenedor sea accesible por múltiples nombres DNS.

```bash
docker run --network mi-red --network-alias mi-alias nginx
```

---

## B

### Bridge (Red Bridge)

Driver de red por defecto en Docker. Crea una red virtual privada donde los contenedores pueden comunicarse entre sí. Usa un bridge de Linux (`docker0`) para conectar contenedores.

```bash
docker network create --driver bridge mi-red
```

### Bind Address

Dirección IP específica a la que se vincula un puerto publicado. Por defecto es `0.0.0.0` (todas las interfaces).

```bash
docker run -p 127.0.0.1:8080:80 nginx  # Solo localhost
```

---

## C

### CIDR (Classless Inter-Domain Routing)

Notación para especificar rangos de direcciones IP. Ejemplo: `172.18.0.0/16` representa 65,536 direcciones.

| CIDR | Direcciones | Ejemplo        |
| ---- | ----------- | -------------- |
| /8   | 16,777,216  | 10.0.0.0/8     |
| /16  | 65,536      | 172.18.0.0/16  |
| /24  | 256         | 192.168.1.0/24 |

### CNI (Container Network Interface)

Especificación estándar para plugins de red en contenedores. Define cómo configurar interfaces de red en contenedores Linux.

### Container Network Model (CNM)

Modelo de red de Docker que define cómo se crean y gestionan las redes de contenedores. Incluye conceptos de sandbox, endpoint y network.

---

## D

### DNS Interno

Servidor DNS embebido en Docker que permite la resolución de nombres de contenedores. Solo funciona en redes personalizadas (no en la red bridge por defecto).

```bash
# Funciona en red personalizada
docker exec contenedor1 ping contenedor2
```

### docker0

Interface de red bridge por defecto creada por Docker en el host. Actúa como gateway para contenedores en la red bridge por defecto.

### Driver de Red

Plugin que implementa la funcionalidad de red en Docker. Drivers disponibles:

- `bridge` - Red virtual local
- `host` - Red del host
- `none` - Sin red
- `overlay` - Multi-host
- `macvlan` - MAC virtuales

---

## E

### Endpoint

Punto de conexión de un contenedor a una red Docker. Un contenedor puede tener múltiples endpoints (uno por cada red a la que está conectado).

### Expose

Instrucción de Dockerfile que documenta qué puertos usa una aplicación. **No publica** el puerto, solo lo documenta.

```dockerfile
EXPOSE 8080
```

---

## F

### Firewall Rules

Reglas de iptables que Docker configura automáticamente para gestionar el tráfico de red. Incluyen NAT, FORWARD y reglas de aislamiento.

---

## G

### Gateway

Router que conecta una red con otras redes. En Docker, cada red bridge tiene un gateway (generalmente `.1` del subnet).

```bash
# Ver gateway de una red
docker network inspect mi-red --format '{{range .IPAM.Config}}{{.Gateway}}{{end}}'
```

---

## H

### Host Network

Driver de red que elimina el aislamiento de red entre el contenedor y el host. El contenedor usa directamente la red del host.

```bash
docker run --network host nginx
```

---

## I

### Internal Network

Red Docker que no tiene acceso a redes externas. Los contenedores solo pueden comunicarse entre sí dentro de la red.

```bash
docker network create --internal red-interna
```

### IP Address Management (IPAM)

Sistema de Docker para asignar direcciones IP a contenedores y redes. Permite configurar subnets, gateways y pools de direcciones.

### iptables

Herramienta de Linux para configurar reglas de firewall. Docker la usa para:

- NAT de contenedores
- Port forwarding
- Aislamiento de redes

---

## L

### Link (Deprecated)

Método antiguo para conectar contenedores. **Obsoleto** - usar redes personalizadas en su lugar.

```bash
# No usar - deprecated
docker run --link contenedor1 contenedor2
```

---

## M

### MAC Address

Dirección de hardware de una interfaz de red. Docker asigna MAC addresses virtuales a los contenedores.

### Macvlan

Driver de red que asigna una MAC address única a cada contenedor, haciéndolo aparecer como un dispositivo físico en la red.

```bash
docker network create -d macvlan \
  --subnet=192.168.1.0/24 \
  --gateway=192.168.1.1 \
  -o parent=eth0 mi-macvlan
```

### MTU (Maximum Transmission Unit)

Tamaño máximo de paquete que puede transmitirse. Por defecto 1500 bytes. Puede necesitar ajuste en redes overlay.

---

## N

### NAT (Network Address Translation)

Técnica que permite a contenedores acceder a redes externas usando la IP del host. Docker configura NAT automáticamente.

### Network Namespace

Aislamiento de red a nivel de kernel Linux. Cada contenedor tiene su propio namespace con interfaces, rutas y reglas de firewall independientes.

### None Network

Driver de red que desactiva completamente la red de un contenedor. Útil para contenedores que no necesitan conectividad.

```bash
docker run --network none alpine
```

---

## O

### Overlay Network

Driver de red para comunicación entre contenedores en diferentes hosts Docker. Requiere Docker Swarm o almacenamiento de claves externo.

```bash
docker network create -d overlay mi-overlay
```

---

## P

### Port Binding / Port Mapping

Asociación entre un puerto del host y un puerto del contenedor. Permite acceso externo a servicios del contenedor.

```bash
docker run -p 8080:80 nginx  # host:contenedor
```

### Port Publishing

Acción de exponer un puerto del contenedor al exterior mediante `-p` o `--publish`.

| Formato                | Descripción                     |
| ---------------------- | ------------------------------- |
| `-p 80`                | Puerto aleatorio del host -> 80 |
| `-p 8080:80`           | 8080 del host -> 80             |
| `-p 127.0.0.1:8080:80` | Solo localhost                  |
| `-p 8080:80/udp`       | Protocolo UDP                   |

### Proxy

Intermediario que reenvía tráfico de red. Docker usa un userland proxy para port forwarding cuando iptables no está disponible.

---

## R

### Resolver

Componente que traduce nombres de dominio a direcciones IP. Docker tiene un resolver embebido en `127.0.0.11`.

### Routing

Proceso de determinar la ruta que seguirán los paquetes de red. Docker configura rutas automáticamente para cada red.

---

## S

### Sandbox

Concepto del Container Network Model que representa el stack de red de un contenedor (interfaces, rutas, DNS).

### Service Discovery

Mecanismo para que servicios encuentren y se comuniquen entre sí. En Docker, se logra mediante DNS interno.

### Subnet

Rango de direcciones IP asignado a una red. Cada red Docker tiene su propio subnet.

```bash
docker network create --subnet 172.20.0.0/16 mi-red
```

---

## T

### TCP (Transmission Control Protocol)

Protocolo de transporte orientado a conexión. Por defecto en Docker para port mapping.

### TTL (Time To Live)

Tiempo de vida de registros DNS. Docker usa TTLs cortos para responder rápidamente a cambios de contenedores.

---

## V

### veth (Virtual Ethernet)

Par de interfaces de red virtuales conectadas. Docker las usa para conectar contenedores al bridge:

- Un extremo en el contenedor (`eth0`)
- Otro extremo en el bridge (`vethXXX`)

### Virtual Network

Red creada por software que simula una red física. Todas las redes Docker son virtuales.

### VXLAN (Virtual Extensible LAN)

Tecnología de encapsulación usada por el driver overlay para comunicación multi-host.

---

## 📊 Tabla de Referencia Rápida

| Concepto        | Comando Relacionado         |
| --------------- | --------------------------- |
| Crear red       | `docker network create`     |
| Listar redes    | `docker network ls`         |
| Inspeccionar    | `docker network inspect`    |
| Conectar        | `docker network connect`    |
| Desconectar     | `docker network disconnect` |
| Eliminar        | `docker network rm`         |
| Publicar puerto | `docker run -p`             |
| Red host        | `docker run --network host` |
| Sin red         | `docker run --network none` |
| Alias           | `--network-alias`           |

---

## 🔗 Referencias

- [Docker Network Documentation](https://docs.docker.com/network/)
- [Linux Network Namespaces](https://man7.org/linux/man-pages/man7/network_namespaces.7.html)
- [CNI Specification](https://github.com/containernetworking/cni)

---

> 💡 **Tip**: Usa `docker network inspect <red>` para ver detalles de cualquier concepto en acción.
