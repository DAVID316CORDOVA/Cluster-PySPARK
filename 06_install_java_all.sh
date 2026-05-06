#!/bin/bash
# ==============================================================================
# 06_install_java_all.sh
# Instalacion de Java OpenJDK en todos los nodos del cluster.
# Ejecutar desde el nodo MASTER. Requiere acceso SSH sin contrasena.
# ==============================================================================

set -e

USER="estudiante"
ALL_NODES=("cad02-w000" "cad02-w001" "cad02-w002" "cad02-w003" "cadhead02" "cadcliente02")

echo "=== Instalando Java OpenJDK en todos los nodos ==="

for NODE in "${ALL_NODES[@]}"; do
    echo ""
    echo "--- Instalando en ${NODE} ---"
    ssh ${USER}@${NODE} "sudo dnf install -y java-1.8.0-openjdk-devel"
done

echo ""
echo "=== Verificando instalacion de Java ==="
for NODE in "${ALL_NODES[@]}"; do
    echo -n "${NODE}: "
    ssh ${USER}@${NODE} "java -version 2>&1 | head -1"
done

echo ""
echo "Instalacion de Java completada en todos los nodos."
