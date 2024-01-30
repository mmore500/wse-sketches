#!/usr/bin/bash

set -e
shopt -s globstar

cd "$(dirname "$0")" || exit 1

printf "fmt "
zig fmt --check src/**/*.zig && echo "ok" || exit 1

for f in src/**/*.zig; do
    printf "${f} "
    zig test "${f}"
done
