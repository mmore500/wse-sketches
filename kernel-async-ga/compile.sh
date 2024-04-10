#!/bin/bash

set -e

cd "$(dirname "$0")"

echo "CSLC ${CSLC}"

ASYNC_GA_GENOME_FLAVOR="${ASYNC_GA_GENOME_FLAVOR:-genome_bitdrift}"
echo "ASYNC_GA_GENOME_FLAVOR ${ASYNC_GA_GENOME_FLAVOR}"

ASYNC_GA_GLOBAL_SEED="${ASYNC_GA_GLOBAL_SEED:-0}"
echo "ASYNC_GA_GLOBAL_SEED ${ASYNC_GA_GLOBAL_SEED}"

ASYNC_GA_NCYCLE_AT_LEAST="${ASYNC_GA_NCYCLE_AT_LEAST:-40}"
echo "ASYNC_GA_NCYCLE_AT_LEAST ${ASYNC_GA_NCYCLE_AT_LEAST}"

ASYNC_GA_MSEC_AT_LEAST="${ASYNC_GA_MSEC_AT_LEAST:-0}"
echo "ASYNC_GA_MSEC_AT_LEAST ${ASYNC_GA_MSEC_AT_LEAST}"

ASYNC_GA_TSC_AT_LEAST="${ASYNC_GA_TSC_AT_LEAST:-0}"
echo "ASYNC_GA_TSC_AT_LEAST ${ASYNC_GA_TSC_AT_LEAST}"

ASYNC_GA_FABRIC_DIMS="${ASYNC_GA_FABRIC_DIMS:-10,5}"
echo "ASYNC_GA_FABRIC_DIMS ${ASYNC_GA_FABRIC_DIMS}"

ASYNC_GA_ARCH_FLAG="${ASYNC_GA_ARCH_FLAG:-}"
echo "ASYNC_GA_ARCH_FLAG ${ASYNC_GA_ARCH_FLAG}"

# symlinks don't work and --import-path doesn't work, so this is a workaround
trap "git checkout ./cerebraslib" EXIT
rsync -rI "$(readlink -f cerebraslib)" .
cp "cerebraslib/${ASYNC_GA_GENOME_FLAVOR}.csl" "cerebraslib/genome.csl"

# target a 2x2 region of interest
# Every program using memcpy must use a fabric offset of 4,1, and if compiling
# for a simulated fabric, must use a fabric dimension of at least
# width+7,height+1, where width and height are the dimensions of the program.
# These additional PEs are used by memcpy to route data on and off the wafer.
# see https://sdk.cerebras.net/csl/tutorials/gemv-01-complete-program/
# 9x4 because compiler says
# RuntimeError: Fabric dimension must be at least 9-by-4

"${CSLC}" layout.csl ${ASYNC_GA_ARCH_FLAG} --fabric-dims=${ASYNC_GA_FABRIC_DIMS} --fabric-offsets=4,1 --channels=1 --memcpy --params=globalSeed:${ASYNC_GA_GLOBAL_SEED},nCycleAtLeast:${ASYNC_GA_NCYCLE_AT_LEAST},msecAtLeast:${ASYNC_GA_MSEC_AT_LEAST},tscAtLeast:${ASYNC_GA_TSC_AT_LEAST} -o out
