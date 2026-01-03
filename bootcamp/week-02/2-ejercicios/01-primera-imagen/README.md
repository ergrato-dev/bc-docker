# 💻 Ejercicio 01: Mi Primera Imagen

## 🎯 Objetivo

Crear tu primera imagen Docker desde cero utilizando las instrucciones básicas de Dockerfile.

---

## 📋 Descripción

Construirás una imagen que ejecute un simple servidor web estático usando Python.

---

## ⏱️ Tiempo Estimado

20 minutos

---

## 📚 Conceptos Aplicados

- `FROM` - Imagen base
- `RUN` - Ejecutar comandos
- `WORKDIR` - Directorio de trabajo
- `COPY` - Copiar archivos
- `EXPOSE` - Documentar puertos
- `CMD` - Comando de inicio

---

## 📝 Instrucciones

### Paso 1: Preparar el Entorno

```bash
# Navegar al directorio del ejercicio
cd bootcamp/week-02/2-ejercicios/01-primera-imagen

# Verificar que Docker está funcionando
docker --version
```

### Paso 2: Crear el Contenido Web

Crea un archivo `index.html`:

```html
<!DOCTYPE html>
<html lang="es">
  <head>
    <meta charset="UTF-8" />
    <meta
      name="viewport"
      content="width=device-width, initial-scale=1.0" />
    <title>Mi Primera Imagen Docker</title>
    <style>
      body {
        font-family: 'Segoe UI', sans-serif;
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        min-height: 100vh;
        display: flex;
        justify-content: center;
        align-items: center;
        margin: 0;
        color: white;
      }
      .container {
        text-align: center;
        padding: 2rem;
        background: rgba(255, 255, 255, 0.1);
        border-radius: 20px;
        backdrop-filter: blur(10px);
      }
      h1 {
        font-size: 3rem;
        margin-bottom: 1rem;
      }
      p {
        font-size: 1.2rem;
        opacity: 0.9;
      }
      .emoji {
        font-size: 4rem;
      }
    </style>
  </head>
  <body>
    <div class="container">
      <div class="emoji">🐳</div>
      <h1>¡Mi Primera Imagen!</h1>
      <p>Construida con Docker</p>
      <p>Ejercicio 01 - Semana 02</p>
    </div>
  </body>
</html>
```

### Paso 3: Crear el Dockerfile

Crea un archivo llamado `Dockerfile` con los siguientes requisitos:

| Requisito             | Instrucción | Valor                   |
| --------------------- | ----------- | ----------------------- |
| Imagen base           | `FROM`      | `python:3.12-alpine`    |
| Directorio de trabajo | `WORKDIR`   | `/app`                  |
| Copiar archivo HTML   | `COPY`      | `index.html` a `/app/`  |
| Puerto                | `EXPOSE`    | `8000`                  |
| Comando de inicio     | `CMD`       | Servidor HTTP de Python |

> 💡 **Hint**: El servidor HTTP de Python se inicia con:
>
> ```bash
> python -m http.server 8000
> ```

### Paso 4: Construir la Imagen

```bash
# Construir la imagen
docker build -t mi-primera-imagen:v1 .

# Verificar que se creó
docker images | grep mi-primera-imagen
```

### Paso 5: Ejecutar el Contenedor

```bash
# Ejecutar en segundo plano
docker run -d --name mi-web -p 8080:8000 mi-primera-imagen:v1

# Verificar que está corriendo
docker ps
```

### Paso 6: Probar

```bash
# Probar con curl
curl http://localhost:8080

# O abre en el navegador: http://localhost:8080
```

### Paso 7: Limpiar

```bash
# Detener y eliminar contenedor
docker stop mi-web && docker rm mi-web

# (Opcional) Eliminar imagen
docker rmi mi-primera-imagen:v1
```

---

## ✅ Checklist de Verificación

- [ ] El Dockerfile usa `python:3.12-alpine` como base
- [ ] El archivo `index.html` está en `/app/`
- [ ] El puerto 8000 está expuesto
- [ ] El contenedor inicia el servidor HTTP automáticamente
- [ ] La página web es accesible en `http://localhost:8080`

---

## 🔍 Comandos de Verificación

```bash
# Ver capas de la imagen
docker history mi-primera-imagen:v1

# Inspeccionar la imagen
docker inspect mi-primera-imagen:v1

# Ver logs del contenedor
docker logs mi-web
```

---

## 💡 Hints

<details>
<summary>Hint 1: Estructura del Dockerfile</summary>

```dockerfile
FROM <imagen_base>
WORKDIR <directorio>
COPY <origen> <destino>
EXPOSE <puerto>
CMD [<comando>, <argumentos>...]
```

</details>

<details>
<summary>Hint 2: Comando CMD</summary>

```dockerfile
CMD ["python", "-m", "http.server", "8000"]
```

</details>

---

## 📂 Estructura de Archivos

```
01-primera-imagen/
├── README.md       # Este archivo
├── Dockerfile      # Lo crearás tú
└── index.html      # Lo crearás tú
```

---

## 🔗 Navegación

| ← Índice                            | Siguiente →                                                |
| ----------------------------------- | ---------------------------------------------------------- |
| [Volver a Ejercicios](../README.md) | [02 - Variables y Argumentos](../02-variables-argumentos/) |
