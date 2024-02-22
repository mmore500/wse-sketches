#!/bin/bash

set -e

cd "$(dirname "$0")"

echo "CS_PYTHON ${CS_PYTHON}"

MAX_PROCESSES=1  # $([ -n "$CI" ] && echo 1 || echo 2)

# Find directories that match the pattern 'out*'
dir_list=$(find . -maxdepth 1 -type d -name 'out*')

# Check if the directory list is empty
if [ -z "$dir_list" ]; then
    echo "No tests found, did you run ./compile.sh?"
    exit 0
fi

# Count the number of directories to process
num_dirs=$(echo "$dir_list" | wc -l)
echo "${num_dirs} directories detected"

echo "Running ${num_dirs} tests with up to ${MAX_PROCESSES} parallel processes"

# set if not set to 0
export SINGULARITYENV_CSL_SUPPRESS_SIMFAB_TRACE=${SINGULARITYENV_CSL_SUPPRESS_SIMFAB_TRACE:-1}
echo "SINGULARITYENV_CSL_SUPPRESS_SIMFAB_TRACE ${SINGULARITYENV_CSL_SUPPRESS_SIMFAB_TRACE}"

for dir in $dir_list END; do
    if [ "$dir" = "END" ]; then
        wait
    else
        # Ensure the number of parallel jobs does not exceed MAX_PROCESSES
        while [ "$(jobs -r | wc -l)" -ge "$MAX_PROCESSES" ]; do
            wait -n
        done

        # Run the client.py script in the background for the current directory
        touch "${dir}.running"
        ("${CS_PYTHON}" client.py --name "${dir}" && rm -f "${dir}.running" || touch "${dir}.failed") >/dev/null 2>&1  # &

        # Print the directory name to stdout for tqdm to track progress
        echo "${dir}"
    fi
done | python3 -m tqdm --total "${num_dirs}" --unit test --unit_scale --desc "running tests"

echo "All tests processed."
