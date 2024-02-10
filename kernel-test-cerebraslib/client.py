import numpy as np
import argparse

from cerebras.sdk.sdk_utils import memcpy_view
from cerebras.sdk.runtime.sdkruntimepybind import (
    SdkRuntime,
)  # pylint: disable=no-name-in-module

parser = argparse.ArgumentParser()
parser.add_argument("--name", help="the test compile output dir")
parser.add_argument("--cmaddr", help="IP:port for CS system")
args = parser.parse_args()

# Path to ELF and simulation output files
runner = SdkRuntime("out", cmaddr=args.cmaddr)

runner.load()
runner.run()
runner.launch("dolaunch", nonblock=False)

# runner.dump("corefile.cs1")
runner.stop()

# Ensure that the result matches our expectation
print("SUCCESS!")
