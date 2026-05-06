# Configuracion de un Cluster Apache Spark sobre Rocky Linux

**Pontificia Universidad Javeriana**
Computacion de Alto Desempeno / Procesamiento de Datos 2024-30
Laboratorio ML00 -- John Corredor, PhD

---

## Integrantes

| Nombre | Correo |
|---|---|
| Juan Sebastian Bravo Santacruz | bravos.js@javeriana.edu.co |
| Felix David Cordova Garcia | fdcordova@javeriana.edu.co |
| Jonatan Alejandro Gallo Martinez | jonatan.gallo@javeriana.edu.co |
| Jose Alejandro Jaime Lopez | jo.jaime@javeriana.edu.co |
| Josman Alexdy Ramirez Torres | josman.ramirez@javeriana.edu.co |
| Jesus David Romero Melo | jesus-romero@javeriana.edu.co |
| Juan Camilo Torres Pena | torrespjc@javeriana.edu.co |

**Fecha:** 2026/04/30

---

## 1. Objetivo

Se configuro un cluster de Apache Spark en modo standalone utilizando maquinas virtuales con Rocky Linux 9. El cluster consta de un nodo maestro, un servidor NFS dedicado y multiples nodos worker que comparten los binarios de Spark a traves de un sistema de archivos en red (NFS).

---

## 2. Arquitectura del Cluster

```
+------------------+        +------------------+
|   cadhead02      |        |   cad02-nfs01    |
|   (Master/Worker)|        |   (Servidor NFS) |
|   10.43.97.146   |        |   10.43.97.149   |
+--------+---------+        +--------+---------+
         |                           |
         +----------+  +-------------+
                    |  |
              +-----+--+------+
              |   Red interna  |
              |  10.43.97.0/24 |
              +--+--+--+--+---+
                 |  |  |  |
    +------------+  |  |  +------------+
    |               |  |               |
+---+----+   +-----+-+--+   +--------+---+
|cad02-  |   |cad02-     |   |cad02-      |
|w000    |   |w001       |   |w002        |
|.141    |   |.135       |   |.136        |
+--------+   +-----------+   +------------+

                +------------+     +----------------+
                |cad02-w003  |     |cadcliente02    |
                |.148        |     |.145 (Cliente)  |
                +------------+     +----------------+
```

El directorio `/nfs/condor` fue exportado desde el servidor NFS (`cad02-nfs01`) y montado en todos los nodos del cluster. Dentro de este directorio se instalo Apache Spark 3.5.2 con Hadoop 3, lo que permitio que todos los nodos accedan a los mismos binarios sin necesidad de instalaciones independientes.

---

## 3. Requisitos Previos

Se utilizaron los siguientes componentes de software:

- **Sistema operativo:** Rocky Linux 9
- **Java:** OpenJDK 1.8.0 (java-1.8.0-openjdk-devel)
- **Apache Spark:** 3.5.2 con soporte para Hadoop 3
- **Python:** 3.x (preinstalado en el sistema)
- **NFS:** nfs-utils

---

## 4. Descripcion de los Pasos Realizados

### 4.1 Configuracion de SSH sin contrasena (2A)

Se genero un par de claves SSH en el nodo maestro y se copio la clave publica a todos los workers. Este paso fue necesario porque Spark utiliza SSH para iniciar y detener procesos remotos al ejecutar `start-all.sh`.

**Script:** `scripts/01_setup_ssh.sh`

### 4.2 Edicion del fichero /etc/hosts (2B)

Se agrego la resolucion de nombres de todos los nodos en el fichero `/etc/hosts` de cada maquina del cluster. Se definio un hostname y un FQDN para cada nodo, evitando la dependencia de un servidor DNS externo.

**Script:** `scripts/02_setup_hosts.sh`

Nodos registrados:

| IP | Hostname | Rol |
|---|---|---|
| 10.43.97.146 | cadhead02 | Master / Worker |
| 10.43.97.141 | cad02-w000 | Worker |
| 10.43.97.135 | cad02-w001 | Worker |
| 10.43.97.136 | cad02-w002 | Worker |
| 10.43.97.148 | cad02-w003 | Worker |
| 10.43.97.145 | cadcliente02 | Cliente Spark |
| 10.43.97.149 | cad02-nfs01 | Servidor NFS |

### 4.3 Creacion de la carpeta compartida en el servidor NFS (2C)

Se creo el directorio `/nfs/condor` en el servidor NFS y se configuro el fichero `/etc/exports` para permitir el acceso desde la red interna del cluster con permisos de lectura y escritura.

**Script:** `scripts/03_setup_nfs_master.sh`

### 4.4 Instalacion y configuracion del servicio NFS (2D)

Se instalo el paquete `nfs-utils` en el servidor NFS, se habilito el servicio `nfs-server` con `systemctl enable` y se inicio con `systemctl start`. Se verifico que el servicio quedo activo y las exportaciones fueron visibles con `exportfs -v`.

**Script:** `scripts/03_setup_nfs_master.sh` (incluye este paso)

### 4.5 Montaje del NFS en los workers (2E)

En cada nodo worker se creo el directorio `/nfs/condor` y se monto el recurso compartido del servidor NFS. Se verifico el montaje con `df -h`, confirmando que el sistema de archivos remoto quedo accesible.

**Script:** `scripts/04_mount_nfs_workers.sh`

### 4.6 Instalacion de Apache Spark en la carpeta compartida (2F)

Se copio el archivo `spark-3.5.2-bin-hadoop3.tgz` al directorio NFS compartido, se descomprimio y se renombro el directorio resultante a `Spark`. Se instalo Java OpenJDK 1.8.0 en todos los nodos del cluster.

**Scripts:**
- `scripts/05_install_spark.sh`
- `scripts/06_install_java_all.sh`

### 4.7 Configuracion de variables de entorno (2G)

Se editaron los ficheros `.bashrc` de todos los nodos para exportar las siguientes variables de entorno:

```bash
export SPARK_HOME="/nfs/condor/apps/Spark"
export SPARK_CONF_DIR="$SPARK_HOME/conf"
export PATH="$SPARK_HOME/bin":$PATH
export PYSPARK_PYTHON="/usr/bin/python3"
export PYSPARK_DRIVER_PYTHON="/usr/bin/python3"
```

Se recargo la configuracion con `source .bashrc` y se verifico con `env | grep -i SPARK`.

**Script:** `scripts/07_setup_env.sh`

### 4.8 Configuracion de Apache Spark (2H)

Se configuraron dos ficheros dentro del directorio `$SPARK_HOME/conf`:

**spark-env.sh** -- parametros del cluster:

| Parametro | Valor | Descripcion |
|---|---|---|
| SPARK_MASTER_HOST | 10.43.97.145 | IP del nodo maestro |
| SPARK_WORKER_PORT | 8888 | Puerto de comunicacion de workers |
| SPARK_WORKER_WEBUI_PORT | 8081 | Puerto de la interfaz web de workers |
| SPARK_WORKER_CORES | 4 | Cores asignados por worker |
| SPARK_WORKER_MEMORY | 12g | Memoria asignada por worker |
| SPARK_EXECUTOR_CORES | 2 | Cores por executor |
| SPARK_EXECUTOR_MEMORY | 2g | Memoria por executor |
| SPARK_DAEMON_MEMORY | 1g | Memoria para el daemon |
| Scheduler mode | FAIR | Modo de planificacion |

**workers** -- lista de nodos worker:

```
cad02-w000
cad02-w001
cad02-w002
cad02-w003
cadhead02
```

**Script:** `scripts/08_configure_spark.sh`

### 4.9 Inicio del servicio Spark y verificacion (2I)

Se inicio el cluster desde el nodo maestro ejecutando `./start-all.sh`. Se verifico con `jps` que los procesos `Master` y `Worker` estuvieran activos. Finalmente, se accedio a la interfaz web del Spark Master en `http://10.43.97.145:8080`.

**Scripts:**
- `scripts/09_start_cluster.sh`
- `scripts/10_stop_cluster.sh`

Estado final del cluster verificado en la interfaz web:

| Metrica | Valor |
|---|---|
| Workers activos | 5 |
| Cores totales | 20 |
| Memoria total | 60 GB |
| Estado | ALIVE |

---

## 5. Estructura del Repositorio

```
spark-cluster-lab/
|-- README.md
|-- scripts/
|   |-- 01_setup_ssh.sh
|   |-- 02_setup_hosts.sh
|   |-- 03_setup_nfs_master.sh
|   |-- 04_mount_nfs_workers.sh
|   |-- 05_install_spark.sh
|   |-- 06_install_java_all.sh
|   |-- 07_setup_env.sh
|   |-- 08_configure_spark.sh
|   |-- 09_start_cluster.sh
|   |-- 10_stop_cluster.sh
```

---

## 6. Ejecucion

Los scripts deben ejecutarse en orden numerico. Antes de ejecutarlos, se deben otorgar permisos de ejecucion:

```bash
chmod +x scripts/*.sh
```

El orden de ejecucion es el siguiente:

```bash
# Desde el nodo master:
./scripts/01_setup_ssh.sh
./scripts/02_setup_hosts.sh

# Desde el servidor NFS:
./scripts/03_setup_nfs_master.sh

# Desde el nodo master:
./scripts/04_mount_nfs_workers.sh
./scripts/05_install_spark.sh
./scripts/06_install_java_all.sh
./scripts/07_setup_env.sh
./scripts/08_configure_spark.sh
./scripts/09_start_cluster.sh
```

Para detener el cluster:

```bash
./scripts/10_stop_cluster.sh
```

---

## 7. Conclusiones

La configuracion del cluster Apache Spark sobre maquinas virtuales con Rocky Linux permitio consolidar conceptos fundamentales de computacion distribuida. Se identificaron los siguientes puntos clave:

El acceso SSH sin contrasena entre el nodo maestro y los workers resulto indispensable para el funcionamiento del cluster, dado que Spark depende de este mecanismo para coordinar procesos remotos al ejecutar `start-all.sh`.

El uso de NFS como sistema de archivos compartido demostro ser una estrategia eficiente para gestionar los binarios de Spark en un entorno multi-nodo. Al instalar Spark una sola vez en `/nfs/condor/apps` y montar ese directorio en todos los workers, se garantizo la consistencia de versiones y se simplifico el mantenimiento.

La resolucion de nombres mediante `/etc/hosts` fue critica para la comunicacion interna del cluster, eliminando la necesidad de un servidor DNS externo y asegurando que el maestro pudiera identificar a cada worker por nombre de host.

La configuracion de `spark-env.sh` permitio ajustar parametros como la memoria por worker (12 GB), los cores disponibles (4 por nodo) y el modo de planificacion FAIR, lo que evidencia la flexibilidad de Spark para adaptarse a los recursos fisicos disponibles.

La verificacion a traves de la interfaz web del Spark Master confirmo que los 5 workers quedaron en estado ALIVE con un total de 20 cores y 60 GB de memoria disponibles para procesamiento distribuido, validando que el cluster quedo operativo.

---

## 8. Referencias

- Apache Spark Documentation: https://spark.apache.org/docs/3.5.2/
- Rocky Linux Documentation: https://docs.rockylinux.org/
- NFS Configuration on RHEL-based systems: https://access.redhat.com/documentation/
