#!/bin/bash
# =============================================================================
# cleanup.sh - Eliminar contenedores y redes
# =============================================================================

set -e

echo "🧹 Limpiando recursos..."

# -----------------------------------------------------------------------------
# Detener y eliminar contenedores
# -----------------------------------------------------------------------------
echo "📦 Deteniendo contenedores..."

CONTAINERS="nginx api-gateway users-service products-service postgres redis"

for container in $CONTAINERS; do
    # TODO: Detener y eliminar cada contenedor
    # Usar docker stop y docker rm
    # Ignorar errores si el contenedor no existe
    
    # docker stop $container 2>/dev/null || true
    # docker rm $container 2>/dev/null || true
    echo "  - $container (implementar)"
done

# -----------------------------------------------------------------------------
# Eliminar redes
# -----------------------------------------------------------------------------
echo ""
echo "🌐 Eliminando redes..."

NETWORKS="dmz-net app-net data-net"

for network in $NETWORKS; do
    # TODO: Eliminar cada red
    # Ignorar errores si la red no existe
    
    # docker network rm $network 2>/dev/null || true
    echo "  - $network (implementar)"
done

# -----------------------------------------------------------------------------
# Verificación
# -----------------------------------------------------------------------------
echo ""
echo "📋 Estado actual:"
echo ""
echo "Contenedores:"
docker ps -a --filter "name=nginx|api-gateway|users-service|products-service|postgres|redis" --format "table {{.Names}}\t{{.Status}}" 2>/dev/null || echo "  Ninguno"

echo ""
echo "Redes:"
docker network ls --filter "name=dmz-net|app-net|data-net" --format "table {{.Name}}\t{{.Driver}}" 2>/dev/null || echo "  Ninguna"

echo ""
echo "✅ Limpieza completada"
