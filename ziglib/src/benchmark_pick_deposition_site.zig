const std = @import("std");
const fs = std.fs;
const io = std.io;
const time = std.time;

// implementation detail for benchmark_pick_deposition_site
fn do_benchmark_trial(
    comptime pick_deposition_site: anytype,
    num_ops: u32,
    comptime surface_size: u32,
) i128 {
    var surface = [_]u32{0} ** surface_size;
    std.mem.doNotOptimizeAway(surface);

    const start: i128 = time.nanoTimestamp();
    for (0..num_ops) |step| {
        const deposition_site = pick_deposition_site(
            @intCast(step),
            surface_size,
        );
        surface[deposition_site] += 1;
    }
    const end: i128 = time.nanoTimestamp();
    return end - start;
}

/// This function performs a benchmark for calculation of hsurf deposition site.
///
/// The benchmark runs `num_ops` calculation operations for successive ranks on
/// a surface of size `surface_size`. It writes the benchmark results to a CSV
/// file in `/tmp/` with a filename based on the `policy_name`.
///
/// The benchmark consists of a warmup phase and a main benchmark phase. During
/// the main benchmark phase, it performs `num_replicates` replicates and
/// records the duration of each replicate.
pub fn benchmark_pick_deposition_site(
    comptime pick_deposition_site: anytype,
    comptime policy_name: anytype,
) void {
    const num_ops: u32 = 1000000;
    const surface_size: u32 = 64;

    const file = fs.cwd().createFile(
        "/tmp/a=benchmark-zig-hsurf+policy=" ++ policy_name ++ "+ext=.csv",
        .{},
    ) catch unreachable;
    const writer = file.writer();
    defer file.close();

    // write CSV header
    writer.print(
        "Nanoseconds,Replicate,Num Operations,Surface Size,Policy,Implementation,Language\n",
        .{},
    ) catch unreachable;

    // warmup
    for (0..10) |_| {
        _ = do_benchmark_trial(pick_deposition_site, num_ops, surface_size);
    }

    const num_replicates: u32 = 20;
    for (0..num_replicates) |replicate| {
        const duration: i128 = do_benchmark_trial(
            pick_deposition_site,
            num_ops,
            surface_size,
        );
        writer.print(
            "{},{},{},{},{s},{s},{s}\n",
            .{
                duration,
                replicate,
                num_ops,
                surface_size,
                policy_name,
                "surface",
                "Zig",
            },
        ) catch unreachable;
    }
}
