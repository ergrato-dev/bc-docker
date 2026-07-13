# 📖 Glosario - Semana 01: Fundamentos de Docker

## 🔤 Términos Clave

### A

#### Alpine Linux

Distribución Linux ultraligera (~5MB) optimizada para contenedores. Muy popular como imagen base por su pequeño tamaño.

```bash
docker pull alpine:3.21
```

### C

#### cgroups (Control Groups)

Característica del kernel Linux que permite limitar y aislar el uso de recursos (CPU, memoria, I/O) de procesos. Es una de las tecnologías fundamentales que hacen posibles los contenedores.

#### Cliente Docker

Interfaz de línea de comandos (CLI) que permite interactuar con el daemon Docker mediante comandos como `docker run`, `docker build`, etc.

#### Contenedor

Instancia ejecutable de una imagen Docker. Es un proceso aislado que contiene todo lo necesario para ejecutar una aplicación: código, runtime, librerías y configuración.

```bash
# Crear contenedor
docker run -d --name mi-app nginx
```

#### containerd

Runtime de contenedores de alto nivel que gestiona el ciclo de vida completo de los contenedores. Es usado por Docker Engine internamente.

### D

#### Daemon Docker (dockerd)

Servicio que corre en segundo plano y gestiona objetos Docker (imágenes, contenedores, redes, volúmenes). Escucha peticiones del cliente Docker vía API REST.

#### Detached Mode (-d)

Modo de ejecución donde el contenedor corre en segundo plano, liberando la terminal.

```bash
docker run -d nginx
```

#### Docker Desktop

Aplicación para Windows y macOS que incluye Docker Engine, CLI, Compose y herramientas adicionales con interfaz gráfica.

#### Docker Engine

El software core de Docker que permite construir y ejecutar contenedores. Incluye el daemon, la API REST y el CLI.

#### Docker Hub

Registry público oficial de Docker donde se almacenan y comparten imágenes. Similar a GitHub pero para imágenes Docker.

```bash
docker pull nginx  # Descarga de Docker Hub
```

### H

#### Host

La máquina (física o virtual) donde se ejecuta Docker Engine y los contenedores.

#### Hypervisor

Software que permite ejecutar múltiples máquinas virtuales en un solo host físico. Ejemplos: VMware, VirtualBox, Hyper-V, KVM.

### I

#### Imagen

Plantilla de solo lectura con instrucciones para crear un contenedor. Está compuesta de capas (layers) que se construyen a partir de un Dockerfile.

```bash
docker images  # Listar imágenes
```

### K

#### Kernel

Núcleo del sistema operativo que gestiona recursos del hardware. Los contenedores comparten el kernel del host, a diferencia de las máquinas virtuales.

### L

#### Layer (Capa)

Cada instrucción en un Dockerfile crea una capa en la imagen. Las capas son de solo lectura y se apilan. Se comparten entre imágenes para ahorrar espacio.

### N

#### Namespace

Característica del kernel Linux que proporciona aislamiento de recursos del sistema (procesos, red, usuarios, etc.) para los contenedores.

| Namespace | Aísla                       |
| --------- | --------------------------- |
| PID       | Procesos                    |
| NET       | Interfaces de red           |
| MNT       | Sistema de archivos         |
| UTS       | Hostname                    |
| IPC       | Comunicación entre procesos |
| USER      | UIDs/GIDs                   |

### O

#### OCI (Open Container Initiative)

Organización que define estándares abiertos para contenedores, incluyendo el formato de imagen y el runtime.

### P

#### Port Mapping

Técnica para exponer puertos del contenedor al host, permitiendo acceso externo a servicios del contenedor.

```bash
docker run -p 8080:80 nginx  # Host:8080 → Container:80
```

#### Pull

Acción de descargar una imagen desde un registry.

```bash
docker pull ubuntu:22.04
```

#### Push

Acción de subir una imagen a un registry.

```bash
docker push miusuario/miapp:v1
```

### R

#### Registry

Servicio que almacena y distribuye imágenes Docker. Puede ser público (Docker Hub) o privado (Harbor, ECR, GCR).

#### runc

Herramienta de bajo nivel que crea y ejecuta contenedores según la especificación OCI. Es usada por containerd.

### T

#### Tag

Etiqueta que identifica una versión específica de una imagen. Por defecto es `latest`.

```bash
# imagen:tag
nginx:alpine
python:3.12-slim
ubuntu:22.04
```

### V

#### Virtualización

Tecnología que permite ejecutar múltiples sistemas operativos en un solo host físico. Los contenedores usan virtualización a nivel de OS, mientras que las VMs usan virtualización de hardware.

#### Volumen

Mecanismo para persistir datos generados por contenedores. Los datos en volúmenes sobreviven a la eliminación del contenedor.

```bash
docker volume create mis-datos
docker run -v mis-datos:/data nginx
```

---

## 📊 Comparativa Rápida

| Término    | Descripción Corta               |
| ---------- | ------------------------------- |
| Imagen     | Plantilla (solo lectura)        |
| Contenedor | Instancia ejecutable de imagen  |
| Registry   | Almacén de imágenes             |
| Daemon     | Servicio que gestiona Docker    |
| Cliente    | CLI para interactuar con Docker |
| Volumen    | Almacenamiento persistente      |
| Network    | Red para comunicación           |

---

## 🔗 Navegación

| ← Proyecto                                  | Recursos →                             |
| ------------------------------------------- | -------------------------------------- |
| [Proyecto Semanal](../3-proyecto/README.md) | [Recursos Adicionales](../4-recursos/) |
