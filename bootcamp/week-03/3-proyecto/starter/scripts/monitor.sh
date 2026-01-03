#!/bin/bash
# monitor.sh - Sistema de monitoreo de contenedores
# Uso: ./monitor.sh [--continuous] [--interval N]

# ============================================
# TODO: Completa este script de monitoreo
# ============================================

set -e

# Configuración
SERVICES="mon-web mon-api mon-db mon-cache"
INTERVAL=${INTERVAL:-10}
THRESHOLD_CPU=80
THRESHOLD_MEM=80

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# ============================================
# TODO 1: Función para obtener stats de un contenedor
# Debe retornar: nombre, CPU%, MEM%, estado
# ============================================
get_container_stats() {
    local container=$1
    
    # TODO: Implementar usando docker stats --no-stream
    # Hint: docker stats --no-stream --format "{{.Name}},{{.CPUPerc}},{{.MemPerc}}" $container
    
    echo "TODO: Implementar get_container_stats"
}

# ============================================
# TODO 2: Función para verificar alertas
# Si CPU o MEM > threshold, mostrar alerta
# ============================================
check_alerts() {
    local container=$1
    local cpu=$2
    local mem=$3
    
    # TODO: Implementar verificación de thresholds
    # Hint: Comparar cpu y mem con THRESHOLD_CPU y THRESHOLD_MEM
    # Mostrar alerta si se excede
    
    echo "TODO: Implementar check_alerts"
}

# ============================================
# TODO 3: Función para generar reporte
# Debe mostrar tabla con todos los servicios
# ============================================
generate_report() {
    echo "========================================"
    echo "   Reporte de Monitoreo"
    echo "   $(date '+%Y-%m-%d %H:%M:%S')"
    echo "========================================"
    
    # TODO: Implementar generación de reporte
    # Usar docker stats --no-stream con formato tabla
    # Hint: docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}"
    
    echo ""
    echo "TODO: Implementar generate_report"
    echo ""
    echo "========================================"
}

# ============================================
# TODO 4: Función para monitoreo continuo
# Ejecutar cada N segundos
# ============================================
continuous_monitor() {
    local interval=${1:-10}
    
    echo -e "${BLUE}Iniciando monitoreo continuo (intervalo: ${interval}s)${NC}"
    echo "Presiona Ctrl+C para detener"
    echo ""
    
    # TODO: Implementar loop de monitoreo
    # Hint: while true; do generate_report; sleep $interval; done
    
    echo "TODO: Implementar continuous_monitor"
}

# ============================================
# TODO 5: Función para verificar logs de errores
# Buscar errores en los últimos N minutos
# ============================================
check_recent_errors() {
    local minutes=${1:-5}
    
    echo "Verificando errores en últimos $minutes minutos..."
    
    # TODO: Implementar búsqueda de errores
    # Para cada servicio, ejecutar:
    # docker logs --since ${minutes}m $service 2>&1 | grep -i error | wc -l
    
    echo "TODO: Implementar check_recent_errors"
}

# ============================================
# Main
# ============================================
case "${1:-report}" in
    --continuous|-c)
        continuous_monitor "${2:-$INTERVAL}"
        ;;
    --errors|-e)
        check_recent_errors "${2:-5}"
        ;;
    --help|-h)
        echo "Uso: $0 [opción]"
        echo ""
        echo "Opciones:"
        echo "  (sin args)      Generar reporte único"
        echo "  --continuous N  Monitoreo continuo cada N segundos"
        echo "  --errors M      Buscar errores de últimos M minutos"
        echo "  --help          Mostrar esta ayuda"
        ;;
    *)
        generate_report
        ;;
esac
