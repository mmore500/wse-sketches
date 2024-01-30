#!/bin/bash

set -e

cd "$(dirname "$0")" || exit 1

printf "fmt "
zig fmt --check src/*.zig && echo "ok" || exit 1

for f in src/main.zig src/test_*.zig; do
    printf "${f} "
    zig test "${f}"
done
