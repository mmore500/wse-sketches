const std = @import("std");

const bpds = @import("benchmark_pick_deposition_site.zig");
// const steady = @import("steady.zig");  not yet implemented
const tilted = @import("tilted.zig");
const tilted_sticky = @import("tilted_sticky.zig");

fn trivial_pick_deposition_site(rank: u32, surfaceSize: u32) u32 {
    _ = rank;
    _ = surfaceSize;
    return 0;
}

/// Run microbenchmarks for deposition site calculation algorithms.
pub fn main() !void {
    std.debug.print("Benchmarks begin.\n", .{});

    // steady algo not yet implemented
    // std.debug.print("Benchmark: steady.\n", .{});
    // bpds.benchmark_pick_deposition_site(
    //     steady.pick_deposition_site,
    //     "steady",
    // );

    std.debug.print("Benchmark: tilted.\n", .{});
    bpds.benchmark_pick_deposition_site(tilted.pick_deposition_site, "tilted");

    std.debug.print("Benchmark: tilted-sticky.\n", .{});
    bpds.benchmark_pick_deposition_site(
        tilted_sticky.pick_deposition_site,
        "tilted-sticky",
    );

    std.debug.print("Benchmark: trivial.\n", .{});
    bpds.benchmark_pick_deposition_site(
        trivial_pick_deposition_site,
        "trivial",
    );

    std.debug.print("Benchmarks complete.\n", .{});
}
