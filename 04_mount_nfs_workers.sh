#!/bin/bash
# ==============================================================================
# 04_mount_nfs_workers.sh
# Montaje del directorio NFS compartido en cada nodo worker.
# Ejecutar desde el nodo MASTER. Requiere acceso SSH sin contrasena.
# ==============================================================================

set -e

USER="estudiante"
NFS_SERVER="cad02-nfs01"
NFS_REMOTE_DIR="/nfs/condor"
NFS_LOCAL_DIR="/nfs/condor"

WORKERS=("cad02-w000" "cad02-w001" "cad02-w002" "cad02-w003" "cadcliente02" "cadhead02")

echo "=== Montando NFS en los nodos del cluster ==="

for WORKER in "${WORKERS[@]}"; do
    echo "--- Montando en ${WORKER} ---"
    ssh ${USER}@${WORKER} "
        sudo mkdir -p ${NFS_LOCAL_DIR}
        if mountpoint -q ${NFS_LOCAL_DIR} 2>/dev/null; then
            echo 'Ya esta montado.'
        else
            sudo mount ${NFS_SERVER}:${NFS_REMOTE_DIR} ${NFS_LOCAL_DIR}
            echo 'Montaje exitoso.'
        fi
    "
done

echo ""
echo "=== Verificando montaje con df -h ==="
for WORKER in "${WORKERS[@]}"; do
    echo "--- ${WORKER} ---"
    ssh ${USER}@${WORKER} "df -h | grep nfs"
    echo ""
done

echo "Montaje NFS completado en todos los workers."
