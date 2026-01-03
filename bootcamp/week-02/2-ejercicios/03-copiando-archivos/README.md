# 💻 Ejercicio 03: Copiando Archivos

## 🎯 Objetivo

Dominar el uso de `COPY`, `WORKDIR` y configurar correctamente `.dockerignore` para optimizar el build context.

---

## 📋 Descripción

Construirás una aplicación Node.js simple, aprendiendo a copiar archivos eficientemente y excluir archivos innecesarios.

---

## ⏱️ Tiempo Estimado

25 minutos

---

## 📚 Conceptos Aplicados

- `COPY` - Copiar archivos y directorios
- `WORKDIR` - Establecer directorio de trabajo
- `.dockerignore` - Excluir archivos del build context
- Orden de instrucciones para optimizar caché

---

## 📝 Instrucciones

### Paso 1: Preparar el Entorno

```bash
cd bootcamp/week-02/2-ejercicios/03-copiando-archivos
```

### Paso 2: Crear la Estructura del Proyecto

```bash
# Crear archivos de la aplicación
mkdir -p src
```

Crea `package.json`:

```json
{
  "name": "docker-copy-exercise",
  "version": "1.0.0",
  "description": "Ejercicio de COPY y .dockerignore",
  "main": "src/index.js",
  "scripts": {
    "start": "node src/index.js"
  }
}
```

Crea `src/index.js`:

```javascript
const http = require('http');

const PORT = process.env.PORT || 3000;

const server = http.createServer((req, res) => {
  res.writeHead(200, { 'Content-Type': 'application/json' });
  res.end(
    JSON.stringify(
      {
        message: '¡Hola desde Docker!',
        exercise: '03-copiando-archivos',
        timestamp: new Date().toISOString(),
        nodeVersion: process.version,
      },
      null,
      2
    )
  );
});

server.listen(PORT, () => {
  console.log(`🚀 Servidor corriendo en puerto ${PORT}`);
});
```

### Paso 3: Crear Archivos que NO Deben Incluirse

```bash
# Simular archivos que no queremos en la imagen
mkdir -p node_modules/.bin
echo "fake dependency" > node_modules/fake-dep.js
echo "NODE_ENV=development" > .env
echo "secreto123" > .env.local
mkdir -p logs
echo "error log" > logs/error.log
mkdir -p .git
echo "git data" > .git/config
echo "# Notas del desarrollo" > NOTES.md
```

### Paso 4: Verificar el Tamaño del Contexto (Sin .dockerignore)

Crea un `Dockerfile` básico:

```dockerfile
FROM node:20-alpine
WORKDIR /app
COPY . .
EXPOSE 3000
CMD ["npm", "start"]
```

```bash
# Construir y observar el tamaño del contexto
docker build -t copy-test:sin-ignore .
# Observa: "Sending build context to Docker daemon  XXX"
```

### Paso 5: Crear .dockerignore

Crea un archivo `.dockerignore`:

```dockerignore
# Dependencias (se instalan en el build)
node_modules/
npm-debug.log*

# Archivos de entorno y secretos
.env
.env.*
*.pem
*.key

# Control de versiones
.git/
.gitignore

# IDE y editores
.vscode/
.idea/
*.swp
.DS_Store

# Logs y temporales
logs/
*.log
tmp/
temp/

# Docker
Dockerfile*
docker-compose*.yml
.dockerignore

# Documentación y notas
*.md
docs/

# Tests
__tests__/
*.test.js
coverage/
```

### Paso 6: Optimizar el Dockerfile

Actualiza el `Dockerfile` con orden optimizado:

```dockerfile
# Imagen base
FROM node:20-alpine

# Directorio de trabajo
WORKDIR /app

# Copiar SOLO archivos de dependencias primero
# (Esto maximiza el uso de caché)
COPY package*.json ./

# Instalar dependencias
RUN npm install --production

# Copiar el resto del código fuente
COPY src/ ./src/

# Puerto de la aplicación
EXPOSE 3000

# Comando de inicio
CMD ["npm", "start"]
```

### Paso 7: Reconstruir y Comparar

```bash
# Construir con .dockerignore
docker build -t copy-test:con-ignore .
# Observa: El contexto ahora es MUCHO más pequeño

# Comparar tamaños
docker images | grep copy-test
```

### Paso 8: Verificar Contenido del Contenedor

```bash
# Ejecutar contenedor
docker run -d --name copy-test -p 3000:3000 copy-test:con-ignore

# Probar la API
curl http://localhost:3000

# Verificar que NO están los archivos excluidos
docker exec copy-test ls -la
docker exec copy-test sh -c "ls node_modules 2>/dev/null || echo 'node_modules existe con deps instaladas'"
docker exec copy-test sh -c "cat .env 2>/dev/null || echo '.env NO existe (correcto!)'"

# Limpiar
docker stop copy-test && docker rm copy-test
```

---

## ✅ Checklist de Verificación

- [ ] El `.dockerignore` excluye `node_modules/`
- [ ] El `.dockerignore` excluye archivos `.env`
- [ ] El `.dockerignore` excluye `.git/`
- [ ] El contexto de build es significativamente menor
- [ ] La aplicación funciona correctamente
- [ ] El orden del Dockerfile optimiza el caché

---

## 💡 Hints

<details>
<summary>Hint 1: Verificar qué se excluye</summary>

```bash
# Ver archivos que SÍ se incluyen en el contexto
# (los que NO están en .dockerignore)
find . -type f | grep -v node_modules | grep -v .git
```

</details>

<details>
<summary>Hint 2: Orden óptimo de COPY</summary>

1. Primero: `COPY package*.json ./`
2. Luego: `RUN npm install`
3. Después: `COPY src/ ./src/`

Esto evita reinstalar dependencias cuando solo cambió el código.

</details>

---

## 🔍 Experimentos Adicionales

```bash
# Modificar solo src/index.js y reconstruir
# Observa que las capas de npm install se reutilizan del caché

# Ver historial de capas
docker history copy-test:con-ignore

# Comparar tamaño de contexto
du -sh --exclude=node_modules --exclude=.git .
```

---

## 📂 Estructura de Archivos

```
03-copiando-archivos/
├── README.md           # Este archivo
├── Dockerfile          # Lo crearás tú
├── .dockerignore       # Lo crearás tú
├── package.json        # Lo crearás tú
└── src/
    └── index.js        # Lo crearás tú
```

---

## 🔗 Navegación

| ← Anterior                                                 | Siguiente →                            |
| ---------------------------------------------------------- | -------------------------------------- |
| [02 - Variables y Argumentos](../02-variables-argumentos/) | [04 - Multi-stage](../04-multi-stage/) |
