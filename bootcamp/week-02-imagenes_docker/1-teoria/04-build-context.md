# 📚 Build Context y .dockerignore

## 🎯 Objetivos de Aprendizaje

Al finalizar esta sección, serás capaz de:

- Comprender qué es el Build Context y cómo afecta el build
- Configurar .dockerignore para optimizar builds
- Evitar incluir archivos innecesarios o sensibles
- Reducir tiempos de build significativamente

---

## 📦 ¿Qué es el Build Context?

El **Build Context** es el conjunto de archivos y directorios que Docker envía al daemon para construir una imagen.

```bash
# El punto (.) define el build context como directorio actual
docker build -t miapp .
#                     └── Build Context
```

### Flujo del Build

| Paso | Acción         | Descripción                      |
| ---- | -------------- | -------------------------------- |
| 1    | **Empaquetar** | Docker CLI empaqueta el contexto |
| 2    | **Enviar**     | Se envía al Docker daemon        |
| 3    | **Procesar**   | El daemon lee el Dockerfile      |
| 4    | **Construir**  | Se ejecutan las instrucciones    |

```bash
# Al construir, verás el tamaño del contexto
docker build -t miapp .
# Sending build context to Docker daemon  45.2MB  ← Tamaño del contexto
```

> ⚠️ **Importante**: Un contexto grande = build lento. Todo el contenido se envía al daemon, incluso lo que no usas.

---

## 🚨 Problemas Comunes

### Contexto Demasiado Grande

```bash
# Ejemplo de problema
mi-proyecto/
├── node_modules/       # 500 MB - ¡NO necesario!
├── .git/               # 100 MB - ¡NO necesario!
├── dist/               # 50 MB  - Generado en build
├── logs/               # 20 MB  - Datos temporales
├── .env                # Secretos - ¡PELIGROSO!
├── package.json        # ✅ Necesario
├── src/                # ✅ Necesario
└── Dockerfile          # ✅ Necesario
```

```bash
docker build -t miapp .
# Sending build context to Docker daemon  670MB  ← ¡Demasiado!
# El build tarda varios minutos...
```

### Archivos Sensibles Expuestos

```bash
# ⚠️ Sin .dockerignore, estos archivos se incluyen:
.env                    # Credenciales
.aws/credentials        # AWS keys
id_rsa                  # SSH keys
*.pem                   # Certificados
```

---

## 📋 .dockerignore

El archivo `.dockerignore` excluye archivos y directorios del Build Context.

### Sintaxis

```dockerignore
# Comentarios
archivo.txt           # Archivo específico
directorio/           # Directorio completo
*.log                 # Patrón con wildcard
**/*.tmp              # Recursivo
!importante.txt       # Excepción (incluir aunque coincida con patrón anterior)
```

### Patrones Disponibles

| Patrón | Descripción                       | Ejemplo     |
| ------ | --------------------------------- | ----------- |
| `*`    | Cualquier secuencia de caracteres | `*.log`     |
| `?`    | Un solo carácter                  | `file?.txt` |
| `**`   | Cualquier número de directorios   | `**/*.tmp`  |
| `!`    | Excepción (negar patrón previo)   | `!keep.log` |
| `/`    | Relativo a la raíz del contexto   | `/config`   |

---

## 📝 .dockerignore Recomendado

### Para Proyectos Node.js

```dockerignore
# Dependencias (se instalan en el build)
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Build outputs
dist/
build/
coverage/

# Control de versiones
.git/
.gitignore
.gitattributes

# IDE y editores
.vscode/
.idea/
*.swp
*.swo
.DS_Store

# Docker
Dockerfile*
docker-compose*.yml
.dockerignore

# Entorno y secretos
.env
.env.*
*.pem
*.key

# Tests
__tests__/
*.test.js
*.spec.js
jest.config.js

# Documentación
README.md
docs/
*.md

# Logs y temporales
logs/
*.log
tmp/
temp/
```

### Para Proyectos Python

```dockerignore
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
venv/
.venv/
env/
.env/
ENV/

# Testing
.pytest_cache/
.coverage
htmlcov/
.tox/

# Build
build/
dist/
*.egg-info/
*.egg

# IDE
.vscode/
.idea/
*.swp
.DS_Store

# Git
.git/
.gitignore

# Docker
Dockerfile*
docker-compose*.yml
.dockerignore

# Secretos
.env
*.pem
*.key

# Docs
README.md
docs/
```

### Para Proyectos Go

```dockerignore
# Binarios
*.exe
*.exe~
*.dll
*.so
*.dylib

# Build
bin/
vendor/

# Test
*.test
coverage.out

# IDE
.vscode/
.idea/

# Git
.git/
.gitignore

# Docker
Dockerfile*
docker-compose*.yml
.dockerignore

# Docs
README.md
docs/
```

---

## 📊 Impacto del .dockerignore

### Sin .dockerignore

```bash
mi-proyecto/
├── node_modules/     # 500 MB
├── .git/             # 100 MB
├── src/              # 1 MB
└── package.json      # 1 KB

# Contexto total: ~601 MB
# Tiempo de build: ~2 minutos
```

### Con .dockerignore

```bash
mi-proyecto/
├── src/              # 1 MB
└── package.json      # 1 KB

# Contexto total: ~1 MB
# Tiempo de build: ~10 segundos
```

| Métrica              | Sin .dockerignore | Con .dockerignore | Mejora |
| -------------------- | ----------------- | ----------------- | ------ |
| **Tamaño contexto**  | 601 MB            | 1 MB              | 99.8%  |
| **Tiempo build**     | 120s              | 10s               | 91.7%  |
| **Riesgo seguridad** | Alto              | Bajo              | ✅     |

---

## 🔍 Verificar el Build Context

### Ver qué se incluye

```bash
# Listar archivos que se enviarían (sin .dockerignore)
find . -type f | grep -v ".git" | head -50

# Simular lo que incluye Docker
tar -cvf - . 2>/dev/null | tar -tvf - | head -50

# Ver tamaño del contexto que se enviaría
du -sh --exclude=.git .
```

### Probar .dockerignore

```bash
# Crear archivo de prueba
cat > test-context.sh << 'EOF'
#!/bin/bash
echo "=== Archivos en el Build Context ==="
tar -czf - . 2>/dev/null | tar -tzvf - | wc -l
echo "archivos"
echo ""
echo "=== Tamaño total ==="
tar -cf - . 2>/dev/null | wc -c | numfmt --to=iec
EOF

chmod +x test-context.sh
./test-context.sh
```

---

## 🎯 Buenas Prácticas

### 1. Siempre incluir .dockerignore

```bash
# Crear .dockerignore al iniciar cualquier proyecto
touch .dockerignore
```

### 2. Empezar restrictivo, añadir lo necesario

```dockerignore
# Ignorar todo por defecto
*

# Incluir solo lo necesario
!src/
!package.json
!package-lock.json
```

### 3. Verificar que no haya secretos

```bash
# Buscar archivos sensibles
grep -r "password\|secret\|key\|token" --include="*.env*" .
find . -name "*.pem" -o -name "*.key" -o -name "id_rsa*"
```

### 4. Documentar el .dockerignore

```dockerignore
# ============================================
# .dockerignore para proyecto Mi App
# ============================================

# --- Dependencias (se instalan durante build) ---
node_modules/

# --- Archivos de desarrollo ---
.vscode/
*.md

# --- Seguridad (NUNCA incluir) ---
.env
*.pem
```

---

## 📁 Build Context Remoto

Docker también puede usar contextos remotos:

```bash
# Desde repositorio Git
docker build -t miapp https://github.com/usuario/repo.git

# Desde URL de tarball
docker build -t miapp https://example.com/app.tar.gz

# Desde stdin (sin contexto de archivos)
docker build -t miapp - < Dockerfile
```

---

## ✅ Verificación de Aprendizaje

1. ¿Qué es el Build Context y por qué es importante su tamaño?
2. ¿Qué archivos deberían SIEMPRE estar en .dockerignore?
3. ¿Cómo afecta un contexto grande al tiempo de build?
4. ¿Qué significa el patrón `**/*.log` en .dockerignore?
5. ¿Cómo puedes verificar qué archivos se incluyen en el contexto?

---

## 🔗 Navegación

| ← Anterior                                            | Siguiente →                             |
| ----------------------------------------------------- | --------------------------------------- |
| [03 - Dockerfile Avanzado](03-dockerfile-avanzado.md) | [05 - Optimización](05-optimizacion.md) |
