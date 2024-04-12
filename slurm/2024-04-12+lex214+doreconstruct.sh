#!/bin/bash
#SBATCH --ntasks=1
#SBATCH --mem=128G
#SBATCH --time=24:00:00
#SBATCH --cpus-per-task=54
#SBATCH --output="/jet/home/%u/joblog/id=%j+ext=.txt"

set -e

pwd
date

# module purge || :
# module load \
#   GCCcore/11.3.0 \
#   binutils/2.39 \
#   ccache/3.3.3 \
#   CMake/3.23.1 \
#   git/2.36.0-nodocs \
#   Python/3.10.4 \
#   || :
echo "loaded modules"

# rm -rf env
# python3 -m venv env
source env/bin/activate
echo "loaded venv"

# python3 -m pip install --upgrade pip
# python3 -m pip install -r requirements.txt
echo "installed dependencies"

mkdir -p outdata

python3 -O - << EOF
import functools
import multiprocessing as mp
import random

import alifedata_phyloinformatics_convert as apc
from hstrat import hstrat
from hsurf import hsurf
from keyname import keyname as kn
import more_itertools as mit
import pandas as pd
from tqdm import tqdm

from pylib._draw_biopython_tree import draw_biopython_tree
from pylib._val_to_color import val_to_color


def process_group(group_tuple):
    replicate, group = group_tuple

    outname = kn.pack({
        "a": "reconstruction",
        "replicate": replicate,
        "genomeFlavor": mit.one(group["genomeFlavor"].unique()),
        "nCycle": mit.one(group["nCycle"].unique()),
        "popSize": len(group),
        "ext": ".pqt",
    })
    print(f"began {outname}")

    seed = random.Random(replicate).randint(0, 2**32)
    sampled = group.sample(n=min(len(group), 10000), random_state=seed, replace=False)

    with open(f"outdata/{outname}.log.txt", "w") as logfile:
        columns = [hsurf.col_from_surf_int(
            value=value,
            differentia_bit_width=differentia_bitwidth,
            site_selection_algo=site_selection_algo,
            differentiae_byte_bit_order="little",
            num_strata_deposited_byte_width=4,  # u32
            num_strata_deposited_byte_order="little",
            value_byte_width=surface_bytelength,
        ) for value in tqdm(
            sampled["bitfield surface"].values,
            desc="deserializing",
            file=logfile,
        )]

        tree_df = hstrat.build_tree(
            columns,
            hstrat.__version__,
            taxon_labels=sampled["taxon name"].values,
            force_common_ancestry=True,
            progress_wrap=functools.partial(
                tqdm, desc="reconstructing", file=logfile
            ),
        )

    tree_df["popSize"] = len(group)
    tree_df["replicate"] = replicate
    tree_df["globalSeed"] = mit.one(group["globalSeed"].unique())
    tree_df["nCycle"] = mit.one(group["nCycle"].unique())
    tree_df["genomeFlavor"] = mit.one(group["genomeFlavor"].unique())
    tree_df["dataSource"] = source
    tree_df.to_parquet(f"outdata/{outname}")

    print(f"completed {outname}")
    return outname


if __name__ == "__main__":
    source = "https://osf.io/s8p7q/download"
    df = pd.read_parquet(source)
    print("downloaded data")

    exclude_leading = 32

    df["bitfield"] = df["bitfield"].apply(lambda x: int(x, 16))
    df["bitfield value bitlengths"] = df["bitfield"].apply(int.bit_length)
    df["bitfield wordlengths"] = 4
    df["bitfield bitlengths"] = df["bitfield wordlengths"] * 32
    df["surface bitlengths"] = df["bitfield bitlengths"] - exclude_leading
    df["surface bytelengths"] = df["surface bitlengths"] // 8

    bitfield_bitlength = int(mit.one(df["bitfield bitlengths"].unique()))
    surface_mask = (  # mask off leading 32 bit
        1 << (bitfield_bitlength - exclude_leading)
    ) - 1
    assert surface_mask.bit_count() == bitfield_bitlength - exclude_leading
    df["bitfield surface"] = df["bitfield"].values & surface_mask

    df["taxon name"] = df.groupby("replicate").cumcount().astype(str)

    surface_bytelength = int(mit.one(df["surface bytelengths"].unique()))
    print(f"{surface_bytelength=}")
    site_selection_algo = hsurf.tilted_sticky_algo
    differentia_bitwidth = 1

    print("preprocessed data")

    group_list = list(df.groupby("replicate"))
    with mp.Pool(processes=mp.cpu_count()) as pool:
        results = pool.map(process_group, group_list)

    for result in results:
        print(result)

EOF

echo "SECONDS $SECONDS"
echo ">>>fin<<<"
