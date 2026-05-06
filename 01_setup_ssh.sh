#!/bin/bash
# ==============================================================================
# 01_setup_ssh.sh
# Configuracion de SSH sin contrasena desde el nodo master hacia los workers.
# Ejecutar unicamente desde el nodo MASTER.
# ==============================================================================

set -e

# --- Definir los hostnames o IPs de los nodos ---
# Modificar segun la topologia del cluster.
MASTER="cadhead02"
WORKERS=("cad02-w000" "cad02-w001" "cad02-w002" "cad02-w003")
USER="estudiante"

echo "=== Generando par de claves SSH ==="
if [ ! -f "$HOME/.ssh/id_rsa" ]; then
    ssh-keygen -t rsa -b 4096 -N "" -f "$HOME/.ssh/id_rsa"
    echo "Claves generadas exitosamente."
else
    echo "Las claves SSH ya existen. Se omite la generacion."
fi

echo ""
echo "=== Copiando clave publica al master ==="
ssh-copy-id ${USER}@${MASTER}

echo ""
echo "=== Copiando clave publica a los workers ==="
for WORKER in "${WORKERS[@]}"; do
    echo "--- Copiando a ${WORKER} ---"
    ssh-copy-id ${USER}@${WORKER}
done

echo ""
echo "=== Verificando conectividad SSH sin contrasena ==="
for NODE in "${MASTER}" "${WORKERS[@]}"; do
    echo -n "Conectando a ${NODE}... "
    ssh -o BatchMode=yes -o ConnectTimeout=5 ${USER}@${NODE} "echo OK" 2>/dev/null \
        && echo "Exitoso" || echo "FALLO"
done

echo ""
echo "Configuracion SSH completada."
