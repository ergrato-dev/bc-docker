# 💻 Ejercicio 04: Multi-stage Build

## 🎯 Objetivo

Implementar un Multi-stage build para crear imágenes optimizadas separando el entorno de compilación del de producción.

---

## 📋 Descripción

Construirás una aplicación TypeScript que se compila en una etapa y se ejecuta en otra, reduciendo drásticamente el tamaño final.

---

## ⏱️ Tiempo Estimado

30 minutos

---

## 📚 Conceptos Aplicados

- Multi-stage builds
- `FROM ... AS <nombre>`
- `COPY --from=<stage>`
- Separación build vs runtime
- Reducción de tamaño de imagen

---

## 📝 Instrucciones

### Paso 1: Preparar el Entorno

```bash
cd bootcamp/week-02/2-ejercicios/04-multi-stage
```

### Paso 2: Crear el Proyecto TypeScript

Crea `package.json`:

```json
{
  "name": "multistage-exercise",
  "version": "1.0.0",
  "description": "Ejercicio Multi-stage Build",
  "main": "dist/index.js",
  "scripts": {
    "build": "tsc",
    "start": "node dist/index.js"
  },
  "devDependencies": {
    "typescript": "^5.3.0",
    "@types/node": "^20.0.0"
  }
}
```

Crea `tsconfig.json`:

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "commonjs",
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules"]
}
```

Crea `src/index.ts`:

```typescript
interface ServerInfo {
  name: string;
  version: string;
  environment: string;
  timestamp: string;
  message: string;
}

const getServerInfo = (): ServerInfo => {
  return {
    name: 'Multi-stage App',
    version: '1.0.0',
    environment: process.env.NODE_ENV || 'development',
    timestamp: new Date().toISOString(),
    message: '¡Compilado con TypeScript, optimizado con Multi-stage!',
  };
};

const main = (): void => {
  console.log('🚀 Aplicación Multi-stage iniciada');
  console.log('━'.repeat(50));

  const info = getServerInfo();
  console.log(JSON.stringify(info, null, 2));

  console.log('━'.repeat(50));
  console.log('✅ TypeScript compilado exitosamente');
  console.log('📦 Imagen optimizada con Multi-stage build');
};

main();
```

### Paso 3: Crear Dockerfile SIN Multi-stage (para comparar)

Crea `Dockerfile.single`:

```dockerfile
# ❌ Sin Multi-stage - Imagen grande
FROM node:20

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY tsconfig.json ./
COPY src/ ./src/

RUN npm run build

ENV NODE_ENV=production

CMD ["npm", "start"]
```

```bash
# Construir versión sin optimizar
docker build -f Dockerfile.single -t multistage:single .

# Ver tamaño
docker images multistage:single
# Aproximadamente: ~1.1 GB
```

### Paso 4: Crear Dockerfile CON Multi-stage

Crea `Dockerfile`:

```dockerfile
# ============================================
# ETAPA 1: Build (Compilación)
# ============================================
FROM node:20-alpine AS builder

WORKDIR /app

# Instalar dependencias (incluye devDependencies para TypeScript)
COPY package*.json ./
RUN npm install

# Copiar código fuente y configuración
COPY tsconfig.json ./
COPY src/ ./src/

# Compilar TypeScript a JavaScript
RUN npm run build

# ============================================
# ETAPA 2: Production (Ejecución)
# ============================================
FROM node:20-alpine AS production

# Metadatos
LABEL maintainer="bootcamp@docker.com" \
      description="App TypeScript con Multi-stage build"

WORKDIR /app

# Solo copiar el código compilado (no fuentes .ts)
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/package*.json ./

# Instalar SOLO dependencias de producción
RUN npm install --production && npm cache clean --force

# Variables de entorno
ENV NODE_ENV=production

# Usuario no-root
USER node

# Comando de inicio
CMD ["node", "dist/index.js"]
```

### Paso 5: Construir y Comparar

```bash
# Construir versión multi-stage
docker build -t multistage:optimized .

# Comparar tamaños
docker images | grep multistage

# Resultado esperado:
# multistage   single      ... ~1.1 GB
# multistage   optimized   ... ~180 MB
```

### Paso 6: Ejecutar y Verificar

```bash
# Ejecutar versión optimizada
docker run --rm multistage:optimized

# Verificar que NO tiene código fuente TypeScript
docker run --rm multistage:optimized ls -la
docker run --rm multistage:optimized sh -c "ls src 2>/dev/null || echo 'src/ NO existe (correcto!)'"
docker run --rm multistage:optimized sh -c "ls dist/"
```

### Paso 7: Analizar las Capas

```bash
# Ver historial de la imagen optimizada
docker history multistage:optimized

# Ver historial de la imagen sin optimizar
docker history multistage:single
```

---

## ✅ Checklist de Verificación

- [ ] El Dockerfile tiene dos etapas: `builder` y `production`
- [ ] La etapa `builder` compila TypeScript
- [ ] La etapa `production` solo tiene código JavaScript compilado
- [ ] NO hay archivos `.ts` en la imagen final
- [ ] NO hay `devDependencies` en la imagen final
- [ ] El tamaño de la imagen es ~85% menor que sin multi-stage
- [ ] La aplicación se ejecuta correctamente

---

## 💡 Hints

<details>
<summary>Hint 1: Nombrar etapas</summary>

```dockerfile
FROM node:20-alpine AS builder
# ... comandos de build

FROM node:20-alpine AS production
COPY --from=builder /app/dist ./dist
```

</details>

<details>
<summary>Hint 2: Copiar desde otra etapa</summary>

```dockerfile
# Copiar solo lo necesario de la etapa anterior
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/package.json ./
```

</details>

<details>
<summary>Hint 3: Solo producción dependencies</summary>

```dockerfile
# En la etapa de producción
RUN npm install --production
# o
RUN npm ci --only=production
```

</details>

---

## 🔍 Experimentos Adicionales

```bash
# Construir solo una etapa específica
docker build --target builder -t multistage:builder-only .

# Ver qué hay en la etapa builder
docker run --rm multistage:builder-only ls -la

# Comparar con producción
docker images | grep multistage
```

---

## 📊 Comparativa de Tamaños

| Imagen                 | Contenido        | Tamaño Aprox |
| ---------------------- | ---------------- | ------------ |
| `node:20`              | Node.js completo | ~1 GB        |
| `multistage:single`    | Todo incluido    | ~1.1 GB      |
| `multistage:optimized` | Solo producción  | ~180 MB      |

**Reducción**: ~85% menos espacio

---

## 📂 Estructura de Archivos

```
04-multi-stage/
├── README.md           # Este archivo
├── Dockerfile          # Multi-stage (lo crearás tú)
├── Dockerfile.single   # Sin multi-stage (comparación)
├── package.json        # Lo crearás tú
├── tsconfig.json       # Lo crearás tú
└── src/
    └── index.ts        # Lo crearás tú
```

---

## 🔗 Navegación

| ← Anterior                                         | Siguiente →                                             |
| -------------------------------------------------- | ------------------------------------------------------- |
| [03 - Copiando Archivos](../03-copiando-archivos/) | [05 - Optimización de Capas](../05-optimizacion-capas/) |
