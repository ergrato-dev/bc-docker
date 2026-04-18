# 📖 Glosario Semana 02: Imágenes Docker

## Términos Clave

| Término               | Definición                                                                                                                                                                     |
| --------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **ADD**               | Instrucción de Dockerfile similar a COPY pero con capacidad de descargar URLs y extraer archivos comprimidos automáticamente. Se recomienda usar COPY excepto para extracción. |
| **Alpine**            | Distribución Linux ultraligera (~5 MB) popular como imagen base Docker. Usa `musl` en lugar de `glibc` y `apk` como gestor de paquetes.                                        |
| **ARG**               | Instrucción de Dockerfile que define variables disponibles solo durante el build. Se pasan con `--build-arg` en `docker build`.                                                |
| **Build Context**     | Conjunto de archivos y directorios enviados al daemon Docker para construir una imagen. Se define con el path en `docker build`.                                               |
| **Cache (Build)**     | Sistema que reutiliza capas previamente construidas si las instrucciones y archivos no han cambiado, acelerando builds posteriores.                                            |
| **CMD**               | Instrucción de Dockerfile que define el comando por defecto al iniciar un contenedor. Puede ser sobrescrito en `docker run`.                                                   |
| **COPY**              | Instrucción de Dockerfile para copiar archivos del build context a la imagen. Preferida sobre ADD para archivos locales.                                                       |
| **Dangling Image**    | Imagen sin tag (aparece como `<none>:<none>`), generalmente resultado de rebuilds. Se limpian con `docker image prune`.                                                        |
| **Digest**            | Identificador único e inmutable de una imagen basado en hash SHA256 de su contenido. Garantiza reproducibilidad exacta.                                                        |
| **Distroless**        | Imágenes de Google que contienen solo la aplicación y sus dependencias, sin shell ni herramientas del sistema. Máxima seguridad.                                               |
| **.dockerignore**     | Archivo que especifica qué archivos excluir del build context, similar a .gitignore. Reduce tamaño y tiempo de build.                                                          |
| **Dockerfile**        | Archivo de texto con instrucciones para construir una imagen Docker. Por convención se nombra `Dockerfile` sin extensión.                                                      |
| **ENTRYPOINT**        | Instrucción de Dockerfile que define el ejecutable principal del contenedor. Más difícil de sobrescribir que CMD.                                                              |
| **ENV**               | Instrucción de Dockerfile para definir variables de entorno disponibles en build y runtime.                                                                                    |
| **EXPOSE**            | Instrucción de Dockerfile que documenta qué puertos usa la aplicación. No abre puertos realmente (es informativo).                                                             |
| **FROM**              | Primera instrucción obligatoria de un Dockerfile. Define la imagen base sobre la cual se construye.                                                                            |
| **HEALTHCHECK**       | Instrucción de Dockerfile que define cómo verificar si el contenedor está funcionando correctamente.                                                                           |
| **Image ID**          | Identificador único de una imagen basado en el hash SHA256 de su configuración y capas.                                                                                        |
| **Image Layer**       | Capa individual de una imagen Docker. Cada instrucción de Dockerfile que modifica el filesystem crea una capa.                                                                 |
| **LABEL**             | Instrucción de Dockerfile para añadir metadatos a la imagen en formato clave-valor.                                                                                            |
| **Layer Caching**     | Mecanismo que reutiliza capas sin cambios para acelerar builds. El orden de instrucciones afecta su efectividad.                                                               |
| **Multi-stage Build** | Técnica de Dockerfile que usa múltiples `FROM` para separar etapas de build y producción, reduciendo tamaño final.                                                             |
| **OCI**               | Open Container Initiative. Estándar de la industria para formatos de imágenes y runtimes de contenedores.                                                                      |
| **Registry**          | Servicio para almacenar y distribuir imágenes Docker. Ejemplos: Docker Hub, GitHub Container Registry, Amazon ECR.                                                             |
| **RUN**               | Instrucción de Dockerfile que ejecuta comandos durante la construcción de la imagen. Cada RUN crea una nueva capa.                                                             |
| **Scratch**           | Imagen base vacía de Docker. Usada para aplicaciones compiladas estáticamente que no necesitan sistema operativo.                                                              |
| **Slim**              | Variante de imagen base reducida (ej: `python:3.12-slim`). Incluye lo mínimo necesario, sin herramientas extra.                                                                |
| **Tag**               | Etiqueta que identifica una versión específica de una imagen (ej: `nginx:1.25-alpine`). `latest` es el tag por defecto.                                                        |
| **USER**              | Instrucción de Dockerfile que establece el usuario para ejecutar instrucciones posteriores y el contenedor.                                                                    |
| **WORKDIR**           | Instrucción de Dockerfile que establece el directorio de trabajo para instrucciones posteriores. Lo crea si no existe.                                                         |

---

## 📊 Comparativa de Imágenes Base

| Tipo           | Ejemplo                    | Tamaño  | Uso                               |
| -------------- | -------------------------- | ------- | --------------------------------- |
| **Full**       | `node:20`                  | ~1 GB   | Desarrollo, máxima compatibilidad |
| **Slim**       | `node:20-slim`             | ~200 MB | Producción general                |
| **Alpine**     | `node:20-alpine`           | ~140 MB | Producción optimizada             |
| **Distroless** | `gcr.io/distroless/nodejs` | ~100 MB | Máxima seguridad                  |
| **Scratch**    | `scratch`                  | 0 B     | Binarios estáticos                |

---

## 🔗 Navegación

| Recursos                      | Índice                       |
| ----------------------------- | ---------------------------- |
| [📚 Recursos](../4-recursos/) | [🏠 Semana 02](../README.md) |
