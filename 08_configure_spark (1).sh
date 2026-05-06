#!/bin/bash
# ==============================================================================
# 08_configure_spark.sh
# Configuracion de los ficheros spark-env.sh y workers de Apache Spark.
# Ejecutar desde cualquier nodo con acceso al directorio NFS compartido.
# ==============================================================================

set -e

SPARK_CONF_DIR="/nfs/condor/apps/Spark/conf"

# --- Parametros del cluster ---
MASTER_IP="10.43.97.145"
WORKER_PORT="8888"
WORKER_WEBUI_PORT="8081"
DAEMON_MEMORY="1g"
WORKER_CORES="4"
WORKER_MEMORY="12g"
EXECUTOR_CORES="2"
EXECUTOR_MEMORY="2g"
SCHEDULER_MODE="FAIR"
PYSPARK_PYTHON="/usr/bin/python3"

echo "=== Configurando spark-env.sh ==="
cd ${SPARK_CONF_DIR}

if [ ! -f spark-env.sh ]; then
    cp spark-env.sh.template spark-env.sh
    echo "Fichero spark-env.sh creado desde template."
else
    echo "El fichero spark-env.sh ya existe. Se sobreescribira la configuracion."
fi

cat >> spark-env.sh << EOF

# === Configuracion del Cluster Spark ===
export SPARK_MASTER_HOST=${MASTER_IP}
export SPARK_WORKER_PORT=${WORKER_PORT}
export SPARK_WORKER_WEBUI_PORT=${WORKER_WEBUI_PORT}

export SPARK_DAEMON_MEMORY=${DAEMON_MEMORY}

export SPARK_WORKER_CORES=${WORKER_CORES}
export SPARK_WORKER_MEMORY=${WORKER_MEMORY}
export SPARK_DAEMON_JAVA_OPTS="-Dspark.schedules.mode=${SCHEDULER_MODE}"

export SPARK_EXECUTOR_CORES=${EXECUTOR_CORES}
export SPARK_EXECUTOR_MEMORY=${EXECUTOR_MEMORY}

export PYSPARK_PYTHON=${PYSPARK_PYTHON}
export PYSPARK_DRIVER_PYTHON=${PYSPARK_PYTHON}
EOF

echo "Configuracion de spark-env.sh completada."

echo ""
echo "=== Configurando fichero workers ==="
if [ -f workers.template ] && [ ! -f workers ]; then
    cp workers.template workers
fi

cat > workers << EOF
# Nodos worker del cluster Spark
cad02-w000
cad02-w001
cad02-w002
cad02-w003
cadhead02
EOF

echo "Fichero workers configurado con los siguientes nodos:"
cat workers

echo ""
echo "Configuracion de Apache Spark completada."
