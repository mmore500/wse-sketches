import numpy as np
import argparse

from cerebras.sdk.sdk_utils import memcpy_view
from cerebras.sdk.runtime.sdkruntimepybind import (
    SdkRuntime,
    MemcpyDataType,
    MemcpyOrder,
)

nRow, nCol, nWav = 5, 4, 3  # number of rows, columns, and genome words
wavSize = 32  # number of bits in a wavelet

parser = argparse.ArgumentParser()
parser.add_argument("--name", help="the test compile output dir")
parser.add_argument("--cmaddr", help="IP:port for CS system")
args = parser.parse_args()

runner = SdkRuntime("out", cmaddr=args.cmaddr, suppress_simfab_trace=True)

runner.load()
runner.run()
runner.launch("dolaunch", nonblock=False)

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

assert len(genome_ints) == nRow * nCol
sentry_bit = 1 << (nWav * wavSize)
for genome_int in genome_ints:
    print(bin(genome_int | sentry_bit))


genome_hexstrings = [
    np.base_repr(genome_int, base=16).zfill(nWav * wavSize // 4)
    for genome_int in genome_ints
]
for genome_hexstring in genome_hexstrings:
    assert len(genome_hexstring) == nWav * wavSize // 4

    word1_hexstring = genome_hexstring[0:8]
    word1 = int.from_bytes(bytes.fromhex(word1_hexstring), byteorder="little")
    assert word1 == 4294901760

    word2_hexstring = genome_hexstring[8:16]
    word2 = int.from_bytes(bytes.fromhex(word2_hexstring), byteorder="little")
    assert word2 == 4042322160

word3_hexstrings = map(lambda x: x[16:24], genome_hexstrings)
assert len(set(word3_hexstrings)) == nRow * nCol

runner.stop()

# Ensure that the result matches our expectation
print("SUCCESS!")
