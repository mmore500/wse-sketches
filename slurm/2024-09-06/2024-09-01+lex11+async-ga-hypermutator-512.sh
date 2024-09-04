#!/bin/bash
#SBATCH --ntasks=1
#SBATCH --mem=64G
#SBATCH --time=4:00:00
#SBATCH --cpus-per-task=28
#SBATCH --output="/jet/home/%u/joblog/id=%j+ext=.txt"

set -e

cd "$(dirname "$0")"

echo "SLURM_ARRAY_TASK_ID ${SLURM_ARRAY_TASK_ID}"

WSE_SKETCHES_REVISION="559de6a2a3e2a767a0e17e3e830616393e000542"
echo "WSE_SKETCHES_REVISION ${WSE_SKETCHES_REVISION}"

WORKDIR="${HOME}/scratch/2024-09-06-staggered-Ub-mild/lex214+async-ga-hypermutator-512"
echo "WORKDIR ${WORKDIR}"

export CSLC="${CSLC:-cslc}"
echo "CSLC ${CSLC}"

echo "initialization telemetry ==============================================="
echo "which cslc $(which cslc)"
echo "SDK_INSTALL_LOCATION ${SDK_INSTALL_LOCATION:-}"
echo "SDK_INSTALL_PATH ${SDK_INSTALL_PATH:-}"

echo "setup WORKDIR =========================================================="
mkdir -p "${WORKDIR}"

echo "setup SOURCEDIR ========================================================"
SOURCEDIR="/tmp/${WSE_SKETCHES_REVISION}-${SLURM_JOB_ID}"
echo "SOURCEDIR ${SOURCEDIR}"
rm -rf "${SOURCEDIR}"
git clone https://github.com/mmore500/wse-sketches.git "${SOURCEDIR}"
cd "${SOURCEDIR}"
git checkout "${WSE_SKETCHES_REVISION}"
cd -

echo "begin work loop ========================================================"
seed=0
for config in \
    "export ASYNC_GA_NCOL_SUBGRID=1 ASYNC_GA_NROW_SUBGRID=1 NREP=1" \
    "export ASYNC_GA_NCOL_SUBGRID=2 ASYNC_GA_NROW_SUBGRID=2 NREP=1" \
    "export ASYNC_GA_NCOL_SUBGRID=4 ASYNC_GA_NROW_SUBGRID=4 NREP=1" \
    "export ASYNC_GA_NCOL_SUBGRID=8 ASYNC_GA_NROW_SUBGRID=8 NREP=1" \
    "export ASYNC_GA_NCOL_SUBGRID=16 ASYNC_GA_NROW_SUBGRID=16 NREP=1" \
    "export ASYNC_GA_NCOL_SUBGRID=32 ASYNC_GA_NROW_SUBGRID=32 NREP=1" \
    "export ASYNC_GA_NCOL_SUBGRID=64 ASYNC_GA_NROW_SUBGRID=64 NREP=1" \
    "export ASYNC_GA_NCOL_SUBGRID=128 ASYNC_GA_NROW_SUBGRID=128 NREP=1" \
    "export ASYNC_GA_NCOL_SUBGRID=256 ASYNC_GA_NROW_SUBGRID=256 NREP=1" \
    "export ASYNC_GA_NCOL_SUBGRID=512 ASYNC_GA_NROW_SUBGRID=512 NREP=4" \
; do
eval "${config}"
echo "ASYNC_GA_NCOL_SUBGRID ${ASYNC_GA_NCOL_SUBGRID}"
echo "ASYNC_GA_NROW_SUBGRID ${ASYNC_GA_NROW_SUBGRID}"
echo "NREP ${NREP}"
for rep in $(seq 1 ${NREP}); do
echo "rep ${rep}"
seed=$((seed+1))
echo "seed ${seed}"

SLUG="wse-sketches+subgrid=${ASYNC_GA_NCOL_SUBGRID}+seed=${seed}"
echo "SLUG ${SLUG}"

echo "configure kernel compile ==============================================="
rm -rf "${WORKDIR}/${SLUG}"
cp -r "${SOURCEDIR}" "${WORKDIR}/${SLUG}"
cd "${WORKDIR}/${SLUG}"
git status

export ASYNC_GA_FABRIC_DIMS="757,996"
echo "ASYNC_GA_FABRIC_DIMS ${ASYNC_GA_FABRIC_DIMS}"

export ASYNC_GA_ARCH_FLAG="--arch=wse2"
echo "ASYNC_GA_ARCH_FLAG ${ASYNC_GA_ARCH_FLAG}"

export ASYNC_GA_GENOME_FLAVOR="genome_hypermutator_staggered_Ub_mild"
echo "ASYNC_GA_GENOME_FLAVOR ${ASYNC_GA_GENOME_FLAVOR}"
export ASYNC_GA_NWAV="${ASYNC_GA_NWAV:-5}"
echo "ASYNC_GA_NWAV ${ASYNC_GA_NWAV}"
export ASYNC_GA_NTRAIT="${ASYNC_GA_NTRAIT:-16}"
echo "ASYNC_GA_NTRAIT ${ASYNC_GA_NTRAIT}"

export ASYNC_GA_NCOL=512
echo "ASYNC_GA_NCOL ${ASYNC_GA_NCOL}"

export ASYNC_GA_NROW=512
echo "ASYNC_GA_NROW ${ASYNC_GA_NROW}"

export ASYNC_GA_MSEC_AT_LEAST=0
echo "ASYNC_GA_MSEC_AT_LEAST ${ASYNC_GA_MSEC_AT_LEAST}"

export ASYNC_GA_NCYCLE_AT_LEAST=10000000
echo "ASYNC_GA_NCYCLE_AT_LEAST ${ASYNC_GA_NCYCLE_AT_LEAST}"

export ASYNC_GA_GLOBAL_SEED="${seed}"
echo "ASYNC_GA_GLOBAL_SEED ${ASYNC_GA_GLOBAL_SEED}"

export ASYNC_GA_POPSIZE=32
echo "ASYNC_GA_POPSIZE ${ASYNC_GA_POPSIZE}"

export ASYNC_GA_TOURNSIZE_NUMERATOR=11
echo "ASYNC_GA_TOURNSIZE_NUMERATOR ${ASYNC_GA_TOURNSIZE_NUMERATOR}"

export ASYNC_GA_TOURNSIZE_DENOMINATOR=10
echo "ASYNC_GA_TOURNSIZE_DENOMINATOR ${ASYNC_GA_TOURNSIZE_DENOMINATOR}"

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
#SBATCH --mem=32G
#SBATCH --time=0:20:00
#SBATCH --output="/jet/home/%u/joblog/id=%j+ext=.txt"
#SBATCH --exclude=sdf-2

set -e
# newgrp GRANT_ID

echo "cc SLURM script --------------------------------------------------------"
JOBSCRIPT="\${HOME}/jobscript/id=\${SLURM_JOB_ID}+ext=.sbatch"
echo "JOBSCRIPT \${JOBSCRIPT}"
cp "\${0}" "\${JOBSCRIPT}"
chmod +x "\${JOBSCRIPT}"

echo "job telemetry ----------------------------------------------------------"
echo "source SLURM_JOB_ID ${SLURM_JOB_ID}"
echo "current SLURM_JOB_ID \${SLURM_JOB_ID}"

echo "initialization telemetry -----------------------------------------------"
echo "WSE_SKETCHES_REVISION ${WSE_SKETCHES_REVISION}"
echo "HEAD_REVISION $(git rev-parse HEAD)"
echo "WORKDIR ${WORKDIR}"
echo "SLUG ${SLUG}"
echo "date \$(date)"
echo "SDK_INSTALL_LOCATION \${SDK_INSTALL_LOCATION:-}"
echo "SDK_INSTALL_PATH \${SDK_INSTALL_PATH:-}"
echo "which cs_python \$(which cs_python)"
echo "CS_IP_ADDR \${CS_IP_ADDR}"

echo "ASYNC_GA_NCOL_SUBGRID ${ASYNC_GA_NCOL_SUBGRID}"
echo "ASYNC_GA_NROW_SUBGRID ${ASYNC_GA_NROW_SUBGRID}"
echo "ASYNC_GA_MSEC_AT_LEAST ${ASYNC_GA_MSEC_AT_LEAST}"
echo "ASYNC_GA_NCYCLE_AT_LEAST ${ASYNC_GA_NCYCLE_AT_LEAST}"
echo "ASYNC_GA_GLOBAL_SEED ${ASYNC_GA_GLOBAL_SEED}"
echo "NREP ${NREP}"
echo "WSE_SKETCHES_REVISION ${WSE_SKETCHES_REVISION}"

export CS_PYTHON="${CS_PYTHON:-cs_python}"
echo "CS_PYTHON \${CS_PYTHON}"
export ASYNC_GA_GENOME_FLAVOR="${ASYNC_GA_GENOME_FLAVOR}"
echo "ASYNC_GA_GENOME_FLAVOR \${ASYNC_GA_GENOME_FLAVOR}"
export ASYNC_GA_NWAV="${ASYNC_GA_NWAV}"
echo "ASYNC_GA_NWAV \${ASYNC_GA_NWAV}"
export ASYNC_GA_NTRAIT="${ASYNC_GA_NTRAIT}"
echo "ASYNC_GA_NTRAIT \${ASYNC_GA_NTRAIT}"
export ASYNC_GA_EXECUTE_FLAGS="--cmaddr \${CS_IP_ADDR}:9000 --no-suptrace"
echo "ASYNC_GA_EXECUTE_FLAGS \${ASYNC_GA_EXECUTE_FLAGS}"

echo "setup WORKDIR ----------------------------------------------------------"
cd "${WORKDIR}"
echo "PWD \${PWD}"

echo "execute kernel program -------------------------------------------------"
./${SLUG}/kernel-async-ga/execute.sh
# clean up and save space
find "${SLUG}" -name "*.elf" -type f -exec rm {} +
find "${SLUG}" -name "*.conf" -type f -exec rm {} +

echo "finalization telemetry -------------------------------------------------"
echo "SECONDS \${SECONDS}"
echo ">>>fin<<<"

EOF
###############################################################################
# ----------------------------------------------------------------------------#
###############################################################################


echo "do kernel compile and submit sbatch file ==============================="
./kernel-async-ga/compile.sh
sbatch "${SBATCH_FILE}"

echo "end work loop =========================================================="
done
done

echo "wait ==================================================================="
wait

echo "finalization telemetry ================================================="
echo "SECONDS ${SECONDS}"
echo ">>>fin<<<"
