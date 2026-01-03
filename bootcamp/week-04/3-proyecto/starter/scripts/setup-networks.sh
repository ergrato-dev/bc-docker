#!/bin/bash
# =============================================================================
# setup-networks.sh - Crear redes Docker para microservicios
# =============================================================================

set -e

echo "🌐 Creando redes Docker..."

# -----------------------------------------------------------------------------
# TODO: Crear las siguientes redes
# -----------------------------------------------------------------------------

# Red DMZ (para servicios expuestos al exterior)
# Nombre: dmz-net
# TODO: Escribe el comando docker network create
# docker network create ...

# Red de Aplicación (para comunicación entre servicios)
# Nombre: app-net
# TODO: Escribe el comando docker network create
# docker network create ...

# Red de Datos (para acceso a bases de datos)
# Nombre: data-net
# TODO: Escribe el comando docker network create
# docker network create ...

# -----------------------------------------------------------------------------
# Verificación
# -----------------------------------------------------------------------------
echo ""
echo "📋 Redes creadas:"
docker network ls | grep -E "dmz-net|app-net|data-net" || echo "❌ No se encontraron las redes"

echo ""
echo "✅ Script completado"
