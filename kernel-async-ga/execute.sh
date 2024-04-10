#!/bin/bash

set -e

cd "$(dirname "$0")"

echo "CS_PYTHON ${CS_PYTHON}"
echo "ASYNC_GA_GENOME_FLAVOR ${ASYNC_GA_GENOME_FLAVOR}"
echo "ASYNC_GA_EXECUTE_FLAGS ${ASYNC_GA_EXECUTE_FLAGS:-}"

"${CS_PYTHON}" client.py --genomeFlavor "${ASYNC_GA_GENOME_FLAVOR}" ${ASYNC_GA_EXECUTE_FLAGS:-}
