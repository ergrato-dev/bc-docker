# 💻 Ejercicios Semana 02: Imágenes Docker

## 📋 Índice de Ejercicios

| #   | Ejercicio                                          | Dificultad    | Tiempo | Conceptos                    |
| --- | -------------------------------------------------- | ------------- | ------ | ---------------------------- |
| 1   | [Mi Primera Imagen](01-primera-imagen/)            | 🟢 Básico     | 20 min | FROM, RUN, CMD               |
| 2   | [Variables y Argumentos](02-variables-argumentos/) | 🟢 Básico     | 25 min | ENV, ARG, LABEL              |
| 3   | [Copiando Archivos](03-copiando-archivos/)         | 🟡 Intermedio | 25 min | COPY, WORKDIR, .dockerignore |
| 4   | [Multi-stage Build](04-multi-stage/)               | 🟡 Intermedio | 30 min | Multi-stage, optimización    |
| 5   | [Optimización de Capas](05-optimizacion-capas/)    | 🟠 Avanzado   | 30 min | Caché, orden, tamaño         |

---

## 🎯 Objetivos Generales

Al completar estos ejercicios serás capaz de:

- ✅ Escribir Dockerfiles desde cero
- ✅ Construir y gestionar imágenes
- ✅ Aplicar buenas prácticas de optimización
- ✅ Usar multi-stage builds
- ✅ Configurar variables y argumentos

---

## 📝 Instrucciones Generales

1. **Lee todo el ejercicio** antes de comenzar
2. **Intenta resolver** sin ver la solución
3. **Usa los hints** si te atascas
4. **Compara con la solución** al finalizar
5. **Verifica** con el checklist de cada ejercicio

---

## 🔧 Preparación

```bash
# Asegúrate de tener Docker funcionando
docker --version

# Limpia recursos anteriores (opcional)
docker system prune -f

# Navega al directorio de ejercicios
cd bootcamp/week-02-imagenes_docker/2-ejercicios/
```

---

## 🔗 Navegación

| Teoría                              | Proyecto                              |
| ----------------------------------- | ------------------------------------- |
| [📖 Material Teórico](../1-teoria/) | [🚀 Proyecto Semanal](../3-proyecto/) |
