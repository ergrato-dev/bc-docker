# 💻 Ejercicio 02: Escaneo de Vulnerabilidades

## 📋 Información del Ejercicio

| Atributo          | Valor                                              |
| ----------------- | -------------------------------------------------- |
| **Duración**      | 50 minutos                                         |
| **Nivel**         | Intermedio                                         |
| **Objetivos**     | Escanear imágenes y reducir CVEs                   |
| **Prerequisitos** | Ejercicio 01 completado                            |

---

## 🎯 Objetivos de Aprendizaje

- ✅ Usar Trivy para escanear imágenes locales y del registry
- ✅ Comparar la superficie de ataque de distintas imágenes base
- ✅ Usar multi-stage y Alpine para reducir CVEs
- ✅ Interpretar los resultados del escaneo

---

## 📝 Instrucciones

### Parte 1: Instalar Trivy (5 min)

```bash
# Opción A: Instalación directa (Linux/macOS)
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin

# Verificar
trivy --version

# Opción B: Usar con Docker (sin instalación) 
alias trivy='docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy:latest'
```

---

### Parte 2: Comparar Imágenes Base (20 min)

```bash
# Escanear diferentes imágenes base y comparar
echo "=== ubuntu:22.04 ==="
trivy image ubuntu:22.04 --severity HIGH,CRITICAL --quiet

echo "=== debian:12-slim ==="
trivy image debian:12-slim --severity HIGH,CRITICAL --quiet

echo "=== python:3.12 (full) ==="
trivy image python:3.12 --severity HIGH,CRITICAL --quiet

echo "=== python:3.12-slim ==="
trivy image python:3.12-slim --severity HIGH,CRITICAL --quiet

echo "=== python:3.12-alpine ==="
trivy image python:3.12-alpine --severity HIGH,CRITICAL --quiet
```

Rellena la tabla con los resultados:

| Imagen               | CRITICAL | HIGH | Total H+C | Tamaño |
| -------------------- | -------- | ---- | --------- | ------ |
| ubuntu:22.04         | ?        | ?    | ?         | ~80MB  |
| debian:12-slim       | ?        | ?    | ?         | ~75MB  |
| python:3.12          | ?        | ?    | ?         | ~900MB |
| python:3.12-slim     | ?        | ?    | ?         | ~130MB |
| python:3.12-alpine   | ?        | ?    | ?         | ~50MB  |

---

### Parte 3: Escanear Imágenes Propias (15 min)

```bash
mkdir scan-lab && cd scan-lab

# Imagen con dependencias vulnerables intencionalmente antiguas
cat > requirements.txt << 'EOF'
flask==2.0.0
requests==2.25.0
pillow==9.0.0
EOF

cat > Dockerfile.fat << 'EOF'
FROM python:3.12
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
CMD ["python", "-m", "flask", "run"]
EOF

cat > Dockerfile.slim << 'EOF'
FROM python:3.12-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
CMD ["python", "-m", "flask", "run"]
EOF

# Construir ambas
docker build -f Dockerfile.fat -t scanlab:fat .
docker build -f Dockerfile.slim -t scanlab:slim .

# Comparar
echo "=== FAT ===" && trivy image scanlab:fat --severity HIGH,CRITICAL
echo "=== SLIM ===" && trivy image scanlab:slim --severity HIGH,CRITICAL

# Ver solo vulnerabilidades en las dependencias de Python
trivy image scanlab:slim --vuln-type library --severity HIGH,CRITICAL
```

---

### Parte 4: Interpretar y Corregir (10 min)

```bash
# Ver un CVE específico con detalle
trivy image scanlab:slim --severity CRITICAL

# Actualizar requirements.txt con versiones corregidas
cat > requirements.txt << 'EOF'
flask==3.0.0
requests==2.31.0
pillow==10.1.0
EOF

# Reconstruir y re-escanear
docker build -f Dockerfile.slim -t scanlab:fixed .
trivy image scanlab:fixed --severity HIGH,CRITICAL
# Debe mostrar menos vulnerabilidades
```

---

### Limpieza

```bash
docker image rm scanlab:fat scanlab:slim scanlab:fixed
cd .. && rm -rf scan-lab
```

---

## ✅ Checklist de Verificación

- [ ] Instalé Trivy y puedo ejecutar `trivy --version`
- [ ] Completé la tabla de comparación de imágenes base
- [ ] `python:3.12-alpine` tiene menos CVEs HIGH/CRITICAL que `python:3.12`
- [ ] Actualicé las dependencias y reduje vulnerabilidades
- [ ] Entiendo la diferencia entre vulns del SO y de librerías

---

## 🔗 Siguiente Ejercicio

[→ Ejercicio 03: Pipeline CI/CD Local](../03-pipeline-cicd/README.md)
