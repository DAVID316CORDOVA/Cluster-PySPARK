#!/bin/bash
# ==============================================================================
# 09_start_cluster.sh
# Inicio del cluster Spark y verificacion de su estado.
# Ejecutar desde el nodo MASTER.
# ==============================================================================

set -e

SPARK_HOME="/nfs/condor/apps/Spark"
MASTER_IP="10.43.97.145"
WEBUI_PORT="8080"

echo "=== Iniciando cluster Apache Spark ==="
cd ${SPARK_HOME}/sbin
./start-all.sh

echo ""
echo "=== Procesos Java activos (jps) ==="
jps

echo ""
echo "=== Interfaz web del Spark Master ==="
echo "Acceder desde un navegador a: http://${MASTER_IP}:${WEBUI_PORT}"

echo ""
echo "Cluster Spark iniciado. Verificar el estado en la interfaz web."
