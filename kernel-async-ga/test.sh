#!/bin/bash

set -e

cd "$(dirname "$0")"

for cmd in "export ASYNC_GA_GLOBAL_SEED=1 ASYNC_GA_NCYCLE=20" \
          "export ASYNC_GA_GLOBAL_SEED=2 ASYNC_GA_NCYCLE=50" \
          "export ASYNC_GA_GLOBAL_SEED=3 ASYNC_GA_NCYCLE=100" \
          "export ASYNC_GA_GLOBAL_SEED=4 ASYNC_GA_NCYCLE=200"; do
  eval $cmd
  echo $ASYNC_GA_GLOBAL_SEED $ASYNC_GA_NCYCLE
  "./compile.sh"
  "./execute.sh"

done

find genomes*.csv | python3 -m joinem concatenated_genomes.csv
