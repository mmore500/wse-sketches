#!/bin/bash

set -e

cd "$(dirname "$0")"

"${CS_PYTHON}" client.py
