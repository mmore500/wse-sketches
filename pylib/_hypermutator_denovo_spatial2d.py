import datetime
import os
import sys
import time

import more_itertools as mit
import numpy as np
import numpy as xp

try:
    import cupy

    if cupy.cuda.is_available():
        xp = cupy  # noqa: F811
except Exception:
    pass
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

pben = 0.000001
pdel = 0.0001


def run(
    n_col: int,
    n_row: int,
    n_row_subgrid: int,
    n_col_subgrid: int,
    tile_pop_size: int,
    n_gen: int,
    seed: int,
    tourn_size: int,
    n_ben: int,
):
    rng = xp.random.RandomState(seed)

    pop_size = n_col * n_row * tile_pop_size
    pop_mutator = xp.ones(pop_size, dtype=xp.uint8)
    pop_ben = xp.zeros(pop_size, dtype=xp.int8)
    pop_del = xp.zeros(pop_size, dtype=xp.int8)
    pop_founder = xp.arange(pop_size, dtype=xp.int32)
    pop_founder = (pop_founder % 256).astype(xp.uint8)

    last_seen0 = xp.zeros(n_row * n_col, dtype=xp.uint32)
    last_seen1 = xp.zeros(n_row * n_col, dtype=xp.uint32)

    n_sub_row = n_row // n_row_subgrid
    n_sub_col = n_col // n_col_subgrid
    n_sub = n_sub_row * n_sub_col
    sub_size = n_col_subgrid * n_row_subgrid

    def mutate() -> None:
        pop_mutator[rng.rand(pop_size) < pben] = 100

        pop_ben[:] += rng.poisson(pben * pop_mutator)
        pop_ben[pop_ben > n_ben] = n_ben
        pop_del[:] += rng.poisson(pdel * pop_mutator)

    tc0 = xp.arange(pop_size, dtype=xp.uint32)
    group_min = tc0 - tc0 % (tile_pop_size)
    group_max = group_min + tile_pop_size
    del tc0

    def select() -> None:
        pop_tourns = xp.floor(rng.rand(pop_size) + tourn_size).astype(xp.uint8)
        # assert (xp.clip(pop_tourns, 1, 2) == pop_tourns).all()

        tc1 = rng.randint(group_min, group_max, dtype=xp.uint32)
        tc2 = rng.randint(group_min, group_max, dtype=xp.uint32)
        tc2[pop_tourns == 1] = tc1[pop_tourns == 1]

        fitness = pop_ben - pop_del

        tc_win = xp.where(fitness[tc1] >= fitness[tc2], tc1, tc2)

        pop_ben[:] = pop_ben[tc_win]
        pop_del[:] = pop_del[tc_win]
        pop_mutator[:] = pop_mutator[tc_win]
        pop_founder[:] = pop_founder[tc_win]

    arange = xp.arange(pop_size, dtype=xp.int32)
    tcm = arange.copy()
    migrate_min = tcm - tcm % (tile_pop_size * sub_size)
    migrate_max = migrate_min + tile_pop_size * sub_size

    tcm[arange % tile_pop_size == 0] -= 1
    tcm[arange % tile_pop_size == tile_pop_size - 1] += 1

    if n_col_subgrid > 2 and n_row_subgrid > 2:
        sub_row_num = (arange - migrate_min) // (tile_pop_size * n_col_subgrid)
        sub_col_num = ((arange - migrate_min) // tile_pop_size) % n_col_subgrid

        # FORWARD
        # even rows
        tcm[
            (arange % tile_pop_size == 1)
            & (sub_row_num % 2 == 0)
            & (sub_col_num > 0)
            & (sub_col_num < n_col_subgrid - 1)
        ] += xp.tile(
            xp.arange(n_col_subgrid * 2 - 3, 1, -2),
            ((n_row_subgrid + 1) // 2) * n_sub
        ) * tile_pop_size

        # odd rows
        tcm[
            (arange % tile_pop_size == 1)
            & (sub_row_num % 2 == 1)
            & (sub_col_num > 0)
            & (sub_col_num < n_col_subgrid - 1)
        ] -= xp.tile(
            xp.arange(n_col_subgrid * 2 - 3, 1, -2),
            (n_row_subgrid // 2) * n_sub
        ) * tile_pop_size

        # BACKWARD
        # odd rows
        tcm[
            (arange % tile_pop_size == 2)
            &   (sub_row_num % 2 == 1)
            & (sub_col_num > 0)
            & (sub_col_num < n_col_subgrid - 1)
        ] += xp.tile(
            xp.arange(3, n_col_subgrid * 2 - 2, 2),
            (n_row_subgrid // 2) * n_sub
        ) * tile_pop_size

        # even rows
        tcm[
            (arange % tile_pop_size == 2)
            & (sub_row_num % 2 == 0)
            & (sub_col_num > 0)
            & (sub_col_num < n_col_subgrid - 1)
        ] -= xp.tile(
            xp.arange(3, n_col_subgrid * 2 - 2, 2),
            ((n_row_subgrid + 1) // 2) * n_sub
        ) * tile_pop_size


    tcm[tcm >= migrate_max] = arange[tcm >= migrate_max]
    tcm[tcm < migrate_min] = arange[tcm < migrate_min]

    assert set(
        tcm.get() if not isinstance(tcm, np.ndarray) else tcm
    ) == set(range(pop_size))

    def migrate() -> None:
        pop_ben[:] = pop_ben[tcm]
        pop_del[:] = pop_del[tcm]
        pop_mutator[:] = pop_mutator[tcm]
        pop_founder[:] = pop_founder[tcm]

    def last_seen(generation: int) -> None:
        trait = (pop_mutator != 1).reshape(-1, tile_pop_size).sum(axis=1)
        last_seen0[trait < tile_pop_size] = generation
        last_seen1[trait > 0] = generation

    def reshape(x: np.ndarray) -> np.ndarray:
        if not isinstance(x, np.ndarray):
            x = x.get()

        assert x.size == n_sub * sub_size

        arrs = np.array_split(x.ravel(), n_sub, axis=0)
        assert len(arrs) == n_sub
        arrs = [arr.reshape(n_row_subgrid, n_col_subgrid) for arr in arrs]

        chunks = [[*chunk] for chunk in mit.chunked(arrs, n_sub_col)]
        assert len(chunks) == n_sub_row

        return np.block(chunks)

    start_time = time.perf_counter_ns()
    for generation in tq.tqdm(range(n_gen)):
        mutate()
        select()
        migrate()
        last_seen(generation)

    end_time = time.perf_counter_ns()
    elapsed_ns = end_time - start_time

    genomes = np.zeros((n_row, n_col, 1), dtype=np.int32)
    genomes[:, :, 0] = reshape(pop_founder[::tile_pop_size])
    genomes[:, :, 0] <<= 8
    genomes[:, :, 0] |= reshape(pop_mutator[::tile_pop_size])
    genomes[:, :, 0] <<= 8
    genomes[:, :, 0] |= reshape(pop_del[::tile_pop_size])
    genomes[:, :, 0] <<= 8
    genomes[:, :, 0] |= reshape(pop_ben[::tile_pop_size])

    fitnesses = reshape(pop_ben[::tile_pop_size] - pop_del[::tile_pop_size])

    trait1 = (pop_mutator != 1).reshape(-1, tile_pop_size).sum(axis=1)
    assert (trait1 <= tile_pop_size).all()
    trait0 = tile_pop_size - trait1
    assert (trait0 <= tile_pop_size).all()
    traits_counts = np.stack(
        (
            reshape(trait0),
            reshape(trait1),
        ),
        axis=-1,
    )

    trait_values = np.stack(
        (
            reshape(np.zeros(n_row * n_col)),
            reshape(np.ones(n_row * n_col)),
        ),
        axis=-1,
    )

    last_seen_ = np.stack(
        (
            reshape(last_seen0),
            reshape(last_seen1),
        ),
        axis=-1,
    )

    mgrid = np.mgrid[0:n_row, 0:n_col]
    whereami_x, whereami_y = mgrid

    whoami = np.arange(n_row * n_col).reshape(n_row, n_col)

    return {
        "whereami_x": whereami_x,
        "whereami_y": whereami_y,
        "whoami": whoami,
        "genomes": genomes,
        "fitnesses": fitnesses,
        "trait_counts": traits_counts,
        "trait_values": trait_values,
        "last_seen": last_seen_,
        "elapsed_ns": elapsed_ns,
    }
