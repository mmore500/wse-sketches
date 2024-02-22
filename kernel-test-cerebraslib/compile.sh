#!/bin/bash

set -e

cd "$(dirname "$0")"

echo "CSLC ${CSLC}"

# symlinks don't work and --import-path doesn't work, so this is a workaround
trap "git checkout ./cerebraslib" EXIT
rsync -rI "$(readlink -f cerebraslib)" .

# remove any old output
rm -rf out*

# target a 1x1 region of interest
# Every program using memcpy must use a fabric offset of 4,1, and if compiling
# for a simulated fabric, must use a fabric dimension of at least
# width+7,height+1, where width and height are the dimensions of the program.
# These additional PEs are used by memcpy to route data on and off the wafer.
# see https://sdk.cerebras.net/csl/tutorials/gemv-01-complete-program/
# 9x4 because compiler says
# RuntimeError: Fabric dimension must be at least 9-by-4
test_module_paths="$(ls cerebraslib/test_*.csl)"
num_tests="$(echo "${test_module_paths}" | wc -l)"
echo "${num_tests} tests detected"

MAX_PROCESSES=$([ -n "$CI" ] && echo 2 || echo 4)
echo "Compiling ${num_tests} tests with up to ${MAX_PROCESSES} processes"

for test_module_path in ${test_module_paths} END; do
    if [ "${test_module_path}" = "END" ]; then
        wait
    else
        cp "${test_module_path}" "cerebraslib/current_compilation_target.csl"
        test_basename="$(basename -- "${test_module_path}")"
        test_name="${test_basename%.csl}"
          while [ "$(jobs -r | wc -l)" -ge "$MAX_PROCESSES" ]; do
            wait -n
        done
        "${CSLC}" layout.csl --fabric-dims=9,4 --fabric-offsets=4,1 --channels=1 --memcpy -o "out_${test_name}" --verbose >/dev/null 2>&1 &
        echo "${test_module_path}"
    fi
done | python3 -m tqdm --total "${num_tests}" --unit test --unit_scale --desc "Compiling"
