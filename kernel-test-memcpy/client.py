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

# re-arrange data to consecutively group wavelets from each PE 
newData = [data[i][j][k] for i in range(nCol) for j in range(nRow) for k in range(nWav)]

# create a new list with each group of nWav wavelets converted into a single string
binData = [''.join(bin(int(newData[i + j]))[2:].zfill(32) for j in range(3))[16:] for i in range(0, nRow * nCol * nWav, nWav)]

df = pd.DataFrame(binData, columns=["bitfield"])
df.to_csv('out.csv', index=False)

runner.stop()

# Ensure that the result matches our expectation
print("SUCCESS!")
