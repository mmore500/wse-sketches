#!/usr/bin/bash

set -e

cd "$(dirname "$0")" || exit 1

python3 -m pytest test/
