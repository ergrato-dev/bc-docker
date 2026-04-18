#!/bin/bash
# =============================================================================
# test-connectivity.sh - Verificar matriz de comunicación
# =============================================================================

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "🔍 Verificando matriz de comunicación..."
echo ""

# Función para verificar conectividad
test_connection() {
    local from=$1
    local to=$2
    local expected=$3
    
    # Intentar ping con timeout de 2 segundos
    if docker exec $from ping -c 1 -W 2 $to > /dev/null 2>&1; then
        if [ "$expected" = "yes" ]; then
            echo -e "  ${GREEN}✓${NC} $from -> $to (OK)"
            return 0
        else
            echo -e "  ${RED}✗${NC} $from -> $to (DEBERÍA FALLAR)"
            return 1
        fi
    else
        if [ "$expected" = "no" ]; then
            echo -e "  ${GREEN}✓${NC} $from -> $to (bloqueado como esperado)"
            return 0
        else
            echo -e "  ${RED}✗${NC} $from -> $to (DEBERÍA CONECTAR)"
            return 1
        fi
    fi
}

ERRORS=0

# =============================================================================
# DMZ Network - Pruebas desde nginx
# =============================================================================
echo "📡 Red DMZ (dmz-net):"

# nginx -> api-gateway (sí, via app-net)
test_connection "nginx" "api-gateway" "yes" || ((ERRORS++))

# nginx -> postgres (NO - aislamiento)
test_connection "nginx" "postgres" "no" || ((ERRORS++))

# nginx -> redis (NO - aislamiento)
test_connection "nginx" "redis" "no" || ((ERRORS++))

echo ""

# =============================================================================
# APP Network - Pruebas de comunicación interna
# =============================================================================
echo "📡 Red APP (app-net):"

# api-gateway -> users-service (sí)
test_connection "api-gateway" "users-service" "yes" || ((ERRORS++))

# api-gateway -> products-service (sí)
test_connection "api-gateway" "products-service" "yes" || ((ERRORS++))

# users-service -> products-service (sí)
test_connection "users-service" "products-service" "yes" || ((ERRORS++))

echo ""

# =============================================================================
# DATA Network - Pruebas de acceso a datos
# =============================================================================
echo "📡 Red DATA (data-net):"

# api-gateway -> postgres (sí)
test_connection "api-gateway" "postgres" "yes" || ((ERRORS++))

# api-gateway -> redis (sí)
test_connection "api-gateway" "redis" "yes" || ((ERRORS++))

# users-service -> postgres (sí)
test_connection "users-service" "postgres" "yes" || ((ERRORS++))

# products-service -> redis (sí)
test_connection "products-service" "redis" "yes" || ((ERRORS++))

echo ""

# =============================================================================
# Verificar DNS aliases
# =============================================================================
echo "📡 Verificación de DNS aliases:"

# Probar aliases
if docker exec api-gateway ping -c 1 -W 2 db > /dev/null 2>&1; then
    echo -e "  ${GREEN}✓${NC} Alias 'db' resuelve correctamente"
else
    echo -e "  ${RED}✗${NC} Alias 'db' no resuelve"
    ((ERRORS++))
fi

if docker exec api-gateway ping -c 1 -W 2 cache > /dev/null 2>&1; then
    echo -e "  ${GREEN}✓${NC} Alias 'cache' resuelve correctamente"
else
    echo -e "  ${RED}✗${NC} Alias 'cache' no resuelve"
    ((ERRORS++))
fi

echo ""

# =============================================================================
# Verificar puertos publicados
# =============================================================================
echo "📡 Verificación de puertos:"

if curl -s -o /dev/null -w "%{http_code}" http://localhost:8080 | grep -q "200\|301\|302\|404"; then
    echo -e "  ${GREEN}✓${NC} Puerto 8080 accesible desde host"
else
    echo -e "  ${YELLOW}!${NC} Puerto 8080 - nginx puede no estar sirviendo contenido"
fi

echo ""

# =============================================================================
# Resumen
# =============================================================================
echo "============================================"
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✅ Todas las pruebas pasaron correctamente${NC}"
else
    echo -e "${RED}❌ Se encontraron $ERRORS errores${NC}"
fi
echo "============================================"

exit $ERRORS
