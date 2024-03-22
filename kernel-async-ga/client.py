import numpy as np
import argparse
import pandas as pd
import json
import uuid

from cerebras.sdk.sdk_utils import memcpy_view
from cerebras.sdk.runtime.sdkruntimepybind import (
    SdkRuntime,
    MemcpyDataType,
    MemcpyOrder,
)  # pylint: disable=no-name-in-module

nRow, nCol, nWav = 3, 3, 3  # number of rows, columns, and genome words
wavSize = 32  # number of bits in a wavelet

parser = argparse.ArgumentParser()
parser.add_argument("--name", help="the test compile output dir", default="out")
parser.add_argument("--cmaddr", help="IP:port for CS system")
args = parser.parse_args()

# Path to ELF and simulation output files
runner = SdkRuntime("out", cmaddr=args.cmaddr, suppress_simfab_trace=True)

runner.load()
runner.run()
runner.launch("dolaunch", nonblock=False)

print("whoami ===============================================================")
memcpy_dtype = MemcpyDataType.MEMCPY_32BIT
out_tensors_u32 = np.zeros((nCol, nRow), np.uint32)

runner.memcpy_d2h(
    out_tensors_u32,
    runner.get_id("whoami"),
    0,  # x0
    0,  # y0
    nCol,  # width
    nRow,  # height
    1,  # num wavelets
    streaming=False,
    data_type=memcpy_dtype,
    order=MemcpyOrder.ROW_MAJOR,
    nonblock=False,
)
data = memcpy_view(out_tensors_u32, np.dtype(np.int16))
print(data)

print("whereami x ===========================================================")
memcpy_dtype = MemcpyDataType.MEMCPY_32BIT
out_tensors_u32 = np.zeros((nCol, nRow), np.uint32)

runner.memcpy_d2h(
    out_tensors_u32,
    runner.get_id("whereami_x"),
    0,  # x0
    0,  # y0
    nCol,  # width
    nRow,  # height
    1,  # num wavelets
    streaming=False,
    data_type=memcpy_dtype,
    order=MemcpyOrder.ROW_MAJOR,
    nonblock=False,
)
data = memcpy_view(out_tensors_u32, np.dtype(np.int16))
print(data)

print("whereami y ===========================================================")
memcpy_dtype = MemcpyDataType.MEMCPY_32BIT
out_tensors_u32 = np.zeros((nCol, nRow), np.uint32)

runner.memcpy_d2h(
    out_tensors_u32,
    runner.get_id("whereami_y"),
    0,  # x0
    0,  # y0
    nCol,  # width
    nRow,  # height
    1,  # num wavelets
    streaming=False,
    data_type=memcpy_dtype,
    order=MemcpyOrder.ROW_MAJOR,
    nonblock=False,
)
data = memcpy_view(out_tensors_u32, np.dtype(np.int16))
print(data)


print("cycle counter =======================================================")
memcpy_dtype = MemcpyDataType.MEMCPY_32BIT
out_tensors_u32 = np.zeros((nCol, nRow), np.uint32)

runner.memcpy_d2h(
    out_tensors_u32,
    runner.get_id("cycleCounter"),
    0,  # x0
    0,  # y0
    nCol,  # width
    nRow,  # height
    1,  # num wavelets
    streaming=False,
    data_type=memcpy_dtype,
    order=MemcpyOrder.ROW_MAJOR,
    nonblock=False,
)
data = memcpy_view(out_tensors_u32, np.dtype(np.uint16))
print(data)


print("recv counter N ========================================================")
memcpy_dtype = MemcpyDataType.MEMCPY_32BIT
out_tensors_u32 = np.zeros((nCol, nRow), np.uint32)

runner.memcpy_d2h(
    out_tensors_u32,
    runner.get_id("recvCounter_N"),
    0,  # x0
    0,  # y0
    nCol,  # width
    nRow,  # height
    1,  # num wavelets
    streaming=False,
    data_type=memcpy_dtype,
    order=MemcpyOrder.ROW_MAJOR,
    nonblock=False,
)
data = memcpy_view(out_tensors_u32, np.dtype(np.uint16))
print(data)

print("recv counter S ========================================================")
memcpy_dtype = MemcpyDataType.MEMCPY_32BIT
out_tensors_u32 = np.zeros((nCol, nRow), np.uint32)

runner.memcpy_d2h(
    out_tensors_u32,
    runner.get_id("recvCounter_S"),
    0,  # x0
    0,  # y0
    nCol,  # width
    nRow,  # height
    1,  # num wavelets
    streaming=False,
    data_type=memcpy_dtype,
    order=MemcpyOrder.ROW_MAJOR,
    nonblock=False,
)
data = memcpy_view(out_tensors_u32, np.dtype(np.uint16))
print(data)

print("recv counter E ========================================================")
memcpy_dtype = MemcpyDataType.MEMCPY_32BIT
out_tensors_u32 = np.zeros((nCol, nRow), np.uint32)

runner.memcpy_d2h(
    out_tensors_u32,
    runner.get_id("recvCounter_E"),
    0,  # x0
    0,  # y0
    nCol,  # width
    nRow,  # height
    1,  # num wavelets
    streaming=False,
    data_type=memcpy_dtype,
    order=MemcpyOrder.ROW_MAJOR,
    nonblock=False,
)
data = memcpy_view(out_tensors_u32, np.dtype(np.uint16))
print(data)

print("recv counter W ========================================================")
memcpy_dtype = MemcpyDataType.MEMCPY_32BIT
out_tensors_u32 = np.zeros((nCol, nRow), np.uint32)

runner.memcpy_d2h(
    out_tensors_u32,
    runner.get_id("recvCounter_W"),
    0,  # x0
    0,  # y0
    nCol,  # width
    nRow,  # height
    1,  # num wavelets
    streaming=False,
    data_type=memcpy_dtype,
    order=MemcpyOrder.ROW_MAJOR,
    nonblock=False,
)
data = memcpy_view(out_tensors_u32, np.dtype(np.uint16))
print(data)

print("send counter N ========================================================")
memcpy_dtype = MemcpyDataType.MEMCPY_32BIT
out_tensors_u32 = np.zeros((nCol, nRow), np.uint32)

runner.memcpy_d2h(
    out_tensors_u32,
    runner.get_id("sendCounter_N"),
    0,  # x0
    0,  # y0
    nCol,  # width
    nRow,  # height
    1,  # num wavelets
    streaming=False,
    data_type=memcpy_dtype,
    order=MemcpyOrder.ROW_MAJOR,
    nonblock=False,
)
data = memcpy_view(out_tensors_u32, np.dtype(np.uint16))
print(data)

print("send counter S ========================================================")
memcpy_dtype = MemcpyDataType.MEMCPY_32BIT
out_tensors_u32 = np.zeros((nCol, nRow), np.uint32)

runner.memcpy_d2h(
    out_tensors_u32,
    runner.get_id("sendCounter_S"),
    0,  # x0
    0,  # y0
    nCol,  # width
    nRow,  # height
    1,  # num wavelets
    streaming=False,
    data_type=memcpy_dtype,
    order=MemcpyOrder.ROW_MAJOR,
    nonblock=False,
)
data = memcpy_view(out_tensors_u32, np.dtype(np.uint16))
print(data)

print("send counter E ========================================================")
memcpy_dtype = MemcpyDataType.MEMCPY_32BIT
out_tensors_u32 = np.zeros((nCol, nRow), np.uint32)

runner.memcpy_d2h(
    out_tensors_u32,
    runner.get_id("sendCounter_E"),
    0,  # x0
    0,  # y0
    nCol,  # width
    nRow,  # height
    1,  # num wavelets
    streaming=False,
    data_type=memcpy_dtype,
    order=MemcpyOrder.ROW_MAJOR,
    nonblock=False,
)
data = memcpy_view(out_tensors_u32, np.dtype(np.uint16))
print(data)

print("send counter W ========================================================")
memcpy_dtype = MemcpyDataType.MEMCPY_32BIT
out_tensors_u32 = np.zeros((nCol, nRow), np.uint32)

runner.memcpy_d2h(
    out_tensors_u32,
    runner.get_id("sendCounter_W"),
    0,  # x0
    0,  # y0
    nCol,  # width
    nRow,  # height
    1,  # num wavelets
    streaming=False,
    data_type=memcpy_dtype,
    order=MemcpyOrder.ROW_MAJOR,
    nonblock=False,
)
data = memcpy_view(out_tensors_u32, np.dtype(np.uint16))
print(data)

print("genome values ========================================================")
memcpy_dtype = MemcpyDataType.MEMCPY_32BIT
out_tensors_u32 = np.zeros((nCol, nRow, nWav), np.uint32)

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
genome_bytes = [inner.view(np.uint8).tobytes() for outer in data for inner in outer]
genome_ints = [int.from_bytes(genome, byteorder="big") for genome in genome_bytes]

# display genome values
assert len(genome_ints) == nRow * nCol
print("------------------------------------------------ genome binary strings")
for genome_int in genome_ints:
    print(np.binary_repr(genome_int, width=nWav * wavSize))

print("--------------------------------------------------- genome hex strings")
for genome_int in genome_ints:
    print(np.base_repr(genome_int, base=16).zfill(nWav * wavSize // 4))

# prevent polars from reading as int64 and overflowing
genome_hex = (
    np.base_repr(genome_int, base=16).zfill(nWav * wavSize // 4)
    for genome_int in genome_ints
)

with open(f"{args.name}/out.json", encoding="utf-8") as json_file:
    compile_data = json.load(json_file)

globalSeed = int(compile_data["params"]["globalSeed"])
nCycle = int(compile_data["params"]["nCycle"])

# save genome values to a file
df = pd.DataFrame(genome_hex, columns=["bitfield"])
df["globalSeed"] = globalSeed
df["nCycle"] = nCycle
df["replicate"] = str(uuid.uuid4())

df.to_csv(f"genomes_{globalSeed}_{nCycle}.csv", index=False)

# runner.dump("corefile.cs1")
runner.stop()

# Ensure that the result matches our expectation
print("SUCCESS!")
