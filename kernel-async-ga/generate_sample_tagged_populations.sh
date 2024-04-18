#!/bin/bash

set -e

cd "$(dirname "$0")"

export ASYNC_GA_GENOME_FLAVOR="genome_hsurftiltedsticky_tagged"
echo "ASYNC_GA_GENOME_FLAVOR ${ASYNC_GA_GENOME_FLAVOR}"
for cmd in "export ASYNC_GA_GLOBAL_SEED=1 ASYNC_GA_NCYCLE_AT_LEAST=25" \
          "export ASYNC_GA_GLOBAL_SEED=2 ASYNC_GA_NCYCLE_AT_LEAST=50" \
          "export ASYNC_GA_GLOBAL_SEED=3 ASYNC_GA_NCYCLE_AT_LEAST=100" \
        ; do
          # "export ASYNC_GA_GLOBAL_SEED=5 ASYNC_GA_NCYCLE_AT_LEAST=250" \
  eval $cmd
  echo "ASYNC_GA_GLOBAL_SEED ${ASYNC_GA_GLOBAL_SEED}"
  echo "ASYNC_GA_NCYCLE_AT_LEAST ${ASYNC_GA_NCYCLE_AT_LEAST}"
  ./compile.sh
  ./execute.sh

done

find a=genomes+flavor=${ASYNC_GA_GENOME_FLAVOR}+*.csv \
  | python3 -m joinem "a=concatenated_genomes+flavor=${ASYNC_GA_GENOME_FLAVOR}+ext=.csv"
