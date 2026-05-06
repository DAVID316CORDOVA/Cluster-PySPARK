#!/bin/bash
# ==============================================================================
# 02_setup_hosts.sh
# Configuracion del fichero /etc/hosts en todos los nodos del cluster.
# Ejecutar desde el nodo MASTER. Requiere acceso SSH sin contrasena.
# ==============================================================================

set -e

USER="estudiante"

# --- Definir las entradas del fichero hosts ---
# Modificar las IPs y hostnames segun la topologia del cluster.
HOSTS_ENTRIES="
################################################
# IPs Master/Workers - Cluster Spark
################################################
10.43.97.146  cadhead02.javeriana.edu.co      cadhead02
10.43.97.141  cad02-w000.javeriana.edu.co     cad02-w000
10.43.97.135  cad02-w001.javeriana.edu.co     cad02-w001
10.43.97.136  cad02-w002.javeriana.edu.co     cad02-w002
10.43.97.148  cad02-w003.javeriana.edu.co     cad02-w003
10.43.97.145  cadcliente02.javeriana.edu.co   cadcliente02
10.43.97.149  cad02-nfs01.javeriana.edu.co    cad02-nfs01
"

ALL_NODES=("cadhead02" "cad02-w000" "cad02-w001" "cad02-w002" "cad02-w003" "cadcliente02")

echo "=== Configurando /etc/hosts en todos los nodos ==="

for NODE in "${ALL_NODES[@]}"; do
    echo "--- Configurando ${NODE} ---"
    ssh ${USER}@${NODE} "
        if ! grep -q 'Cluster Spark' /etc/hosts; then
            echo '${HOSTS_ENTRIES}' | sudo tee -a /etc/hosts > /dev/null
            echo 'Entradas agregadas exitosamente.'
        else
            echo 'Las entradas del cluster ya existen. Se omite.'
        fi
    "
done

echo ""
echo "=== Verificando resolucion de nombres ==="
for NODE in "${ALL_NODES[@]}"; do
    echo -n "${NODE} -> "
    getent hosts ${NODE} 2>/dev/null || echo "NO RESUELVE"
done

echo ""
echo "Configuracion de /etc/hosts completada."
