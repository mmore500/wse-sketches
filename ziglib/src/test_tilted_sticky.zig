const std = @import("std");

const reference_pick_deposition_site = @import("tilted.zig").pick_deposition_site;
const pick_deposition_site = @import("tilted_sticky.zig").pick_deposition_site;

test "test_vs_reference_8_254" {
    const surface_size: u32 = 8;
    const num_generations: u32 = 254;

    for (0..num_generations) |rank| {
        const expected = reference_pick_deposition_site(@intCast(rank), surface_size);
        const res = pick_deposition_site(@intCast(rank), surface_size);
        try std.testing.expect((expected == res) == (expected != 0));
    }
}

test "test_vs_reference_16_2_12" {
    const surface_size: u32 = 16;
    const num_generations: u32 = 4096; // 2^12

    for (0..num_generations) |rank| {
        const expected = reference_pick_deposition_site(@intCast(rank), surface_size);
        const res = pick_deposition_site(@intCast(rank), surface_size);
        try std.testing.expect((expected == res) == (expected != 0));
    }
}

test "test_vs_reference_32_2_12" {
    const surface_size: u32 = 32;
    const num_generations: u32 = 4096; // 2^12

    for (0..num_generations) |rank| {
        const expected = reference_pick_deposition_site(@intCast(rank), surface_size);
        const res = pick_deposition_site(@intCast(rank), surface_size);
        try std.testing.expect((expected == res) == (expected != 0));
    }
}

test "test_vs_reference_64_2_12" {
    const surface_size: u32 = 64;
    const num_generations: u32 = 4096; // 2^12

    for (0..num_generations) |rank| {
        const expected = reference_pick_deposition_site(@intCast(rank), surface_size);
        const res = pick_deposition_site(@intCast(rank), surface_size);
        try std.testing.expect((expected == res) == (expected != 0));
    }
}
