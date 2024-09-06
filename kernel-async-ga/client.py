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
nColSubgrid = int(compile_data["params"]["nColSubgrid"])
nRowSubgrid = int(compile_data["params"]["nRowSubgrid"])
tilePopSize = int(compile_data["params"]["popSize"])
tournSize = (
    float(compile_data["params"]["tournSizeNumerator"])
    / float(compile_data["params"]["tournSizeDenominator"])
)
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
    "nColSubgrid": nColSubgrid,
    "nRowSubgrid": nRowSubgrid,
    "tilePopSize": tilePopSize,
    "tournSize": tournSize,
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
    out_tensors_u32.ravel(),
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
whoami_data = out_tensors_u32.copy()
print(whoami_data[:20,:20])

print("whereami x ===========================================================")
memcpy_dtype = MemcpyDataType.MEMCPY_32BIT
out_tensors_u32 = np.zeros((nCol, nRow), np.uint32)

runner.memcpy_d2h(
    out_tensors_u32.ravel(),
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
whereami_x_data = out_tensors_u32.copy()
print(whereami_x_data[:20,:20])

print("whereami y ===========================================================")
memcpy_dtype = MemcpyDataType.MEMCPY_32BIT
out_tensors_u32 = np.zeros((nCol, nRow), np.uint32)

runner.memcpy_d2h(
    out_tensors_u32.ravel(),
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
whereami_y_data = out_tensors_u32.copy()
print(whereami_y_data[:20,:20])


print("cycle counter =======================================================")
memcpy_dtype = MemcpyDataType.MEMCPY_32BIT
out_tensors_u32 = np.zeros((nCol, nRow), np.uint32)

runner.memcpy_d2h(
    out_tensors_u32.ravel(),
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
cycle_counts = out_tensors_u32.flat.copy()
print(cycle_counts[:100])


print("recv counter N ========================================================")
memcpy_dtype = MemcpyDataType.MEMCPY_32BIT
out_tensors_u32 = np.zeros((nCol, nRow), np.uint32)

runner.memcpy_d2h(
    out_tensors_u32.ravel(),
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
recvN = out_tensors_u32.copy()
print(recvN[:20,:20])

print("recv counter S ========================================================")
memcpy_dtype = MemcpyDataType.MEMCPY_32BIT
out_tensors_u32 = np.zeros((nCol, nRow), np.uint32)

runner.memcpy_d2h(
    out_tensors_u32.ravel(),
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
recvS = out_tensors_u32.copy()
print(recvS[:20,:20])

print("recv counter E ========================================================")
memcpy_dtype = MemcpyDataType.MEMCPY_32BIT
out_tensors_u32 = np.zeros((nCol, nRow), np.uint32)

runner.memcpy_d2h(
    out_tensors_u32.ravel(),
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
recvE = out_tensors_u32.copy()
print(recvE[:20,:20])

print("recv counter W ========================================================")
memcpy_dtype = MemcpyDataType.MEMCPY_32BIT
out_tensors_u32 = np.zeros((nCol, nRow), np.uint32)

runner.memcpy_d2h(
    out_tensors_u32.ravel(),
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
recvW = out_tensors_u32.copy()
print(recvW[:20,:20])

print("recv counter sum =====================================================")
recvSum = [*map(sum, zip(recvN.flat, recvS.flat, recvE.flat, recvW.flat))]
print(recvSum[:100])
print(f"{np.mean(recvSum)=} {np.std(recvSum)=} {sps.sem(recvSum)=}")

print("send counter N ========================================================")
memcpy_dtype = MemcpyDataType.MEMCPY_32BIT
out_tensors_u32 = np.zeros((nCol, nRow), np.uint32)

runner.memcpy_d2h(
    out_tensors_u32.ravel(),
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
sendN = out_tensors_u32.copy()
print(sendN[:20,:20])

print("send counter S ========================================================")
memcpy_dtype = MemcpyDataType.MEMCPY_32BIT
out_tensors_u32 = np.zeros((nCol, nRow), np.uint32)

runner.memcpy_d2h(
    out_tensors_u32.ravel(),
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
sendS = out_tensors_u32.copy()
print(sendS[:20,:20])

print("send counter E ========================================================")
memcpy_dtype = MemcpyDataType.MEMCPY_32BIT
out_tensors_u32 = np.zeros((nCol, nRow), np.uint32)

runner.memcpy_d2h(
    out_tensors_u32.ravel(),
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
sendE = out_tensors_u32.copy()
print(sendE[:20,:20])

print("send counter W ========================================================")
memcpy_dtype = MemcpyDataType.MEMCPY_32BIT
out_tensors_u32 = np.zeros((nCol, nRow), np.uint32)

runner.memcpy_d2h(
    out_tensors_u32.ravel(),
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
sendW = out_tensors_u32.copy()
print(sendW[:20,:20])

print("send counter sum =====================================================")
sendSum = [*map(sum, zip(sendN.flat, sendS.flat, sendE.flat, sendW.flat))]
print(sendSum[:100])
print(f"{np.mean(sendSum)=} {np.std(sendSum)=} {sps.sem(sendSum)=}")

print("tscControl values ====================================================")
memcpy_dtype = MemcpyDataType.MEMCPY_32BIT
out_tensors_u32 = np.zeros((nCol, nRow, tscSizeWords // 2), np.uint32)

runner.memcpy_d2h(
    out_tensors_u32.ravel(),
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
data = out_tensors_u32
tscControl_bytes = [
    inner.view(np.uint8).tobytes() for outer in data for inner in outer
]
tscControl_ints = [
    int.from_bytes(genome, byteorder="little") for genome in tscControl_bytes
]
print(tscControl_ints[:100])

print("tscStart values ======================================================")
memcpy_dtype = MemcpyDataType.MEMCPY_32BIT
out_tensors_u32 = np.zeros((nCol, nRow, tscSizeWords // 2), np.uint32)

runner.memcpy_d2h(
    out_tensors_u32.ravel(),
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
data = out_tensors_u32
tscStart_bytes = [
    inner.view(np.uint8).tobytes() for outer in data for inner in outer
]
tscStart_ints = [
    int.from_bytes(genome, byteorder="little") for genome in tscStart_bytes
]
print(tscStart_ints[:100])

print("tscEnd values ========================================================")
memcpy_dtype = MemcpyDataType.MEMCPY_32BIT
out_tensors_u32 = np.zeros((nCol, nRow, tscSizeWords // 2), np.uint32)

runner.memcpy_d2h(
    out_tensors_u32.ravel(),
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
data = out_tensors_u32
tscEnd_bytes = [
    inner.view(np.uint8).tobytes() for outer in data for inner in outer
]
tscEnd_ints = [
    int.from_bytes(genome, byteorder="little") for genome in tscEnd_bytes
]
print(tscEnd_ints[:100])

print("tsc diffs ============================================================")
print("--------------------------------------------------------------- ticks")
tsc_ticks = [end - start for start, end in zip(tscStart_ints, tscEnd_ints)]
print(tsc_ticks[:100])
print(f"{np.mean(tsc_ticks)=} {np.std(tsc_ticks)=} {sps.sem(tsc_ticks)=}")

print("-------------------------------------------------------------- seconds")
tsc_sec = [diff / tscTicksPerSecond for diff in tsc_ticks]
print(tsc_sec[:100])
print(f"{np.mean(tsc_sec)=} {np.std(tsc_sec)=} {sps.sem(tsc_sec)=}")

print("---------------------------------------------------- seconds per cycle")
tsc_cysec = [sec / ncy for (sec, ncy) in zip(tsc_sec, cycle_counts)]
print(tsc_cysec[:100])
print(f"{np.mean(tsc_cysec)=} {np.std(tsc_cysec)=} {sps.sem(tsc_cysec)=}")

print("---------------------------------------------------------- cycle hertz")
tsc_cyhz = [1 / cysec for cysec in tsc_cysec]
print(tsc_cyhz[:100])
print(f"{np.mean(tsc_cyhz)=} {np.std(tsc_cyhz)=} {sps.sem(tsc_cyhz)=}")

print("--------------------------------------------------------- ns per cycle")
tsc_cyns = [cysec * 1e9 for cysec in tsc_cysec]
print(tsc_cyns[:100])
print(f"{np.mean(tsc_cyns)=} {np.std(tsc_cyns)=} {sps.sem(tsc_cyns)=}")

print("perf ================================================================")
# save performance metrics to a file
df = pd.DataFrame(
    {
        "tsc ticks": tsc_ticks,
        "tsc seconds": tsc_sec,
        "tsc seconds per cycle": tsc_cysec,
        "tsc cycle hertz": tsc_cyhz,
        "tsc ns per cycle": tsc_cyns,
        "recv sum": recvSum,
        "send sum": sendSum,
        "cycle count": cycle_counts,
        "tsc start": tscStart_ints,
        "tsc end": tscEnd_ints,
        "send N": sendN.flat,
        "send S": sendS.flat,
        "send E": sendE.flat,
        "send W": sendW.flat,
        "recv N": recvN.flat,
        "recv S": recvS.flat,
        "recv E": recvE.flat,
        "recv W": recvW.flat,
        "tile": whoami_data.flat,
        "row": whereami_y_data.flat,
        "col": whereami_x_data.flat,
        **metadata,
    },
)
df.to_csv(
    "a=perf"
    f"+flavor={genomeFlavor}"
    f"+seed={globalSeed}"
    f"+ncycle={nCycleAtLeast}"
    "+ext=.csv.gz",
    compression="gzip",
    index=False,
)

print("fitness =============================================================")
memcpy_dtype = MemcpyDataType.MEMCPY_32BIT
out_tensors_f32 = np.zeros((nCol, nRow), np.float32)

runner.memcpy_d2h(
    out_tensors_f32.ravel(),
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
data = out_tensors_f32.copy()
print(data[:20,:20])

print("trait data ===========================================================")
memcpy_dtype = MemcpyDataType.MEMCPY_32BIT
out_tensors_u32 = np.zeros((nCol, nRow, nTrait), np.uint32)
runner.memcpy_d2h(
    out_tensors_u32.ravel(),
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
traitCounts_data = out_tensors_u32.copy()
print("traitCounts_data", Counter(traitCounts_data.flat))

memcpy_dtype = MemcpyDataType.MEMCPY_32BIT
out_tensors_u32 = np.zeros((nCol, nRow, nTrait), np.uint32)
runner.memcpy_d2h(
    out_tensors_u32.ravel(),
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
traitCycles_data = out_tensors_u32.copy()
print("traitCycles_data", Counter(traitCycles_data.flat))

memcpy_dtype = MemcpyDataType.MEMCPY_32BIT
out_tensors_u32 = np.zeros((nCol, nRow, nTrait), np.uint32)
runner.memcpy_d2h(
    out_tensors_u32.ravel(),
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
traitValues_data = out_tensors_u32.copy()
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

for trait, group in df.groupby("trait value"):
    print(
        f"trait {trait} total count is",
        group["trait count"].sum()
    )

df.to_csv(
    "a=traits"
    f"+flavor={genomeFlavor}"
    f"+seed={globalSeed}"
    f"+ncycle={nCycleAtLeast}"
    "+ext=.csv.gz",
    compression="gzip",
    index=False,
)

print("genome values ========================================================")
memcpy_dtype = MemcpyDataType.MEMCPY_32BIT
out_tensors_u32 = np.zeros((nCol, nRow, nWav), np.uint32)

runner.memcpy_d2h(
    out_tensors_u32.ravel(),
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
data = out_tensors_u32
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
    print([inner[word] for outer in data for inner in outer][:100])

print("------------------------------------------------ genome binary strings")
for genome_int in genome_ints[:100]:
    print(np.binary_repr(genome_int, width=nWav * wavSize))

print("--------------------------------------------------- genome hex strings")
for genome_int in genome_ints[:100]:
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
    "+ext=.csv.gz",
    compression="gzip",
    index=False,
)

# runner.dump("corefile.cs1")
runner.stop()

# Ensure that the result matches our expectation
print("SUCCESS!")
