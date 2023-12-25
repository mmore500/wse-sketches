import numpy as np
import argparse

from cerebras.sdk.sdk_utils import memcpy_view
from cerebras.sdk.runtime.sdkruntimepybind import (
    SdkRuntime,
    MemcpyDataType,
    MemcpyOrder,
)  # pylint: disable=no-name-in-module

parser = argparse.ArgumentParser()
parser.add_argument("--name", help="the test compile output dir")
parser.add_argument("--cmaddr", help="IP:port for CS system")
args = parser.parse_args()

# Simulate ELF file and produce the simulation output
runner = SdkRuntime("out", cmaddr=args.cmaddr)

runner.load()
runner.run()
runner.launch("dolaunch", nonblock=False)

memcpy_dtype = MemcpyDataType.MEMCPY_16BIT
out_tensors_u32 = np.zeros((2, 2), np.uint32)
runner.memcpy_d2h(
    out_tensors_u32,
    runner.get_id("counter"),
    0,  # x0
    0,  # y0
    2,  # width
    2,  # height
    1,  # num wavelets
    streaming=False,
    data_type=memcpy_dtype,
    order=MemcpyOrder.COL_MAJOR,
    nonblock=False,
)
data = memcpy_view(out_tensors_u32, np.dtype(np.uint16))

runner.stop()

# Ensure that the result matches our expectation
print(data)
print("SUCCESS!")
