# 📚 Instalación de Docker

## 🎯 Objetivos de Aprendizaje

Al finalizar esta sección, serás capaz de:

- Instalar Docker en tu sistema operativo
- Verificar que la instalación funciona correctamente
- Configurar Docker para uso sin sudo (Linux)

---

## 🖥️ Opciones de Instalación

| Sistema Operativo         | Opción Recomendada |
| ------------------------- | ------------------ |
| **Windows 10/11**         | Docker Desktop     |
| **macOS**                 | Docker Desktop     |
| **Linux (Ubuntu/Debian)** | Docker Engine      |
| **Linux (Fedora/CentOS)** | Docker Engine      |

---

## 🪟 Windows

### Requisitos

- Windows 10 64-bit: Pro, Enterprise, o Education (Build 19041+)
- Windows 11 64-bit
- WSL 2 habilitado
- 4 GB RAM mínimo

### Pasos de Instalación

1. **Habilitar WSL 2**

```powershell
# En PowerShell como Administrador
wsl --install
```

2. **Descargar Docker Desktop**

   - Ve a [docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop/)
   - Descarga el instalador para Windows

3. **Instalar**

   - Ejecuta el instalador
   - Marca "Use WSL 2 instead of Hyper-V"
   - Reinicia si es necesario

4. **Verificar**

```powershell
docker --version
docker run hello-world
```

---

## 🍎 macOS

### Requisitos

- macOS 12 (Monterey) o superior
- Chip Intel o Apple Silicon (M1/M2/M3)
- 4 GB RAM mínimo

### Pasos de Instalación

1. **Descargar Docker Desktop**

   - Ve a [docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop/)
   - Selecciona la versión para tu chip (Intel o Apple Silicon)

2. **Instalar**

   - Abre el archivo `.dmg`
   - Arrastra Docker a Aplicaciones
   - Ejecuta Docker desde Aplicaciones

3. **Verificar**

```bash
docker --version
docker run hello-world
```

---

## 🐧 Linux (Ubuntu/Debian)

### Método Recomendado: Script Oficial

```bash
# Descargar y ejecutar script de instalación
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
```

### Método Manual (Ubuntu 22.04/24.04)

```bash
# 1. Actualizar e instalar dependencias
sudo apt-get update
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# 2. Añadir clave GPG oficial de Docker
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# 3. Configurar repositorio
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 4. Instalar Docker Engine
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 5. Verificar instalación
sudo docker run hello-world
```

### Ejecutar Docker sin sudo

```bash
# Crear grupo docker (si no existe)
sudo groupadd docker

# Añadir tu usuario al grupo docker
sudo usermod -aG docker $USER

# Aplicar cambios (o reiniciar sesión)
newgrp docker

# Verificar que funciona sin sudo
docker run hello-world
```

> ⚠️ **Importante**: Cierra sesión y vuelve a entrar para que los cambios de grupo surtan efecto.

---

## 🐧 Linux (Fedora/CentOS/RHEL)

```bash
# Fedora
sudo dnf -y install dnf-plugins-core
sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Iniciar Docker
sudo systemctl start docker
sudo systemctl enable docker

# Verificar
sudo docker run hello-world
```

---

## ✅ Verificación de la Instalación

### Comandos de Verificación

```bash
# Versión de Docker
docker --version
# Esperado: Docker version 27.x.x, build xxxxxxx

# Versión de Docker Compose
docker compose version
# Esperado: Docker Compose version v2.31.x

# Información del sistema Docker
docker info

# Ejecutar contenedor de prueba
docker run hello-world
```

### Resultado Esperado (hello-world)

```
Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
 3. The Docker daemon created a new container from that image...
 ...
```

---

## 🔧 Configuración Adicional

### Iniciar Docker al Arranque (Linux)

```bash
sudo systemctl enable docker
sudo systemctl start docker
```

### Configurar Recursos (Docker Desktop)

En Docker Desktop → Settings → Resources:

| Recurso | Recomendación Mínima | Desarrollo |
| ------- | -------------------- | ---------- |
| CPUs    | 2                    | 4+         |
| Memory  | 2 GB                 | 4-8 GB     |
| Disk    | 20 GB                | 60+ GB     |

### Configurar Proxy (si es necesario)

```bash
# Crear directorio de configuración
sudo mkdir -p /etc/systemd/system/docker.service.d

# Crear archivo de configuración de proxy
sudo tee /etc/systemd/system/docker.service.d/http-proxy.conf <<EOF
[Service]
Environment="HTTP_PROXY=http://proxy.example.com:8080"
Environment="HTTPS_PROXY=http://proxy.example.com:8080"
Environment="NO_PROXY=localhost,127.0.0.1"
EOF

# Recargar y reiniciar
sudo systemctl daemon-reload
sudo systemctl restart docker
```

---

## 🐛 Solución de Problemas

### Error: "permission denied"

```bash
# Solución: añadir usuario al grupo docker
sudo usermod -aG docker $USER
# Cerrar sesión y volver a entrar
```

### Error: "Cannot connect to Docker daemon"

```bash
# Verificar si Docker está corriendo
sudo systemctl status docker

# Iniciar Docker si está detenido
sudo systemctl start docker
```

### Error: "WSL 2 installation is incomplete" (Windows)

```powershell
# Actualizar kernel WSL
wsl --update
# Reiniciar
```

---

## ✅ Verificación de Aprendizaje

1. ¿Qué comando verifica la versión de Docker instalada?
2. ¿Por qué es necesario añadir el usuario al grupo `docker` en Linux?
3. ¿Qué componentes se instalan con Docker Engine?
4. ¿Cuál es el contenedor de prueba estándar para verificar la instalación?

---

## 🔗 Navegación

| ← Anterior                                     | Siguiente →                                           |
| ---------------------------------------------- | ----------------------------------------------------- |
| [03 - Arquitectura](03-arquitectura-docker.md) | [05 - Comandos Esenciales](05-comandos-esenciales.md) |
