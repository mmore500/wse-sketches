#!/usr/bin/env python3
print("pyscript/hypermutator-denovo.py ######################################")
print("######################################################################")
from collections import Counter
import os
import uuid

# log environment variables
print("- log environment variables")
print(f"{os.environ['ASYNC_GA_NCOL']=}")
print(f"{os.environ['ASYNC_GA_NROW']=}")
print(f"{os.environ['ASYNC_GA_NCOL_SUBGRID']=}")
print(f"{os.environ['ASYNC_GA_NROW_SUBGRID']=}")
print(f"{os.environ['ASYNC_GA_MSEC_AT_LEAST']=}")
print(f"{os.environ['ASYNC_GA_TSC_AT_LEAST']=}")
print(f"{os.environ['ASYNC_GA_NCYCLE_AT_LEAST']=}")
print(f"{os.environ['ASYNC_GA_GLOBAL_SEED']=}")
print(f"{os.environ['ASYNC_GA_GENOME_FLAVOR']=}")
print(f"{os.environ['ASYNC_GA_POPSIZE']=}")
print(f"{os.environ['ASYNC_GA_TOURNSIZE_NUMERATOR']=}")
print(f"{os.environ['ASYNC_GA_TOURNSIZE_DENOMINATOR']=}")
print(f"{os.environ['NBEN']=}")


print("- importing third-party dependencies")
import numpy as np
print("  - numpy")
import polars as pl
print("  - polars")
from scipy import stats as sps
print("  - scipy")

print("- defining helper functions")
def write_parquet_verbose(df: pl.DataFrame, file_name: str) -> None:
    print(f"saving df to {file_name=}")
    print(f"- {df.shape=}")

    df.write_parquet(file_name, compression="lz4")
    print("- write_parquet complete")

    file_size_mb = os.path.getsize(file_name) / (1024 * 1024)
    print(f"- saved file size: {file_size_mb:.2f} MB")

    lazy_frame = pl.scan_parquet(file_name)
    print("- LazyFrame describe:")
    print(lazy_frame.describe())

    original_row_count = df.shape[0]
    lazy_row_count = lazy_frame.select(pl.count()).collect().item()
    assert lazy_row_count == original_row_count, (
        f"Row count mismatch between original and lazy frames: "
        f"{original_row_count=}, {lazy_row_count=}"
    )
    print("- verbose save complete!")

# adapted from https://stackoverflow.com/a/31347222/17332200
def add_bool_arg(parser, name, default=False):
    group = parser.add_mutually_exclusive_group(required=False)
    group.add_argument("--" + name, dest=name, action="store_true")
    group.add_argument("--no-" + name, dest=name, action="store_false")
    parser.set_defaults(**{name: default})

print("- reading env variables")
# number of rows, columns, and genome words
nCol = int(os.getenv("ASYNC_GA_NCOL", 3))
nRow = int(os.getenv("ASYNC_GA_NROW", 3))
nWav = int(os.getenv("ASYNC_GA_NWAV", 4))
nTrait = int(os.getenv("ASYNC_GA_NTRAIT", 1))
print(f"{nCol=}, {nRow=}, {nWav=}, {nTrait=}")

print("- setting global variables")
wavSize = 32  # number of bits in a wavelet
tscSizeWords = 3  # number of 16-bit values in 48-bit timestamp values
tscSizeWords += tscSizeWords % 2  # make even multiple of 32-bit words
tscTicksPerSecond = 850 * 10**6  # 850 MHz


print("metadata =============================================================")
globalSeed = int(os.environ["ASYNC_GA_GLOBAL_SEED"])
nCycleAtLeast = int(os.environ["ASYNC_GA_NCYCLE_AT_LEAST"])
msecAtLeast = int(os.environ["ASYNC_GA_MSEC_AT_LEAST"])
tscAtLeast = int(os.environ["ASYNC_GA_TSC_AT_LEAST"])
nColSubgrid = int(os.environ["ASYNC_GA_NCOL_SUBGRID"])
nRowSubgrid = int(os.environ["ASYNC_GA_NROW_SUBGRID"])
tilePopSize = int(os.environ["ASYNC_GA_POPSIZE"])
tournSize = (
    int(os.environ["ASYNC_GA_TOURNSIZE_NUMERATOR"])
    / int(os.environ["ASYNC_GA_TOURNSIZE_DENOMINATOR"])
)
genomeFlavor = os.environ["ASYNC_GA_GENOME_FLAVOR"]
nBen = int(os.environ["NBEN"])

# save genome values to a file
metadata = {
    "genomeFlavor": (genomeFlavor, pl.Categorical),
    "globalSeed": (globalSeed, pl.UInt32),
    "nCol": (nCol, pl.UInt16),
    "nRow": (nRow, pl.UInt16),
    "nWav": (nWav, pl.UInt8),
    "nTrait": (nTrait, pl.UInt8),
    "nCycle": (nCycleAtLeast, pl.UInt32),
    "nColSubgrid": (nColSubgrid, pl.UInt16),
    "nRowSubgrid": (nRowSubgrid, pl.UInt16),
    "tilePopSize": (tilePopSize, pl.UInt16),
    "tournSize": (tournSize, pl.Float32),
    "msec": (msecAtLeast, pl.Float32),
    "tsc": (tscAtLeast, pl.UInt64),
    "replicate": (str(uuid.uuid4()), pl.Categorical),
    "nBen": (nBen, pl.UInt8),
}
print(metadata)

print("do run ===============================================================")
from pylib._hypermutator_denovo import run
res = run(
    n_col=nCol,
    n_row=nRow,
    n_row_subgrid=nRowSubgrid,
    n_col_subgrid=nColSubgrid,
    tile_pop_size=tilePopSize,
    n_gen=nCycleAtLeast,
    seed=globalSeed,
    tourn_size=tournSize,
    n_ben=nBen,
)

print("whoami ===============================================================")
out_tensors = np.zeros((nCol, nRow), np.uint32)
whoami_data = out_tensors.copy()
whoami_data[:,:] = res["whoami"]
print(whoami_data[:20,:20])

print("whereami x ===========================================================")
out_tensors = np.zeros((nCol, nRow), np.uint32)
whereami_x_data = out_tensors.copy()
whereami_x_data[:,:] = res["whereami_x"]
print(whereami_x_data[:20,:20])

print("whereami y ===========================================================")
out_tensors = np.zeros((nCol, nRow), np.uint32)
whereami_y_data = out_tensors.copy()
whereami_y_data[:,:] = res["whereami_y"]
print(whereami_y_data[:20,:20])

print("trait data ===========================================================")
out_tensors = np.zeros((nCol, nRow, nTrait), np.uint32)
traitCounts_data = out_tensors.copy()
traitCounts_data[:,:,:] = res["trait_counts"]
print("traitCounts_data", Counter(traitCounts_data.ravel()))

out_tensors = np.zeros((nCol, nRow, nTrait), np.uint32)
traitCycles_data = out_tensors.copy()
traitCycles_data[:,:,:] = res["last_seen"]
print("traitCycles_data", Counter(traitCycles_data.ravel()))

out_tensors = np.zeros((nCol, nRow, nTrait), np.uint32)
traitValues_data = out_tensors.copy()
traitValues_data[:,:,:] = res["trait_values"]
print("traitValues_data", str(Counter(traitValues_data.ravel()))[:500])

# save trait data values to a file
df = pl.DataFrame({
    "trait count": pl.Series(traitCounts_data.ravel(), dtype=pl.UInt16),
    "trait cycle last seen": pl.Series(traitCycles_data.ravel(), dtype=pl.UInt32),
    "trait value": pl.Series(traitValues_data.ravel(), dtype=pl.UInt8),
    "tile": pl.Series(np.repeat(whoami_data.ravel(), nTrait), dtype=pl.UInt32),
    "row": pl.Series(np.repeat(whereami_y_data.ravel(), nTrait), dtype=pl.UInt16),
    "col": pl.Series(np.repeat(whereami_x_data.ravel(), nTrait), dtype=pl.UInt16),
}).with_columns([
    pl.lit(value, dtype=dtype).alias(key)
    for key, (value, dtype) in metadata.items()
])


for trait, group in df.group_by("trait value"):
    print(
        f"trait {trait} total count is",
        group["trait count"].sum()
    )

write_parquet_verbose(
    df,
    "a=traits"
    f"+flavor={genomeFlavor}"
    f"+seed={globalSeed}"
    f"+ncycle={nCycleAtLeast}"
    "+ext=.pqt",
)
del df, traitCounts_data, traitCycles_data, traitValues_data

print("fitness =============================================================")
out_tensors = np.zeros((nCol, nRow), np.float32)
fitness_data = out_tensors.copy()
fitness_data[:,:] = res["fitnesses"]
print(fitness_data[:20,:20])

print("genome values ========================================================")
out_tensors = np.zeros((nCol, nRow, nWav), np.uint32)
genome_data = out_tensors.copy()
genome_data[:,:,:] = res["genomes"]
genome_bytes = [
    inner.view(np.uint8).tobytes() for outer in genome_data for inner in outer
]
genome_ints = [
    int.from_bytes(genome, byteorder="big") for genome in genome_bytes
]

# display genome values
assert len(genome_ints) == nRow * nCol
for word in range(nWav):
    print(f"---------------------------------------------- genome word {word}")
    print([inner[word] for outer in genome_data for inner in outer][:100])

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
df = pl.DataFrame({
    "bitfield": pl.Series(genome_hex, dtype=pl.Utf8),
    "fitness": pl.Series(fitness_data.ravel(), dtype=pl.Float32),
    "tile": pl.Series(whoami_data.ravel(), dtype=pl.UInt32),
    "row": pl.Series(whereami_y_data.ravel(), dtype=pl.UInt16),
    "col": pl.Series(whereami_x_data.ravel(), dtype=pl.UInt16),
}).with_columns([
    pl.lit(value, dtype=dtype).alias(key)
    for key, (value, dtype) in metadata.items()
])

write_parquet_verbose(
    df,
    "a=genomes"
    f"+flavor={genomeFlavor}"
    f"+seed={globalSeed}"
    f"+ncycle={nCycleAtLeast}"
    "+ext=.pqt",
)
del df, fitness_data, genome_ints, genome_bytes, genome_hex

print("cycle counter =======================================================")
out_tensors = np.zeros((nCol, nRow), np.uint32)
# TODO
cycle_counts = out_tensors.ravel().copy()
print(cycle_counts[:100])


print("recv counter N ========================================================")
out_tensors = np.zeros((nCol, nRow), np.uint32)
recvN = out_tensors.copy()
print(recvN[:20,:20])

print("recv counter S ========================================================")
recvS = out_tensors.copy()
print(recvS[:20,:20])

print("recv counter E ========================================================")
out_tensors = np.zeros((nCol, nRow), np.uint32)
recvE = out_tensors.copy()
print(recvE[:20,:20])

print("recv counter W ========================================================")
out_tensors = np.zeros((nCol, nRow), np.uint32)
recvW = out_tensors.copy()
print(recvW[:20,:20])

print("recv counter sum =====================================================")
recvSum = [*map(sum, zip(recvN.ravel(), recvS.ravel(), recvE.ravel(), recvW.ravel()))]
print(recvSum[:100])
print(f"{np.mean(recvSum)=} {np.std(recvSum)=} {sps.sem(recvSum)=}")

print("send counter N ========================================================")
out_tensors = np.zeros((nCol, nRow), np.uint32)
sendN = out_tensors.copy()
print(sendN[:20,:20])

print("send counter S ========================================================")
out_tensors = np.zeros((nCol, nRow), np.uint32)
sendS = out_tensors.copy()
print(sendS[:20,:20])

print("send counter E ========================================================")
out_tensors = np.zeros((nCol, nRow), np.uint32)
sendE = out_tensors.copy()
print(sendE[:20,:20])

print("send counter W ========================================================")
out_tensors = np.zeros((nCol, nRow), np.uint32)
sendW = out_tensors.copy()
print(sendW[:20,:20])

print("send counter sum =====================================================")
sendSum = [*map(sum, zip(sendN.ravel(), sendS.ravel(), sendE.ravel(), sendW.ravel()))]
print(sendSum[:100])
print(f"{np.mean(sendSum)=} {np.std(sendSum)=} {sps.sem(sendSum)=}")

print("tscControl values ====================================================")
out_tensors = np.zeros((nCol, nRow, tscSizeWords // 2), np.uint32)
data = out_tensors
tscControl_bytes = [
    inner.view(np.uint8).tobytes() for outer in data for inner in outer
]
tscControl_ints = [
    int.from_bytes(genome, byteorder="little") for genome in tscControl_bytes
]
print(tscControl_ints[:100])

print("tscStart values ======================================================")
out_tensors = np.zeros((nCol, nRow, tscSizeWords // 2), np.uint32)
data = out_tensors
tscStart_bytes = [
    inner.view(np.uint8).tobytes() for outer in data for inner in outer
]
tscStart_ints = [
    int.from_bytes(genome, byteorder="little") for genome in tscStart_bytes
]
print(tscStart_ints[:100])

print("tscEnd values ========================================================")
out_tensors = np.zeros((nCol, nRow, tscSizeWords // 2), np.uint32)
data = out_tensors
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
tsc_sec = [res["elapsed_ns"] * (10 ** -9)] * (nRow * nCol)
print(tsc_sec[:100])
print(f"{np.mean(tsc_sec)=} {np.std(tsc_sec)=} {sps.sem(tsc_sec)=}")

print("---------------------------------------------------- seconds per cycle")
tsc_cysec = [sec / nCycleAtLeast for sec in tsc_sec]
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
df = pl.DataFrame({
    "tsc ticks": pl.Series(tsc_ticks, dtype=pl.UInt64),
    "tsc seconds": pl.Series(tsc_sec, dtype=pl.Float32),
    "tsc seconds per cycle": pl.Series(tsc_cysec, dtype=pl.Float32),
    "tsc cycle hertz": pl.Series(tsc_cyhz, dtype=pl.Float32),
    "tsc ns per cycle": pl.Series(tsc_cyns, dtype=pl.Float32),
    "recv sum": pl.Series(recvSum, dtype=pl.UInt32),
    "send sum": pl.Series(sendSum, dtype=pl.UInt32),
    "cycle count": pl.Series(cycle_counts, dtype=pl.UInt32),
    "tsc start": pl.Series(tscStart_ints, dtype=pl.UInt64),
    "tsc end": pl.Series(tscEnd_ints, dtype=pl.UInt64),
    "send N": pl.Series(sendN.ravel(), dtype=pl.UInt32),
    "send S": pl.Series(sendS.ravel(), dtype=pl.UInt32),
    "send E": pl.Series(sendE.ravel(), dtype=pl.UInt32),
    "send W": pl.Series(sendW.ravel(), dtype=pl.UInt32),
    "recv N": pl.Series(recvN.ravel(), dtype=pl.UInt32),
    "recv S": pl.Series(recvS.ravel(), dtype=pl.UInt32),
    "recv E": pl.Series(recvE.ravel(), dtype=pl.UInt32),
    "recv W": pl.Series(recvW.ravel(), dtype=pl.UInt32),
    "tile": pl.Series(whoami_data.ravel(), dtype=pl.UInt32),
    "row": pl.Series(whereami_y_data.ravel(), dtype=pl.UInt16),
    "col": pl.Series(whereami_x_data.ravel(), dtype=pl.UInt16),
})
df.with_columns([
    pl.lit(value, dtype=dtype).alias(key)
    for key, (value, dtype) in metadata.items()
])
write_parquet_verbose(
    df,
    "a=perf"
    f"+flavor={genomeFlavor}"
    f"+seed={globalSeed}"
    f"+ncycle={nCycleAtLeast}"
    "+ext=.pqt",
)
del df, tsc_ticks, tsc_sec, tsc_cysec, tsc_cyhz, tsc_cyns, tscStart_ints, tscEnd_ints

# Ensure that the result matches our expectation
print("SUCCESS!")
