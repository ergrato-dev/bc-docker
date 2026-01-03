#!/bin/bash
# =============================================================================
# deploy.sh - Desplegar contenedores de microservicios
# =============================================================================

set -e

echo "🚀 Desplegando microservicios..."

# -----------------------------------------------------------------------------
# NGINX - Frontend y Proxy
# Redes: dmz-net, app-net
# Puerto: 8080:80
# -----------------------------------------------------------------------------
echo "📦 Desplegando nginx..."

# TODO: Crear contenedor nginx
# - Nombre: nginx
# - Red inicial: dmz-net
# - Puerto: 8080:80
# - Imagen: nginx:alpine
# - Volumen: ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro (opcional)

# docker run -d \
#   --name nginx \
#   ... completar ...

# TODO: Conectar nginx a app-net
# docker network connect ...

# -----------------------------------------------------------------------------
# API Gateway
# Redes: app-net, data-net
# -----------------------------------------------------------------------------
echo "📦 Desplegando api-gateway..."

# TODO: Crear contenedor api-gateway
# - Nombre: api-gateway
# - Red inicial: app-net
# - Alias en app-net: gateway, api
# - Imagen: alpine
# - Comando: sleep 3600

# docker run -d \
#   --name api-gateway \
#   ... completar ...

# TODO: Conectar api-gateway a data-net
# docker network connect ...

# -----------------------------------------------------------------------------
# Users Service
# Redes: app-net, data-net
# -----------------------------------------------------------------------------
echo "📦 Desplegando users-service..."

# TODO: Crear contenedor users-service
# - Nombre: users-service
# - Red inicial: app-net
# - Alias: users, users-svc
# - Imagen: alpine
# - Comando: sleep 3600

# docker run -d \
#   --name users-service \
#   ... completar ...

# TODO: Conectar users-service a data-net
# docker network connect ...

# -----------------------------------------------------------------------------
# Products Service
# Redes: app-net, data-net
# -----------------------------------------------------------------------------
echo "📦 Desplegando products-service..."

# TODO: Crear contenedor products-service
# - Nombre: products-service
# - Red inicial: app-net
# - Alias: products, products-svc
# - Imagen: alpine
# - Comando: sleep 3600

# docker run -d \
#   --name products-service \
#   ... completar ...

# TODO: Conectar products-service a data-net
# docker network connect ...

# -----------------------------------------------------------------------------
# PostgreSQL
# Redes: data-net (SOLO)
# -----------------------------------------------------------------------------
echo "📦 Desplegando postgres..."

# TODO: Crear contenedor postgres
# - Nombre: postgres
# - Red: data-net (SOLO esta red)
# - Alias: db, database
# - Imagen: postgres:15-alpine
# - Variables: POSTGRES_PASSWORD=secret123

# docker run -d \
#   --name postgres \
#   ... completar ...

# -----------------------------------------------------------------------------
# Redis
# Redes: data-net (SOLO)
# -----------------------------------------------------------------------------
echo "📦 Desplegando redis..."

# TODO: Crear contenedor redis
# - Nombre: redis
# - Red: data-net (SOLO esta red)
# - Alias: cache
# - Imagen: redis:alpine

# docker run -d \
#   --name redis \
#   ... completar ...

# -----------------------------------------------------------------------------
# Verificación
# -----------------------------------------------------------------------------
echo ""
echo "📋 Contenedores desplegados:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo ""
echo "✅ Despliegue completado"
