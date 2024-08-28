print("kernel-async-ga/client.py ############################################")
print("######################################################################")
import argparse
from collections import Counter
import json
import os
import uuid

import numpy as np
import pandas as pd
from scipy import stats as sps

from cerebras.sdk.sdk_utils import memcpy_view
from cerebras.sdk.runtime.sdkruntimepybind import (
    SdkRuntime,
    MemcpyDataType,
    MemcpyOrder,
)  # pylint: disable=no-name-in-module


# adapted from https://stackoverflow.com/a/31347222/17332200
def add_bool_arg(parser, name, default=False):
    group = parser.add_mutually_exclusive_group(required=False)
    group.add_argument("--" + name, dest=name, action="store_true")
    group.add_argument("--no-" + name, dest=name, action="store_false")
    parser.set_defaults(**{name: default})


# number of rows, columns, and genome words
nCol = int(os.getenv("ASYNC_GA_NCOL", 3))
nRow = int(os.getenv("ASYNC_GA_NROW", 3))
nWav = int(os.getenv("ASYNC_GA_NWAV", 4))
nTrait = int(os.getenv("ASYNC_GA_NTRAIT", 1))
print(f"{nCol=}, {nRow=}, {nWav=}, {nTrait=}")

wavSize = 32  # number of bits in a wavelet
tscSizeWords = 3  # number of 16-bit values in 48-bit timestamp values
tscSizeWords += tscSizeWords % 2  # make even multiple of 32-bit words
tscTicksPerSecond = 850 * 10**6  # 850 MHz

parser = argparse.ArgumentParser()
parser.add_argument("--name", help="the test compile output dir", default="out")
add_bool_arg(parser, "suptrace", default=True)
parser.add_argument("--cmaddr", help="IP:port for CS system")
parser.add_argument(
    "--genomeFlavor", help="specify what genome source is used", default=""
)
args = parser.parse_args()

print("args =================================================================")
print(args)

print("metadata =============================================================")
with open(f"{args.name}/out.json", encoding="utf-8") as json_file:
    compile_data = json.load(json_file)

globalSeed = int(compile_data["params"]["globalSeed"])
nCycleAtLeast = int(compile_data["params"]["nCycleAtLeast"])
msecAtLeast = int(compile_data["params"]["msecAtLeast"])
tscAtLeast = int(compile_data["params"]["tscAtLeast"])
genomeFlavor = args.genomeFlavor or "unknown"

# save genome values to a file
metadata = {
    "genomeFlavor": genomeFlavor,
    "globalSeed": globalSeed,
    "nCol": nCol,
    "nRow": nRow,
    "nWav": nWav,
    "nTrait": nTrait,
    "nCycle": nCycleAtLeast,
    "msec": msecAtLeast,
    "tsc": tscAtLeast,
    "replicate": str(uuid.uuid4()),
}
print(metadata)

print("do run ===============================================================")
# Path to ELF and simulation output files
runner = SdkRuntime(
    "out", cmaddr=args.cmaddr, suppress_simfab_trace=args.suptrace
)
print("- SdkRuntime created")

runner.load()
print("- runner loaded")

runner.run()
print("- runner run ran")

runner.launch("dolaunch", nonblock=False)
print("- runner launch unblocked")

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
whoami_data = memcpy_view(out_tensors_u32, np.dtype(np.uint32)).copy()
print(whoami_data)

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
whereami_x_data = memcpy_view(out_tensors_u32, np.dtype(np.uint32)).copy()
print(whereami_x_data)

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
whereami_y_data = memcpy_view(out_tensors_u32, np.dtype(np.uint32)).copy()
print(whereami_y_data)


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
data = memcpy_view(out_tensors_u32, np.dtype(np.uint32))
cycle_counts = data.flat
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
recvN = memcpy_view(out_tensors_u32, np.dtype(np.uint32))
print(recvN)

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
recvS = memcpy_view(out_tensors_u32, np.dtype(np.uint32))
print(recvS)

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
recvE = memcpy_view(out_tensors_u32, np.dtype(np.uint32))
print(recvE)

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
recvW = memcpy_view(out_tensors_u32, np.dtype(np.uint32))
print(recvW)

print("recv counter sum =====================================================")
recvSum = [*map(sum, zip(recvN.flat, recvS.flat, recvE.flat, recvW.flat))]
print(recvSum)
print(f"{np.mean(recvSum)=} {np.std(recvSum)=} {sps.sem(recvSum)=}")

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
sendN = memcpy_view(out_tensors_u32, np.dtype(np.uint32))
print(sendN)

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
sendS = memcpy_view(out_tensors_u32, np.dtype(np.uint32))
print(sendS)

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
sendE = memcpy_view(out_tensors_u32, np.dtype(np.uint32))
print(sendE)

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
sendW = memcpy_view(out_tensors_u32, np.dtype(np.uint32))
print(sendW)

print("send counter sum =====================================================")
sendSum = [*map(sum, zip(sendN.flat, sendS.flat, sendE.flat, sendW.flat))]
print(sendSum)
print(f"{np.mean(sendSum)=} {np.std(sendSum)=} {sps.sem(sendSum)=}")

print("tscControl values ====================================================")
memcpy_dtype = MemcpyDataType.MEMCPY_32BIT
out_tensors_u32 = np.zeros((nCol, nRow, tscSizeWords // 2), np.uint32)

runner.memcpy_d2h(
    out_tensors_u32,
    runner.get_id("tscControlBuffer"),
    0,  # x0
    0,  # y0
    nCol,  # width
    nRow,  # height
    tscSizeWords // 2,  # num values
    streaming=False,
    data_type=memcpy_dtype,
    order=MemcpyOrder.ROW_MAJOR,
    nonblock=False,
)
data = memcpy_view(out_tensors_u32, np.dtype(np.uint32))
tscControl_bytes = [
    inner.view(np.uint8).tobytes() for outer in data for inner in outer
]
tscControl_ints = [
    int.from_bytes(genome, byteorder="little") for genome in tscControl_bytes
]
print(tscControl_ints)

print("tscStart values ======================================================")
memcpy_dtype = MemcpyDataType.MEMCPY_32BIT
out_tensors_u32 = np.zeros((nCol, nRow, tscSizeWords // 2), np.uint32)

runner.memcpy_d2h(
    out_tensors_u32,
    runner.get_id("tscStartBuffer"),
    0,  # x0
    0,  # y0
    nCol,  # width
    nRow,  # height
    tscSizeWords // 2,  # num values
    streaming=False,
    data_type=memcpy_dtype,
    order=MemcpyOrder.ROW_MAJOR,
    nonblock=False,
)
data = memcpy_view(out_tensors_u32, np.dtype(np.uint32))
tscStart_bytes = [
    inner.view(np.uint8).tobytes() for outer in data for inner in outer
]
tscStart_ints = [
    int.from_bytes(genome, byteorder="little") for genome in tscStart_bytes
]
print(tscStart_ints)

print("tscEnd values ========================================================")
memcpy_dtype = MemcpyDataType.MEMCPY_32BIT
out_tensors_u32 = np.zeros((nCol, nRow, tscSizeWords // 2), np.uint32)

runner.memcpy_d2h(
    out_tensors_u32,
    runner.get_id("tscEndBuffer"),
    0,  # x0
    0,  # y0
    nCol,  # width
    nRow,  # height
    tscSizeWords // 2,  # num values
    streaming=False,
    data_type=memcpy_dtype,
    order=MemcpyOrder.ROW_MAJOR,
    nonblock=False,
)
data = memcpy_view(out_tensors_u32, np.dtype(np.uint32))
tscEnd_bytes = [
    inner.view(np.uint8).tobytes() for outer in data for inner in outer
]
tscEnd_ints = [
    int.from_bytes(genome, byteorder="little") for genome in tscEnd_bytes
]
print(tscEnd_ints)

print("tsc diffs ============================================================")
print("--------------------------------------------------------------- ticks")
tsc_ticks = [end - start for start, end in zip(tscStart_ints, tscEnd_ints)]
print(tsc_ticks)
print(f"{np.mean(tsc_ticks)=} {np.std(tsc_ticks)=} {sps.sem(tsc_ticks)=}")

print("-------------------------------------------------------------- seconds")
tsc_sec = [diff / tscTicksPerSecond for diff in tsc_ticks]
print(tsc_sec)
print(f"{np.mean(tsc_sec)=} {np.std(tsc_sec)=} {sps.sem(tsc_sec)=}")

print("---------------------------------------------------- seconds per cycle")
tsc_cysec = [sec / ncy for (sec, ncy) in zip(tsc_sec, cycle_counts)]
print(tsc_cysec)
print(f"{np.mean(tsc_cysec)=} {np.std(tsc_cysec)=} {sps.sem(tsc_cysec)=}")

print("---------------------------------------------------------- cycle hertz")
tsc_cyhz = [1 / cysec for cysec in tsc_cysec]
print(tsc_cyhz)
print(f"{np.mean(tsc_cyhz)=} {np.std(tsc_cyhz)=} {sps.sem(tsc_cyhz)=}")

print("--------------------------------------------------------- ns per cycle")
tsc_cyns = [cysec * 1e9 for cysec in tsc_cysec]
print(tsc_cyns)
print(f"{np.mean(tsc_cyns)=} {np.std(tsc_cyns)=} {sps.sem(tsc_cyns)=}")

print("fitness =============================================================")
memcpy_dtype = MemcpyDataType.MEMCPY_32BIT
out_tensors_f32 = np.zeros((nCol, nRow), np.float32)

runner.memcpy_d2h(
    out_tensors_f32,
    runner.get_id("fitness"),
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
data = memcpy_view(out_tensors_f32, np.dtype(np.float32))
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
genome_bytes = [
    inner.view(np.uint8).tobytes() for outer in data for inner in outer
]
genome_ints = [
    int.from_bytes(genome, byteorder="big") for genome in genome_bytes
]

# display genome values
assert len(genome_ints) == nRow * nCol
for word in range(nWav):
    print(f"---------------------------------------------- genome word {word}")
    print([inner[word] for outer in data for inner in outer])

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

# save genome values to a file
df = pd.DataFrame(
    {
        "bitfield": genome_hex,
        "tile": whoami_data.flat,
        "row": whereami_y_data.flat,
        "col": whereami_x_data.flat,
        **metadata,
    },
)
df.to_csv(
    "a=genomes"
    f"+flavor={genomeFlavor}"
    f"+seed={globalSeed}"
    f"+ncycle={nCycleAtLeast}"
    "+ext=.csv",
    index=False,
)

print("trait data ===========================================================")
memcpy_dtype = MemcpyDataType.MEMCPY_32BIT
out_tensors_u32 = np.zeros((nCol, nRow, nTrait), np.uint32)
runner.memcpy_d2h(
    out_tensors_u32,
    runner.get_id("traitCounts"),
    0,  # x0
    0,  # y0
    nCol,  # width
    nRow,  # height
    nTrait,  # num possible trait values
    streaming=False,
    data_type=memcpy_dtype,
    order=MemcpyOrder.ROW_MAJOR,
    nonblock=False,
)
traitCounts_data = memcpy_view(out_tensors_u32, np.dtype(np.uint32)).copy()
print("traitCounts_data", Counter(traitCounts_data.flat))

memcpy_dtype = MemcpyDataType.MEMCPY_32BIT
out_tensors_u32 = np.zeros((nCol, nRow, nTrait), np.uint32)
runner.memcpy_d2h(
    out_tensors_u32,
    runner.get_id("traitCycles"),
    0,  # x0
    0,  # y0
    nCol,  # width
    nRow,  # height
    nTrait,  # num possible trait values
    streaming=False,
    data_type=memcpy_dtype,
    order=MemcpyOrder.ROW_MAJOR,
    nonblock=False,
)
traitCycles_data = memcpy_view(out_tensors_u32, np.dtype(np.uint32)).copy()
print("traitCycles_data", Counter(traitCycles_data.flat))

memcpy_dtype = MemcpyDataType.MEMCPY_32BIT
out_tensors_u32 = np.zeros((nCol, nRow, nTrait), np.uint32)
runner.memcpy_d2h(
    out_tensors_u32,
    runner.get_id("traitValues"),
    0,  # x0
    0,  # y0
    nCol,  # width
    nRow,  # height
    nTrait,  # num possible trait values
    streaming=False,
    data_type=memcpy_dtype,
    order=MemcpyOrder.ROW_MAJOR,
    nonblock=False,
)
traitValues_data = memcpy_view(out_tensors_u32, np.dtype(np.uint32)).copy()
print("traitValues_data", Counter(traitValues_data.flat))

# save trait data values to a file
df = pd.DataFrame(
    {
        "trait count": traitCounts_data.flat,
        "trait cycle last seen": traitCycles_data.flat,
        "trait value": traitValues_data.flat,
        "tile": np.repeat(whoami_data.flat, nTrait),
        "row": np.repeat(whereami_y_data.flat, nTrait),
        "col": np.repeat(whereami_x_data.flat, nTrait),
        **metadata,
    },
)
df.to_csv(
    "a=traits"
    f"+flavor={genomeFlavor}"
    f"+seed={globalSeed}"
    f"+ncycle={nCycleAtLeast}"
    "+ext=.csv",
    index=False,
)

# runner.dump("corefile.cs1")
runner.stop()

# Ensure that the result matches our expectation
print("SUCCESS!")
