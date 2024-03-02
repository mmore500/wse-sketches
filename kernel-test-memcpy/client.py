import numpy as np
import argparse
import pandas as pd

from cerebras.sdk.sdk_utils import memcpy_view
from cerebras.sdk.runtime.sdkruntimepybind import (
    SdkRuntime,
    MemcpyDataType,
    MemcpyOrder,
)

nRow, nCol, nWav = 3, 3, 3

parser = argparse.ArgumentParser()
parser.add_argument("--name", help="the test compile output dir")
parser.add_argument("--cmaddr", help="IP:port for CS system")
args = parser.parse_args()

runner = SdkRuntime("out", cmaddr=args.cmaddr, suppress_simfab_trace=True)

runner.load()
runner.run()
runner.launch("dolaunch", nonblock=False)

memcpy_dtype = MemcpyDataType.MEMCPY_32BIT
out_tensors_u32 = np.zeros((nCol, nRow, 3), np.uint32)

runner.memcpy_d2h(
    out_tensors_u32,
    runner.get_id("genome"),
    0,  # x0
    0,  # y0
    nCol,  # width
    nRow,  # height
    nWav,  # num wavelets
    streaming=False,
    data_type=memcpy_dtype,
    order=MemcpyOrder.ROW_MAJOR,
    nonblock=False,
)
data = memcpy_view(out_tensors_u32, np.dtype(np.uint32))

bin_data = [''.join(bin(data.byteswap().ravel()[i + j])[2:].zfill(32) for j in range(3))[16:] for i in range(0, 27, 3)] 
# bin_data = [''.join([bin(x)[2:].zfill(8) for x in data.ravel().view(np.uint8)][i:i+12])[16:] for i in range(0, 108, 12)] # alternative approach

new_data = [eval(f"0b{num}") for num in bin_data]

df = pd.DataFrame(new_data, columns=["bit_field"])
df.to_csv('out.csv', index=False)

runner.stop()

# Ensure that the result matches our expectation
print("SUCCESS!")
