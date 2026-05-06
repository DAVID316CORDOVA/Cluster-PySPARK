#!/bin/bash
# ==============================================================================
# 03_setup_nfs_master.sh
# Instalacion y configuracion del servidor NFS en el nodo maestro (o nodo NFS).
# Ejecutar unicamente en el nodo que actuara como servidor NFS.
# ==============================================================================

set -e

# --- Parametros de configuracion ---
NFS_DIR="/nfs/condor"
EXPORT_NETWORK="10.43.96.0/20"
NFS_USER="estudiante"

echo "=== Instalando utilidades NFS ==="
sudo dnf install -y nfs-utils

echo ""
echo "=== Creando directorio compartido: ${NFS_DIR} ==="
sudo mkdir -p ${NFS_DIR}
sudo chown ${NFS_USER}:${NFS_USER} ${NFS_DIR}
echo "Directorio creado con propietario ${NFS_USER}."

echo ""
echo "=== Configurando exportaciones NFS ==="
EXPORT_LINE="${NFS_DIR} ${EXPORT_NETWORK}(rw,sync,no_root_squash,no_all_squash)"

if ! grep -q "${NFS_DIR}" /etc/exports 2>/dev/null; then
    echo "${EXPORT_LINE}" | sudo tee -a /etc/exports > /dev/null
    echo "Exportacion agregada a /etc/exports."
else
    echo "La exportacion ya existe en /etc/exports. Se omite."
fi

echo ""
echo "=== Habilitando e iniciando el servicio NFS ==="
sudo systemctl enable nfs-server
sudo systemctl start nfs-server
sudo exportfs -rv

echo ""
echo "=== Estado del servicio NFS ==="
sudo systemctl status nfs-server --no-pager

echo ""
echo "=== Exportaciones activas ==="
sudo exportfs -v

echo ""
echo "Configuracion del servidor NFS completada."
