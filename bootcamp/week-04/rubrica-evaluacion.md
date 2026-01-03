# 📋 Rúbrica de Evaluación - Semana 04: Redes en Docker

## 📊 Distribución de Puntos

| Componente                | Peso     | Puntos      |
| ------------------------- | -------- | ----------- |
| 🧠 Conocimiento (Quiz)    | 30%      | 30 pts      |
| 💪 Desempeño (Ejercicios) | 40%      | 40 pts      |
| 📦 Producto (Proyecto)    | 30%      | 30 pts      |
| **Total**                 | **100%** | **100 pts** |

---

## 🧠 Conocimiento Teórico (30 puntos)

### Quiz - Criterios de Evaluación

| Tema                    | Puntos     | Aprobación        |
| ----------------------- | ---------- | ----------------- |
| Tipos de redes Docker   | 8 pts      | ≥6 pts            |
| Bridge network y DNS    | 8 pts      | ≥6 pts            |
| Port mapping            | 7 pts      | ≥5 pts            |
| Aislamiento y seguridad | 7 pts      | ≥5 pts            |
| **Total**               | **30 pts** | **≥21 pts (70%)** |

### Preguntas Ejemplo

1. **Tipos de Redes** (2 pts)

   - ¿Cuál es la diferencia entre la red bridge por defecto y una red bridge personalizada?

2. **DNS Interno** (2 pts)

   - ¿Por qué el DNS interno solo funciona en redes personalizadas?

3. **Port Mapping** (2 pts)

   - ¿Qué significa `-p 127.0.0.1:8080:80`?

4. **Aislamiento** (2 pts)
   - ¿Cómo se puede crear una red que no tenga acceso a Internet?

---

## 💪 Desempeño - Ejercicios (40 puntos)

### Ejercicio 01: Redes Básicas (12 pts)

| Criterio               | Puntos | Descripción                         |
| ---------------------- | ------ | ----------------------------------- |
| Crear red bridge       | 3 pts  | Red creada con subnet personalizado |
| Listar e inspeccionar  | 2 pts  | Comandos ejecutados correctamente   |
| Conectar contenedores  | 3 pts  | Contenedores conectados a la red    |
| Verificar comunicación | 2 pts  | Ping exitoso entre contenedores     |
| Limpieza               | 2 pts  | Recursos eliminados correctamente   |

### Ejercicio 02: Comunicación (14 pts)

| Criterio              | Puntos | Descripción                        |
| --------------------- | ------ | ---------------------------------- |
| DNS interno           | 4 pts  | Resolución de nombres funciona     |
| Aliases de red        | 3 pts  | Aliases configurados y funcionando |
| Port mapping básico   | 3 pts  | Servicio accesible desde host      |
| Port mapping avanzado | 2 pts  | Binding a localhost                |
| Documentación         | 2 pts  | Pasos documentados                 |

### Ejercicio 03: Aislamiento (14 pts)

| Criterio              | Puntos | Descripción                       |
| --------------------- | ------ | --------------------------------- |
| Redes separadas       | 4 pts  | Múltiples redes creadas           |
| Contenedor multi-red  | 4 pts  | Contenedor conectado a 2+ redes   |
| Verificar aislamiento | 4 pts  | Comunicación bloqueada verificada |
| Red interna           | 2 pts  | Red --internal creada             |

---

## 📦 Producto - Proyecto (30 puntos)

### Proyecto: Microservicios con Redes

#### Estructura y Configuración (10 pts)

| Criterio          | Puntos | Descripción                |
| ----------------- | ------ | -------------------------- |
| 3 redes creadas   | 3 pts  | dmz-net, app-net, data-net |
| Subnets correctos | 2 pts  | Subnets personalizados     |
| Red interna       | 2 pts  | data-net con --internal    |
| Documentación     | 3 pts  | README con arquitectura    |

#### Despliegue de Contenedores (10 pts)

| Criterio             | Puntos | Descripción                        |
| -------------------- | ------ | ---------------------------------- |
| 6 contenedores       | 3 pts  | Todos los contenedores desplegados |
| Conexiones de red    | 4 pts  | Contenedores en redes correctas    |
| Aliases configurados | 3 pts  | DNS aliases funcionando            |

#### Matriz de Comunicación (10 pts)

| Criterio                 | Puntos | Descripción               |
| ------------------------ | ------ | ------------------------- |
| nginx -> api-gateway     | 2 pts  | Comunicación permitida    |
| nginx -/-> postgres      | 2 pts  | Comunicación bloqueada    |
| api-gateway -> servicios | 2 pts  | Comunicación app-net      |
| servicios -> datos       | 2 pts  | Comunicación data-net     |
| Test automatizado        | 2 pts  | Script de prueba funciona |

---

## 📈 Niveles de Desempeño

### Excelente (90-100 pts)

- Todos los ejercicios completados correctamente
- Proyecto funciona sin errores
- Documentación clara y completa
- Comprensión profunda de los conceptos

### Bueno (75-89 pts)

- Mayoría de ejercicios completados
- Proyecto funciona con ajustes menores
- Documentación adecuada
- Buena comprensión de conceptos

### Satisfactorio (60-74 pts)

- Ejercicios básicos completados
- Proyecto funciona parcialmente
- Documentación básica
- Comprensión fundamental

### Necesita Mejora (<60 pts)

- Ejercicios incompletos
- Proyecto no funciona
- Falta documentación
- Conceptos no claros

---

## ✅ Lista de Verificación del Estudiante

### Antes de Entregar

#### Conocimiento

- [ ] Estudié los 5 tipos de redes Docker
- [ ] Entiendo la diferencia entre bridge default y personalizado
- [ ] Sé cómo funciona el DNS interno
- [ ] Comprendo las opciones de port mapping

#### Ejercicios

- [ ] Completé el ejercicio de redes básicas
- [ ] Completé el ejercicio de comunicación
- [ ] Completé el ejercicio de aislamiento
- [ ] Verifiqué que todos los comandos funcionan

#### Proyecto

- [ ] Creé las 3 redes requeridas
- [ ] Desplegué los 6 contenedores
- [ ] La matriz de comunicación es correcta
- [ ] El script de prueba pasa todas las verificaciones
- [ ] Documenté la arquitectura

---

## 🎯 Criterios de Aprobación

| Requisito        | Mínimo           |
| ---------------- | ---------------- |
| Puntuación total | ≥60/100 pts      |
| Quiz teórico     | ≥21/30 pts (70%) |
| Ejercicios       | ≥24/40 pts (60%) |
| Proyecto         | ≥15/30 pts (50%) |

---

## 📝 Rúbrica Detallada por Competencia

### Competencia: Diseño de Redes

| Nivel      | Descripción                                 | Puntos |
| ---------- | ------------------------------------------- | ------ |
| Avanzado   | Diseña arquitecturas multi-red complejas    | 10     |
| Intermedio | Crea redes personalizadas con configuración | 7      |
| Básico     | Usa redes predeterminadas                   | 4      |
| Inicial    | No comprende los conceptos de red           | 0      |

### Competencia: Comunicación entre Contenedores

| Nivel      | Descripción             | Puntos |
| ---------- | ----------------------- | ------ |
| Avanzado   | DNS, aliases, multi-red | 10     |
| Intermedio | DNS interno básico      | 7      |
| Básico     | Solo por IP             | 4      |
| Inicial    | No logra comunicación   | 0      |

### Competencia: Seguridad de Red

| Nivel      | Descripción                          | Puntos |
| ---------- | ------------------------------------ | ------ |
| Avanzado   | Aislamiento completo, redes internas | 10     |
| Intermedio | Segmentación básica                  | 7      |
| Básico     | Todos en la misma red                | 4      |
| Inicial    | No considera seguridad               | 0      |

---

## 📌 Notas para el Evaluador

1. **Verificar conectividad**: Ejecutar scripts de prueba
2. **Inspeccionar redes**: `docker network inspect`
3. **Validar aislamiento**: Probar ping entre contenedores no conectados
4. **Revisar documentación**: Claridad y completitud

---

## 🔗 Referencias

- [Objetivos de la Semana](README.md)
- [Proyecto](3-proyecto/README.md)
- [Docker Networking Docs](https://docs.docker.com/network/)
