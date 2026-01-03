# 🔌 Redes Host y None

## 📋 Tabla de Contenidos

- [Host Network](#host-network)
- [None Network](#none-network)
- [Comparación Bridge vs Host vs None](#comparación-bridge-vs-host-vs-none)
- [Casos de Uso Prácticos](#casos-de-uso-prácticos)

---

## Host Network

La red **host** elimina el aislamiento de red entre el contenedor y el host. El contenedor usa directamente el stack de red del sistema operativo.

### Características

| Aspecto            | Descripción                                        |
| ------------------ | -------------------------------------------------- |
| **Aislamiento**    | Ninguno - comparte red con el host                 |
| **Rendimiento**    | Máximo - sin overhead de virtualización            |
| **Puertos**        | Directos del host (sin -p necesario)               |
| **DNS**            | Usa resolución del host                            |
| **Disponibilidad** | Solo Linux (no funciona en Docker Desktop Mac/Win) |

### Sintaxis

```bash
docker run --network host <imagen>
```

### Ejemplo: Nginx en Host Network

```bash
# Ejecutar nginx directamente en puerto 80 del host
docker run -d --name nginx-host --network host nginx

# Verificar - nginx escucha en el host
curl localhost:80

# Ver que no hay port mapping
docker ps
# PORTS vacío porque usa directamente los del host
```

### Verificar Interfaces

```bash
# Dentro del contenedor, verás las interfaces del host
docker run --rm --network host alpine ip addr

# Comparar con el host
ip addr

# Son idénticas!
```

### Cuándo Usar Host Network

✅ **Recomendado:**

```bash
# Aplicaciones de monitoreo de red
docker run -d --network host \
  --name netdata \
  netdata/netdata

# Herramientas de diagnóstico
docker run --rm --network host \
  nicolaka/netshoot \
  tcpdump -i eth0

# Aplicaciones de alto rendimiento
docker run -d --network host \
  --name haproxy \
  haproxy:latest
```

❌ **No Recomendado:**

```bash
# Múltiples instancias del mismo servicio
# (conflicto de puertos)
docker run -d --network host nginx  # Puerto 80
docker run -d --network host nginx  # ERROR: puerto 80 ya en uso

# Entornos multi-tenant
# (sin aislamiento entre contenedores)
```

### Limitaciones

1. **Solo Linux**: En Docker Desktop (Mac/Windows), `--network host` no funciona como se espera
2. **Conflictos de puertos**: No puedes tener múltiples servicios en el mismo puerto
3. **Seguridad reducida**: El contenedor tiene acceso completo a la red del host

```bash
# En Mac/Windows, esto NO funcionará como se espera
docker run --network host nginx
# Nginx no será accesible en localhost:80
```

---

## None Network

La red **none** desactiva completamente la red del contenedor, excepto la interfaz loopback (`lo`).

### Características

| Aspecto          | Descripción                      |
| ---------------- | -------------------------------- |
| **Aislamiento**  | Total - sin conectividad externa |
| **Interfaces**   | Solo loopback (127.0.0.1)        |
| **Comunicación** | Solo consigo mismo               |
| **Uso**          | Tareas sin requisitos de red     |

### Sintaxis

```bash
docker run --network none <imagen>
```

### Ejemplo: Contenedor Aislado

```bash
# Ejecutar contenedor sin red
docker run -d --name isolated --network none alpine sleep 3600

# Verificar interfaces
docker exec isolated ip addr

# Salida:
# 1: lo: <LOOPBACK,UP,LOWER_UP>
#     inet 127.0.0.1/8 scope host lo
# (Solo loopback, sin eth0)

# Intentar conectar - fallará
docker exec isolated ping -c 1 8.8.8.8
# ping: bad address '8.8.8.8'
```

### Verificar Aislamiento

```bash
# No hay rutas de red
docker exec isolated ip route
# (vacío)

# No hay resolución DNS
docker exec isolated nslookup google.com
# nslookup: can't resolve 'google.com'

# No hay conectividad
docker exec isolated wget -q --timeout=5 http://google.com
# wget: bad address 'google.com'
```

### Casos de Uso para None Network

```bash
# 1. Procesamiento de datos sensibles
docker run --network none \
  -v /data/input:/input:ro \
  -v /data/output:/output \
  data-processor

# 2. Compilación segura
docker run --network none \
  -v $(pwd):/src \
  gcc:latest \
  gcc -o /src/app /src/main.c

# 3. Generación de claves/certificados
docker run --network none \
  -v $(pwd)/certs:/certs \
  alpine/openssl \
  genrsa -out /certs/private.key 4096

# 4. Análisis de malware (sandbox)
docker run --network none \
  --read-only \
  malware-analyzer
```

---

## Comparación Bridge vs Host vs None

### Tabla Comparativa

| Característica       | Bridge       | Host             | None     |
| -------------------- | ------------ | ---------------- | -------- |
| Aislamiento de red   | ✅ Sí        | ❌ No            | ✅ Total |
| IP propia            | ✅ Sí        | ❌ No (usa host) | ❌ N/A   |
| Port mapping (-p)    | ✅ Requerido | ❌ No aplica     | ❌ N/A   |
| DNS interno          | ✅ Sí\*      | Usa host         | ❌ No    |
| Comunicación externa | ✅ Vía NAT   | ✅ Directa       | ❌ No    |
| Rendimiento          | Medio        | Alto             | N/A      |
| Multi-contenedor     | ✅ Sí        | ⚠️ Limitado      | ❌ No    |
| Seguridad            | Alta         | Baja             | Máxima   |

\*Solo en redes bridge personalizadas

### Diagrama de Decisión

```
¿Necesita conectividad de red?
│
├─ NO → None Network
│
└─ SÍ → ¿Requiere máximo rendimiento?
         │
         ├─ SÍ → Host Network (solo Linux)
         │
         └─ NO → Bridge Network (recomendado)
```

### Ejemplo Comparativo

```bash
# Mismo contenedor, diferentes redes
# ===================================

# Bridge (default)
docker run --rm nginx ip addr | grep eth0
# eth0: 172.17.0.2/16

# Host
docker run --rm --network host nginx ip addr | grep eth0
# eth0: 192.168.1.100/24 (IP del host)

# None
docker run --rm --network none alpine ip addr
# Solo muestra: lo (loopback)
```

---

## Casos de Uso Prácticos

### Caso 1: Monitoreo con Host Network

```bash
# Prometheus con acceso a métricas del host
docker run -d \
  --name prometheus \
  --network host \
  -v /prometheus-data:/prometheus \
  prom/prometheus

# Node Exporter para métricas del sistema
docker run -d \
  --name node-exporter \
  --network host \
  --pid host \
  -v /:/host:ro \
  prom/node-exporter \
  --path.rootfs=/host
```

### Caso 2: Procesamiento Seguro con None

```bash
# Cifrar archivo sin acceso a red
docker run --rm --network none \
  -v $(pwd)/data:/data \
  alpine/openssl \
  enc -aes-256-cbc -salt -in /data/secret.txt -out /data/secret.enc

# Generar hash de archivos
docker run --rm --network none \
  -v $(pwd)/files:/files:ro \
  alpine \
  sh -c "cd /files && sha256sum * > checksums.txt"
```

### Caso 3: Debugging de Red con Host

```bash
# Analizar tráfico de red del host
docker run --rm -it --network host \
  nicolaka/netshoot \
  tcpdump -i any port 80

# Escanear puertos locales
docker run --rm --network host \
  instrumentisto/nmap \
  -sT localhost

# Ver conexiones activas
docker run --rm --network host \
  alpine \
  netstat -tulpn
```

### Caso 4: Benchmark de Red

```bash
# Comparar rendimiento bridge vs host

# Bridge (con overhead de NAT)
docker run --rm \
  networkstatic/iperf3 -c servidor-iperf

# Host (sin overhead)
docker run --rm --network host \
  networkstatic/iperf3 -c servidor-iperf

# El modo host típicamente muestra 10-20% mejor throughput
```

---

## 🧪 Laboratorio

### Ejercicio 1: Comparar Interfaces

```bash
# 1. Ver interfaces en modo bridge
docker run --rm alpine ip addr

# 2. Ver interfaces en modo host
docker run --rm --network host alpine ip addr

# 3. Ver interfaces en modo none
docker run --rm --network none alpine ip addr

# Pregunta: ¿Cuántas interfaces tiene cada uno?
```

### Ejercicio 2: Probar Conectividad

```bash
# Crear script de prueba
cat > test-network.sh << 'EOF'
echo "=== Probando conectividad ==="
echo "Interfaces:"
ip addr | grep -E "^[0-9]+:|inet "
echo ""
echo "Probando ping a 8.8.8.8:"
ping -c 1 -W 2 8.8.8.8 2>&1 || echo "Sin conectividad"
EOF

# Probar en cada modo
docker run --rm -v $(pwd)/test-network.sh:/test.sh alpine sh /test.sh
docker run --rm --network host -v $(pwd)/test-network.sh:/test.sh alpine sh /test.sh
docker run --rm --network none -v $(pwd)/test-network.sh:/test.sh alpine sh /test.sh
```

---

## 📚 Recursos Adicionales

- [Host Network Driver](https://docs.docker.com/network/host/)
- [Disable Networking for a Container](https://docs.docker.com/network/none/)
- [Network Drivers Overview](https://docs.docker.com/network/drivers/)

---

<div align="center">

⬅️ [Anterior: Bridge Network](02-bridge-network.md) | [Siguiente: DNS Interno](04-dns-interno.md) ➡️

</div>
