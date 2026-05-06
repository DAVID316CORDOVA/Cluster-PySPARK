#!/bin/bash
# ==============================================================================
# 10_stop_cluster.sh
# Detencion del cluster Apache Spark.
# Ejecutar desde el nodo MASTER.
# ==============================================================================

SPARK_HOME="/nfs/condor/apps/Spark"

echo "=== Deteniendo cluster Apache Spark ==="
cd ${SPARK_HOME}/sbin
./stop-all.sh

echo ""
echo "=== Procesos Java activos (jps) ==="
jps

echo ""
echo "Cluster Spark detenido."
