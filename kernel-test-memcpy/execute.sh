#!/bin/bash

set -e

cd "$(dirname "$0")"

echo "CS_PYTHON ${CS_PYTHON}"

"${CS_PYTHON}" client.py
