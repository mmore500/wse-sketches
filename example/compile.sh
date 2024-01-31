#!/bin/bash

set -e

cd "$(dirname "$0")"

echo "CSLC ${CSLC}"

"${CSLC}" layout.csl --fabric-dims=9,3 --fabric-offsets=4,1 --params=M:4,N:6 --memcpy --channels=1 -o out

