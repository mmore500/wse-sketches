#!/bin/bash

set -e

echo "CSLC ${CSLC}"

"${CSLC}" kernel.csl --fabric-dims=2,2 --fabric-offsets=0,0 -o out
