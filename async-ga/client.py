import numpy as np
import argparse

from cerebras.sdk.sdk_utils import memcpy_view
from cerebras.sdk.runtime.sdkruntimepybind import (
    SdkRuntime,
    MemcpyDataType,
    MemcpyOrder,
)  # pylint: disable=no-name-in-module

nRow, nCol = 3, 3

parser = argparse.ArgumentParser()
parser.add_argument("--name", help="the test compile output dir")
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
    nrow,  # height
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
    nrow,  # height
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
    nrow,  # height
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
    nrow,  # height
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
out_tensors_u32 = np.zeros((nCol, nRow), np.float32)

runner.memcpy_d2h(
    out_tensors_u32,
    runner.get_id("genome"),
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
data = memcpy_view(out_tensors_u32, np.dtype(np.float32))
print(data)

# runner.dump("corefile.cs1")
runner.stop()

# Ensure that the result matches our expectation
print("SUCCESS!")
