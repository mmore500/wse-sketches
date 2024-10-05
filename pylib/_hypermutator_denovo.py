import datetime
import os
import sys

try:
    import cupy as xp
except ImportError:
    import numpy as xp
import pandas as pd
import tqdm as tq

print("date", datetime.datetime.now())
print("sys.version", sys.version)
print("numpy/cupy", xp.__version__)
print("pandas", pd.__version__)
print("tqdm", tq.__version__)


HOME = os.environ.get("HOME")
SLURM_ARRAY_JOB_ID = os.environ.get("SLURM_ARRAY_JOB_ID", "nojid")
SLURM_JOB_ID = os.environ.get("SLURM_JOB_ID", "nojid")
SLURM_ARRAY_TASK_ID = int(os.environ.get("SLURM_ARRAY_TASK_ID", "32"))

print("HOME={} SLURM_ARRAY_JOB_ID={}".format(HOME, SLURM_ARRAY_JOB_ID))
print(
    "SLURM_JOB_ID={} SLURM_ARRAY_TASK_ID={}".format(
        SLURM_JOB_ID, SLURM_ARRAY_TASK_ID
    )
)

def run():
    print("running")
    print("done")
