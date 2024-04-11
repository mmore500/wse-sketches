#!/usr/bin/bash
#SBATCH --ntasks=1
#SBATCH --mem=16G
#SBATCH --cpus-per-task=4
#SBATCH --time=0:20:00
#SBATCH --output="/jet/home/%u/joblog/id=%j+ext=.txt"

set -e

cd "$(dirname "$0")"

WSE_SKETCHES_REVISION="2657ef4350d2f1f046a33d1f99c7a5215a2e0074"
echo "WSE_SKETCHES_REVISION ${WSE_SKETCHES_REVISION}"

WORKDIR="${HOME}/2024-04-10/lex10+async-ga-3x3"
echo "WORKDIR ${WORKDIR}"

export CSLC="${CSLC:-cslc}"
echo "CSLC ${CSLC}"

echo "initialization telemetry ==============================================="
echo "which cslc $(which cslc)"
echo "SDK_INSTALL_LOCATION ${SDK_INSTALL_LOCATION:-}"
echo "SDK_INSTALL_PATH ${SDK_INSTALL_PATH:-}"

echo "setup WORKDIR =========================================================="
rm -rf "${WORKDIR}"
mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

echo "configure kernel compile ==============================================="
git clone https://github.com/mmore500/wse-sketches.git
cd wse-sketches
git checkout "${WSE_SKETCHES_REVISION}"
git status

export ASYNC_GA_COOLDOWN_CYCLES="${ASYNC_GA_COOLDOWN_CYCLES:-50000}"
echo "ASYNC_GA_COOLDOWN_CYCLES ${ASYNC_GA_COOLDOWN_CYCLES}"

export ASYNC_GA_FABRIC_DIMS="757,996"
echo "ASYNC_GA_FABRIC_DIMS ${ASYNC_GA_FABRIC_DIMS}"

export ASYNC_GA_ARCH_FLAG="--arch=wse2"
echo "ASYNC_GA_ARCH_FLAG ${ASYNC_GA_ARCH_FLAG}"

export ASYNC_GA_GENOME_FLAVOR="${ASYNC_GA_GENOME_FLAVOR:-genome_purifyingplus}"
echo "ASYNC_GA_GENOME_FLAVOR ${ASYNC_GA_GENOME_FLAVOR}"
export ASYNC_GA_NWAV="${ASYNC_GA_NWAV:-4}"
echo "ASYNC_GA_NWAV ${ASYNC_GA_NWAV}"

echo "do kernel compile ======================================================"
./kernel-async-ga/compile.sh

echo "create sbatch file ====================================================="

SBATCH_FILE="$(mktemp)"
echo "SBATCH_FILE ${SBATCH_FILE}"

###############################################################################
# ----------------------------------------------------------------------------#
###############################################################################
cat > "${SBATCH_FILE}" << EOF
#!/bin/bash
#SBATCH --gres=cs:cerebras:1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --time=0:05:00
#SBATCH --output="/jet/home/%u/joblog/id=%j+ext=.txt"

set -e
# newgrp GRANT_ID

echo "cc SLURM script --------------------------------------------------------"
JOBSCRIPT="\${HOME}/jobscript/id=\${SLURM_JOB_ID}+ext=.sbatch"
echo "JOBSCRIPT \${JOBSCRIPT}"
cp "\${0}" "\${JOBSCRIPT}"
chmod +x "\${JOBSCRIPT}"

echo "initialization telemetry -----------------------------------------------"
echo "WSE_SKETCHES_REVISION ${WSE_SKETCHES_REVISION}"
echo "HEAD_REVISION $(git rev-parse HEAD)"
echo "WORKDIR ${WORKDIR}"
echo "date \$(date)"
echo "SDK_INSTALL_LOCATION \${SDK_INSTALL_LOCATION:-}"
echo "SDK_INSTALL_PATH \${SDK_INSTALL_PATH:-}"
echo "which cs_python \$(which cs_python)"
echo "CS_IP_ADDR \${CS_IP_ADDR}"

export CS_PYTHON="${CS_PYTHON:-cs_python}"
echo "CS_PYTHON \${CS_PYTHON}"
export ASYNC_GA_GENOME_FLAVOR="${ASYNC_GA_GENOME_FLAVOR}"
echo "ASYNC_GA_GENOME_FLAVOR \${ASYNC_GA_GENOME_FLAVOR}"
export ASYNC_GA_GENOME_FLAVOR="${ASYNC_GA_NWAV}"
echo "ASYNC_GA_NWAV \${ASYNC_GA_NWAV}"
export ASYNC_GA_EXECUTE_FLAGS="--cmaddr \${CS_IP_ADDR}:9000 --no-suptrace"
echo "ASYNC_GA_EXECUTE_FLAGS \${ASYNC_GA_EXECUTE_FLAGS}"
export ASYNC_GA_MSEC_AT_LEAST="${ASYNC_GA_MSEC_AT_LEAST:-0}"
echo "ASYNC_GA_MSEC_AT_LEAST \${ASYNC_GA_MSEC_AT_LEAST}"
export ASYNC_GA_NCYCLE_AT_LEAST="${ASYNC_GA_NCYCLE_AT_LEAST:-100}"
echo "ASYNC_GA_NCYCLE_AT_LEAST \${ASYNC_GA_NCYCLE_AT_LEAST}"

echo "setup WORKDIR ----------------------------------------------------------"
cd "${WORKDIR}"
echo "PWD \${PWD}"

echo "execute kernel program -------------------------------------------------"
./wse-sketches/kernel-async-ga/execute.sh

echo "finalization telemetry -------------------------------------------------"
echo "SECONDS \${SECONDS}"
echo ">>>fin<<<"

EOF
###############################################################################
# ----------------------------------------------------------------------------#
###############################################################################

echo "submit sbatch file ====================================================="
sbatch "${SBATCH_FILE}"

echo "finalization telemetry ================================================="
echo "SECONDS ${SECONDS}"
echo ">>>fin<<<"
