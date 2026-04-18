#!/bin/bash
# health-check.sh - Verifica el estado de los servicios
# Uso: ./health-check.sh [servicio]

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para verificar un contenedor
check_container() {
    local name=$1
    local status=$(docker inspect -f '{{.State.Status}}' "$name" 2>/dev/null || echo "not_found")
    
    case $status in
        "running")
            echo -e "${GREEN}✓${NC} $name: Running"
            return 0
            ;;
        "exited")
            local exit_code=$(docker inspect -f '{{.State.ExitCode}}' "$name")
            echo -e "${RED}✗${NC} $name: Exited (code: $exit_code)"
            return 1
            ;;
        "paused")
            echo -e "${YELLOW}⏸${NC} $name: Paused"
            return 1
            ;;
        "not_found")
            echo -e "${RED}✗${NC} $name: Not found"
            return 1
            ;;
        *)
            echo -e "${YELLOW}?${NC} $name: $status"
            return 1
            ;;
    esac
}

# Función para verificar conectividad HTTP
check_http() {
    local name=$1
    local port=$2
    local path=${3:-"/"}
    
    if docker exec "$name" wget -q -O /dev/null "http://localhost:${port}${path}" 2>/dev/null; then
        echo -e "  ${GREEN}→${NC} HTTP :$port OK"
        return 0
    else
        echo -e "  ${RED}→${NC} HTTP :$port FAIL"
        return 1
    fi
}

# Función para verificar MySQL
check_mysql() {
    local name=$1
    
    if docker exec "$name" mysqladmin ping -h localhost --silent 2>/dev/null; then
        echo -e "  ${GREEN}→${NC} MySQL responding"
        return 0
    else
        echo -e "  ${RED}→${NC} MySQL not responding"
        return 1
    fi
}

# Función para verificar Redis
check_redis() {
    local name=$1
    
    if docker exec "$name" redis-cli ping 2>/dev/null | grep -q "PONG"; then
        echo -e "  ${GREEN}→${NC} Redis responding"
        return 0
    else
        echo -e "  ${RED}→${NC} Redis not responding"
        return 1
    fi
}

# Main
echo "========================================"
echo "   Health Check - Sistema de Monitoreo"
echo "========================================"
echo ""

SERVICES="mon-web mon-api mon-db mon-cache"
FAILED=0

for service in $SERVICES; do
    check_container "$service" || FAILED=$((FAILED + 1))
    
    # Verificaciones específicas por servicio
    case $service in
        "mon-web")
            docker inspect "$service" &>/dev/null && check_http "$service" 80
            ;;
        "mon-api")
            # API simula respuesta
            ;;
        "mon-db")
            docker inspect "$service" &>/dev/null && check_mysql "$service"
            ;;
        "mon-cache")
            docker inspect "$service" &>/dev/null && check_redis "$service"
            ;;
    esac
    echo ""
done

echo "========================================"
if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}Todos los servicios están saludables${NC}"
    exit 0
else
    echo -e "${RED}$FAILED servicio(s) con problemas${NC}"
    exit 1
fi
