#!/bin/bash
# ==============================================================================
# 07_setup_env.sh
# Configuracion de variables de entorno de Spark y Python en todos los nodos.
# Ejecutar desde el nodo MASTER. Requiere acceso SSH sin contrasena.
# ==============================================================================

set -e

USER="estudiante"
ALL_NODES=("cadhead02" "cad02-w000" "cad02-w001" "cad02-w002" "cad02-w003" "cadcliente02")

# --- Variables de entorno a configurar ---
ENV_BLOCK='
# === Configuracion Apache Spark ===
export SPARK_HOME="/nfs/condor/apps/Spark"
export SPARK_CONF_DIR="$SPARK_HOME/conf"
export PATH="$SPARK_HOME/bin":$PATH
export PYSPARK_PYTHON="/usr/bin/python3"
export PYSPARK_DRIVER_PYTHON="/usr/bin/python3"
'

echo "=== Configurando variables de entorno en todos los nodos ==="

for NODE in "${ALL_NODES[@]}"; do
    echo "--- Configurando ${NODE} ---"
    ssh ${USER}@${NODE} "
        if ! grep -q 'Configuracion Apache Spark' ~/.bashrc 2>/dev/null; then
            echo '${ENV_BLOCK}' >> ~/.bashrc
            source ~/.bashrc
            echo 'Variables de entorno agregadas.'
        else
            echo 'Las variables ya estan configuradas. Se omite.'
        fi
    "
done

echo ""
echo "=== Verificando configuracion de entorno ==="
for NODE in "${ALL_NODES[@]}"; do
    echo "--- ${NODE} ---"
    ssh ${USER}@${NODE} "source ~/.bashrc && env | grep -i SPARK"
    echo ""
done

echo "Configuracion de variables de entorno completada."
