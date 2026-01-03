#!/bin/bash
# ============================================
# 🐳 Proyecto Semana 01 - Comandos
# Bootcamp Docker Zero to Hero
# ============================================

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Nombres de recursos
NETWORK_NAME="dev-network"
DB_CONTAINER="db"
CACHE_CONTAINER="cache"
WEB_CONTAINER="web"
ADMIN_CONTAINER="dbadmin"

# ============================================
# Función: setup - Crear todos los recursos
# ============================================
setup() {
    echo -e "${BLUE}🚀 Iniciando setup del proyecto...${NC}"
    
    # Crear red
    echo -e "${GREEN}📡 Creando red ${NETWORK_NAME}...${NC}"
    docker network create ${NETWORK_NAME}
    
    # PostgreSQL
    echo -e "${GREEN}🐘 Iniciando PostgreSQL...${NC}"
    docker run -d \
        --name ${DB_CONTAINER} \
        --network ${NETWORK_NAME} \
        -e POSTGRES_USER=devuser \
        -e POSTGRES_PASSWORD=devpass \
        -e POSTGRES_DB=devdb \
        -p 5432:5432 \
        --restart unless-stopped \
        postgres:16-alpine
    
    # Esperar a que PostgreSQL esté listo
    echo "   Esperando a que PostgreSQL inicie..."
    sleep 5
    
    # Redis
    echo -e "${GREEN}🔴 Iniciando Redis...${NC}"
    docker run -d \
        --name ${CACHE_CONTAINER} \
        --network ${NETWORK_NAME} \
        -p 6379:6379 \
        --restart unless-stopped \
        redis:alpine
    
    # Nginx
    echo -e "${GREEN}🌐 Iniciando Nginx...${NC}"
    docker run -d \
        --name ${WEB_CONTAINER} \
        --network ${NETWORK_NAME} \
        -p 8080:80 \
        --restart unless-stopped \
        nginx:alpine
    
    # Adminer
    echo -e "${GREEN}🔧 Iniciando Adminer...${NC}"
    docker run -d \
        --name ${ADMIN_CONTAINER} \
        --network ${NETWORK_NAME} \
        -p 8081:8080 \
        --restart unless-stopped \
        adminer
    
    echo ""
    echo -e "${BLUE}✅ Setup completado!${NC}"
    echo ""
    status
}

# ============================================
# Función: status - Ver estado de los servicios
# ============================================
status() {
    echo -e "${BLUE}📊 Estado de los servicios:${NC}"
    echo ""
    docker ps --filter "network=${NETWORK_NAME}" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    echo ""
    echo -e "${GREEN}URLs disponibles:${NC}"
    echo "  🌐 Nginx:    http://localhost:8080"
    echo "  🔧 Adminer:  http://localhost:8081"
    echo "  🐘 PostgreSQL: localhost:5432 (devuser/devpass/devdb)"
    echo "  🔴 Redis:    localhost:6379"
}

# ============================================
# Función: cleanup - Eliminar todos los recursos
# ============================================
cleanup() {
    echo -e "${RED}🧹 Limpiando recursos del proyecto...${NC}"
    
    # Detener contenedores
    echo -e "${BLUE}⏹️  Deteniendo contenedores...${NC}"
    docker stop ${DB_CONTAINER} ${CACHE_CONTAINER} ${WEB_CONTAINER} ${ADMIN_CONTAINER} 2>/dev/null
    
    # Eliminar contenedores
    echo -e "${BLUE}🗑️  Eliminando contenedores...${NC}"
    docker rm ${DB_CONTAINER} ${CACHE_CONTAINER} ${WEB_CONTAINER} ${ADMIN_CONTAINER} 2>/dev/null
    
    # Eliminar red
    echo -e "${BLUE}📡 Eliminando red...${NC}"
    docker network rm ${NETWORK_NAME} 2>/dev/null
    
    echo ""
    echo -e "${GREEN}✅ Limpieza completada!${NC}"
}

# ============================================
# Función: test - Probar conectividad
# ============================================
test_connectivity() {
    echo -e "${BLUE}🧪 Probando conectividad...${NC}"
    echo ""
    
    # Test Redis
    echo -n "Redis PING: "
    docker exec ${CACHE_CONTAINER} redis-cli ping
    
    # Test PostgreSQL
    echo -n "PostgreSQL: "
    docker exec ${DB_CONTAINER} pg_isready -U devuser -d devdb
    
    # Test Nginx
    echo -n "Nginx: "
    curl -s -o /dev/null -w "%{http_code}" http://localhost:8080
    echo " (HTTP status)"
    
    # Test Adminer
    echo -n "Adminer: "
    curl -s -o /dev/null -w "%{http_code}" http://localhost:8081
    echo " (HTTP status)"
}

# ============================================
# Main - Procesar argumentos
# ============================================
case "$1" in
    setup)
        setup
        ;;
    status)
        status
        ;;
    cleanup)
        cleanup
        ;;
    test)
        test_connectivity
        ;;
    *)
        echo "Uso: $0 {setup|status|cleanup|test}"
        echo ""
        echo "Comandos:"
        echo "  setup   - Crear todos los contenedores y la red"
        echo "  status  - Ver estado de los servicios"
        echo "  cleanup - Eliminar todos los recursos"
        echo "  test    - Probar conectividad de los servicios"
        exit 1
        ;;
esac
