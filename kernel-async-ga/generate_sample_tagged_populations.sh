#!/bin/bash

set -e

cd "$(dirname "$0")"

export ASYNC_GA_GENOME_FLAVOR="genome_hsurftiltedsticky_tagged"
export ASYNC_GA_NCOL=3
export ASYNC_GA_NCOL_SUBGRID=2
export ASYNC_GA_NROW=3
export ASYNC_GA_NROW_SUBGRID=4  # should have no effect
echo "ASYNC_GA_GENOME_FLAVOR ${ASYNC_GA_GENOME_FLAVOR}"
for cmd in "export ASYNC_GA_GLOBAL_SEED=1 ASYNC_GA_NCYCLE_AT_LEAST=25" \
          "export ASYNC_GA_GLOBAL_SEED=2 ASYNC_GA_NCYCLE_AT_LEAST=50" \
          "export ASYNC_GA_GLOBAL_SEED=3 ASYNC_GA_NCYCLE_AT_LEAST=100" \
          "export ASYNC_GA_GLOBAL_SEED=4 ASYNC_GA_NCYCLE_AT_LEAST=250" \
        ; do
  eval $cmd
  echo "ASYNC_GA_GLOBAL_SEED ${ASYNC_GA_GLOBAL_SEED}"
  echo "ASYNC_GA_NCYCLE_AT_LEAST ${ASYNC_GA_NCYCLE_AT_LEAST}"
  ./compile.sh
  ./execute.sh

done

find a=genomes+flavor=${ASYNC_GA_GENOME_FLAVOR}+*.csv \
  | python3 -m joinem "a=concatenated_genomes+flavor=${ASYNC_GA_GENOME_FLAVOR}+ext=.csv"
