#!/bin/bash

set -e

cd "$(dirname "$0")"

export ASYNC_GA_GENOME_FLAVOR="genome_hsurftiltedsticky_tagged"
echo "ASYNC_GA_GENOME_FLAVOR ${ASYNC_GA_GENOME_FLAVOR}"
for cmd in "export ASYNC_GA_GLOBAL_SEED=1 ASYNC_GA_NCYCLE=20" \
          "export ASYNC_GA_GLOBAL_SEED=2 ASYNC_GA_NCYCLE=50" \
          "export ASYNC_GA_GLOBAL_SEED=3 ASYNC_GA_NCYCLE=100" \
          "export ASYNC_GA_GLOBAL_SEED=3 ASYNC_GA_NCYCLE=200" \
          "export ASYNC_GA_GLOBAL_SEED=4 ASYNC_GA_NCYCLE=500" \; do
  eval $cmd
  echo "ASYNC_GA_GLOBAL_SEED ${ASYNC_GA_GLOBAL_SEED}"
  echo "ASYNC_GA_NCYCLE ${ASYNC_GA_NCYCLE}"
  ./compile.sh
  ./execute.sh

done

find a=genomes+flavor=${ASYNC_GA_GENOME_FLAVOR}+*.csv \
  | python3 -m joinem "a=concatenated_genomes+flavor=${ASYNC_GA_GENOME_FLAVOR}+ext=.csv"
