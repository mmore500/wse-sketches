const bpds = @import(
    "benchmark_pick_deposition_site.zig",
);

fn trivial_pick_deposition_site(rank: u32, surfaceSize: u32) u32 {
    _ = rank;
    _ = surfaceSize;
    return 0;
}

test "test_benchmark" {
    bpds.benchmark_pick_deposition_site(
        trivial_pick_deposition_site,
        "trivial",
    );
}
