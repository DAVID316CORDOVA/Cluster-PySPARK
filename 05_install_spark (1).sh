#!/bin/bash
# ==============================================================================
# 05_install_spark.sh
# Instalacion de Apache Spark en el directorio NFS compartido.
# Ejecutar desde el nodo MASTER (o cualquier nodo con acceso al NFS).
# ==============================================================================

set -e

SPARK_VERSION="3.5.2"
HADOOP_VERSION="hadoop3"
SPARK_TGZ="spark-${SPARK_VERSION}-bin-${HADOOP_VERSION}.tgz"
SPARK_SOURCE="/home/estudiante/${SPARK_TGZ}"
NFS_APPS_DIR="/nfs/condor/apps"
SPARK_INSTALL_DIR="${NFS_APPS_DIR}/Spark"

echo "=== Creando directorio de aplicaciones ==="
mkdir -p ${NFS_APPS_DIR}

echo ""
echo "=== Copiando paquete Spark al directorio compartido ==="
if [ -f "${SPARK_SOURCE}" ]; then
    cp ${SPARK_SOURCE} ${NFS_APPS_DIR}/
    echo "Copia completada."
else
    echo "ERROR: No se encontro el archivo ${SPARK_SOURCE}"
    echo "Descargar desde https://spark.apache.org/downloads.html"
    exit 1
fi

echo ""
echo "=== Descomprimiendo Spark ==="
cd ${NFS_APPS_DIR}
tar -zxvf ${SPARK_TGZ}

echo ""
echo "=== Renombrando directorio ==="
if [ -d "spark-${SPARK_VERSION}-bin-${HADOOP_VERSION}" ]; then
    mv "spark-${SPARK_VERSION}-bin-${HADOOP_VERSION}" Spark
    echo "Spark instalado en ${SPARK_INSTALL_DIR}"
else
    echo "ERROR: No se encontro el directorio descomprimido."
    exit 1
fi

echo ""
echo "=== Contenido de ${NFS_APPS_DIR} ==="
ls -la ${NFS_APPS_DIR}

echo ""
echo "Instalacion de Apache Spark completada."
